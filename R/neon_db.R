
#' Cache-able duckdb database connection
#' 
#' @details Creates a connection to a permanent duckdb database
#' instance in the provided directory (see [neon_dir()]).  This 
#' connection is also cached, so that code which repeatedly calls 
#' `[neon_db]` will not stall or hang.  Only `read_only` connections
#' will be cached.
#' 
#' NOTE: `[duckdb::duckdb()]` can only support a single read-write connection
#' at a time.  The default option of `read_only = TRUE` allows
#' multiple connections. `[neon_store()]` will automatically set this to
#' `FALSE` to allow data import.
#' 
#' @export
#' @inheritParams neon_download
#' @param read_only allow concurrent connections by enforcing read_only.
#'   See details. 
#' @param ... additional arguments to dbConnect
#' @importFrom DBI dbConnect
#' @importFrom duckdb duckdb
#' @examples 
#' 
#' # tempfile used for illustration only
#' neon_db(tempfile())
#' 
neon_db <- function (dir = neon_db_dir(), read_only = TRUE,  ...) {

  if (!dir.exists(dir)){
    dir.create(dir, FALSE, TRUE)
  }
  dbname <- file.path(dir, "database")

  ## Cannot open read-only on a database that does not exist
  if (!file.exists(dbname) && read_only) {
    db <- DBI::dbConnect(duckdb::duckdb(), 
                         dbdir = dbname, read_only = FALSE)
    dbWriteTable(db, "init", data.frame(NEON="NEON"))
    dbDisconnect(db, shutdown=TRUE)
  }

  db <- mget("neon_db", envir = neonstore_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    if (DBI::dbIsValid(db)) {
      if (read_only) {
        return(db)
      } else {
        ## shut down the cached (read_only) connection first 
        ## so we can make a new connection with write privileges
        dbDisconnect(db, shutdown = TRUE)
      }
    }
  }

  db <- DBI::dbConnect(duckdb::duckdb(), 
                       dbdir = dbname,
                       read_only = read_only,
                       ...)

  if (read_only) {
    assign("neon_db", db, envir = neonstore_cache)
  }
  
  db
}


#' Disconnect from the neon database
#' @param db link to an existing database connection
#' @export
#' @importFrom DBI dbDisconnect
neon_disconnect <- function (db = neon_db()) {
  
  dir <- dirname(db@driver@dbdir)
  if (inherits(db, "DBIConnection")) {
      DBI::dbDisconnect(db, shutdown = TRUE)
  }
  if (exists("neon_db", envir = neonstore_cache)) {
    suppressWarnings(
    rm("neon_db", envir = neonstore_cache)
    )
  }
}

neonstore_cache <- new.env()

#' delete the local NEON database
#' 
#' @param db neon database connection from `[neon_db()]`
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
#' db <- neon_db(dir)
#' 
#' # Delete it
#' neon_delete_db(db, ask = FALSE)
#' 
#' 
neon_delete_db <- function(db = neon_db(), ask = interactive()){
  continue <- TRUE
  if(ask){
    continue <- utils::askYesNo(paste("Delete the local duckdb database?", 
             "(downloaded files will be kept)"))
  }
  if(continue){
    dir <- dirname(db@driver@dbdir)
    DBI::dbDisconnect(db, shutdown = TRUE)
    db_files <- list.files(dir, "^database.*", full.names = TRUE)
    lapply(db_files, unlink, TRUE)
  }
  if (exists("neon_db", envir = neonstore_cache)) {
    suppressWarnings(
      rm("neon_db", envir = neonstore_cache)
    )
  }
  return(invisible(continue))
}

