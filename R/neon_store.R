
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
neon_store <- function(table = NA,
                       type = "expanded", 
                       dir = neon_dir(),
                       n = 20L,
                       quiet = FALSE, 
                       ...)
{
  
  index <- neon_index(table = table,
                      type = type,
                      hash = "md5",
                      dir = dir,
                      deprecated = FALSE)
  
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
                      n = 100L, quiet = FALSE, ...){
  
  total <- length(files) %/% n
  if(length(files) %% n > 0)  ## and the remainder
    total <- total + 1
  
  ## all files in one go
  if(total == 1){
    df <- neon_stack(files = files,
                     keep_filename = TRUE,
                     sensor_metadata = TRUE,
                     altrep = FALSE,
                     ...)
    DBI::dbWriteTable(con, table, df, append = TRUE)
    return(invisible(con))
  }
  
  ## Otherwise do chinks
  pb <- progress::progress_bar$new(
    format = "  importing [:bar] :percent eta: :eta",
    total = total, 
    clear = FALSE, width= 60)
  
  for(i in 0:(total-1)){
    if(!quiet) pb$tick()
    chunk <- files[ (i*n+1):((i+1)*n) ]
    df <- neon_stack(files = chunk,
                     keep_filename = TRUE,
                     sensor_metadata = TRUE, 
                     altrep = FALSE,
                     ...)
    DBI::dbWriteTable(con, table, df, append = TRUE)  
    return(invisible(con))
    
  }
  
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
  
  meta <- neon_index(table = table, 
                     dir = dir, 
                     deprecated = TRUE)
  key_cols <- c("product", "site", "month", "table", 
                "verticalPosition", "horizontalPosition")
  deprecated <- duplicated(meta[key_cols])
  
  old <- paste(lapply(meta$path[deprecated], 
                      function(x) paste0("'", x, "'")),
               collapse = ", ")
  # Could be a big query!
  query <- paste(paste0("DELETE from \"", table, "\" WHERE "),
                 paste0("file IN (", old, ")"))

  ## drop the deprecated rows from the database
  res <- DBI::dbSendQuery(con, old)        
  
  ## Should we also drop those files from the provenance table? 
  ## Not necessary, better to keep the record!
  
  ## Now we can re-import the tables
  
}





