#' Download NEON data products into a local store
#'
#'
#' 
#' @details Each NEON data product consists of a collection of 
#' objects (e.g. tables), which are in turn broken into individual files by 
#' site and sampling month.  Additionally, many NEON products have been 
#' expanded, including some additional columns. Consequently, users must
#' specify if they want the "basic" or "expanded" version of this data. 
#' 
#' In the products table (see [neon_products]), the `productHasExpanded` 
#' column indicates if the data
#' product has expanded, and the columns `productHasBasicDescription` and
#' `productHasExpandedDescription` provide a detailed explanation of the
#' differences between the `"expanded"` and `"basic"` versions of that
#' particular product.
#' 
#' The API provides access to a `.zip` file containing all the component objects
#' (e.g. tables) for that product at that site and sampling month. Additionally,
#' the API allows users to request component files directly (e.g. as `.csv` 
#' files).  Requesting component files directly avoids the additional overhead 
#' of downloading other components that are not needed.  Both the `.zip` and 
#' relevant `.csv` and `zip` files in products that have expanded will include
#' both a `"basic"` and `"expanded"` name in the filename.  Setting `type`
#' argument of `neon_download()` to the preferred one will make it filter out
#' the other one.
#' 
#' By default, `neon_download()` will request the `.zip` packet for the product,
#' matching the requested type.  `neon_download()` will extract the component 
#' files into the store, removing the `.zip` file.  Specific files within a
#' product can be identified by altering the `file_regex` argument
#' (see examples).  
#' 
#' `neon_download()` will avoid downloading metadata files which are bitwise
#' identical to other files in the same download request, as indicated by the
#' crc32 hash reported by the API.  These typically include metadata that are
#' shared across the product as a whole, but are for some reason included in 
#' each sampling month for each site -- potentially thousands of duplicates.
#' These duplicates are also packaged within the `.zip` downloads where it
#' is not possible to exclude them from the download. 
#' 
#' @param product A NEON `productCode`. See [neon_download].
#' @param start_date Download only files as recent as (`YYYY-MM-DD`). Leave
#' as `NA` to download up to the most recent available data.
#' @param end_date Download only files up to end_date (`YYYY-MM-DD`). Leave as 
#' `NA` to download all prior data.
#' @param site 4-letter site code(s) to filter on. Leave as `NA` to search all.
#' @param type Should we prefer the basic or expanded version of this product? 
#' See details. 
#' @param file_regex Download only files matching this pattern.  See details.
#' @param quiet Should download progress be displayed?
#' @param verify Should downloaded files be compared against the MD5 hash
#' reported by the NEON API to verify integrity? (default `TRUE`)
#' @param keep_zip should we keep zip files after extracting contents?
#'  (default `FALSE`)
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
#' Note that once files are downloaded once, `neonstore` provides persistent
#' access to them without further interaction required with the API.
#'
#' @export
#' @importFrom utils unzip
#' @importFrom curl curl_download
#' @examples 
#' \donttest{
#'  
#'  neon_download("DP1.10003.001", 
#'                start_date = "2018-01-01", 
#'                end_date = "2019-01-01",
#'                site = "YELL")
#'                
#'  ## Advanced use: filter for a particular table in the product
#'  neon_download(product = "DP1.10003.001",
#'                start_date = "2018-01-01",
#'                end_date = "2019-01-01",
#'                site = "YELL",
#'                file_regex = ".*brd_countdata.*\\.csv")
#' 
#' }
neon_download <- function(product, 
                          start_date = NA,
                          end_date = NA,
                          site = NA,
                          type = "expanded",
                          file_regex =  "[.]csv",
                          quiet = FALSE,
                          verify = TRUE,
                          dir = neon_dir(), 
                          keep_zip = FALSE,
                          api = "https://data.neonscience.org/api/v0",
                          .token =  Sys.getenv("NEON_TOKEN")){
  
  ## Query the API for a list of all files associated with this data product.
  files <- neon_data(product, 
                     start_date = start_date, 
                     end_date = end_date,
                     site = site,
                     api = api,
                     .token = .token)
  
  ## no additional files to download
  if(is.null(files)) return(invisible(NULL))
  
  ## Omit those files we already have
  ## Consider using file hashes instead of file names here!
  already_have <- list.files(dir)
  files <- files[!(files$name %in% already_have), ]
  
  ## Filter for only files matching the file regex
  files <- files[grepl(file_regex, files$name), ]
  files$path <- file.path(dir, files$name)
  
  
  ## Filter to have only expanded or basic (not both)
  ## Confirm we have expanded product first:
  products <- neon_products(api = api, .token = .token)
  expanded <- products$productHasExpanded[products$productCode %in% product]
  if(!any(expanded)){
    type <- "basic"
    if(!quiet) message("no expanded product, using basic product")
  }
  if(type == "expanded")
    files <- files[!grepl("basic", files$name), ]
  if(type == "basic")
    files <- files[!grepl("expanded", files$name), ]
  
  ## Filter out duplicate files, e.g. have identical crc32 values
  unique_files <- take_first_match(files, "crc32")
  
  ## make sure destination exists
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  
  ## now time to download!
  pb <- progress::progress_bar$new(
    format = "  downloading [:bar] :percent eta: :eta",
    total = length(unique_files$url), 
    clear = FALSE, width= 60)
  
  for(i in seq_along(unique_files$url)){
    if(!quiet) pb$tick()
    curl::curl_download(unique_files$url[i], 
                        unique_files$path[i])
  }
  
  if(verify) {
    md5 <- vapply(unique_files$path, 
                  function(y) as.character(openssl::md5(file(y))),
                  character(1L), USE.NAMES = FALSE)
    i <- which(md5 != unique_files$crc32)
    if(length(i) > 0) {
      warning(paste("Some downloaded files which", 
                    "did not match the expected hash:",
                    unique_files$path[i]), call. = FALSE)
    }
  }
  
  
  # unzip and remove .zips
  zips <- unique_files$path[grepl("[.]zip", unique_files$path)]
  lapply(zips, zip::unzip, exdir = dir)
  if(!keep_zip) unlink(zips)
  
  unique_files <- tibble::as_tibble(unique_files)
  invisible(unique_files)
}





#' @importFrom progress progress_bar
#' @importFrom httr GET content stop_for_status
#' @importFrom jsonlite fromJSON
#' @noRd
neon_data <- function(product, 
                      start_date = NA,
                      end_date = NA,
                      site = NA,
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
  
  product_regex <- "DP\\d\\.\\d{5}\\.\\d{3}"
  regex <- paste0(api, "/data/", product_regex, "/(\\w+)/(\\d{4}-\\d{2})$")
  ## Filter by time -- year-month is included at end of data_api list
  dates <- as.Date(gsub(regex, "\\2-01", data_api))
  if(!is.na(start_date)){
    data_api <- data_api[dates >= start_date]
  }
  if(!is.na(end_date)){
    data_api <- data_api[dates <= end_date]
  }  
  
  ## Filter by site
  data_sites <- gsub(regex, "\\1", data_api)
  if(!all(is.na(site))){
    data_api <- data_api[data_sites %in% site]
  }
  
  if(length(data_api) == 0){
    message("No additional files to download.")
    return(invisible(NULL))
  }
  
  ## Extract the file list from the data endpoint.  O(sites * months) calls
  pb <- progress::progress_bar$new(
    format = "  querying API [:bar] :percent eta: :eta",
    total = length(data_api), 
    clear = FALSE, width= 60)
  
  resp <- lapply(data_api, function(x){
    if(!quiet){ pb$tick() }
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
  
  tibble::as_tibble(data)
}



## helper method for filtering out duplicate tables
## NEON API loves returning metadata files with identical content but 
## different names associated with each site and sampling month.
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
  rownames(out) <- NULL
  out[,-1]
}


