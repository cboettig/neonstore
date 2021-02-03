#' Download NEON data products into a local store
#'
#'
#' 
#' @details Each NEON data product consists of a collection of 
#' objects (e.g. tables), which are in turn broken into individual files by 
#' site and sampling month.  Additionally, many NEON products have been 
#' expanded, including some additional columns. Consequently, users must
#' specify if they want the "basic" or "expanded" version of this data. 
#' 
#' In the products table (see [neon_products]), the `productHasExpanded` 
#' column indicates if the data
#' product has expanded, and the columns `productHasBasicDescription` and
#' `productHasExpandedDescription` provide a detailed explanation of the
#' differences between the `"expanded"` and `"basic"` versions of that
#' particular product.
#' 

#' The API allows users to request component files directly.
#' By default, `neon-download()` will download all available
#' extensions.  Users can request only products of a certain format 
#' (e.g. `.csv` or `.h5`) by altering the `file_regex` argument
#' (see examples).  
#'
#' Prior to 2021, the API provided
#' access to a `.zip` file containing all the component objects
#' (e.g. tables) for that product at that site and sampling month. 
#' 
#' 
#' `neon_download()` will avoid downloading metadata files which are bitwise
#' identical to other files in the same download request, as indicated by the
#' crc32 hash reported by the API.  These typically include metadata that are
#' shared across the product as a whole, but are for some reason included in 
#' each sampling month for each site -- potentially thousands of duplicates.
#' These duplicates are also packaged within the `.zip` downloads where it
#' is not possible to exclude them from the download. 
#' 
#' @param product A NEON `productCode`. See [neon_download].
#' @param start_date Download only files as recent as (`YYYY-MM-DD`). Leave
#' as `NA` to download up to the most recent available data.
#' @param end_date Download only files up to end_date (`YYYY-MM-DD`). Leave as 
#' `NA` to download all prior data.
#' @param site 4-letter site code(s) to filter on. Leave as `NA` to search all.
#' @param type Should we prefer the basic or expanded version of this product? 
#' See details. 
#' @param file_regex Download only files matching this pattern.  See details.
#' @param quiet Should download progress be displayed?
#' @param verify Should downloaded files be compared against the MD5 hash
#' reported by the NEON API to verify integrity? (default `TRUE`)
#' @param unzip should we extract .zip files? (default `TRUE`). Note: .zip
#' files are preserved in the store to avoid repeated downloads. 
#' @param dir Location where files should be downloaded. By default will
#' use the appropriate applications directory for your system 
#' (see [tools::R_user_dir()]).  This default also be configured by
#' setting the environmental variable `NEONSTORE_HOME`, see [Sys.setenv] or
#' [Renviron].
#' @param release Download only data files associated with a particular release tag,
#' see <https://www.neonscience.org/data-samples/data-management/data-revisions-releases>.
#' @param api the URL to the NEON API, leave as default.
#' @param .token an authentication token from NEON. A token is not
#' required but will allow access to a higher number of requests before
#' rate limiting applies, see 
#' <https://data.neonscience.org/data-api/rate-limiting/#api-tokens>.
#' Note that once files are downloaded once, `neonstore` provides persistent
#' access to them without further interaction required with the API.
#'
#' @export
#' @importFrom R.utils gunzip
#' @importFrom tools file_path_sans_ext
#' @examples 
#' \donttest{
#'  
#'  neon_download("DP1.10003.001", 
#'                start_date = "2018-01-01", 
#'                end_date = "2019-01-01",
#'                site = "YELL")
#'                
#'  ## Advanced use: filter for a particular table in the product
#'  neon_download(product = "DP1.10003.001",
#'                start_date = "2018-01-01",
#'                end_date = "2019-01-01",
#'                site = "YELL",
#'                file_regex = ".*brd_countdata.*\\.csv")
#' 
#' }
neon_download <- function(product, 
                           start_date = NA,
                           end_date = NA,
                           site = NA,
                           type = "expanded",
                           file_regex =  ".",
                           quiet = FALSE,
                           verify = TRUE,
                           dir = neon_dir(),
                           release = NA,
                           unzip = FALSE,
                           api = "https://data.neonscience.org/api/v0",
                           .token =  Sys.getenv("NEON_TOKEN")){
  
  x <- lapply(product, neon_download_, 
              start_date = start_date,
              end_date = end_date,
              site = site,
              type = type,
              file_regex =  file_regex,
              quiet = quiet,
              verify = verify,
              dir = dir, 
              unzip = unzip,
              api = api,
              .token =  .token)
  invisible(do.call(rbind, x))
      
}

neon_download_ <- function(product, 
                          start_date = NA,
                          end_date = NA,
                          site = NA,
                          type = "expanded",
                          file_regex =  ".",
                          release = NA,
                          quiet = FALSE,
                          verify = TRUE,
                          dir = neon_dir(), 
                          unzip = FALSE,
                          api = "https://data.neonscience.org/api/v0",
                          .token =  Sys.getenv("NEON_TOKEN")){
  
  ## make sure destination exists
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  
  ## Query the API for a list of all files associated with this data product.
  files <- neon_data(product = product, 
                     start_date = start_date,
                     end_date = end_date,
                     site = site,
                     type = type,
                     release = release,
                     api = api,
                     .token = .token)
  
  
  
  ## Update release manifest
  ## Run before filters? slower but will ensure manifest of existing files
  update_release_manifest(x = files, dir = dir)
  
  
  ## confirm product has expanded type, if requested
  type <- type_check(product, type)
  
  ## additional filters on already_have, type and file_regex:
  files <- download_filters(files, file_regex, type, quiet, dir)
  if(is.null(files)){
    return(invisible(NULL)) # nothing to download
  }
  if(length(files) == 0) {
    return(invisible(NULL)) # nothing to download
  }
  
  # hash algo used (md5 or crc32)
  algo <- hash_type(files)
  
  ## Time to download, verify, and unzip
  ## NOTE: file$path destination is not guaranteed to be unique!
  download_all(files$url, 
               files$path,
               hash = files[[algo]],
               algo = algo,
               verify = verify,
               quiet = quiet)
  
  if(unzip) 
    unzip_all(files$path, dir, keep_zips = TRUE, quiet = quiet)

  ## Always gunzip (e.g., .h5.gz files)
  gzips <- list.files(path = dir, full.names = TRUE, recursive = TRUE)
  gunzip_all(gzips, dir = dir, quiet = quiet)
  
  ## file metadata (url, path, md5sum)  
  invisible(files)
}

type_check <- function(product, type){
  if(type == "basic"){
    return("basic")
  }
  
  p <- neon_products()
  x <- p[p$productCode %in% product,]
  if(!x$productHasExpanded){
    message("product has no expanded format, using basic")
    return("basic")
  }
  "expanded"
}


download_filters <- function(files, file_regex, 
                             type, quiet, dir){
  
  if(is.null(files)) return(invisible(NULL)) # nothing to download
  if(nrow(files) == 0) return(invisible(NULL)) # nothing to download
  
  ## Omit those file names we already have
  already_have <- files$name %in% basename(list.files(dir, recursive = TRUE))
  if(sum(already_have) > 0 && !quiet){
    message(paste("  omitting", 
                  sum(already_have), 
                  "files previously downloaded"))
  }
  files <- files[!already_have, ]
  
  ## Filter for only files matching the file regex
  files <- files[grepl(file_regex, files$name), ]
  
  ## Filter to have only expanded or basic (not both)
  if(type == "expanded")
    files <- files[!grepl("basic", files$name), ]
  if(type == "basic")
    files <- files[!grepl("expanded", files$name), ]

  
  if(nrow(files) == 0) return(invisible(NULL)) # nothing to download
  
  ## Filter out duplicate files, e.g. have identical hash values
  ## (as reported by NEON's own hash)
  files <- take_first_match(files, hash_type(files))

  ## create path column for dest
  ## NOTE: file$name not guaranteed to be unique.  
  files$path <- neon_subdir(files$name, dir = dir)
  
  
  files
}


## Generate subdir paths and ensure they exist
neon_subdir <- function(path, dir){
    vapply(path, function(path){
    n <- basename(path)
    df <- neon_filename_parser(n)
    if(nrow(df) == 0){ # not parsable string
      return(file.path(dir, n))
    }
    product <- paste_na(df$DPL, df$PRNUM, df$REV)
    dirs <- file.path(dir, paste(product, 
                                 na_to_char(df$SITE), 
                                 na_to_char(df$YYYY_MM), sep = "/"))
    
    
    lapply(unique(dirs), dir.create, FALSE, TRUE)
    dirs <- normalizePath(dirs) # path must exist for this to work...
    paste(dirs, n, sep="/")
    }, character(1L), USE.NAMES = FALSE)
}

download_all <- function(addr, 
                         dest, 
                         hash = character(length(dest)),
                         algo = "md5",
                         verify = TRUE,
                         quiet = FALSE){
  # recycle algo choice if length 1
  if(length(algo) == 1) algo <- rep(algo, length(dest))
  
  pb <- progress::progress_bar$new(
    format = "  downloading [:bar] :percent in :elapsed, eta: :eta",
    total = length(addr), 
    clear = FALSE, width= 80)
  
  for(i in seq_along(addr)){
    if(!quiet) pb$tick()
    safe_download(addr[i], dest[i], hash = hash[i], 
                  algo = algo[i], verify = verify)
  }  
}

safe_download <- function(url, dest, hash = NULL, algo = "md5", verify = TRUE){
  requireNamespace("curl", quietly = FALSE)
  tryCatch({ ## treat errors as warnings
    curl::curl_download(url, dest)
    verify_hash(dest, hash, verify, algo)
    },
    error = function(e) 
      warning(paste(e$message, "on", url),
              call. = FALSE),
    finally = NULL
  )
  
}



update_release_manifest <- function(x, dir = neon_dir()){
  
  current <- data.frame("name" = character(),
                        "md5" = character(),
                        "crc32"=character(),
                        "size"=integer(),
                        "release" = character())
  x <- x[names(current)]
  x$md5 <- as.character(x$md5)
  x$crc32 <- as.character(x$crc32)
  
  # path to manifest
  manifest <- file.path(dir, "release_manifest.csv")
  if(!dir.exists(dir)) dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  
  # load current manifest, if it exists
  if(file.exists(manifest))
    current <- read.csv(manifest, colClasses = 
      c("character", "character", "character", "integer", "character"))
    #current <- vroom::vroom(manifest, col_types = "cccic")
  
  # combine rows and determine distinct.
  updated <- merge(x, current, by = names(current), all = TRUE)
  
  write.csv(updated, manifest, row.names = FALSE)
  invisible(updated)
}



