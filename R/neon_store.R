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
  
  #db <- duckdb_memory_manager(db)
  neon_disconnect(db = db)
  invisible(index)
}


stackable_tables <- function(tables){
  tables <- unique(tables)
  ## We do not attempt to stack these:
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
  if(!inherits(con, "duckdb_connection")) return(con)
  if(Sys.getenv("duckdb_restart", FALSE)){
    message("finalizing duckdb import to disk...")
    ## power cycle to force import
    ## shouldn't be necessary when memory management improves in duckdb...
    dir <- dirname(con@driver@dbdir)
    DBI::dbDisconnect(con, shutdown = TRUE)
    con <- neon_db(dir, read_only = FALSE)
  }
  con
}

#' @importFrom DBI dbWriteTable dbListTables dbGetQuery
omit_imported <- function(con, index){
  
  # if nothing here, return empty data.frame
  if(is.null(index)){
    return(data.frame())
  }
  # from import index, here are table names in database format
  db_tables <- stackable_tables(paste0(index$table, "-", index$product))
  existing <- DBI::dbListTables(con)
  
  # basename for comparison
  index$id <- basename(index$path)
  
  ## place the index into the database temporarily so we can use it
  DBI::dbWriteTable(con, "zzzfilter", tibble::as_tibble(index),
                    overwrite = TRUE, temporary = TRUE)
  

  out <- lapply(db_tables, function(db_table){
    who <- split_db_tablename(db_table)
    table <- who[1]
    product <- who[2]
    ## table doesn't exist yet,
    if (!(db_table %in% existing)) {
      query <- paste0("SELECT * FROM zzzfilter ", 
                      "WHERE ((\"product\" = '",product,"') ",
                      "AND (\"table\" = '",table, "'))")
      df <- DBI::dbGetQuery(con, query)
      return(df)
    }
    ## filter 
    query <- paste0("SELECT * FROM zzzfilter ", 
                    "WHERE (",
                    "(\"product\" = '",product,"') AND ",
                    "(\"table\" = '",table, "') AND ",
                    "zzzfilter.id NOT IN ( SELECT \"file\" FROM ",
                    "\"", db_table, "\"))")
    df <- DBI::dbGetQuery(con, query)
    df
  })
  ## return index slices
  do.call(rbind, out)
}


split_db_tablename <- function(db_table) {
  table_regex <- paste0("(^.*)", "-(", paste(DPL, PRNUM, REV, sep="."), ")")
  product <- gsub(table_regex,"\\2", db_table)
  table <- gsub(table_regex,"\\1", db_table)
  c(table, product)
}


drop_deprecated <- function(table, 
                            dir = neon_dir(),
                            con = neon_db(read_only = FALSE)){
  
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
  meta <- flag_deprecated(meta)
 
  deprecated <- meta$deprecated
  
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

