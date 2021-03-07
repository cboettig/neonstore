na_bool_to_char <- function(df){
  if(is.null(df)) return(df)
  
  types <- vapply(df, function(x) class(x)[[1]], "")
  bool <- which(types %in% "logical")
  
  if(length(bool) == 0 ){
    return(df)
  }
  ## convert  
  for(i in bool){
    if(all(is.na(df[[i]])))
      df[i] <- as.character(df[[i]])
  }
  
  df
}

na_to_char <- function(x, char = ""){
  x <- as.character(x)
  x[is.na(x)] <- char
  x
}

## Whoa nelly, make this faster
paste_na <- function(..., sep = "."){
  do.call("paste", c(lapply(list(...), na_to_char), list(sep = sep)))
}



hash_type <- function(df){
  type <- "md5"
  if(is.null(df[[type]]) | any(is.na(df[[type]]))){
    type <- "crc32"
  }
  type
}



verify_hash <- function(path, hash, verify, algo = "md5"){
  if(any(is.na(hash)) | any(is.na(path))  ){
    return(NULL)
  }
  hashfn <- switch(algo, md5 = md5, crc32 =  crc32)
  if(verify){
    md5 <- vapply(path, hashfn,
                  character(1L), USE.NAMES = FALSE)
    i <- which(md5 != hash)
    if(length(i) > 0) {
      warning(paste(algo, "missmatch:\n",
                    paste(path[i], sep="\n"), "\n"), call. = FALSE)
    }
  }
}

md5 <- function(x) {
  requireNamespace("openssl", quietly = TRUE)
  con <- file(x, "rb")
  on.exit(close(con), add=TRUE)
  as.character(openssl::md5(con))
}

crc32 <- function(x) {
  requireNamespace("digest", quietly = TRUE)
  digest::digest(x, "crc32", file=TRUE)
}



unzip_all <- function(path, dir, keep_zips = TRUE, quiet = FALSE){
  
  zips <- path[grepl("[.]zip", path)]
  pb <- progress::progress_bar$new(
    format = "  unzipping [:bar] :percent in :elapsed, eta: :eta",
    total = length(zips), 
    clear = FALSE, width= 80)
  
  lapply(zips, function(x){
    if(!quiet) pb$tick()
    zip::unzip(x, exdir = neon_subdir(x), junkpaths = TRUE)
  })
  if(!keep_zips) {
    unlink(zips)
  }
  
}

gunzip_all <- function(filenames, dir, quiet = FALSE){
  
  gzips <- filenames[grepl("[.]gz", filenames)]
  
  pb <- progress::progress_bar$new(
    format = "  gunzipping gz's [:bar] :percent in :elapsed, eta: :eta",
    total = length(gzips), 
    clear = FALSE, width= 80)
  
  gunzip_ <- function(file, ...){
    if(!quiet) pb$tick()
    R.utils::gunzip(file, ...)
  }
  
  if(length(gzips) > 0){
    destname <- neon_subdir(tools::file_path_sans_ext(gzips), dir = dir)
    mapply(gunzip_, gzips, destname, remove = TRUE, overwrite = TRUE)
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





