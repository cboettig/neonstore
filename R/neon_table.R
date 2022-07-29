#' Return a neon table from the database
#'
#' @inheritParams neon_read
#' @param db a connection to the database, see `[neon_db()]`.
#' @details
#' We cannot filter on start_date or end_date since these
#' come only from the filename metadata and are only added
#' to instrument tables, not observation tables etc.
#' @param type filter for basic or expanded. Can be omitted unless you have 
#' imported both types a given table into your database.
#' @param lazy logical, default FALSE. Should we return a remote dplyr 
#' connection to the table in duckdb? This can substantially improve 
#' performance and avoid out-of-memory errors when working with very large
#' tables. However, not all R operations can be performed on a remote table,
#' only (most) functions from `dplyr` and `tidyr`, as these can be 
#' translated automatically to SQL language used by the remote database.
#' Use `dplyr` functions like [dplyr::filter()], [dplyr::group_by()], and 
#' [dplyr::summarise()] to subset
#' the data appropriately within the remote table before calling
#'  `[dplyr::collect()]` to import the data fully into R.
#' @export
#' @importFrom DBI dbGetQuery
#' 
neon_table <- function(table,
                       product = NA,
                       type = NA,
                       site = NA,
                       db = neon_db(),
                       lazy = FALSE){

  con <- db

  table <- check_tablename(table, 
                           product = product,
                           type = type,
                           tables = DBI::dbListTables(con))
  
  
  if(lazy){
    if(!requireNamespace("dplyr", quietly = TRUE)){
      stop("dplyr is required for lazy evaluation")
    }
    return(dplyr::tbl(db, table))
  }
  
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
check_tablename <- function(x, product = NA, type = NA, tables){
 out <- tables[grepl(x, tables)]
 
 ## Filter on product & type if requested
 if (!is.na(product)) {
   out <- out[grepl(product, out)]
 }

 if (!is.na(type)) {
   out <- out[grepl(type, out)]
 }
 
  
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

