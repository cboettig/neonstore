############### Experimental ####################


#' Download requested NEON files from an S3 bucket 
#' 
#' It is possible to copy the local neonstore (see `[neon_dir()]`) to
#' an S3 bucket for faster shared access to a large store.  This function
#' mimics the behavior of `[neon_download()]` but accesses files directly
#' from such an S3 bucket.
#' Queries the AWS-S3 REST endpoint GET bucket for a file list
#' in (in 1000-file chunks), then filters file names to determine
#' what to download. Users must set the `api` to the address of their S3
#' bucket to take advantage of this feature.  For demonstration purposes,
#' an example S3 bucket is provided as the default.  Note that data 
#' obtained in this way is only as up-to-date or complete as the underlying
#' cache.  Users should always draw from the NEON API using `[neon_download()]`
#' to ensure they have the most recent and complete data files.  
#' 
#' Note: at this time, release information associated with files in the store
#' is not available from neonstore S3 caches. As such, this mechanism is not
#' able to filter data for specific RELEASE tags, is which are only available
#' from the NEON API.  Querying products by `[neon_download()]` will update
#' the corresponding release tags.  
#' 
#' 
#' @inheritParams neon_download
#' @param api URL to an S3 bucket containing raw NEON data files (in
#' flat file structure like that used by neonstore).
#' @return (invisibly) table of requested files and metadata
#' @export
#' @examples 
#' 
#' \dontshow{
#' # Users get confused by use of tempdir in examples, so hide
#' Sys.setenv(NEONSTORE_HOME=tempdir())
#' }
#' 
#' \donttest{
#'  neon_download("DP1.10003.001", 
#'                start_date = "2018-01-01", 
#'                end_date = "2019-01-01",
#'                site = "YELL")
#' }
#' 
#' \dontshow{
#'  # And clean up
#' Sys.unsetenv("NEONSTORE_HOME")
#' }
#' 
neon_download_s3 <- function(product, 
                             table =  NA,
                             site = NA,
                             start_date = NA,
                             end_date = NA,
                             type = "basic",
                             release = NA,
                             quiet = FALSE,
                             verify = TRUE,
                             dir = neon_dir(),
                             get_zip = FALSE,
                             unzip = FALSE,
  api = "https://minio.thelio.carlboettiger.info/neonstore/"){
  
  if(!quiet) message("querying S3 API...")
  files <- s3_index_public(api)
  
  ## These two checks overlap with neon_download() steps
  ## only files matching regex
  if(!is.na(table)){
    files <- files[grepl(table, files)]
  }
  if(get_zip){
    files <- files[grepl("[.]zip", files)]
  } else {
    files <- files[!grepl("[.]zip", files)]
  }
    
  ## only files we don't already have in the store
  already_have <- basename(files) %in% basename(list.files(dir, recursive = TRUE))
  if(sum(already_have) > 0 && !quiet){
    message(paste("omitting", sum(already_have), "files previously downloaded"))
  }
  files <- files[!already_have]
  
  if(length(files) == 0){
    message("No new files found")
    return(invisible(NULL))
  } 
  
  ## Apply filters to filenames
  meta <- filename_parser(files)
  meta <- meta_filter(meta, 
                      product = product, 
                      table = table,
                      site = site, 
                      start_date = start_date, 
                      end_date = end_date,
                      type = type)
  
  if(length(meta$path) == 0) {
    message("No new files found")
    return(invisible(NULL))
  } 
  
  ## make sure destination exists
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  
  ## URL and destination
  addr <- paste0(api, meta$path)
  dest <- file.path(dir, meta$path)
  lapply(dirname(dest), dir.create, FALSE, TRUE)
  
  # crc32/md5 sums not recorded
  download_all(addr, dest, quiet = quiet, verify = FALSE)
  if(unzip) unzip_all(dest, dir)

  
  ## Technically we should hash the files and add them to the 
  ## registry with the hashes and `UNKNOWN` release tag information
  
  invisible(meta)
}


# @importFrom xml2 xml_nn xml_find_first xml_find_all xml_text
# @importFrom httr GET content
# MINIO appears to be using version 1 of ListBucket method.
# https://docs.aws.amazon.com/AmazonS3/latest/API/archive-RESTBucketGET.html
# This format is several versions behind current AWS syntax!
# In particular, this uses `marker` instead of `continuation-token`

s3_index_public <- function(
  bucket = "https://minio.thelio.carlboettiger.info/neonstore/"){
  
  ## use xml2 conditionally
  if(!requireNamespace("xml2", quietly = TRUE)){
    stop("install xml2 to access data from S3 buckets")
  }
 
  isTruncated <- TRUE
  startAfter <- NULL
  files <- ""

  while(isTruncated){
    resp <- httr::GET(bucket,
                      query = list("marker" = startAfter))
    xml <- httr::content(resp, encoding = "UTF-8")
    ns <- xml2::xml_ns(xml)
    isTruncated <- xml2::xml_find_first(xml, "//d1:IsTruncated", ns)
    isTruncated <-as.logical( xml2::xml_text(isTruncated) )
    startAfter <- xml2::xml_text(xml2::xml_find_first(xml, "//d1:NextMarker", ns))
    set <- xml2::xml_text(xml2::xml_find_all(xml, "//d1:Key", ns))
    files <- c(files,set)
  }
  files
}
