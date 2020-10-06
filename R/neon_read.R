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
#' @param altrep enable or disable altrep.  Logical, default `FALSE`. Setting to 
#' `TRUE` can speed up reading, but may cause [vroom::vroom] to throw
#' `mapping error: Too many open files`.  
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
                      altrep = FALSE,
                      ...){
  
  if(is.null(files)){
    
    if(is.na(table)) {
      stop(paste("please specify a table name."),
           call. = FALSE)
    }
    
    meta <- neon_index(product = product,
                       table = table, 
                       site = site,
                       start_date = start_date,
                       end_date = end_date,
                       ext = ext,
                       hash = NULL, 
                       dir = dir,
                       deprecated = FALSE)
    
    if(is.null(meta)) return(NULL)
    if(dim(meta)[[1]] == 0 )  return(NULL)
    
    files <- meta$path
  }
  
  if(length(files) == 0){
    if(is.null(table)) table <- "unspecified tables"
    warning(paste("no files found for", table, "in", dir, "\n",
                  "perhaps you need to download them first?"))
    return(NULL)
  }
  
  ## don't attempt to stack things we don't understand
  files <- files[grepl("[.]h5", files) | grepl("[.]csv", files)]
  

  neon_stack(files, 
             keep_filename = FALSE,
             sensor_metadata = sensor_metadata, 
             altrep = altrep, 
             ...)
  
  
}


neon_stack <- function(files, 
                       keep_filename = FALSE,
                       sensor_metadata = TRUE, 
                       altrep = FALSE, 
                       progress = TRUE,
                       vroom_progress = FALSE,
                       ...){
  
  if(any(grepl("[.]h5$", files))){
    stack_eddy(files, progress = progress, ...)
    
  } else if(is_sensor_data(files) && sensor_metadata){
    df <- vroom_each(files, 
                     progress = progress,
                     altrep = altrep, 
                     vroom_progress = vroom_progress,
                     ...)
    add_sensor_columns(df)
    
  } else if(keep_filename) {
    ## Just keeps files names as an additional column in stacked data
    vroom_each(files, 
               progress = progress,
               altrep = altrep,
               vroom_progress = vroom_progress,
               ...)
    
  } else {
    ## Usually much much faster if we can do this one
    vroom_many(files, 
               progress = progress,
               altrep = altrep, 
               vroom_progress = vroom_progress,
               ...)
  }
}


add_sensor_columns <- function(df){
  filename_meta <- neon_filename_parser(df$file)
  df$domainID <- filename_meta$DOM
  df$siteID <- filename_meta$SITE
  df$horizontalPosition <- filename_meta$HOR
  df$verticalPosition <- filename_meta$VER
  df$publicationDate <- as.POSIXct(filename_meta$GENTIME, 
                                   format = "%Y%m%dT%H%M%OS")
  
  df
}




## read each file in separately and then stack them.
## include file name as additional id column
vroom_each <- function(files,
                       progress = TRUE,
                       altrep = FALSE, 
                       vroom_progress = FALSE,
                       ...){
  
  if(progress){
  pb <- progress::progress_bar$new(
    format = paste("  reading files",
                   "[:bar] :percent in :elapsed, eta: :eta"),
    total = length(files), 
    clear = FALSE, 
    width = 80)
  }
  
  suppress_msg({
    groups <-  lapply(files,
                      function(x){
                        if(progress) pb$tick()
                        out <- vroom::vroom(x, guess_max = 5e4,
                                            altrep = altrep,
                                            progress = vroom_progress,
                                            ...)
                        out$file <- basename(x)
                        out
                      })
  })
  suppressWarnings({
    df <- ragged_bind(groups)
    na_bool_to_char(df)
  }) 
}



## vroom can read in a list of files, but only if columns are consistent
## So this attempts vroom over a list of files, but falls back on vroom_ragged
vroom_many <- function(files, 
                       altrep = FALSE, 
                       progress = FALSE,
                       vroom_progress = FALSE,
                       ...){
  suppress_msg({ ## We don't need vroom telling us every table spec!
  df <- tryCatch(vroom::vroom(files, 
                              guess_max = 5e4, 
                              altrep = altrep,
                              progress = vroom_progress,
                              ...),
           error = function(e) vroom_ragged(files, 
                                            guess_max = 5e4,
                                            altrep = altrep,
                                            progress = vroom_progress,
                                            ...),
           finally = NULL)
  })
  na_bool_to_char(df)
}


## Apply vroom over files that share a common schema.
vroom_ragged <- function(files, altrep = FALSE, vroom_progress = FALSE, ...){
  
  ## We read the 1st line of every file to determine schema  
  suppress_msg(
    schema <- lapply(files, 
                     vroom::vroom, 
                     n_max = 1, 
                     altrep = altrep, 
                     progress = FALSE,
                     ...)
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
    tbl <- vroom::vroom(files[index], 
                        altrep = altrep,
                        progress = vroom_progress,
                        col_types = col_types)
    
    ## append any columns missing from all_cols set
    missing <- all_cols[ !(all_cols %in% colnames(tbl)) ]
    tbl[ missing ] <- NA
    tbl_list[[i]] <- tbl
    i <- i+1
    
  }
  do.call(rbind, tbl_list)
  
}

## A base-R version of (recent versions of) dplyr::bind_rows,
## which can handle varying numbers of columns
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


suppress_msg <- function(expr, pattern = c("Rows:")){
  withCallingHandlers(expr,
                      message = function(e){
                        if(any(vapply(pattern, grepl, logical(1), e$message)))
                          invokeRestart("muffleMessage")
                      })
}

