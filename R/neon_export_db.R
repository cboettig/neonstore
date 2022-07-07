
#' Export NEON database to parquet
#' 
#' Export your current database. This can be important to (1)
#' archive and share your database files with another user or machine, 
#' (2) expose your database using an S3 bucket using neon_remote_db(),
#' (3) assist in upgrading your duckdb version.
#' @param dir directory to which parquet export is written.
#' @param db Connection to your local NEON database
#' @export
neon_export_db <- function(dir = file.path(neon_dir(), "parquet"),
                           db = neon_db()
                           ) {
  query <- paste0("EXPORT DATABASE '", dir, "' (FORMAT PARQUET);")
  DBI::dbExecute(db, query)
}

#' Import a NEON database exported from neon_export_db()
#' 
#' @inheritParams neon_export_db
#' @export
#' 
neon_import_db <- function(dir = file.path(neon_dir(), "parquet"),
                           db = neon_db(read_only = FALSE)
                           ) {
  
  ## FIXME detect if `schema.sql` & `load.sql` do not exist, and 
  ## create views of each table based on table name
  
  queries <- readLines(file.path(dir, "schema.sql"))
  queries <- queries[queries != ""]
  
  # FIXME Currently duckdb exports all DATEs as TIMESTAMPs
  queries <- gsub("DATE", "TIMESTAMP", queries)
  lapply(queries, function(q) DBI::dbExecute(db, q))
  
  queries <- readLines(file.path(dir, "load.sql"))
  lapply(queries, function(q) DBI::dbExecute(db, q))
  DBI::dbDisconnect(db, shutdown=TRUE)
  
}


rename_tables <- function(dir) {
  
  parquet_files <- list.files(dir, full.names = TRUE)
  parquet_files <- parquet_files[grepl("[.]parquet",parquet_files)]
  ## Ick, table names were mangled in file names, repair them!
  con <- file.path(dir, "load.sql")
  meta <- vroom::vroom_lines(con)
  pattern <- '^COPY "?(.*)"? FROM \'.*\\w*/(\\d+\\w*\\.parquet).*'
  table_name <- gsub('\\"', '', unname(gsub(pattern, "\\1", meta )))
  file_name <- unname(gsub(pattern, "\\2", meta ))
  names(table_name) <- file_name
  
  labels <- table_name[file_name]
  file.rename(file.path(dir, names(labels)),
                file.path(dir, paste0(labels, ".parquet"))
  )
  invisible(labels)
}


#' sync local parquet export to an S3 database
#' 
#' @param to an `[arrow::SubTreeFileSystem]`, such as a remote connection to
#' an S3 bucket from `[arrow::s3_bucket()]`.
#' @param from another `[arrow::SubTreeFileSystem]`, such as local path. 
#'  By default, this is the same default path used by `[neon_import_db()]`
#'  and `[neon_export_db()]`
#' @details character strings will be interpreted as local paths for either
#'  argument.
#' @export
neon_sync_db <- function(to, from = file.path(neon_dir(), "parquet")) {
  
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("arrow must be installed to use  this function")
  }
  
  if(is.character(to)) {
    to <- local_bucket(dir = to)
  }
  
  if(is.character(from)) {
    from <- local_bucket(dir = from)
  }

  parquet_files <- from$ls()
  parquet_files <- parquet_files[grepl("[.]parquet",parquet_files)]
  
  status <- lapply(parquet_files, 
               function(fi) {
                 f <- file.path(from$base_path,fi)
                 df <- arrow::open_dataset(f)
                 arrow::write_dataset(df, to$path(fi))
                 TRUE
               })
  
  
}

local_bucket <- function(dir =  file.path(neon_dir(), "parquet")) {
  arrow::SubTreeFileSystem$create(base_path = dir, 
                                  arrow::LocalFileSystem$create())
}
