


neon_db_import <- function(table = NA,
                          product = NA, 
                          site = NA,
                          start_date = NA,
                          end_date = NA,
                          ext = NA,
                          timestamp = NA,
                          dir = neon_dir(),
                          n = 1000L,
                          quiet = FALSE){
  
  
  index <- neon_index(product = product,
                      table = table,
                      site = site,
                      start_date = start_date,
                      end_date = end_date,
                      ext = ext,
                      timestamp = timestamp,
                      hash = "md5",
                      dir = dir)
  
  con <- neon_db(dir)
  prov_table <- paste(table, "prov", sep = "_")

  ## Omit already imported files
  if(prov_table %in% DBI::dbListTables(con)){
    prov <- DBI::dbReadTable(con, prov_table)
    imported_files <- prov$files
    index <- index[!(basename(index$path) %in% basename(imported_files)),  ]
  }
  
  ## work through files list in chunks, with progress
  db_chunks(con, index$path, table, n, quiet)
  
  ## update the provenance table
  DBI::dbWriteTable(con, prov_table, index, append = TRUE)
  
  
}


db_chunks <- function(con, files, table, n = 1000L, quiet = FALSE){
  
  total <- length(files) %/% n
  if(length(files) %% n > 0)  ## and the remainder
    total <- total + 1
  
  pb <- progress::progress_bar$new(
    format = "  importing [:bar] :percent eta: :eta",
    total = total, 
    clear = FALSE, width= 60)
  
  for(i in 0:(total-1)){
    chunk <- files[ (i*n+1):((i+1)*n) ]
    suppressMessages({
    df <- neon_read(files = files,
                    sensor_metadata = TRUE)
    })
    DBI::dbWriteTable(con, table, df, append = TRUE)    
    if(!quiet) pb$tick()
  }
  
}

## Cache-able connection

neon_db <- function (dbdir = neon_dir(), ...) {
  dbname <- file.path(dbdir, "database")
  db <- mget("neon_db", envir = neonstore_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    if (DBI::dbIsValid(db)) {
      return(db)
    }
  }
  db <- duckdb::dbConnect(duckdb::duckdb(), dbdir = dbname, ...)

  assign("neon_db", db, envir = neonstore_cache)
  db
}

neon_db_disconnect <- 
  function (db = local_db(), env = neonstore_cache) 
{
  if (inherits(db, "DBIConnection")) {
    suppressWarnings(DBI::dbDisconnect(db))
  }
  if (exists("neon_db", envir = env)) {
    rm("neon_db", envir = env)
  }
}

neonstore_cache <- new.env()




