

#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
neon_sites <- function(api = "https://data.neonscience.org/api/v0", 
                       .token = Sys.getenv("NEON_TOKEN")){
  
  resp <- httr::GET(paste0(api, "/sites"), httr::add_headers("X-API-Token" = .token))
  sites <- httr::content(resp, as="text")
  jsonlite::fromJSON(sites)[[1]]
 
}

#' @importFrom httr GET content stop_for_status
#' @importFrom jsonlite fromJSON
neon_data <- function(product, api = "https://data.neonscience.org/api/v0", .token = Sys.getenv("NEON_TOKEN")){

  ## A single API call to sites, includes product & month at each site    
  sites_df <- neon_sites(api)
  dataProducts <- do.call(rbind, sites_df$dataProducts)
  
  ## Consider all/only the sites including the requested product.
  ## The DataUrl column gives the API endpoint data/{ProductCode}/{SiteCode}{Month}
  available <- dataProducts[dataProducts$dataProductCode == product,]
  data_api <- unlist(available$availableDataUrls)
  
  ## Extract the file list from the data endpoint.  O(sites * months) calls
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

#' @export
neon_download <- function(product, dest = neon_dir(), file_regex = "[.]csv", api = "https://data.neonscience.org/api/v0", quiet = FALSE){
  
  ## Query the API for a list of all files associated with this data product.
  data <- neon_data(product)
  
  ## Omit those files we already have
  already_have <- list.files(dest)
  new_data <- data[!(data$name %in% already_have), ]
  
  ## Filter for only files matching the file regex
  files <- new_data[grepl(file_regex, new_data$name),]
  files$dest <- file.path(dest, files$name)
  
  ## make sure destination exists
  dir.create(dest, showWarnings = FALSE, recursive = TRUE)
  
  ## download time!
  handle <- curl::new_handle()
  for(i in seq_along(files$url)){
    curl::curl_download(files[i, "url"], files[i, "dest"], quiet = quiet, handle = handle)
  }

  invisible(dest)  
}

#' file_regex = "brd_countdata.*basic.*"

neon_read_table <- function(table_string, dest, ...){
  tables <- list.files(dest, pattern = table_string, full.names = TRUE)
  vroom::vroom(tables, ...)
}

# birds <- fs::dir_ls("birds") %>% vroom::vroom()


