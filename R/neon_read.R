#' read in neon tabular data
#' 
#' @details
#' NEON's tabular data files are separated out into separate .csv
#' files for each site for each month of sampling.  In principle,
#' each file has identical columns.  [vroom::vroom] can read in a
#' data table that has been sharded into many files like this much
#' much faster than other parsers can read in each table iteratively, 
#' (and thus can greatly out-perform the 'stacking" methods in `neonUtilities`).
#' 
#' When reading in very large numbers of files, it may be helpful to set
#' `altrep = FALSE` to opt out of `vroom`'s fast altrep mechanism, which
#' can cause [neon_read()] to fail when stacking thousands of files.
#'
#' Unfortunately, not all datasets are entirely consistent in their use
#' of columns.  `neon_read` works around this by parsing such tables in
#' groups of matching schema, which is still reasonably fast.
#' 
#' NEON sensor data products currently do not include important metadata columns
#' containing DomainID, SiteID, horizontalPosition, verticalPosition, and
#' publicationDate in the data files themselves, but only encode this in the 
#' in the raw file names. All though these values are shared across a raw 
#' data file, this information is lost when stacking the tables unless explicit
#' columns are added to the data.  This requires us to parse the files
#' one-by-one, which is much slower.  By default this information is added to
#' the table, altering the stacked table schema from that of the raw table.  
#' Disable this behavior by setting `sensor_metadata = FALSE`.  Future
#' NEON sensor data products may start including this information in 
#' the raw data files, as is already the case for observational data.
#' 
#' 
#' @param table the name of a downloaded NEON table in the store,
#'  see [neon_index]
#' @param sensor_metadata logical, default TRUE. Should we add 
#' metadata fields from file names of sensor data into the table?  Adds
#' DomainID, SiteID, horizontalPosition, verticalPosition, and publicationDate.
#' Results in slower parsing.  
#' @param keep_filename Should we include a column indicating the original 
#'  file name for each row?  Can be a useful source of additional metadata that
#'  NEON may omit from the raw files (i.e. `siteID`), but will also result in
#'  slower parsing.  Default `FALSE`.
#' @param ... additional arguments to [vroom::vroom], can usually be omitted.
#' @param altrep enable or disable altrep.  Logical, default `FALSE`. Setting to 
#' `TRUE` can speed up reading, but may cause [vroom::vroom] to throw
#' `mapping error: Too many open files`.  
#' @param files optionally, specify a vector of file paths directly (e.g. as
#' provided from [neon_index]) and specify `table` argument as NULL.
#' @inheritParams neon_index
#' @importFrom vroom vroom spec
#' @export
#' 
#' @examples 
#' 
#' neon_read("brd_countdata-expanded")
#' 
#' ## Sensor inputs will add metadata columns by default
#' neon_read("waq_instantaneous", site = c("CRAM","SUGG"))
#'
#' 
neon_read <- function(table = NA,
                      product = NA, 
                      site = NA,
                      start_date = NA,
                      end_date = NA,
                      ext = NA,
                      timestamp = NA,
                      dir = neon_dir(),
                      files = NULL,
                      sensor_metadata = TRUE,
                      keep_filename = FALSE,
                      altrep = FALSE,
                      ...){
  
  if(is.null(files)){
    
    if(is.na(table)) {
      stop(paste("please specify a table name."),
           call. = FALSE)
    }
    
    meta <- neon_index(product = product,
                       table = table, 
                       site = site,
                       start_date = start_date,
                       end_date = end_date,
                       ext = ext,
                       hash = NULL, 
                       dir = dir,
                       deprecated = FALSE)
    
    if(is.null(meta)) return(NULL)
    if(dim(meta)[[1]] == 0 )  return(NULL)
    
    files <- meta$path
  }
  
  if(length(files) == 0){
    if(is.null(table)) table <- "unspecified tables"
    warning(paste("no files found for", table, "in", dir, "\n",
                  "perhaps you need to download them first?"))
    return(NULL)
  }
  
  ## don't attempt to stack things we don't understand
  files <- files[grepl("[.]h5", files) | grepl("[.]csv", files)]
  

  neon_stack(files, 
             keep_filename = keep_filename,
             sensor_metadata = sensor_metadata, 
             altrep = altrep, 
             ...)
  
  
}
