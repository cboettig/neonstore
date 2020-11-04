#' import neon data into a local database
#' 
#' @param n number of files that should be read per iteration
#' @param quiet show progress?
#' @param db_dir location of the database directory
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
                       db_dir = neon_db_dir(),
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
  
  ## standardize table name
  tables <- stackable_tables(index$table)

  
  ## Establish a write-able database connection
  con <- neon_db(db_dir, read_only = FALSE)
  
  ## Omit already imported files
  index <- omit_imported(con, index)
  if(nrow(index) == 0){
    message("all files have been imported")
    neon_disconnect(db = con)
    return(invisible(con))
  }
  
  for (table in tables) {
    ## Drop rows from the database which come from deprecated files
    drop_deprecated(table, dir, con)
    meta <- index[index$table == table, ]
    if(nrow(meta) > 0){
      con <- db_chunks(con = con, 
                       files = meta$path,
                       table = table, 
                       n = n, 
                       quiet = quiet, 
                       ...)
    }
  }
  
  ## update the provenance table
  con <- duckdb_memory_manager(con)
  if(!is.null(index)){
    DBI::dbWriteTable(con, "provenance", index, append = TRUE)
  }
  neon_disconnect(db = con)
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
    return(con)
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
      DBI::dbWriteTable(con, table, df, append = TRUE)
    }
    
    con <- duckdb_memory_manager(con)
    return(invisible(con))
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
    DBI::dbWriteTable(con, table, df, append = TRUE)  
    con <- duckdb_memory_manager(con)

  }
  
  con <- duckdb_memory_manager(con)
  return(invisible(con))
  
}


duckdb_memory_manager <- function(con){
  if(Sys.getenv("duckdb_restart", FALSE)){
    # shouldn't be necessary when memory management improves in duckdb...
    dir <- dirname(con@driver@dbdir)
    ## power cycle to force import
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
    
    
  DBI::dbWriteTable(con, "zzzfilter", index,
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
  
  ## Detect updated files
  meta <- neon_index(table = table, 
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
  old <- paste(lapply(meta$path[deprecated], 
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

