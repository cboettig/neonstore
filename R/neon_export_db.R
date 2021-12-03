
neon_export_db <- function(db = neon_db(), 
                           dir = file.path(neon_dir(), "parquet"),
                           
                           ) {
  query <- paste0("EXPORT DATABASE '", dir, "' (FORMAT PARQUET);")
  DBI::dbExecute(db, query)
}


neon_import_db <- function(db = neon_db(),
                           dir = file.path(neon_dir(), "parquet")) {
 
  
}
