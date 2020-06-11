#' Table of all NEON sites
#' 
#' Returns a table of all NEON sites by making a single API call
#' to the `/sites` endpoint.
#' @inheritParams neon_download
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @export
neon_sites <- function(api = "https://data.neonscience.org/api/v0", 
                       .token = Sys.getenv("NEON_TOKEN")){
  
  resp <- httr::GET(paste0(api, "/sites"), 
                    httr::add_headers("X-API-Token" = .token))
  txt <- httr::content(resp, as="text")
  sites <- jsonlite::fromJSON(txt)[[1]]
  tibble::as_tibble(sites)
}
