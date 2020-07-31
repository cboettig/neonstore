#' Default directory for persistent NEON file store
#' 
#' Use `neon_dir()` to view or access the currently active local store.
#' By default, [neon_download()] downloads files into the `neon_dir()`,
#' which uses an appropriate application directory for your operating system,
#' see [rappdirs::user_data_dir()].  This location can be overridden by setting
#' the environmental variable `NEONSTORE_HOME`.  `neonstore` functions 
#' (e.g. [neon_index()], [neon_store()], and [neon_read()]) look for files in
#' the `neon_store()` directory by default.  (All functions can also take
#' a one-off argument to `dir` in the function call in place of the calling
#' `neon_dir()` to access the default.  
#'
#' @return the active `neonstore` directory.
#' @export
#' @examples 
#' 
#' neon_dir()
#' 
#' ## Override with an environmental variable:
#' Sys.setenv(NEONSTORE_HOME = tempdir())
#' neon_dir()
#' ## Unset
#' Sys.unsetenv("NEONSTORE_HOME")
#' 
neon_dir <- function(){
  Sys.getenv("NEONSTORE_HOME", 
             rappdirs::user_data_dir("neonstore"))
}
