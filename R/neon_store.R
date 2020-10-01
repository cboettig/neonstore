
#' import neon data into a local database
#' 
#' @param quiet show progress?
#' @inheritParams neon_index
#' @inheritDotParams neon_read
#' @return the connection object (invisibly)
#' @importFrom DBI dbWriteTable dbSendQuery dbGetQuery
#' @importFrom utils read.csv
#' @export
#' 
neon_store <- function(table,
                       type = "expanded", 
                       dir = neon_dir(),
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
            quiet = quiet, 
            ...)
  
  ## update the provenance table
  DBI::dbWriteTable(con, "provenance", index, append = TRUE)
  
  invisible(con)
}




db_chunks <- function(con, files, table, 
                      quiet = FALSE, ...){
  
  
  pb <- progress::progress_bar$new(
    format = "  importing [:bar] :percent eta: :eta",
    total = length(files), 
    clear = FALSE, 
    width = 60,
    show_after = 0)

  for(x in files){
    if(!quiet) pb$tick()
    
    ## vroom is doing weird stuff to progress bar
    df <- utils::read.csv(x)
    df$file <- x
    rownames(df) <- NULL
    if(is_sensor_data(basename(x)))
    df <-add_sensor_columns(df)
    
    silent <- DBI::dbWriteTable(con, table, df, append = TRUE)  
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

