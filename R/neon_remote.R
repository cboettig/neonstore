

neon_remote_db <- function(host = "minio.thelio.carlboettiger.info",
                          bucket = "shared-data",
                          path = "neonstoredb") {
    
  if(!requireNamespace("arrow", quietly = TRUE))
    stop("arrow must be installed to use neon_remote()")

  s3 <- arrow::s3_bucket(bucket, endpoint_override = host)
  dir <- s3$path(path)

  ## Ick, file names were mangled  
  files <- s3$path(path)
  con <- files$OpenInputFile("load.sql")
  meta <- readr::read_lines(con$Read()$data())
  
  table_name <- gsub('^COPY "(.*)" FROM \'\\w*/(\\d+\\w*\\.parquet).*', "\\1", meta )
  file_name <- gsub('^COPY "(.*)" FROM \'\\w*/(\\d+\\w*\\.parquet).*', "\\2", meta )
  names(table_name) <- file_name
  parquet_files <- dir$ls()
  parquet_files <- parquet_files[grepl("[.]parquet",parquet_files)]
  
  db <- lapply(seq_along(parquet_files), 
      function(i) {
        parquet_file <- dir$ls()[i]
        fi <- s3$path(file.path(path, parquet_file))
        arrow::open_dataset(fi)
      })
  
  labels <- gsub("-", "_",  table_name[parquet_files])
  names(db) <- labels
  db
}

neon_remote <- function(tbl = "", product = "", type = "", db = neon_remote_db()){
  labels <- names(db)
  i <- grepl(tbl, labels) & grepl(product, labels)  & grepl(type, labels)
  db[i]
}
