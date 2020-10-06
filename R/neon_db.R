
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
#' @examples 
#' 
#' # tempfile used for illustration only
#' neon_db(tempfile())
#' 
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
#' @inheritParams neon_db
#' @export
#' @importFrom DBI dbDisconnect
neon_disconnect <- function (dir = neon_dir()) {
  
  db <- neon_db(dir)
  if (inherits(db, "DBIConnection")) {
    suppressWarnings(DBI::dbDisconnect(db, shutdown = TRUE))
  }
  if (exists("neon_db", envir = neonstore_cache)) {
    rm("neon_db", envir = neonstore_cache)
  }
}

neonstore_cache <- new.env()

#' delete the local NEON database
#' 
#' @inheritParams neon_db
#' @param ask Ask for confirmation first?
#' @details Just a helper function that deletes the NEON database
#' files, which are found under `file.path(neon_dir(), "database")`.
#' This does not delete downloaded raw data, which can easily be 
#' re-loaded with `neon_store()`.  Usually unnecessary but can be
#' helpful in resetting a corrupt database.  
#' 
#' If you want to delete all raw data files downloaded by neonstore
#' as well, simply delete the entire directory given by [neon_dir()]
#' @importFrom utils askYesNo
#' @export
#' @examples 
#' 
#' # Create a db
#' dir <- tempfile()
#' neon_db(dir)
#' 
#' # Delete it
#' neon_delete_db(dir, ask = FALSE)
#' 
#' 
neon_delete_db <- function(dir = neon_dir(), ask = interactive()){
  continue <- TRUE
  if(ask){
    continue <- utils::askYesNo(paste("Delete the local duckdb database?", 
             "(downloaded files will be kept)"))
  }
  if(continue){
    neon_disconnect(dir)
    unlink(file.path(dir, "database"), TRUE)
  }
  return(invisible(continue))
}

