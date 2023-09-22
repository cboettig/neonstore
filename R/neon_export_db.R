
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
  dir <- path.expand(dir)
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
  
  dir <- path.expand(dir)
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
  labels <- parquet_labels(dir)
  file.rename(file.path(dir, names(labels)),
                file.path(dir, paste0(labels, ".parquet"))
  )
  invisible(labels)
}


from_sql_strings <- function(str, part = 2){ 
  table_names <- vapply(strsplit(str, " "), 
                        function(x){
                          bits <- gsub("[\'\"]", "", x)
                          bits[[part]]
                        }, 
                        character(1L))
}

parquet_labels <- function(dir) {
  parquet_files <- list.files(dir, full.names = TRUE)
  parquet_files <- parquet_files[grepl("[.]parquet",parquet_files)]
  ## Ick, table names were mangled in file names, repair them!
  con <- file.path(dir, "load.sql")
  meta <- vroom::vroom_lines(con)
  table_name <- from_sql_strings(meta, 2)
  file_path <-  from_sql_strings(meta, 4)
  names(table_name) <- file_path
  table_name
}


#' sync local parquet export to an S3 database
#' 
#' @param s3 an `[arrow::SubTreeFileSystem]`, such as a remote connection to
#' an S3 bucket from `[arrow::s3_bucket()]`.
#' @inheritParams neon_export_db
#' @details Remote files are named according to the table name (including 
#'     product id, not according to the 'sanitized' file name duckdb uses 
#'     when generating exports.)
#' @export
neon_sync_db <- function(s3, dir = file.path(neon_dir(), "parquet")) {
  
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("arrow must be installed to use  this function")
  }
  
  if(is.character(s3)) {
    s3 <- local_bucket(dir = s3)
  }
  
  table_names <- parquet_labels(dir)
  file_paths <- names(table_names)
  
  status <- lapply(seq_along(table_names), 
               function(i) {
                 df <- arrow::open_dataset(file_paths[[i]])
                 arrow::write_dataset(df, s3$path(table_names[[i]]))
               })
  
  
}

#' standardize export names
#' 
#' @details
#' DUCKDB clobbers database filenames to avoid potentially incompatible characters.
#' This is pretty unnecessary, so we can restore the original table names for
#' use with S3-based remote access which assumes parquet files map to the 
#' desired table names (i.e. including product numbers.)
#' 
#' However, note that `[neon_import_db()]` uses native duckdb functions 
#' that assume the original mangled names.
#' 
#' @inheritParams neon_export_db
#' @export
standardize_export_names <- function(dir = file.path(neon_dir(), 
                                                     "parquet")
                                     ) {
  table_names <- parquet_labels(dir)
  file_paths <- names(table_names)
  new_names <- file.path(dir, table_names, "part-0.parquet")
  lapply(dirname(new_names), dir.create)
  
  ## these get in the way.
  unlink(file.path(dir, "schema.sql"))
  unlink(file.path(dir, "load.sql"))
  
  status <- lapply(seq_along(table_names), 
                   function(i) {
                     file.rename(file_paths[[i]],
                                 new_names[[i]])
                   })

}


local_bucket <- function(dir =  file.path(neon_dir(), "parquet")) {
  arrow::SubTreeFileSystem$create(base_path = dir, 
                                  arrow::LocalFileSystem$create())
}
