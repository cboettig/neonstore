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
#' Unfortunately, not all datasets are entirely consistent in their use
#' of columns.  `neon_read` works around this by parsing such tables in
#' groups of matching schema, which is still reasonably fast.
#' 
#' For convenience, `neon_read` takes the name of a table in the local store.
#' 
#' @param table the name of a downloaded NEON table in the store,
#'  see [neon_store]
#' @param .id add an additional id column with metadata from filename.
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
neon_read <- function(table = NA,
                      product = NA, 
                      site = NA,
                      start_date = NA,
                      end_date = NA,
                      ext = NA,
                      dir = neon_dir(),
                      files = NULL,
                      .id = NA,
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
  
  ## Handle the case of needing to add an id column 
  if(!is.na(.id)){
    id <- unique(meta[[.id]])
    groups <- 
      lapply(id,
             function(x){
              paths <- meta$path[meta[[.id]] == x]
              out <- read_csvs(paths, ...)
              out[.id] <- x
              out
    })
    ragged_bind(groups)
  ## Otherwise we can just read in:  
  } else {
    read_csvs(files, ...)
  }
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




