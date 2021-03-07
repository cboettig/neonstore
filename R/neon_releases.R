
update_release_manifest <- function(x, dir = neon_dir()){
  
  if(nrow(x) < 1) return(invisible(NULL))
  x <- x[c("name", "md5", "crc32", "release")]

  ## Map gzip hashes expanded file-names
  x$name <- gsub("\\.gz", "", x$name)
 
  # index on name
  db <- lmdb(dir)
  write_lmdb(db, x$name, x)
  
  # index on hash
  md5s <- x[!is.na(x$md5),]
  crc32s <- x[!is.na(x$crc32),]
  if(nrow(md5s)>0) write_lmdb(db, md5s$md5, md5s)
  if(nrow(crc32s)>0) write_lmdb(db, crc32s$crc32, crc32s)
  

}

read_release_manifest <- function(id, 
                                  dir, 
                                  col.names = c("name", 
                                                "md5",
                                                "crc32", 
                                                "release"),
                                  colClasses = c("character",
                                               "character",
                                               "character",
                                               "character")){
  db <- lmdb(dir)
  read_lmdb(db, id, col.names = col.names, colClasses = colClasses)
}


lmdb_serialize <- function(df){
  apply(df, 1, paste0, collapse = "\t")
}

## parse text string back into a data.frame
lmdb_parse <- function(x, ...){
  utils::read.table(text = paste0(x, collapse="\n"), 
             header = FALSE, sep = "\t",
             quote = "",  ...)
}


write_lmdb <- function(db, key, df){
  value <- lmdb_serialize(df)
  db$mput(key, value)
  
}

read_lmdb <- function(db, ids, ...){
  
  out <- db$mget(ids, FALSE)
  lmdb_parse(out, ...)
}

## lmdb needs to remain synced to the filestore, not the database
lmdb <- function(dir = neon_dir()) {
  path <- file.path(dir, "lmdb")
  thor::mdb_env(path, mapsize = 1e9)
}




add_release <- function(meta, dir = neon_dir()){  
  ## First grab the hashes & release-tags of these files
  manifest <- read_release_manifest(basename(meta$path), dir = dir)
 
 
  manifest <- most_recent_release(manifest, dir)
  ## Use this release tag as the correct one (applies to content, not filename)
  meta$name <- basename(meta$path)
  meta <- tibble::as_tibble(merge(meta, manifest, 
                                  by = "name", all = TRUE))
  meta$name <- NULL
  meta
}

# neonstore will not download files with newer timestamps in the name if the 
# content (checksum) remains unchanged.  The release manifest stores the 
# new file names and hashes even though the duplicate content is not downloaded.
# The release manifest updates the key for the hash to point to the newest file
# name.  Thus, by querying by that key, we get the most recent filename
# and release tag associated with that content hash.
most_recent_release <- function(manifest, dir){ 
  manifest_md5 <- manifest[!is.na(manifest$md5),]
  updated <- read_release_manifest(manifest_md5$md5, dir = dir)
  manifest_md5 <- merge(manifest_md5[c("name", "md5", "crc32")], 
                        updated[c("md5", "release")], 
                        by = "md5")
  manifest_crc32 <- manifest[!is.na(manifest$crc32),]
  updated <- read_release_manifest(manifest_crc32$crc32, dir = dir)
  manifest_crc32 <- merge(manifest_crc32[c("name", "md5", "crc32")], 
                          updated[c("crc32", "release")], 
                          by = "crc32")
  manifest <- rbind(manifest_md5, manifest_crc32)
}

