
#' Table of all NEON sites
#' 
#' Returns a table of all NEON sites by making a single API call
#' to the `/sites` endpoint.
#' @inheritParams neon_download
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
neon_sites <- function(api = "https://data.neonscience.org/api/v0", 
                       .token = Sys.getenv("NEON_TOKEN")){
  
  resp <- httr::GET(paste0(api, "/sites"), 
                    httr::add_headers("X-API-Token" = .token))
  sites <- httr::content(resp, as="text")
  jsonlite::fromJSON(sites)[[1]]
 
}

#' Table of all NEON Data Products
#'
#' Return a table of all NEON Data Products, including product descriptions
#' and the productCode needed for [neon_download].  
#' @param fields a list of fields (columns) to include.  Default includes
#' most common columns, set to NULL to display all columns
#' (including list-columns).
#' @inheritParams neon_download
#' @seealso [neon_download]
#' @export
#' @examples 
#' \donttest{
#' 
#' products <- neon_products()
#' 
#' # Or search for a keyword
#' i <- grepl("bird", products$keyword)
#' products[i, c("productCode", "productName")]
#' 
#' }
neon_products <- function(
  fields = c("productCode", 
             "productName", 
             "productStatus", 
             "productDescription", 
             "productStatus",
             "themes",
             "keywords",
             "productCategory",
             "productAbstract",
             "productDesignDescription",
             "productRemarks",
             "productSensor",
             "productPublicationFormatType",
             "productHasExpanded",
             "productBasicDescription", 
             "productExpandedDescription"),
  api = "https://data.neonscience.org/api/v0",
  .token = Sys.getenv("NEON_TOKEN")){
  
  # consider a local cache option?
  
  resp <- httr::GET(paste0(api, "/products"),
                    httr::add_headers("X-API-Token" = .token))
  txt <- httr::content(resp, as="text")
  products <-jsonlite::fromJSON(txt)[[1]]
  
  # un-list character columns
  products$themes <- 
    vapply(products$themes, paste0, character(1L), collapse = " | ")
  products$keywords <- 
    vapply(products$keywords, paste0, character(1L), collapse = " | ")
  
  if(!is.null(fields))
    products <- products[fields]
  
  # allow tibble-style printing for tidyverse users
  class(products) <- c("tbl_df", "tbl", "data.frame")
  products
  
}


#' product <- "DP1.10003.001"

#' 
#' @importFrom httr GET content stop_for_status
#' @importFrom jsonlite fromJSON
neon_data <- function(product, 
                      start_date = NA,
                      end_date = NA,
                      quiet = FALSE,
                      api = "https://data.neonscience.org/api/v0", 
                      .token = Sys.getenv("NEON_TOKEN")){

  start_date <- as.Date(start_date)
  end_date <- as.Date(end_date)
  
  ## A single API call to sites, includes product & month at each site    
  sites_df <- neon_sites(api)
  dataProducts <- do.call(rbind, sites_df$dataProducts)
  
  ## Consider all/only the sites including the requested product.
  ## The DataUrl column gives the API endpoint data/{ProductCode}/{SiteCode}{Month}
  available <- dataProducts[dataProducts$dataProductCode %in% product,]
  
  data_api <- unlist(available$availableDataUrls)

  ## Filter by time -- year-month is included at end of data_api list
  dates <- as.Date( gsub(".*(\\d{4}-\\d{2})$", "\\1-01", data_api) )
  if(!is.na(start_date)){
   data_api <- data_api[dates >= start_date]
  }
  if(!is.na(end_date)){
    data_api <- data_api[dates <= end_date]
  }  
  
    
  ## Extract the file list from the data endpoint.  O(sites * months) calls
  pb <- progress::progress_bar$new(
    format = "  querying API for available data [:bar] :percent eta: :eta",
    total = length(data_api), 
    clear = FALSE, width= 60)
  
  resp <- lapply(data_api, function(x){
    if(!quiet) pb$tick()$print()
    httr::GET(x, httr::add_headers("X-API-Token" = .token))
  })
  
  
  
  ## Format the result as a data.frame
  data <- do.call(rbind,
                  lapply(resp, function(x) {
    
    httr::stop_for_status(x)
    cont <- httr::content(x, as = "text")
    dat <- jsonlite::fromJSON(cont)[[1]]
    if(length(dat) == 0) return(NULL)
    if(length(dat$files) == 0) return(NULL)
    dat$files
  }))

  data
}


neon_dir <- function(){
  Sys.getenv("NEONSTORE_HOME", 
             rappdirs::user_data_dir("neonstore"))
}
 
#neon_contentstore <- function(files, dir = contentid::content_dir()){
#  
#  files$ids <- vapply(files$url, contentid::store, character(1L), dir = dir)
#  files
#}


#' product <- "DP1.10003.001"
#' ".*basic.*[.]zip"


#' Download NEON data products into a local store
#' @param product A NEON productCode. See [neon_download].
#' @param start_date Download only files as recent as (YYYY-MM-DD). Leave
#' as `NA` to download up to the most recent avaialble data.
#' @param end_date Download only files up to end_date (YYYY-MM-DD). Leave as 
#' `NA` to download all prior data.
#' @param file_regex Download only files matching this pattern.  See details.
#' @param quiet Should progress be displayed?
#' @param dir Location where files should be downloaded. By default will
#' use the appropriate applications directory for your system 
#' (see [rappdirs::user_data_dir]).  This default also be configured by
#' setting the environmental variable `NEONSTORE_HOME`, see [Sys.setenv] or
#' [Renviron].
#' @param api the URL to the NEON API, leave as default.
#' @param .token an authentication token from NEON. A token is not
#' required but will allow access to a higher number of requests before
#' rate limiting applies, see 
#' <https://data.neonscience.org/data-api/rate-limiting/#api-tokens>.
#' Note that once files are downloaded once, `neonstore` provides persitent
#' access to them without further interaction required with the API.
#' 
#' @details `"*basic*.zip`
#' 
#' @export
#' @examples 
#' \donttest{
#'  
#'  neon_download("DP1.10003.001", 
#'                start_date = "2019-01-01", 
#'                file_regex = ".*basic.*[.]zip")
#' 
#' }
neon_download <- function(product, 
                          start_date = NA,
                          end_date = NA,
                          file_regex =  ".*basic.*[.]zip",
                          quiet = FALSE,
                          dir = neon_dir(), 
                          api = "https://data.neonscience.org/api/v0",
                          .token =  Sys.getenv("NEON_TOKEN")){
  
  ## Query the API for a list of all files associated with this data product.
  data <- neon_data(product, 
                    start_date = start_date, 
                    end_date = end_date, 
                    api = api,
                    .token = .token)
  
  ## Omit those files we already have
  already_have <- list.files(dir)
  new_data <- data[!(data$name %in% already_have), ]
  
  ## Filter for only files matching the file regex
  files <- new_data[grepl(file_regex, new_data$name),]
  files$dir <- file.path(dir, files$name)
  
  ## Filter duplicate files, e.g. have identical crc32 values
  unique_files <- take_first_match(files, "crc32")
  
  ## Report total expected download size:
  
  
  ## make sure destination exists
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  
  ## now time to download!
  
  pb <- progress::progress_bar$new(
    format = "  downloading [:bar] :percent eta: :eta",
    total = length(data_api), 
    clear = FALSE, width= 60)
  
  handle <- curl::new_handle()
  for(i in seq_along(unique_files$url)){
    if(!quiet) pb$tick()$print()
    curl::curl_download(unique_files[i, "url"], 
                        unique_files[i, "dir"], 
                        handle = handle)
  }

  
  # unzip zip files
  lapply(list.files(dir, "[.]zip", full.names = TRUE),
         unzip, exdir = dir)
  
  
  invisible(unique_files)
}


take_first_match <- function(df, col){
  
  if(nrow(df) < 2) return(df)
  
  uid <- unique(df[[col]])
  na <- df[1,]
  na[1,] <- NA
  rownames(na) <- NULL
  out <- data.frame(uid, na)
  
  ## Should really figure out vectorized implementation here...
  ## but in any event download step will be far more rate-limiting.
  for(i in seq_along(uid)){
    match <- df[[col]] == uid[i]
    first <- which(match)[[1]]
    out[i,-1] <- df[first, ]
  }
  out
}


