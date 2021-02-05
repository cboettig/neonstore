# Tools for managing NEON release data


release_manifest <- function(dir){
  file.path(dir, "release_manifest.csv")
}

read_release_manifest <- function(dir = neon_dir()){
  current <- data.frame("name" = character(),
                        "md5" = character(),
                        "crc32"=character(),
                        "size"=integer(),
                        "release" = character())
  
  manifest <- release_manifest(dir)
  # load current manifest, if it exists
  if(file.exists(manifest)){
    current <- utils::read.csv(manifest, colClasses = 
                                 c("character", "character",
                                   "character", "integer", "character"))
    #current <- vroom::vroom(manifest, col_types = "cccic")
  }
  current
}

update_release_manifest <- function(x, dir = neon_dir()){
  
  x <- x[c("name", "md5", "crc32", "size", "release")]
  x$md5 <- as.character(x$md5)
  x$crc32 <- as.character(x$crc32)
  
  # path to manifest
  current <- read_release_manifest(dir)
  # combine rows and determine distinct.
  updated <- merge(x, current, by = names(current), all = TRUE)
  
  
  # ensure dir exists for writing
  if(!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }
  manifest <- release_manifest(dir)
  utils::write.csv(updated, manifest, row.names = FALSE)
  invisible(updated)
}



