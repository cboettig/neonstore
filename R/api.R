

## 

API <- "https://data.neonscience.org/api/v0" 

neon_sites <- function(api = API){
  
  resp <- httr::GET(paste0(api, "/sites"))
  sites <- httr::content(resp, as="text")
  sites_df <- jsonlite::fromJSON(sites)[[1]]
  products <- sites_df$dataProducts
  names(products) <- sites_df$siteCode
  df <- purrr::map_dfr(products, identity, .id = "siteCode")
  df
}


neon_data <- function(product, api = API){

  ## A single API call to sites, includes product & month at each site    
  sites_df <- neon_sites(api)
  
  ## Consider only sites including the requested product.
  ## The DataUrl column gives the API endpoint data/{ProductCode}/{SiteCode}{Month}
  available_sites <- sites_df[sites_df$dataProductCode == product,]
  data_api <- unlist(available_sites$availableDataUrls)
  
  ## Exract the file list from the data endpoint:
  resp <- lapply(data_api, httr::GET)
  
  data <- purrr::map_dfr(resp, function(x) {
    
    cont <- httr::content(x, as = "text")
    dat <- jsonlite::fromJSON(cont)[[1]]
    dat$files
  })

  data
}




product <- "DP1.10003.001"
"brd_countdata.*basic.*"
neon_download <- function(data, dest = tempdir(), table_regex = ".*basic.*[.]zip")
  
  files <- data[grepl(table_regex, data$name),]
  loc <- file.path(dest, files$name)
  
  
  
  
  purrr::walk2(files$url, loc, download.file)
  
  birds <- fs::dir_ls("birds") %>% vroom::vroom()
  
  
  
}

