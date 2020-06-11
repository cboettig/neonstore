
#' Generate the appropriate citation for your data
#' 
#' @inheritParams neon_download
#' @param  download_date Date of download to be included in citation.
#'  default is today's date, see details. 
#' 
#' @references <https://www.neonscience.org/data/about-data/data-policies>
#' @return returns a [utils::bibentry] object, which can be used as text
#' or formatted for bibtex.
#' @details
#' Note that the `neon_download()` does not record download date for each file.
#' Citing a single product download date is after all rather meaningless, as 
#' parts of a products may not have all been downloaded on different dates.
#' Indeed, `neon_download()` is designed in precisely this way, to allow easy
#' updating of downloads without re-downloading older data.
#' 
#' @importFrom utils bibentry person
#' @export
#' @examples 
#' 
#' neon_citation("DP1.10003.001")
#' 
#' ## or the citation for all products in store:
#' neon_citation()
#' 
#' ## as bibtex
#' format(neon_citation("DP1.10003.001"), "bibtex")
#' 
neon_citation <- function(product = NULL, 
                          download_date = Sys.Date(),
                          dir = neon_dir()){
  
  download_date <- as.Date(download_date)
  year <-  format(Sys.Date(), "%Y")
  
  if(is.null(product)){
    meta <- neon_index(hash = NULL, dir = dir)
    product <- unique(meta$product)
  }
  
  product_list <- ""
  if(length(product) < 6)
    product_list <- paste("Data Products:", 
                          paste0("NEON.", product, collapse = " "),
                          ". ")
  
  
  author <- "National Ecological Observatory Network"
  year <- year
  title <- paste0(product_list, 
                  "Provisional data downloaded from http://data.neonscience.org on ",
                  format(download_date, "%d %b %Y"))  
  publisher = "Battelle"
  location = "Boulder, CO, USA"
  
  txt <- paste(author, year, title, 
               paste(publisher, location, sep = ", "), sep = ". ")
  
  utils::bibentry("Misc", 
                  author = utils::person(family = author), 
                  year = year, 
                  title = title, 
                  publisher = publisher, 
                  location = location,
                  textVersion = txt)
  
  
}