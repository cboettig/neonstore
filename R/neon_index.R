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
#' @param ext only match files with this file extension(s)
#' @param timestamp only match timestamps prior this. See details in [neon_index()].
#'        Should be a datetime POSIXct object (or coerce-able string)
#' @param hash name of a hashing algorithm to check file integrity. Can be
#'  `"md5"`, `"sha1"`, or `"sha256"` currently; or set to [NULL] (default)
#'   to skip hash computation.
#' @inheritParams neon_download
#' @param deprecated Should the index include files that have since been deprecated by
#' more recent downloads?  logical, default [TRUE]. 
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
                       release = NA,
                       hash = NULL,
                       dir = neon_dir(),
                       deprecated = TRUE){
  
  files <- list.files(dir, recursive = TRUE, full.names = TRUE)
  
 
  
  ## Turn file names into a metadata table
  meta <- filename_parser(files)

  ## Paths should not have NAs
  meta <- meta[!is.na(meta$path),]
  
  
  if(is.null(meta)) return(NULL)
  
  ## Add release information
  meta <- add_release(meta, dir = dir)

  ## Apply filters
  meta <- meta_filter(meta, 
                      product = product,
                      table = table, 
                      site = site, 
                      start_date = start_date,
                      end_date = end_date,
                      type = type,
                      timestamp = timestamp,
                      ext = ext,
                      release = release)
  
  ## Compute hashes, if requested
  meta$hash <- file_hash(meta$path, hash = hash)
  
  if(!deprecated){
    meta <- filter_deprecated(meta)
  }
  
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
                        ext = NA,
                        release = NA){
  
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
    month <- year_month(meta$month)
    keep <- month >= start_date
    ## don't filter out tables without a month:
    keep[is.na(keep)] <- TRUE
    meta <- meta[keep, ]
  }
  
  if(!is.na(end_date)){
    end_date <- as.Date(end_date)
    month <- year_month(meta$month)
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
  
  if(any(is.na(meta$path))){
    meta <- meta[!is.na(meta$path), ]
  }
  
  if(!is.na(release)){
    meta <- meta[meta$release %in% release,]
  }
  
  tibble::as_tibble(meta)
  
}

year_month <- function(x){
  
  ym <- function(x){
    if(is.na(x)) return(as.Date(NA))
    as.Date(paste0(x, "-01"))
  }
  vapply(x, ym, as.Date("2020-01-01"))
  
}


na_omit <- function(x) x[!is.na(x)]




filename_parser <- function(files){
  
  
  df <- neon_filename_parser(files)
  
  if(nrow(df) == 0) return(NULL)
  
  ## We may want more columns than this than this.  
  out <- df[c("SITE", "DESC", "PKGTYPE", "EXT","YYYY_MM",  "GENTIME", 
              "HOR", "VER", "TMI", "DATE_RANGE", "name")]
  out$product <- paste_na(df$DPL, df$PRNUM, df$REV)
  
  ## append 'type' to table name
  i <- !is.na(out$PKGTYPE)
  out$DESC[i] <- paste_na(out$DESC[i], out$PKGTYPE[i], sep = "-")
  
  ## Apply names used originally -- FIXME maybe stick with NEON terms?
  names(out) <- c("site", "table", "type", "ext", "month", "timestamp", 
                  "horizontalPosition", "verticalPosition", "samplingInterval",
                  "date_range", "path", "product")
  
  ## re-order
  out <- out[, c("product", "site", "table", "type",
                 "ext", "month", "timestamp",
                 "horizontalPosition", "verticalPosition", "samplingInterval",
                 "date_range", "path")]
  
  ## cast timestamp as POSIXct
  out$timestamp <- as.POSIXct(out$timestamp, format = "%Y%m%dT%H%M%OS")
  
  ## enforce types on possibly-missing columns
  out$horizontalPosition <- as.numeric(out$horizontalPosition)
  out$verticalPosition <- as.numeric(out$verticalPosition)
  out$samplingInterval <- as.character(out$samplingInterval)
  out$site <- as.character(out$site)
  out$table <- as.character(out$table)
  out$type <- as.character(out$type)
  out$month <- as.character(out$month)
  
  out
}


# openssl md5 sha1 sha256
file_hash <- function(x, hash = "md5"){
  
  
  if(is.null(hash)) return(NULL)
  if(length(x) == 0)  return(NULL)
  requireNamespace("openssl", quietly = TRUE)
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
                          function(y) {
                            con <- file(y, "rb")
                            on.exit(close(con), add = TRUE)
                            as.character(hash_fn(con))
                          },
                          character(1L)))
  
  hashes
  
}




## Sometimes a NEON file will have changed
flag_deprecated <- function(meta){
  ## Sort by most recent timestamp
  meta <- meta[order(meta$timestamp, decreasing = TRUE),] 
  ## base-R de-duplicate on key-columns.  always takes first match (most recent)
  key_cols <- c("product", "site", "month", "table", "type", 
                "verticalPosition", "horizontalPosition", "date_range")
  deprecated <- duplicated(meta[key_cols])
  meta$deprecated <- deprecated
  meta
}
filter_deprecated <- function(meta){
  meta <- flag_deprecated(meta)
  ## We don't care if metadata is updated, since those are not stacking data.
  ## We might care if a data file has actually been changed 
  changed_data <- meta$deprecated & !is.na(meta$month)
  if(any(changed_data)){
    message(paste0("  Some raw data files have changed.\n",
                   "  Using only most updated file to avoid duplicates.\n",
                   "  see ?neonstore::show_deprecated_data() for details."))
  }
  out <- meta[!meta$deprecated,]
  out$deprecated <- NULL # drop flag after filtering
  out
}
