
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
#' @param memory_limit Set a memory limit for duckdb, in GB.  This can
#' also be set for the session by using options, e.g. 
#' `options(duckdb_memory_limit=10)` for a limit of 10GB.  On most systems 
#' duckdb will automatically set a limit to 80% of machine capacity if not 
#' set explicitly.  
#' @importFrom DBI dbConnect
#' @importFrom duckdb duckdb
#' @examples 
#' 
#' # tempfile used for illustration only
#' neon_db(tempfile())
#' 
neon_db <- function (dir = neon_db_dir(), 
                     read_only = TRUE, 
                     memory_limit = getOption("duckdb_memory_limit", NA), 
                     ...) {

  if (!dir.exists(dir)){
    dir.create(dir, FALSE, TRUE)
  }
  dbname <- file.path(dir, "database")

  ## Cannot open read-only on a database that does not exist
  if (!file.exists(dbname) && read_only) {
    message("initializing database")
    db <- DBI::dbConnect(duckdb::duckdb(), 
                         dbdir = dbname, read_only = FALSE)
    DBI::dbWriteTable(db, "init", data.frame(NEON="NEON"))
    DBI::dbDisconnect(db, shutdown=TRUE)
  }

  db <- mget("neon_db", envir = neonstore_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    if (DBI::dbIsValid(db)) {
      dir_matches <- db@driver@dbdir == dbname
      if (read_only & dir_matches) {
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
  if(!is.na(memory_limit)){
    duckdb_mem_limit(db, memory_limit, "GB")
  }

  if (read_only) {
    assign("neon_db", db, envir = neonstore_cache)
  }
  
  #e <- globalenv()
  #reg.finalizer(e, function(e) neon_disconnect(db),TRUE)
  
  db
}


#' Disconnect from the neon database
#' @param db link to an existing database connection
#' @export
#' @importFrom DBI dbDisconnect
neon_disconnect <- function (db = neon_db()) {
  default = getOption("warn")
  options(warn=-1)
  
  if(DBI::dbIsValid(db)) {
    DBI::dbDisconnect(db, shutdown = TRUE)
  }

  if (exists("neon_db", envir = neonstore_cache)) {
    suppressWarnings(
    rm("neon_db", envir = neonstore_cache)
    )
  }
  
  gc(FALSE)
  options(warn=default)
  invisible(TRUE)
}


silent_gc <- function() {
  default = getOption("warn")
  options(warn=-1)
  gc(FALSE)
  options(warn=default)
  invisible(TRUE)
}

neonstore_cache <- new.env()

#' delete the local NEON database
#' 
#' @param db_dir neon database location (configurable with the NEONSTORE_DB
#'  environmental variable)
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
#' neon_delete_db(dir, ask = FALSE)
#' 
#' 
neon_delete_db <- function(db_dir = neon_db_dir(), ask = interactive()){
  continue <- TRUE
  if(ask){
    continue <- utils::askYesNo(paste("Delete local DB in", db_dir, "?"))
  }
  if(continue){
    db_files <- list.files(db_dir, "^database.*", full.names = TRUE)
    lapply(db_files, unlink, TRUE)
  }
  if (exists("neon_db", envir = neonstore_cache)) {
    suppressWarnings(
      rm("neon_db", envir = neonstore_cache)
    )
  }
  return(invisible(continue))
}


duckdb_mem_limit <- function(db = neon_db(), mem_limit = 16, units = "GB"){
  DBI::dbExecute(db, paste0("PRAGMA memory_limit='", mem_limit, " ", units,"'"))
}
duckdb_parallel <- function(duckdb_cores = getOption("mc.cores", 2L)){
  DBI::dbExecute(neon_db(), paste0("PRAGMA threads=", duckdb_cores))
}

