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
#' The API provides access to a `.zip` file containing all the component objects
#' (e.g. tables) for that product at that site and sampling month. Additionally,
#' the API allows users to request component files directly (e.g. as `.csv` 
#' files).  Requesting component files directly avoids the additional overhead 
#' of downloading other components that are not needed.  Both the `.zip` and 
#' relevant `.csv` and `zip` files in products that have expanded will include
#' both a `"basic"` and `"expanded"` name in the filename.  Setting `type`
#' argument of `neon_download()` to the preferred one will make it filter out
#' the other one.
#' 
#' By default, `neon_download()` will request the `.zip` packet for the product,
#' matching the requested type.  `neon_download()` will extract the component 
#' files into the store, removing the `.zip` file.  Specific files within a
#' product can be identified by altering the `file_regex` argument
#' (see examples).  
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
#' (see [rappdirs::user_data_dir]).  This default also be configured by
#' setting the environmental variable `NEONSTORE_HOME`, see [Sys.setenv] or
#' [Renviron].
#' @param api the URL to the NEON API, leave as default.
#' @param .token an authentication token from NEON. A token is not
#' required but will allow access to a higher number of requests before
#' rate limiting applies, see 
#' <https://data.neonscience.org/data-api/rate-limiting/#api-tokens>.
#' Note that once files are downloaded once, `neonstore` provides persistent
#' access to them without further interaction required with the API.
#'
#' @export
#' @importFrom curl curl_download
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
                           file_regex =  "[.]zip",
                           quiet = FALSE,
                           verify = TRUE,
                           dir = neon_dir(), 
                           unzip = TRUE,
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
                          file_regex =  "[.]zip",
                          quiet = FALSE,
                          verify = TRUE,
                          dir = neon_dir(), 
                          unzip = TRUE,
                          api = "https://data.neonscience.org/api/v0",
                          .token =  Sys.getenv("NEON_TOKEN")){
  
  ## make sure destination exists
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  
  ## Query the API for a list of all files associated with this data product.
  files <- neon_data(product = product, 
                     start_date = start_date, 
                     end_date = end_date, 
                     site = site,  
                     api = api, 
                     .token = .token)
  
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
  
  ## Time to download, verify, and unzip
  download_all(files$url, files$path, quiet)
  
  algo <- hash_type(files)
  verify_hash(files$path, files[algo], verify, algo)
  
  if(unzip) 
    unzip_all(files$path, dir, keep_zips = TRUE, quiet = quiet)

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
  files$path <- neon_subdir(files$name, dir = dir)
  
  
  files
}


## Generate subdir paths and ensure they exist
neon_subdir <- function(path, dir){
  df <- neon_filename_parser(basename(path))
  product <- paste_na(df$DPL, df$PRNUM, df$REV)
  dirs <- file.path(dir, paste(product, df$SITE, df$YYYY_MM, sep = "/"))
  lapply(unique(dirs), dir.create, FALSE, TRUE)
  paste(dirs, path, sep="/")
}





hash_type <- function(df){
  type <- "md5"
  if(is.null(df[[type]]) | any(is.na(df[[type]]))){
    type <- "crc32"
  }
  type
}


download_all <- function(addr, dest, quiet){
  
  pb <- progress::progress_bar$new(
    format = "  downloading [:bar] :percent in :elapsed, eta: :eta",
    total = length(addr), 
    clear = FALSE, width= 80)
  
  for(i in seq_along(addr)){
    if(!quiet) pb$tick()
    tryCatch( ## treat errors as warnings
      curl::curl_download(addr[i], dest[i]),
      error = function(e) 
        warning(paste(e$message, "on", addr[i]),
                call. = FALSE),
      finally = NULL
    )
  }  
}

unzip_all <- function(path, dir, keep_zips = TRUE, quiet = FALSE){
  
  zips <- path[grepl("[.]zip", path)]
  
  pb <- progress::progress_bar$new(
    format = "  unzipping [:bar] :percent in :elapsed, eta: :eta",
    total = length(zips), 
    clear = FALSE, width= 80)
  
  lapply(zips, function(x){
    if(!quiet) pb$tick()
    zip::unzip(x, exdir = dirname(x))
    })
  if(!keep_zips) {
    unlink(zips)
  }
  path <- list.files(path = dir, full.names = TRUE, recursive = TRUE)
  filename <- path[grepl("[.]gz", path)]
  if(length(filename) > 0){
    destname <- tools::file_path_sans_ext(filename)
    mapply(R.utils::gunzip, filename, destname, remove = TRUE)
  }
  
}

#' @importFrom digest digest
#' @importFrom openssl md5
verify_hash <- function(path, hash, verify, algo = "md5"){
  if(any(is.na(hash))){
    return(NULL)
  }
  
  
  hashfn <- switch(algo,
                   md5 = function(x) as.character(openssl::md5(file(x))),
                   crc32 =  function(x) digest::digest(x, "crc32", file=TRUE))
  
  if(verify){
    md5 <- vapply(path, hashfn,
                  character(1L), USE.NAMES = FALSE)
    i <- which(md5 != hash)
    if(length(i) > 0) {
      warning(paste("Some downloaded files which", 
                    "did not match the expected hash:",
                    path[i]), call. = FALSE)
    }
  }
}





## helper method for filtering out duplicate tables
## NEON API loves returning metadata files with identical content but 
## different names associated with each site and sampling month.
take_first_match <- function(df, col){
  
  if(nrow(df) < 2) return(df)
  
  uid <- unique(df[[col]])
  na <- df[1,]
  na[1,] <- NA
  rownames(na) <- NULL
  out <- data.frame(uid, na)
  
  ## Should really figure out vectorized implementation here...
  ## but in any event download step will be far more rate-limiting.
  for(i in seq_along(uid)){
    match <- df[[col]] == uid[i]
    first <- which(match)[[1]]
    out[i,-1] <- df[first, ]
  }
  rownames(out) <- NULL
  out[,-1]
}


