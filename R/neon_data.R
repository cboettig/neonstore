#

#' @importFrom progress progress_bar
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @noRd
#' @examples
#' x <- neon_data("DP1.10003.001") 
#' x <- neon_data("DP1.10003.001", release="RELEASE-2021") 
neon_data <- function(product, 
                      start_date = NA,
                      end_date = NA,
                      site = NA,
                      type = NA,
                      release = NA,
                      quiet = FALSE,
                      api = "https://data.neonscience.org/api/v0", 
                      .token = Sys.getenv("NEON_TOKEN")){
  
  data_api <- data_api_queries(product = product, 
                               start_date = start_date, 
                               end_date = end_date, 
                               site = site,
                               type = type,
                               release = release,
                               quiet = quiet,
                               api = api,
                               .token = .token)
  
  ## Adjust for rate-limiting
  batch <- 950                 # authenticated
  if(.token == "") batch <- 150 # unauthenticated
  
  
  ## Extract the file list from the data endpoint.  O(sites * months) calls
  pb <- progress::progress_bar$new(
    format = paste("  requesting", product, 
                   "from API [:bar] :percent in :elapsed, eta: :eta"),
    total = length(data_api), 
    clear = FALSE, width= 80)
  
  resp <- vector("list", length = length(data_api))
  for(i in seq_along(data_api)){
    if(!quiet){ pb$tick() }
    resp[[i]] <- httr::GET(data_api[[i]],
                           httr::add_headers("X-API-Token" = .token))
    status <- neon_warn_http_errors(resp[[i]])
    if(status == 429){ # retry once
      resp[[i]] <- httr::GET(data_api[[i]],
                             httr::add_headers("X-API-Token" = .token))
    }
    if(i %% batch == 0){
      if(!quiet) message("  NEON rate limiting enforced, pausing for 100s\n")
      Sys.sleep(105)
    }
  }
  
  ## Format the result as a data.frame
  data <- do.call(rbind,
                  lapply(resp, function(x) {
                    status <- httr::status_code(x)
                    if(status >= 400) return(NULL)
                    cont <- httr::content(x, as = "text")
                    dat <- jsonlite::fromJSON(cont)[[1]]
                    if(length(dat) == 0) return(NULL)
                    if(length(dat$files) == 0) return(NULL)
                    out <- dat$files
                    out$release <- dat$release
                    out
                  }))
  
  tibble::as_tibble(data)
}

#' @importFrom httr status_code content
neon_warn_http_errors <- function(x){
  status <- httr::status_code(x)
  if(status < 400) return(invisible(0L))
  out <- httr::content(x, encoding = "UTF-8")
  message("  NEON rate limiting enforced, pausing for 100s\n")
  Sys.sleep(101)
  invisible(status)
}

## Some DataUrls reported by products table include date ranges that are not valid, e.g.: 
## https://data.neonscience.org/api/v0/data/DP1.20093.001/ARIK/2011-04
## Hence, we warn on these errors but will continue with any other downloads in the list.


## prepare a vector of API queries
# x <- data_api_queries("DP1.10003.001", release="RELEASE-2021") 
data_api_queries <- function(product, 
                            start_date = NA,
                            end_date = NA,
                            site = NA,
                            type = NA,
                            release = NA,
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
    dates <- as.Date(gsub(regex, "\\2-01", data_api))
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
    if(!quiet) message("  No files to download.")
    return(invisible(NULL))
  }
  
  if(!is.na(release)){
    # check release tag matches known value?
    data_api <- vapply(data_api, 
                       httr::modify_url, 
                       character(1L), 
                       query = list(release=release),
                       USE.NAMES = FALSE)
  }
  if(!is.na(type)){
    if( !(type %in% c("basic", "expanded")) ){
      warning("type must be 'basic', 'expanded', or NA (default)", call. = FALSE)
      return(data_api)
    }
    data_api <- vapply(data_api, 
                       httr::modify_url, 
                       character(1L), 
                       query = list(package=type),
                       USE.NAMES = FALSE)
  }
  
  data_api
}






