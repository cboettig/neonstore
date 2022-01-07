
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
  queries <- readLines(file.path(dir, "schema.sql"))
  queries <- queries[queries != ""]
  
  # FIXME Currently duckdb exports all DATEs as TIMESTAMPs
  queries <- gsub("DATE", "TIMESTAMP", queries)
  lapply(queries, function(q) DBI::dbExecute(db, q))
  
  queries <- readLines(file.path(dir, "load.sql"))
  lapply(queries, function(q) DBI::dbExecute(db, q))
  DBI::dbDisconnect(db, shutdown=TRUE)
  
}
