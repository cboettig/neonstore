### Functions in store.R do not require API access, but interact only with
### the local persistent storage




#' Show tables that have been downloaded to the neon store
#' 
#' @details
#' The table names displayed can be read in using [neon_read]. 
#' Optionally, specify a NEON productCode to view only tables associated
#' with a specific product. 
#' 
#' Only downloaded tables will be displayed.  Users can view all available
#' NEON data products using [neon_products] to choose which ones to download
#' into the store.
#' 
#' `neon_store()` does not need to access the API and thus does not require
#' an internet connection or incur rate limiting on requests.
#' 
#' @seealso [neon_products], [neon_download], [neon_index]
#' @inheritParams neon_index
#' @importFrom stats aggregate
#' @export
#' @examples
#' 
#' neon_store()
#' 
#' 
neon_store <- function(product = NA, 
                       table = NA, 
                       site = NA,
                       start_date = NA,
                       end_date = NA,
                       ext = NA,
                       hash = NULL,
                       dir = neon_dir()){
  
  meta <- neon_index(product = product, 
                     table = table, 
                     hash = NULL,
                     dir = dir)
  
  if(is.null(meta)){
    message("No data found in store:\n", dir)
    return(invisible(NULL))
  }
  
  # no dplyr. time for old-school 
  out <- stats::aggregate(formula = site ~ product + table, 
            data = meta, 
            FUN = length)
  out[order(out$product),]
  
  out <- as_tibble(out)
  names(out) <- c("product", "table", "n_files")
  out
}











