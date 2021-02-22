

update_release_manifest <- function(x, dir = neon_dir()){
  
  if(nrow(x) < 1) return(invisible(NULL))
  x <- x[c("name", "md5", "crc32", "release")]

  db <- lmdb(dir)
  write_lmdb(db, x$name, x)

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
  read.table(text = paste0(x, collapse="\n"), 
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


lmdb <- function(dir = neon_db_dir()) {
  path = file.path(dir, "lmdb")
  thor::mdb_env(path, mapsize = 1e12) ## ~1 TB
}








