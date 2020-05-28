#' download and store a data product
#' 
#' @details This is a very simple wrapper around zipsByProduct.  zipsByProduct downloads
#' the requested data as a set of .zip files to local disk.  We jsut want to know
#' if those files are the same each time, or have changed.    
#' @inheritParams neonUtilities::zipsByProduct
#' @inheritParams neon_stack
#' @return path to the neon data registry csv file (invisibly)
#' @export
#' @importFrom readr read_csv write_csv
#' @importFrom neonUtilities zipsByProduct stackByTable
#' @importFrom contentid store retrieve
#' @importFrom fs dir_ls path_file path path_abs link_create
#' @examples \donttest{
#' neon_store("DP1.10003.001")
#'  }
#' 
#' 
neon_store <- function(dpID, site="all", startdate=NA, enddate=NA, package="basic",
                       avg="all", check.size=TRUE, savepath=NA, load=F, 
                       registry = neon_registry(),
                       dir = contentid::content_dir()) {

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
  
  ## All files are now downloaded to `savepath`
  
  
  ## Add all downloaded files to the (local) content store.  
  workdir <- paste(savepath, "/filesToStack", substr(dpID, 5, 9), sep="")
  zips <- fs::dir_ls(workdir)
  ids <- vapply(zips, contentid::store, character(1L), dir)
  

  ## NOTE: if we re-download NEON data and a file has changed, it will not 
  ## overwrite the previous store record
  entry <- data.frame(id = unname(ids), 
                    name = fs::path_file(zips), 
                    date = Sys.time(),
                    product = dpID,
                    type = "raw_csv",
                    stringsAsFactors = FALSE)

  readr::write_csv(entry, registry, append=TRUE)
  
  registry
  
  ## Save this metadata registry too!
}


## Stack NEON data files into a combined data product
#' Stack zip files into combined tables using the local store
#' 
#' @param registry location to write the local neon data registry
#' @param dir location to use for the content store
#' @param workdir Location to use for temporary storage, will be purged after use
#' @inheritParams neonUtilities::stackByTable
#' @return ids and names of stacked tables
#' @export
#' @examples \donttest{
#' neon_store("DP1.10003.001")
#' neon_stack("DP1.10003.001")
#' }
neon_stack <- function(dpID=NA, 
                       dir = contentid::content_dir(),
                       registry = neon_registry(),
                       workdir = fs::path_temp("temporary"), 
                       nCores=parallel::detectCores() 
                       ){

  fs::dir_create(workdir)
  meta <- readr::read_csv(registry, col_types = "ccTcc")
  if(!is.na(dpID))
    meta <- meta[meta$product == dpID, ]
  
  ## What do you do if name maps to two different content files?  We don't want to stack both!
  ## Grab the more recent one and throw a warning?
  ## Meanwhile, let's throw a cold stop
  if(length(unique(meta$name)) != length(unique(meta$id)))
    stop("Found conflicting versions of the same file, please consult the registry")
  
  for(i in seq_along(meta[[1]])){
    fs::link_create(contentid::retrieve(meta[i,"id"], dir = dir), fs::path(workdir, meta[i, "name"]))
  }
  
  
  ## Now lets stack all this many many zips into csvs
  ## Note: stackByTable's messages ain't suppressable
  suppressMessages({
  neonUtilities::stackByTable(workdir, dpID = dpID, nCores = nCores)
  })

    
  ## Now let's also store the stacked CSVs -- filter these for the dpID
  stacked_csvs <- fs::dir_ls(fs::path(workdir, "stackedFiles"))
  
  ## Careful, avoid double-zipping?
  lapply(stacked_csvs, R.utils::gzip)
  csv_gz <- paste0(stacked_csvs, ".gz")
  csv_ids <- vapply(csv_gz, contentid::store, character(1L), dir = dir)

  entry <- data.frame(id = unname(csv_ids), name = path_file(csv_gz),  
                      date = Sys.time(), product = dpID, type = "stacked_csv",
                      stringsAsFactors = FALSE)
  
  readr::write_csv(entry, registry, append=TRUE)
  
  fs::dir_delete(workdir)

  entry
}

#' importFrom rappdirs user_data_dir
neon_default_registry <- function(){
  Sys.getenv("NEON_REGISTRY", 
             fs::path_abs("registry.csv", 
                          start = rappdirs::user_data_dir("neon")))
}

#' neon registry
#' 
#' @param path specify a directory for the registry, or use the default
#' @return Will create an empty cv file at the registry if no exists
#' @export
#' @importFrom fs file_exists dir_create path_dir
neon_registry <- function(path = neon_default_registry()){
  if(!fs::file_exists(path) ){
    dir <- fs::path_dir(path)
    fs::dir_create(dir)
    df <- data.frame(id = NA, name = NA, date = NA, product = NA, type = NA,
                     stringsAsFactors = FALSE)
    readr::write_csv( df[0,], path)
  }
  invisible(path)
    
}

#br_count <- contentid::retrieve(
# "hash://sha256/3544e9345cc9ff9e235ff49e2d446dfea1ce5fb2be2c82c66f4e58516bf8a3bd")

#stacked_products(dpID) <- function(){
#  neon_registry() %>% 
#      dplyr::filter(product == paste0("stacked-", dpID)) %>% 
#      dplyr::select(id, name) %>% 
#      dplyr::distinct()
#  
#  ## if name isn't unique, could re-join hash against original table to get dates?
#}
