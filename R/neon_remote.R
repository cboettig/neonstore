#' Establish a remote database connection using `arrow`
#' 
#' 
#' Provides a remote connection 
#' @param host An S3-compliant host address
#' @param bucket bucket name
#' @param path path (prefix) on bucket to parquet files
#' 
#' @export
#' @examplesIf interactive()
#' 
#' db <- neon_remote_db()
#' 
neon_remote_db <- function(host = "minio.thelio.carlboettiger.info",
                          bucket = "shared-data",
                          path = "neonstoredb") {
    
  if(!requireNamespace("arrow", quietly = TRUE))
    stop("arrow must be installed to use neon_remote()")

  s3 <- arrow::s3_bucket(bucket, endpoint_override = host)
  dir <- s3$path(path)


  
  parquet_files <- dir$ls()
  parquet_files <- parquet_files[grepl("[.]parquet",parquet_files)]
  
  db <- lapply(seq_along(parquet_files), 
      function(i) {
        parquet_file <- dir$ls()[i]
        fi <- s3$path(file.path(path, parquet_file))
        arrow::open_dataset(fi)
      })
  
  
  ## Ick, table names were mangled in file names, repair them!
  files <- s3$path(path)
  con <- files$OpenInputFile("load.sql")
  meta <- vroom::vroom_lines(con$Read()$data())
  pattern <- '^COPY "(.*)" FROM \'\\w*/(\\d+\\w*\\.parquet).*'
  table_name <- gsub(pattern, "\\1", meta )
  file_name <- gsub(pattern, "\\2", meta )
  names(table_name) <- file_name
  labels <- gsub("-", "_",  table_name[parquet_files])
  
  ## wow, that's done, now we can label files by table
  names(db) <- labels
  db
}

#' neon_remote 
#'  
#' select a table from the remote connection
#' @param tbl table name (pattern match regex)
#' @param product product code
#' @param type basic or extended (if necessary to distinguish)
#' @export
#' @return a arrow::FileSystemDataset object, or a named list of such
#' objects if multiple matches are found.  This table is not downloaded
#' but remains on the remote storage location, but can be filtered
#' with dplyr functions like filter and select, and can also be
#' grouped and summarised, all without ever downloading the whole table.
#' Use [dplyr::collect()] to download the (possibly filtered) table into
#' and pull into memory.  
neon_remote <- function(tbl = "", product = "", type = "", db = neon_remote_db()){
  labels <- names(db)
  i <- grepl(tbl, labels) & grepl(product, labels)  & grepl(type, labels)
  if(sum(i) > 1){
    message(paste0("multiple matches found\n", 
                  "returning list with tables:\n",
                  paste(labels[i], collapse = "\n")))
    return(invisible(db[i]))
  }
    
  db[[which(i)]]
}
