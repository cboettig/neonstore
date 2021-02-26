
#' show deprecated data
#' 
#' Show the file information for any raw data files which have been deprecated by 
#' the release of modified historical data to the NEON API.  
#' 
#' NEON data files are sometimes updated to correct errors.  Old files are 
#' removed from access from the API, but may be present in your local store
#' from an earlier download.  `neonstore` stacking functions (`[neon_read()]`
#' and `neon_store()`) automatically exclude these deprecated files, though
#' `neon_read()` can be instructed to use older files by passing a file list.
#' 
#' A data file is identified as deprecated whenever the local file store contains
#' a second data file with the same product, table, site, month, and position 
#' (sensor products only) information, but having an updated timestamp.  If such
#' a change occurs in a file with a non-missing "month" code, it may indicate a
#' data file has been updated.  This could result in changes to the results of 
#' any previous analyses.  
#' 
#' Note that metadata files, (readme, variables, positions) are 'pre-stacked':
#' the metadata file in a given product-site-month set contains metadata going back
#' to the start and not just for that month.  As a result, each new version deprecates
#' the old metadata file, but the old files are always available from the NEON API
#' and always present in the store.  Users will only need to care about the most recent
#' ones, and the presence of old files is no cause for concern. This function will
#' only show data files that have changed, and not metadata files.  This can
#' help pinpoint specific altered data.
#' @inheritParams neon_index
#' @seealso neon_index, neon_read
#' @examples 
#' \dontshow{
#' # Hide setting tempfile, since a user would specify a persistent location
#'  Sys.setenv("NEONSTORE_HOME"=tempfile())
#' }
#' show_deprecated_data()
#' 
#' 
#' \dontshow{
#' # tidy
#'  Sys.unsetenv("NEONSTORE_HOME")
#' }
#' 
#' @export
show_deprecated_data <- function(product = NA, 
                                 table = NA, 
                                 site = NA,
                                 start_date = NA,
                                 end_date = NA,
                                 type = NA,
                                 ext = NA,
                                 timestamp = NA,
                                 release = NA,
                                 dir = neon_dir()){
  
  meta <- neon_index(product = product,
                     table = table, 
                     site = site, 
                     start_date = start_date,
                     end_date = end_date,
                     type = type,
                     ext = ext,
                     timestamp = timestamp,
                     release = release,
                     dir = dir)
  if(is.null(meta)) return(NULL)
  if(nrow(meta) == 0) return(NULL)
  meta <- flag_deprecated(meta)
  changed_data <- meta$deprecated & !is.na(meta$month)
  meta[changed_data,]
  
}

