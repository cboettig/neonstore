#' Show information about all files downloaded to the local store
#' 
#' 
#' NEON products consist of several individual components, which are in turn
#' broken up by site and sampling month. By storing these individual files,
#' neonstore enables more reproducible workflows that can be traced back to
#' original, unaltered input data.  These atomized files can be quickly and easily
#' combined into unified tables, see [neon_read].
#' 
#' File names include metadata such as the file productCode,
#' table name, site, and sampling month, as well as timestamp of creation.
#' `neon_index()` parses this metadata from the file name string and returns
#' the information in a convenient table, along with a path to each file.
#' 
#' **Regarding timestamps:**  NEON will occasionally publish new versions of
#' previously-released raw data files (which may or may not actually differ).
#' The NEON download API, and hence [neon_download()], only serve the most recent
#' of such files, but earlier versions may still exist in your local `neonstore`
#' if you downloaded them before the updated files were released.  By default,
#' [neon_read()] will always select the most recent of such files, thus avoiding
#' duplication and providing the most updated data.  For reproducibility however,
#' it may be necessary to access older version instead. Setting the timestamp 
#' argument allows the user to filter out newer files and select the original
#' ones instead.  Unfortunately, at this time users cannot request the outdated
#' data files from NEON API.  For strict reproducibility, users should also
#' archive their local store.
#' 
#' @seealso  [neon_download()]
#' 
#' @param product Include only files matching this NEON productCode(s)
#' @param table Include only files matching this table name (or regex pattern). 
#' (optional).
#' @param ext only match files with this file extension(s)
#' @param timestamp only match timestamps prior this. See details in [neon_index()].
#'        Should be a datetime POSIXct object (or coerce-able string)
#' @param hash name of a hashing algorithm to check file integrity. Can be
#'  `"md5"`, `"sha1"`, or `"sha256"` currently; or set to [NULL] (default)
#'   to skip hash computation.
#' @inheritParams neon_download
#' 
#' @export
#' @examples
#' 
#' \dontshow{
#' # Hide setting tempfile, since a user would specify a persistent location
#'  Sys.setenv("NEONSTORE_HOME"=tempfile())
#' }
#' 
#' neon_index()
#' 
#' ## Just bird survey product
#' neon_index("DP1.10003.001")
#' 
#' \dontshow{
#' # tidy
#'  Sys.unsetenv("NEONSTORE_HOME")
#' }
#' 
neon_index <- function(product = NA, 
                       table = NA, 
                       site = NA,
                       start_date = NA,
                       end_date = NA,
                       type = NA,
                       ext = NA,
                       timestamp = NA,
                       hash = NULL,
                       dir = neon_dir()){
  
  files <- list.files(dir)
  
  ## Turn file names into a metadata table
  meta <- filename_parser(files)
  if(is.null(meta)) return(NULL)
  
  ## Include full paths to files
  meta$path <- file.path(dir, meta$path)
  meta$timestamp <-  as.POSIXct(meta$timestamp, format = "%Y%m%dT%H%M%OS")
  
  ## Apply filters
  meta <- meta_filter(meta, 
                      product = product,
                      table = table, 
                      site = site, 
                      start_date = start_date,
                      end_date = end_date,
                      type = type,
                      timestamp = timestamp,
                      ext = ext)
  
  ## Compute hashes, if requested
  meta$hash <- file_hash(meta$path, hash = hash)
  
  tibble::as_tibble(meta)
}

meta_filter <- function(meta,
                        product = NA, 
                        table = NA, 
                        site = NA, 
                        start_date = NA, 
                        end_date = NA, 
                        type = NA,
                        timestamp = NA,
                        ext = NA){
  
  ## Arguably, filtering could be done on file names
  ## rather than table of parsed file names?
  if(!is.na(table)){
      meta <- meta[grepl(table, meta$table), ]
  }
  
  if(!all(is.na(product))){
      meta <- meta[meta$product %in% product, ]
  }
  
  if(!all(is.na(site))){
    meta <- meta[meta$site %in% site, ]
  }
  
  if(!is.na(start_date)){
    start_date <- as.Date(start_date)
    month <- as.Date(meta$month, "%Y-%M")  
    keep <- month >= start_date
    ## don't filter out tables without a month:
    keep[is.na(keep)] <- TRUE
    meta <- meta[keep, ]
  }
  
  if(!is.na(end_date)){
    end_date <- as.Date(end_date)
    month <- as.Date(meta$month, "%Y-%M")  
    keep <- month <= end_date
    ## don't filter out tables without a month:
    keep[is.na(keep)] <- TRUE
    meta <- meta[keep, ]
  }
  
  if(!is.na(timestamp)){
    meta <- meta[meta$timestamp < as.POSIXct(timestamp),]
  }
  
  if(!is.na(type)){
    meta <- switch(type,
      "basic" = meta[meta$type != "expanded",],
      "expanded" = meta[meta$type != "basic", ],
      meta)
  }
  
  if(!all(is.na(ext))){
    meta <- meta[meta$ext %in% ext, ]
  }
  
  tibble::as_tibble(meta)
  
}

na_to_char <- function(x, char = ""){
  x <- as.character(x)
  x[is.na(x)] <- char
  x
}
paste_na <- function(..., sep = "."){
  do.call("paste", c(lapply(list(...), na_to_char), list(sep = sep)))
}


filename_parser <- function(files){
  
  
  df <- neon_filename_parser(files)
  
  if(nrow(df) == 0) return(NULL)
  
  ## We may want more columns than this than this.  
  out <- df[c("SITE", "DESC", "PKGTYPE", "EXT","YYYY_MM",  "GENTIME", "name")]
  out$product <- paste_na(df$DPL, df$PRNUM, df$REV)
  
  ## append type, historical but maybe dumb?
  out$DESC <- paste_na(out$DESC, out$PKGTYPE, sep = "-")
  
  ## Apply names used originally -- FIXME maybe stick with NEON terms?
  names(out) <- c("site", "table", "type", "ext",
                  "month", "timestamp", "path", "product")
  
  ## re-order
  out <- out[, c("product", "site", "table", "type",
                 "ext", "month", "timestamp", "path")]
  
  out
}


#' @importFrom openssl md5 sha1 sha256
file_hash <- function(x, hash = "md5"){
  
  
  if(is.null(hash)) return(NULL)
  if(length(x) == 0)  return(NULL)
  
  hash_fn <- switch(hash, 
                    "md5" = openssl::md5,
                    "sha1" = openssl::sha1,
                    "sha256" = openssl::sha256,
                    NULL)
  
  if(is.null(hash_fn)) {
    warning(paste("No function for", hash, 
                  "found", call. = FALSE))
    return(NULL)
  }
  
  ## httr imports openssl already
  hashes <- paste0("hash://", hash, "/",
                   vapply(x, 
                          function(y) as.character(hash_fn(file(y))),
                          character(1L)))
  
  hashes
  
}
