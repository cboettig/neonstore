
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
#' i <- grepl("bird", products$keywords)
#' products[i, c("productCode", "productName")]
#' 
#' }
neon_products <- function(
  fields = c("productCode", 
             "productName", 
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
  
  tibble::as_tibble(products)
  
}