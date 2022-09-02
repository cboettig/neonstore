#' Establish a remote database connection using `arrow`
#' 
#' @param bucket an `[arrow::s3_bucket]` connection or other 
#' [arrow::SubTreeFileSystem] object.
#' 
#' @export
#' @examplesIf interactive()
#' 
#' db <- neon_remote_db()
neon_remote_db <- function(bucket = arrow::s3_bucket("neon4cast-targets/neon",
                                          endpoint_override = "data.ecoforecast.org")
                           ) {
    
  if(!requireNamespace("arrow", quietly = TRUE))
    stop("arrow must be installed to use neon_remote()")

  if(is.character(bucket)) {
    bucket <- local_bucket(dir = bucket)
  }
  
  parquet_files <- bucket$ls()
  parquet_files <- parquet_files[!grepl("[.]sql", parquet_files)]

  db <- lapply(parquet_files, 
      function(parquet_file) {
        fi <- bucket$path(parquet_file)
        arrow::open_dataset(fi)
      })
  names(db) <- parquet_files
  db
}


#' neon_remote 
#'  
#' select a table from the remote connection
#' @param table table name (pattern match regex)
#' @param product product code
#' @param type basic or extended (if necessary to distinguish)
#' @param db a [neon_remote_db] connection.  If not provided, one will be created,
#' but it is faster to pass this on for re-use in multiple `neon_remote` calls.
#' @export
#' @return a arrow::FileSystemDataset object, or a named list of such
#' objects if multiple matches are found.  This table is not downloaded
#' but remains on the remote storage location, but can be filtered
#' with dplyr functions like filter and select, and can also be
#' grouped and summarised, all without ever downloading the whole table.
#' Use [dplyr::collect()] to download the (possibly filtered) table into
#' and pull into memory.  
neon_remote <- function(table = "", product = "", type = "", db = neon_remote_db()){
  labels <- names(db)
  i <- grepl(table, labels) & grepl(product, labels)  & grepl(type, labels)
  if(sum(i) > 1){
    message(paste0("multiple matches found\n", 
                  "returning list with tables:\n",
                  paste(labels[i], collapse = "\n")))
    return(invisible(db[i]))
  }
  db[[which(i)]]
}



