#' import neon data into a local database
#' 
#' @param n number of files that should be read per iteration
#' @param quiet show progress?
#' @param db A connection to a write-able relational database backend,
#'  see [neon_db()].  
#' @inheritParams neon_index
#' @inheritDotParams neon_read
#' @return the index of files read in (invisibly)
#' @importFrom DBI dbWriteTable dbSendQuery dbGetQuery
#' @export
#' 
neon_store <- function(table = NA,
                       product = NA,
                       type = NA,
                       dir = neon_dir(),
                       db = neon_db(neon_db_dir(), read_only = FALSE),
                       n = 500L,
                       quiet = FALSE,
                       ...)
{
  
  ## Determine which files will be imported:
  index <- neon_index(table = table,
                      product = product,
                      type = type,
                      dir = dir,
                      deprecated = FALSE)
  ## only h5 or csv data can be imported currently
  index <- index[index$ext == "h5" | index$ext == "csv",]
  
  ## Error conditions
  if(is.null(index)) index <- data.frame()
  if(nrow(index) == 0){
    if(!is.na(table))
      message(paste("table", table, 
                    "not found, do you need to download first?"))
    if(!is.na(product))
      message(paste("No csv/h5 files for product", product,
              "found. do you need to download first?"))
    return(invisible(NULL))
  }
  
  ## standardize table name with product name:
  tables <- stackable_tables(paste0(index$table, "-", index$product))

  

  ## Omit already imported files
  index <- omit_imported(db, index)
  if(nrow(index) == 0){
    message("  all files have been imported")
    neon_disconnect(db = db)
    return(invisible(NULL))
  }
  
  for (table in tables) {
    ## Drop rows from the database which come from deprecated files
    drop_deprecated(table, dir, db)
    index$tablename <- paste0(index$table, "-", index$product)
    meta <- index[index$tablename == table, ]
    if(nrow(meta) > 0){
      db_chunks(con = db, 
                files = meta$path,
                table = table, 
                n = n, 
                quiet = quiet, 
                ...)
    }
  }
  
  ## update the provenance table
  if(!is.null(index)){
    DBI::dbWriteTable(db, "provenance", as.data.frame(index), append = TRUE)
  }
  
  neon_disconnect(db = db)
  invisible(index)
}




stackable_tables <- function(tables){
  tables <- unique(tables)
  tables <- tables[!grepl("^variables", tables)]
  tables <- tables[!grepl("^readme", tables)]
  
  tables
}


db_chunks <- function(con, 
                      files, 
                      table, 
                       n = 100L, 
                      quiet = FALSE,
                      ...){
  
  if(length(files)==0){ 
    return(invisible(NULL))
  }
  
  total <- length(files) %/% n
  if(length(files) %% n > 0)  ## and the remainder
    total <- total + 1
  
  
  progress <- !quiet
  ## all files in one go
  if(total == 1){
    if (!quiet) message(paste0("  importing ", table, "..."))
    df <- neon_stack(files = files,
                     keep_filename = TRUE,
                     sensor_metadata = TRUE,
                     altrep = FALSE,
                     progress = progress,
                     ...)
    if(!is.null(df)){
      DBI::dbWriteTable(con, table, as.data.frame(df), append = TRUE)
    }
    
    return(invisible(NULL))
  }
  
  if (total > 4) {
    progress <- FALSE
  }
  
  ## Otherwise do in chunks
  pb <- progress::progress_bar$new(
    format = paste("  importing", table,
                   "[:bar] :percent in :elapsed, eta: :eta"),
    total = total, 
    clear = FALSE, 
    show_after = 0,
    width = 80)

  if (!quiet && progress) 
    message(paste("  processing", table, "files in", total, "chunks:"))
  for (i in 0:(total-1)){
    if (!quiet && progress) 
      message(paste0("  chunk ", i+1, ":"), appendLF=FALSE)
    if(!quiet && !progress) pb$tick()
    chunk <- na_omit(files[ (i*n+1):((i+1)*n) ])
    df <- neon_stack(files = chunk,
                     keep_filename = TRUE,
                     sensor_metadata = TRUE, 
                     altrep = FALSE,
                     progress = progress)
    DBI::dbWriteTable(con, table, as.data.frame(df), append = TRUE)  

  }
  
  return(invisible(NULL))
  
}


duckdb_memory_manager <- function(con){
  if(Sys.getenv("duckdb_restart", FALSE)){
    ## power cycle to force import
    ## shouldn't be necessary when memory management improves in duckdb...
    dir <- dirname(con@driver@dbdir)
    db <- neon_db(dir, read_only = FALSE)
    DBI::dbDisconnect(db, shutdown = TRUE)
    con <- neon_db(dir, read_only = FALSE)
  }
  con
}

#' @importFrom DBI dbWriteTable dbListTables dbGetQuery
omit_imported <- function(con, index){
  index$id <- basename(index$path)
  
  if( !("provenance" %in% DBI::dbListTables(con)) ){
    return(index)
  }
  if(is.null(index)){
    return(data.frame())
  }
    
    
  DBI::dbWriteTable(con, "zzzfilter", as_tibble(index),
                    overwrite = TRUE, temporary = TRUE)
  query <- paste0(
    'SELECT * FROM zzzfilter ', 
    'WHERE zzzfilter.id NOT IN ( SELECT ID FROM provenance );'
  )
  
  df <- DBI::dbGetQuery(con, query)
  df
}


drop_deprecated <- function(table, 
                            dir = neon_dir(),
                            con = neon_db()){
  
  if( !(table %in% DBI::dbListTables(con)) ){
    return(invisible(NULL))
  }
  
  ## split table and product code
  product_regex <- paste(DPL,PRNUM,REV, sep="\\.")
  product <- gsub(paste0(".*-(",product_regex, ")$"), "\\1", table)
  table_only <- gsub(paste0("-",product_regex, "$"), "", table)
  ## Detect updated files
  meta <- neon_index(table = table_only, 
                     product = product,
                     dir = dir, 
                     deprecated = TRUE)
  key_cols <- c("product", "site", "month", "table", 
                "verticalPosition", "horizontalPosition")
  deprecated <- duplicated(meta[key_cols])
  
  if(!any(deprecated)){
   return(invisible(NULL))
  } else {
    message(
      paste("  Updated version of previously imported data found.\n",
            "  Overwriting some previously imported rows with revised data."
            ))
  }
  
  ## Build SQL query
  old <- paste(lapply(basename(meta$path[deprecated]), 
                      function(x) paste0("'", x, "'")),
               collapse = ", ")
  query <- paste(paste0("DELETE from \"", table, "\" WHERE "),
                 paste0("file IN (", old, ")"))

  ## Execute the DELETE query
  res <- DBI::dbSendQuery(con, query)        
  
  ## Note that dropped file names will remain part of 
  ## the provenance table.

  ## Now we can re-import the tables
  
}

