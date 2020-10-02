#' import neon data into a local database
#' 
#' @param n number of files that should be read per iteration
#' @param quiet show progress?
#' @inheritParams neon_index
#' @inheritDotParams neon_read
#' @return the connection object (invisibly)
#' @importFrom DBI dbWriteTable dbSendQuery dbGetQuery
#' @export
#' 
neon_store <- function(table,
                       dir = neon_dir(),
                       n = 200L,
                       quiet = FALSE, 
                       ...)
{
  
  index <- neon_index(table = table,
                      hash = "md5",
                      dir = dir,
                      deprecated = FALSE)
  
  if(nrow(index) == 0){
    message("table", table, "not found, do you need to import it first?")
    return(invisible(con))
  }
  
  ## standardize table name
  table <- unique(index$table)
  con <- neon_db(dir)
  
  ## Drop rows from the database which come from deprecated files
  drop_deprecated(table, dir, con)
  
  ## Omit already imported files
  index <- omit_imported(con, index)
  if(nrow(index) == 0){
    message("all files for this table have been imported")
    return(invisible(con))
  }
  
  ## work through files list in chunks, with progress
  db_chunks(con = con, 
            files = index$path,
            table = table, 
            n = n, 
            quiet = quiet, 
            ...)
  
  ## update the provenance table
  DBI::dbWriteTable(con, "provenance", index, append = TRUE)
  
  invisible(con)
}




db_chunks <- function(con, files, table, 
                       n = 200L, quiet = FALSE, ...){
  
  total <- length(files) %/% n
  if(length(files) %% n > 0)  ## and the remainder
    total <- total + 1
  
  ## all files in one go
  if(total == 1){
    df <- neon_stack(files = files,
                     keep_filename = TRUE,
                     sensor_metadata = TRUE,
                     altrep = FALSE,
                     progress = FALSE,
                     ...)
    DBI::dbWriteTable(con, table, df, append = TRUE)
    return(invisible(con))
  }
  
  ## Otherwise do chinks
  pb <- progress::progress_bar$new(
    format = "  importing [:bar] :percent in :elapsed, eta: :eta",
    total = total, 
    clear = FALSE, 
    show_after = 0,
    width = 60)
  
  pb$tick(0)
  
  for(i in 0:(total-1)){
    if(!quiet) pb$tick()
    chunk <- na_omit(files[ (i*n+1):((i+1)*n) ])
    df <- neon_stack(files = chunk,
                     keep_filename = TRUE,
                     sensor_metadata = TRUE, 
                     altrep = FALSE,
                     progress = FALSE)
    DBI::dbWriteTable(con, table, df, append = TRUE)  
  }
  return(invisible(con))
  
}


#' @importFrom DBI dbWriteTable dbListTables dbGetQuery
omit_imported <- function(con, index){
  index$id <- basename(index$path)
  
  if( !("provenance" %in% DBI::dbListTables(con)) ){
    return(index)
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
                            con = neon_db(dir)){
  
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
      paste("Updated version of previously imported data found.\n",
            "Overwriting some previously imported rows with revised data."
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

