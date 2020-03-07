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
#' @importFrom contenturi store retrieve
#' @importFrom fs dir_ls path_file path path_abs link_create
#' @examples \donttest{
#' neon_store("DP1.10003.001")
#'  }
#' 
#' 
neon_store <- function(dpID, site="all", startdate=NA, enddate=NA, package="basic",
                       avg="all", check.size=TRUE, savepath=NA, load=F, 
                       registry = neon_registry()) {

  
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
  ids <- vapply(zips, contenturi::store, character(1L))
  

  ## NOTE: if we re-download NEON data and a file has changed, it will not 
  ## overwrite the previous store record
  entry <- data.frame(id = unname(ids), 
                    name = fs::path_file(zips), 
                    date = Sys.time(),
                    product = dpID,
                    stringsAsFactors = FALSE,
                    row.names = FALSE)

  readr::write_csv(entry, registry, append=TRUE)
  
  registry
  
  ## Save this metadata registry too!
}


## Stack NEON data files into a combined data product
#' Stack zip files into combined tables using the local store
#' 
#' @param registry location to write the local neon data registry
#' @param workdir Location to use for temporary storage
#' @inheritParams neonUtilities::stackByTable
#' @return ids and names of stacked tables
#' @export
#' @examples \donntest{
#' neon_store("DP1.10003.001")
#' neon_stack("DP1.10003.001")
#' }
neon_stack <- function(dpID=NA, 
                       registry = neon_registry(),
                       workdir = tempdir(), 
                       nCores=parallel::detectCores() 
                       ){

  
  meta <- readr::read_csv(registry, col_types = "ccTc")
  if(!is.na(dpID))
    meta <- meta[meta$product == dpID, ]
  
  ## What do you do if name maps to two different content files?  We don't want to stack both!
  ## Grab the more recent one and throw a warning?
  
  ## Meanwhile, let's throw a cold stop
  if(length(unique(meta$name)) != length(unique(meta$id)))
    stop("Found conflicting versions of the same file, please consult the registry")
  
  
  ## Populate workdir with symlinks that point to the content expected by stackByTable
  walk2(meta$id, meta$name, function(x, y) 
    fs::link_create(contenturi::retrieve(x), fs::path(workdir, y)))
  
  
  ## Now lets stack all this many many zips into csvs
  ## Note: stackByTable's messages ain't suppressable
  neonUtilities::stackByTable(workdir, dpID = dpID, nCores = nCores)

  ## Now let's also store the stacked CSVs
  stacked_csvs <- fs::dir_ls(fs::path(workdir, "stackedFiles"))
  csv_ids <- map_chr(stacked_csvs, contenturi::store)

  entry <- data.frame(id = unname(csv_ids), name = path_file(stacked_csvs),  
                      date = Sys.time(), product = paste0("stacked-", dpID),
                      stringsAsFactors = FALSE)
  
  readr::write_csv(entry, registry, append=TRUE)

  entry
}


neon_registry_default <- function(){
  Sys.getenv("NEON_REGISTRY", 
             fs::path_abs("registry.csv", 
                          start = rappdirs::user_data_dir("neon")))
}

#' neon registry
#' 
#' @param path specify a path for the registry, or use the default
#' @return Will create an empty cv file at the registry if no exists
#' @export
#' @importFrom fs file_exists dir_create path_dir
neon_registry <- function(path = neon_registry_default()){
  if(!fs::file_exists(path) ){
    fs::dir_create(fs::path_dir(path))
    df <- data.frame(id = NA, name = NA, date = NA, product = NA,
                     stringsAsFactors = FALSE)
    readr::write_csv( df[0,], path)
  }
  invisible(path)
    
}

#br_count <- contenturi::retrieve(
# "hash://sha256/3544e9345cc9ff9e235ff49e2d446dfea1ce5fb2be2c82c66f4e58516bf8a3bd")


