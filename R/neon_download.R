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
#' @param product A NEON `productCode` or list of product codes, see examples.
#' @param start_date Download only files as recent as (`YYYY-MM-DD`). Leave
#' as `NA` to download up to the most recent available data.
#' @param end_date Download only files up to end_date (`YYYY-MM-DD`). Leave as 
#' `NA` to download all prior data.
#' @param site 4-letter site code(s) to filter on. Leave as `NA` to search all.
#' @param type Should we prefer the basic or expanded version of this product? 
#' Note that not all products have expanded formats.  
#' @param table Include only files matching this table name (or regex pattern). 
#' (optional).
#' @param quiet Should download progress be displayed?
#' @param verify Should downloaded files be compared against the MD5 hash
#' reported by the NEON API to verify integrity? (default `TRUE`)
#' @param unique Should we skip downloads of files we already have?  Note: file
#' comparisons are based on file hash, which will omit files that have identical 
#' content but different names. 
#' @param get_zip should we attempt to download .zip archive versions of files?
#' default `FALSE`, as zip archives are being deprecated from NEON API starting
#' in early 2021.
#' @param unzip should we extract .zip files? (default `TRUE`). Note: .zip
#' files are preserved in the store to avoid repeated downloads. Use of .zip
#' files in NEON API is now deprecated in favor of requesting individual files.
#' @param dir Location where files should be downloaded. By default will
#' use the appropriate applications directory for your system 
#' (see [tools::R_user_dir()]).  This default also be configured by
#' setting the environmental variable `NEONSTORE_HOME`, see [Sys.setenv] or
#' [Renviron].
#' @param release Select only data files associated with a particular release tag,
#' see <https://www.neonscience.org/data-samples/data-management/data-revisions-releases>,
#' e.g. "RELEASE-2021".  Releases are associated with a specific DOI and the promise that
#' files associated with a particular release will not change.
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
#'  ## Omit dir=tempfile() to use persistent storage
#'  neon_download("DP1.10003.001", 
#'                start_date = "2018-01-01", 
#'                end_date = "2019-01-01",
#'                site = "YELL",
#'                dir = tempfile())
#'                
#'  ## Advanced use: filter for a particular table in the product
#'  neon_download(product = "DP1.10003.001",
#'                start_date = "2018-01-01",
#'                end_date = "2019-01-01",
#'                site = "YELL",
#'                table = "countdata",
#'                dir = tempfile())
#' 
#' }
neon_download <- function(product, 
                          table =  NA,
                          site = NA,
                          start_date = NA,
                          end_date = NA,
                          type = "basic",
                          release = NA,
                          quiet = FALSE,
                          verify = TRUE,
                          unique = TRUE,
                          dir = neon_dir(),
                          get_zip = FALSE,
                          unzip = FALSE,
                          api = "https://data.neonscience.org/api/v0",
                          .token =  Sys.getenv("NEON_TOKEN")){

  x <- lapply(product, neon_download_,
              table = table,
              site = site,
              start_date = start_date,
              end_date = end_date,
              type = type,
              release = release,
              quiet = quiet,
              verify = verify,
              unique = unique,
              dir = dir, 
              get_zip = get_zip,
              unzip = unzip,
              api = api,
              .token =  .token)
  invisible(do.call(rbind, x))
      
}

neon_download_ <- function(product, 
                           table = NA,
                           site = NA,
                           start_date = NA,
                           end_date = NA,
                           type = "basic",
                           release = NA,
                           quiet = FALSE,
                           verify = TRUE,
                           unique = TRUE,
                           dir = neon_dir(),
                           get_zip = FALSE,
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

  
  ## confirm product has expanded type, if requested
  type <- type_check(product, type)
  
  ## additional filters on already_have, type and table.
  ## Will also update the release manifest
  files <- download_filters(files = files, 
                            table = table, 
                            type = type, 
                            get_zip = get_zip,
                            quiet = quiet, 
                            unique = unique,
                            dir = dir)
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

  
  if(!quiet && nrow(files) > 0) message("  updating release manifest...")
  update_release_manifest(x = files, dir = dir) 
    
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


# filter files out based on hashes we have already seen
already_have_hash <- function(files, quiet = FALSE, unique = TRUE, dir = neon_dir()){
  
  ## Opt out trigger.
  if(!unique) return(files)
  
  if(!quiet) message("  comparing hashes against local file index...")
  ## Faster to check if IDs are in LMDB then to construct neon_index, but that
  ## would not ensure files actually exist
  index <- neon_index(dir = dir)
  
  if(is.null(index)) return(files)
  ## Also drop name duplicates.  This is dodgy, as these could potentially
  ## have different content. Perhaps we should always overwrite instead.
  ## however, files with same name aren't necessarily newer.
  names <- gsub(".gz$", "", files$name)
  name_dups <- files$name %in% stats::na.omit(basename(index$path))
  
  md5_dups <- files$md5 %in% stats::na.omit(index$md5)
  crc32_dups <- files$crc32 %in% stats::na.omit(index$crc32)
  drop <-  md5_dups | crc32_dups | name_dups
  

  
  files <- files[!drop,]
  if(any(drop) && !quiet){
    message(paste("  omitting", 
                  sum(drop), 
                  "files previously downloaded"))
  }
  
  files
}

download_filters <- function(files,
                             table,
                             type,
                             get_zip,
                             quiet,
                             unique = TRUE,
                             dir = neon_dir()){
  
  if(is.null(files)) return(invisible(NULL)) # nothing to download
  if(nrow(files) == 0) return(invisible(NULL)) # nothing to download
    
  if(get_zip){
    files <- files[grepl("[.]zip", files$name), ]
  } else {
    files <- files[!grepl("[.]zip", files$name), ]
  }
  
  ## Filter for only files matching the file regex
  if(!is.na(table)){
    files <- files[grepl(table, files$name), ]
  }
  ## Filter to have only expanded or basic (not both)
  if(type == "expanded")
    files <- files[!grepl("basic", files$name), ]
  if(type == "basic")
    files <- files[!grepl("expanded", files$name), ]

  
  if(nrow(files) == 0) return(invisible(NULL)) # nothing to download
  
  ## Filter out duplicate files, e.g. have identical hash values
  ## (as reported by NEON's own hash)
  files <- take_first_match(files, hash_type(files))

  ## filter out hashes we already have locally
  files <- already_have_hash(files, quiet = quiet, unique = unique, dir = dir)
  
  
  
  ## create path column for dest
  ## NOTE: file$name not guaranteed to be unique.  
  files$path <- neon_subdir(files$name, dir = dir)
  
  
  files
}


## Generate subdir paths and ensure they exist
neon_subdir <- function(path, dir){
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
    paths <- paste(dirs, n, sep="/")
    paths
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
      warning(paste(e$message, "on", url, "\n",
      "Repeat your download request to resume!"),
              call. = FALSE),
    finally = NULL
  )
  
}



