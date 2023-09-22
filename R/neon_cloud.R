
#' neon cloud
#' 
#' @inheritParams neon_download
#' @param table NEON table name
#' @return lazy data frame
#' @export
neon_cloud <-function(table,
                      product, 
                      start_date = NA,
                      end_date = NA,
                      site = NA,
                      type = NA,
                      release = NA,
                      quiet = FALSE,
                      api = "https://data.neonscience.org/api/v0", 
                      .token = Sys.getenv("NEON_TOKEN")){
  
  
  df <- neon_data(product, start_date, end_date, site, type, release,
                  quiet, api, .token = .token)
  
  
  urls <- df$url[ grepl(table, df$name) ]
  
  ## discover or enforce extension
  
  df <- tryCatch({
    duckdbfs::open_dataset(urls, format = "csv")
    },
    error = function(e) {
      message("attempting to unify conflicted schemas...")
      duckdbfs::open_dataset(urls, format = "csv", unify_schemas = TRUE)    
    }
  )
  
  df
}

  



neon_urls <- function(table,
                      product, 
                      start_date = NA,
                      end_date = NA,
                      site = NA,
                      type = NA,
                      release = NA,
                      quiet = FALSE,
                      api = "https://data.neonscience.org/api/v0", 
                      .token = Sys.getenv("NEON_TOKEN")){
  
  
  
}
