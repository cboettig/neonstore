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
#' @param product Include only files matching this NEON productCode(s)
#' @param table Include only files matching this table name (or regex pattern). 
#' (optional).
#' @param ext only match files with this file extension(s)
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
                       ext = NA,
                       hash = NULL,
                       dir = neon_dir()){
  
  files <- list.files(dir)
  
  ## Turn file names into a metadata table
  meta <- filename_parser(files)
  if(is.null(meta)) return(NULL)
  
  ## Include full paths to files
  meta$path <- file.path(dir, meta$path)
  
  ## Apply filters
  meta <- meta_filter(meta, product, table, site, start_date, end_date, ext)
  
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
  
  
  if(!is.na(start_date) | is.na(end_date)){
    start_date <- as.Date(start_date)
    end_date <- as.Date(end_date)
    month <- as.Date(meta$month, "%Y-%M")   
  }
  
  if(!is.na(start_date)){
    ## don't filter out tables without a month:
    keep <- month > start_date
    keep[is.na(keep)] <- TRUE
    meta <- meta[keep, ]
  }
  
  if(!is.na(end_date)){
    month <- as.Date(meta$month, "%Y-%M")
    ## don't filter out tables without a month:
    keep <- month < end_date
    keep[is.na(keep)] <- TRUE
    meta <- meta[keep, ]
    meta <- meta[month < end_date, ]
  }
  
  if(!all(is.na(ext))){
    meta <- meta[meta$ext %in% ext, ]
  }
  
  meta
  
}


filename_parser <- function(files){
  ## Parse metadata from NEON file names
  parsed <- gsub(neon_regex(),
                 "\\2%\\3%\\5-\\7%\\6%\\7%\\8%\\9%\\4%",
                 files)
  meta <- strsplit(parsed, "%", fixed = TRUE)
  into <- c("site", "product", "table", "month",
            "type", "timestamp", "ext", "misc")
  
  ## Confirm parsing was successful
  parts <- vapply(meta, length, integer(1L))
  meta <- meta[parts == length(into)]
  
  ## Drop unparse-able file names
  filenames <- files[parts == length(into)]
  dropped <- files[parts != length(into)]
  
  ## Format as tidy data.frame
  meta_b <- jsonlite::fromJSON(jsonlite::toJSON(meta))
  if(length(meta_b) == 0) return(NULL)
  colnames(meta_b) <- into
  meta_c <- as.data.frame(meta_b, stringsAsFactors = FALSE)
  
  ##drop trailing - on table name created by gsub w blank type
  meta_c$table[meta_c$type == ""] <- 
    gsub("-$", "", meta_c$table[meta_c$type == ""])
  
  meta_c$path <- filenames
  meta_c
}


neon_regex <- function(){
  site <- "(NEON\\.D\\d\\d\\.(\\w{4}))\\."                   # \\1 + \\2
  productCode <- "(DP\\d\\.\\d{5}\\.\\d{3})\\."              # \\3
  misc <- "(:?\\d{3}\\.\\d*\\.*\\d*\\.*)?"                 #   \\4
  name <- "(:?\\w+)?\\.?"                                    # \\5 
  month <- "(:?\\d{4}-\\d{2})?\\.?"                          # \\6
  type <- "(:?basic|expanded)?\\.?"                          # \\7
  timestamp <- "(:?\\d{8}T\\d{6}Z)?\\.?"                     # \\8
  ext <- "(\\w+$)"                                           # \\9
  regex <- paste0(site, productCode, misc, name, month, type, timestamp, ext)
  regex
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
