############### Experimental ####################


#' Download requested NEON files from an S3 bucket 
#' 
#' Queries the AWS-S3 REST endpoint GET bucket for a file list
#' in (in 1000-file chunks), then filters file names to determine
#' what to download. This should be much faster than the NEON API and
#' avoids rate-limiting.
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
                             start_date = NA,
                             end_date = NA,
                             site = NA,
                             type = "expanded",
                             file_regex =  "[.]csv",
                             quiet = FALSE,
                             verify = TRUE,
                             dir = neon_dir(), 
                             unzip = TRUE,
  api = "https://minio.thelio.carlboettiger.info/neonstore/"){
  
  if(!quiet) message("querying S3 API...")
  files <- s3_index_public(api)
  
  ## These two checks overlap with neon_download() steps
  ## only files matching regex
  files <- files[grepl(file_regex, files)]
  ## only files we don't already have in the store
  already_have <- list.files(dir)
  files <- files[!(files %in% already_have)]
  if(length(files) == 0){
    message("No new files found")
    return(invisible(NULL))
  } 
  
  ## Apply filters to filenames
  meta <- filename_parser(files)
  meta <- meta_filter(meta, 
                      product = product, 
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
  
  download_all(addr, dest, quiet)
  # verify_hash(dest, files$crc32, verify)
  if(unzip) unzip_all(dest, dir)

  invisible(meta)
}


# @importFrom xml2 xml_nn xml_find_first xml_find_all xml_text
# @importFrom httr GET content
# MINIO appears to be using version 1 of ListBucket method.
# https://docs.aws.amazon.com/AmazonS3/latest/API/archive-RESTBucketGET.html
# This format is several versions behind current AWS syntax!
# In particular, this uses `marker` instead of `continuation-token`

s3_index_public <- function(
  bucket = "https://minio.jetstream.carlboettiger.info/neonstore/"){
  
  ## use xml2 conditionally
  if(!requireNamespace("xml2", quietly = TRUE)){
    stop("install xml2 to access data from S3 buckets")
  }
  xml_find_all <- getExportedValue("xml2", "xml_find_all")
  xml_find_first <- getExportedValue("xml2", "xml_find_first")
  xml_ns <- getExportedValue("xml2", "xml_ns")
  xml_text <- getExportedValue("xml2", "xml_text")
  
  isTruncated <- TRUE
  startAfter <- NULL
  files <- ""

  while(isTruncated){
    resp <- httr::GET(bucket,
                      query = list("marker" = startAfter))
    xml <- httr::content(resp, encoding = "UTF-8")
    ns <- xml_ns(xml)
    isTruncated <- xml_find_first(xml, "//d1:IsTruncated", ns)
    isTruncated <-as.logical( xml_text(isTruncated) )
    startAfter <- xml_text(xml_find_first(xml, "//d1:NextMarker", ns))
    set <- xml_text(xml_find_all(xml, "//d1:Key", ns))
    files <- c(files,set)
  }
  files
}
