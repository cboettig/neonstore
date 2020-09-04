#' read in neon tabular data
#' 
#' @details
#' NEON's tabular data files are separated out into separate .csv
#' files for each site for each month of sampling.  In principle,
#' each file has identical columns.  [vroom::vroom] can read in a
#' data table that has been sharded into many files like this much
#' much faster than other parsers can read in each table iteratively, 
#' (and thus can greatly out-perform the 'stacking" methods in `neonUtilities`).
#' 
#' When reading in very large numbers of files, it may be helpful to set
#' `altrep = FALSE` to opt out of `vroom`'s fast altrep mechanism, which
#' can cause [neon_read()] to fail when stacking thousands of files.
#'
#' Unfortunately, not all datasets are entirely consistent in their use
#' of columns.  `neon_read` works around this by parsing such tables in
#' groups of matching schema, which is still reasonably fast.
#' 
#' NEON sensor data products currently do not include important metadata columns
#' containing DomainID, SiteID, horizontalPosition, verticalPosition, and
#' publicationDate in the data files themselves, but only encode this in the 
#' in the raw file names. All though these values are shared across a raw 
#' data file, this information is lost when stacking the tables unless explicit
#' columns are added to the data.  This requires us to parse the files
#' one-by-one, which is much slower.  By default this information is added to
#' the table, altering the stacked table schema from that of the raw table.  
#' Disable this behavior by setting `sensor_metadata = FALSE`.  Future
#' NEON sensor data products may start including this information in 
#' the raw data files, as is already the case for observational data.
#' 
#' 
#' @param table the name of a downloaded NEON table in the store,
#'  see [neon_index]
#' @param sensor_metadata logical, default TRUE. Should we add 
#' metadata fields from file names of sensor data into the table?  Adds
#' DomainID, SiteID, horizontalPosition, verticalPosition, and publicationDate.
#' Results in slower parsing.  
#' @param ... additional arguments to [vroom::vroom], can usually be omitted.
#' @param files optionally, specify a vector of file paths directly (e.g. as
#' provided from [neon_index]) and specify `table` argument as NULL.
#' @inheritParams neon_index
#' @importFrom vroom vroom spec
#' @export
#' 
#' @examples 
#' 
#' neon_read("brd_countdata-expanded")
#' 
#' ## Read in specific files from the neon_index():
#' files <- neon_index(table = "brd_countdata-expanded")$path
#' neon_read(files = files)
#' 
#' ## Sensor inputs will add metadata columns by default
#' neon_read("waq_instantaneous", site = c("CRAM","SUGG"))
#'
#' 
neon_read <- function(table = NA,
                      product = NA, 
                      site = NA,
                      start_date = NA,
                      end_date = NA,
                      ext = NA,
                      timestamp = NA,
                      dir = neon_dir(),
                      files = NULL,
                      sensor_metadata = TRUE,
                      ...){
  
  if(is.null(files)){
    meta <- neon_index(product = product,
                       table = table, 
                       site = site,
                       start_date = start_date,
                       end_date = end_date,
                       ext = ext,
                       hash = NULL, 
                       dir = dir)
    
    if(is.null(meta)) return(NULL)
    if(dim(meta)[[1]] == 0 )  return(NULL)
    
    ## If timestamp has changed but other metadata is the same, we only want the newer version
    meta <- filter_duplicates(meta)
    files <- meta$path
  }
  
  if(length(files) == 0){
    if(is.null(table)) table <- "unspecified tables"
    warning(paste("no files found for", table, "in", dir, "\n",
                  "perhaps you need to download them first?"))
    return(NULL)
  }

  ## Handle the case of needing to add columns extracted from filenames
  if(is_sensor_data(files) && sensor_metadata){
    neon_read_sensor(meta, ...)
  ## Otherwise we can just read in:  
  } else {
    read_csvs(files, ...)
  }
  
}


neon_read_sensor <- function(meta, ..., .id = "path") {
    suppressMessages({
      id <- unique(meta[[.id]])
      groups <- 
        lapply(id,
               function(x){
                 paths <- meta$path[meta[[.id]] == x]
                 out <- read_csvs(paths, ...)
                 out[.id] <- x
                 out
               })
    })
    suppressWarnings({
      df <- ragged_bind(groups)
    })
  
  filename_meta <- neon_filename_parser(df$path)
  df$domainID <- filename_meta$DOM
  df$siteID <- filename_meta$SITE
  df$horizontalPosition <- filename_meta$HOR
  df$verticalPosition <- filename_meta$VER
  df$publicationDate <- as.POSIXct(filename_meta$GENTIME, format = "%Y%m%dT%H%M%OS")
  
  df
}

read_csvs <- function(files, ...){
  ## vroom can read in a list of files, but only if columns are consistent
  tryCatch(vroom::vroom(files, ...),
           error = function(e) vroom_ragged(files, ...),
           finally = NULL)  
}


#' @importFrom vroom vroom spec
vroom_ragged <- function(files){
  
  ## We read the 1st line of every file to determine schema  
  suppressMessages(
    schema <- lapply(files, vroom::vroom, n_max = 1, altrep = FALSE)
  )
  
  
  ## Now, we read in tables in groups of matching schema,
  ## filling in additional columns as in bind_rows.
  
  col_schemas <- lapply(schema, colnames)
  u_schemas <- unique(col_schemas)
  tbl_list <- vector("list", length=length(u_schemas))
  
  all_cols <- unique(unlist(u_schemas))
  
  i <- 1
  for(s in u_schemas){
    
    ## select tables that have matching schemas
    index <- vapply(col_schemas, identical, logical(1L), s)
    col_types <- vroom::spec(schema[index][[1]])
    
    ## Read in all those tables
    tbl <- vroom::vroom(files[index], col_types = col_types)
    
    ## append any columns missing from all_cols set
    missing <- all_cols[ !(all_cols %in% colnames(tbl)) ]
    tbl[ missing ] <- NA
    tbl_list[[i]] <- tbl
    i <- i+1
    
  }
  do.call(rbind, tbl_list)
  
}

## simpler case
ragged_bind <- function(x){
  
  col_schemas <- lapply(x, colnames)
  u_schemas <- unique(col_schemas)
  all_cols <- unique(unlist(u_schemas))
  for(i in seq_along(x)){
    ## append any columns missing from all_cols set
    missing <- all_cols[ !(all_cols %in% colnames(x[[i]])) ]
    x[[i]][ missing ] <- NA
  }
  do.call(rbind, x)
  
}

## Sometimes a NEON file will have changed
filter_duplicates <- function(meta){
  meta$timestamp <- as.POSIXct(meta$timestamp, format = "%Y%m%dT%H%M%OS")
  meta_b <- meta[order(meta$timestamp, decreasing = TRUE),] 
  meta_b$id <- paste(meta$product, meta$site, meta$table, meta$month, sep="-")
  out <- take_first_match(meta_b, "id")
  
  if(dim(out)[[1]] < dim(meta)[[1]])
    message("Some raw files were detected with updated timestamps.\n
            Using only most updated file to avoid duplicates.")
  ## FIXME Maybe we should verify if the hash of said file(s) has changed.
  ## maybe we should provide more information on how to check these?
  
  out
}




