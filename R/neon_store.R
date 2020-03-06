
library(fs)
library(purrr)
library(contenturi) # remotes::install_github("cboettig/cotenturi")
library(neonUtilities)  

#' download and store a data product
#' 
#' @details This is a very simple wrapper around zipsByProduct.  zipsByProduct downloads
#' the requested data as a set of .zip files to local disk.  We jsut want to know
#' if those files are the same each time, or have changed.    
#' @inheritParams neonUtilities::zipsByProduct
#' @examples \donttest{
#' savepath <- "neon"
#' dpID <- "DP1.10003.001"
#' startdate <- NA
#' 
#' 
#' 
neon_store <- function(dpID, site="all", startdate=NA, enddate=NA, package="basic",
                          avg="all", check.size=TRUE, savepath=NA, load=F) {

  
  if(is.na(savepath))
    savepath <- tempdir()

  # pass the request to zipsByProduct() to download
  neonUtilities::zipsByProduct(dpID=dpID, 
                site="all", 
                startdate=startdate, 
                enddate=NA, 
                package="expanded", 
                check.size=FALSE, 
                savepath=savepath, 
                load=TRUE)
  
  ## All files are now donloaded to `savepath`
  
  
  ## Add all downloaded files to the (local) content store.  
  workdir <- paste(savepath, "/filesToStack", substr(dpID, 5, 9), sep="")
  zips <- fs::dir_ls(workdir)
  ids <- vapply(zips, contenturi::store, character(1L))
  
  ## Create a local directory where we use the original file names as
  ## symlinks connected to the corresponding content in the store.  
  ## NOTE: if we re-download NEON data and a file has changed, it will not 
  ## overwrite the previous store record
  reg <- data.frame(id = ids, 
                    name = fs::path_file(zips), 
                    date = Sys.time(),
                    stringsAsFactors = FALSE)

  readr::write_csv(reg, paste0(dpID, "-registry.csv"), append=TRUE)
  
  
  ## Save this metadata registry too!
}


## Stacking the raw data
#' Stack zip files into combined tables using the local store
#' @inheritParams stackByTable
neon_stack <- function(workdir = tempdir(), dpID=NA, nCores=parallel::detectCores(), 
                       reg = neon_registry()){

  
  ## Populate workdir with symlinks that point to the content expected by stackByTable
  walk2(reg$id, reg$name, function(x, y) 
    fs::link_create(contenturi::retrieve(x), fs::path(workdir, y)))
  
  
  ## Now lets stack all this many many zips into csvs
  ## Note: stackByTable's messages ain't suppressable
  neonUtilities::stackByTable(workdir, dpID = dpID, nCores = nCores)

  ## Now let's also store the stacked CSVs
  stacked_csvs <- fs::dir_ls(fs::path(zippath, "stackedFiles"))
  csv_ids <- map_chr(stacked_csvs, contenturi::store)


reg <- data.frame(id = csv_ids, name = path_file(stacked_csvs),  date = Sys.time(),
                  stringsAsFactors = FALSE)
readr::write_csv(reg, paste0(dpID, "-registry.csv"), append=TRUE)


}

neon_registry <- function(path = fs::path_abs("registry.csv", 
                                              dir = rappdirs::user_data_dir("neon")
                                              )
                          ){
  if(!file.exists(path) ){
    df <- data.frame(id = NA, name = NA, date = NA, stringsAsFactors = FALSE)
    readr::write_csv( df[0,], path)
  }
  invisible(path)
    
}

#br_count <- contenturi::retrieve(
# "hash://sha256/3544e9345cc9ff9e235ff49e2d446dfea1ce5fb2be2c82c66f4e58516bf8a3bd")


