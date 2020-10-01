




#' Cache-able duckdb database connection
#' 
#' @details Creates a connection to a permanent duckdb database
#' instance in the provided directory (see [neon_dir()]).  This 
#' connection is also cached, so that code which repeatedly calls 
#' `[neon_db]` will not stall or hang.  
#' @export
#' @inheritParams neon_download
#' @param ... additional arguments to dbConnect
#' @importFrom DBI dbConnect
#' @importFrom duckdb duckdb
neon_db <- function (dir = neon_dir(), ...) {
  dir.create(dir, FALSE, TRUE)
  dbname <- file.path(dir, "database")
  db <- mget("neon_db", envir = neonstore_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    if (DBI::dbIsValid(db)) {
      return(db)
    }
  }
  db <- DBI::dbConnect(duckdb::duckdb(), dbdir = dbname, ...)

  assign("neon_db", db, envir = neonstore_cache)
  db
}


#' Disconnect from the neon database
#' 
#' @export
#' @importFrom DBI dbDisconnect
neon_disconnect <- function () {
  
  db <- neon_db()
  if (inherits(db, "DBIConnection")) {
    suppressWarnings(DBI::dbDisconnect(db, shutdown = TRUE))
  }
  if (exists("neon_db", envir = neonstore_cache)) {
    rm("neon_db", envir = neonstore_cache)
  }
}

neonstore_cache <- new.env()




