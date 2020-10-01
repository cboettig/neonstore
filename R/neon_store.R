
#' import neon data into a local database
#' 
#' @param n number of files that should be read per iteration
#' @param quiet show progress?
#' @inheritParams neon_index
#' @inheritDotParams neon_read
#' @return the connection object (invisibly)
#' 
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




#' @importFrom DBI dbWriteTable
db_chunks <- function(con, files, table, 
                      n = 100L, quiet = FALSE, ...){
  
  total <- length(files) %/% n
  if(length(files) %% n > 0)  ## and the remainder
    total <- total + 1
  
  ## all files in one go
  if(total == 1){
    df <- neon_stack(files = files,
                     sensor_metadata = TRUE, 
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
                     sensor_metadata = TRUE, 
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


