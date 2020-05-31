

#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
neon_sites <- function(api = "https://data.neonscience.org/api/v0", 
                       .token = Sys.getenv("NEON_TOKEN")){
  
  resp <- httr::GET(paste0(api, "/sites"), 
                    httr::add_headers("X-API-Token" = .token))
  sites <- httr::content(resp, as="text")
  jsonlite::fromJSON(sites)[[1]]
 
}

neon_products <- function(api = "https://data.neonscience.org/api/v0", 
                       .token = Sys.getenv("NEON_TOKEN")){
  
  resp <- httr::GET(paste0(api, "/products"),
                    httr::add_headers("X-API-Token" = .token))
  txt <- httr::content(resp, as="text")
  products <-jsonlite::fromJSON(txt)[[1]]
  products
  
}


#' product <- "DP1.10003.001"

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
  available <- dataProducts[dataProducts$dataProductCode == product,]
  
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
  ## Consider optional progress indicator here!
  resp <- lapply(data_api, httr::GET, httr::add_headers("X-API-Token" = .token))
  
  
  
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


neon_dir <- neon_default_registry <- function(){
  Sys.getenv("NEONSTORE_HOME", 
             rappdirs::user_data_dir("neonstore"))
}
 
#neon_contentstore <- function(files, dir = contentid::content_dir() ){
#  files$ids <- vapply(files$url, contentid::store, character(1L), dir = dir)
#  files
#}


#' product <- "DP1.10003.001"
#' ".*basic.*[.]zip"


#' 
#' @export
#' @examples 
#' \donttest{
#'  
#'  neon_download("DP1.10003.001", 
#'                start_date = "2019-01-01", 
#'                file_regex = "[.]csv")
#' 
#' }
neon_download <- function(product, 
                          start_date = NA,
                          end_date = NA,
                          file_regex = "[.]csv",
                          quiet = FALSE,
                          dest = neon_dir(), 
                          api = "https://data.neonscience.org/api/v0",
                          .token =  Sys.getenv("NEON_TOKEN")){
  
  ## Query the API for a list of all files associated with this data product.
  data <- neon_data(product, 
                    start_date = start_date, 
                    end_date = end_date, 
                    api = api,
                    .token = .token)
  
  ## Omit those files we already have
  already_have <- list.files(dest)
  new_data <- data[!(data$name %in% already_have), ]
  
  ## Filter for only files matching the file regex
  files <- new_data[grepl(file_regex, new_data$name),]
  files$dest <- file.path(dest, files$name)
  
  ## Filter duplicate files, e.g. have identical crc32 values
  unique_files <- take_first_match(files, "crc32")
  
  ## Report total expected download size:
  
  
  ## make sure destination exists
  dir.create(dest, showWarnings = FALSE, recursive = TRUE)
  
  ## now time to download!
  handle <- curl::new_handle()
  for(i in seq_along(unique_files$url)){
    curl::curl_download(unique_files[i, "url"], unique_files[i, "dest"], 
                        quiet = quiet, handle = handle)
  }

  invisible(dest)  
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


