## 

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
    message("No files to download.")
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

