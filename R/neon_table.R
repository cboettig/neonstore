#' Return a neon table from the database
#'
#' @inheritParams neon_read
#' @param db a connection to the database, see `[neon_db()]`.
#' @details
#' We cannot filter on start_date or end_date since these
#' come only from the filename metadata and are only added
#' to instrument tables, not observation tables etc.
#' 
#' @export
#' @importFrom DBI dbGetQuery
#' 
neon_table <- function(table,
                       site = NA,
                       db = neon_db()){

  con <- db
  tables <- DBI::dbListTables(con)
  table <- check_tablename(table, tables)
  
  where <- NULL
  query <- paste0("SELECT * FROM \"", table, "\"")
  
  if(!any(is.na(site))){
    tmp <- paste(lapply(site, function(x) paste0("'", x, "'")),
                 collapse = ", ")
    where <- c(where, paste0("siteID IN (", tmp, ")")
    )
  }
  
  if(!is.null(where)){
    query <- paste(query,
                   "WHERE",
                   paste(where, collapse = " AND "))
  }
  
  DBI::dbGetQuery(con, query)
}



## Sanitize table names, particularly extended/basic matching
check_tablename <- function(x, tables){
 out <- tables[grepl(x, tables)]
 if(length(out) > 1){
   stop(paste("multiple matches for table", 
              x, ":", out), call. = FALSE)
 } else if(length(out) < 1) {
   stop(paste("no table", x, "found.",
              "Maybe you need to run neon_store() first?"),
        call. = FALSE)
 }
 
 out
}

