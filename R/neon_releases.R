

update_release_manifest <- function(x, dir = neon_dir()){
  
  if(nrow(x) < 1) return(invisible(NULL))
  x <- x[c("name", "release")]

  db <- lmdb(dir)
  write_lmdb(db, x$name, x$release)

}

read_release_manifest <- function(id, dir){
  db <- lmdb(dir)
  read_lmdb(db, id)  
}




write_lmdb <- function(db, key, value){
  db$mput(key, value)
  
}

read_lmdb <- function(db, ids){
  
  db$mget(ids, FALSE)
  
}


lmdb <- function(dir = neon_db_dir()) {
  path = file.path(dir, "lmdb")
  thor::mdb_env(path, mapsize = 1e12) ## ~1 TB
}








