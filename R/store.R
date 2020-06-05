### Functions in store.R do not require API access, but interact only with
### the local persistent storage


#' Show information about all files downloaded to the local store
#' 
#' 
#' NEON products consist of several individual components, which are in turn
#' broken up by site and sampling month. By storing these individual files,
#' neonstore enables more reproducible workflows that can be traced back to
#' original, unaltered input data.  These atomized files can be quickly and easily
#' combined into unified tables, see [neon_read].
#' 
#' File names include metadata such as the file productCode,
#' table name, site, and sampling month, as well as timestamp of creation.
#' `neon_index()` parses this metadata from the file name string and returns
#' the information in a convenient table, along with a path to each file.
#' 
#' @param product Include only files matching this NEON productCode (optional)
#' @param table Include only files matching this table name (or regex pattern). 
#' (optional).
#' @param hash name of a hashing algorithm to check file integrity. Can be
#'  md5, sha1, or sha256 currently; or set to [NULL] to skip hash computation.
#' @inheritParams neon_download
#' 
#' @export
#' @examples
#' 
#' \dontshow{
#' # Hide setting tempfile, since a user would specify a persistent location
#'  Sys.setenv("NEONSTORE_HOME"=tempfile())
#' }
#' 
#' neon_index()
#' 
#' ## Just bird survey product
#' neon_index("DP1.10003.001")
#' 
#' \dontshow{
#' # tidy
#'  Sys.unsetenv("NEONSTORE_HOME")
#' }
#' 
neon_index <- function(product = NULL, 
                       table = NULL, 
                       hash = "md5",
                       dir = neon_dir()){
  
  files <- list.files(dir)
  
  ## Parse metadata from NEON file names
  parsed <- gsub(neon_regex(), "\\1  \\2  \\3-\\5  \\4  \\5  \\6  \\7", files)
  meta <- strsplit(parsed, "  ")
  
  ## Confirm parsing was successful
  into <- c("site", "product", "table", "month", "type", "timestamp", "ext")
  parts <- vapply(meta, length, integer(1L))
  meta <- meta[parts == length(into)]
  
  ## Drop unparse-able file names
  filenames <- files[parts == length(into)]
  dropped <- files[parts != length(into)]
  
  ## Format as tidy data.frame
  meta_b <- jsonlite::fromJSON(jsonlite::toJSON(meta))
  if(length(meta_b) == 0) return(NULL)
  colnames(meta_b) <- into
  meta_c <- as.data.frame(meta_b)
  meta_c$path <- file.path(dir, filenames)

  
  ## Apply any filters
  if(!is.null(table)){
    meta_c <- meta_c[grepl(table, meta_c$table), ]
  }
  
  if(!is.null(product)){
    meta_c <- meta_c[grepl(product, meta_c$product), ]
  }
  
  ## Compute hashes, if requested
  meta_c$hash <- file_hash(meta_c$path, hash = hash)
  
  tibble::as_tibble(meta_c)
}

#' @importFrom openssl md5 sha1 sha256
file_hash <- function(x, hash = "md5"){
  
  
  if(is.null(hash)) return(NULL)
  if(length(x) == 0)  return(NULL)
  
  hash_fn <- switch(hash, 
         "md5" = openssl::md5,
         "sha1" = openssl::sha1,
         "sha256" = openssl::sha256,
         NULL)
  
  if(is.null(hash_fn)) {
   warning(paste("No function for", hash, 
                 "found", call. = FALSE))
   return(NULL)
  }
  
  ## httr imports openssl already
  hashes <- paste0("hash://", hash, "/",
    vapply(x, 
           function(y) as.character(hash_fn(file(y))),
           character(1L)))
  
  hashes
  
}


neon_regex <- function(){
  site <- "(NEON\\.D\\d\\d\\.\\w{4})\\."                     # \\1
  productCode <- "(DP\\d\\.\\d{5}\\.\\d{3})\\."              # \\2
  name <- "(:?\\w+)?\\.?"                                    # \\3 
  month <- "(:?\\d{4}-\\d{2})?\\.?"                          # \\4
  type <- "(:?basic|expanded)?\\.?"                          # \\5
  timestamp <- "(:?\\d{8}T\\d{6}Z)?\\.?"                     # \\6
  ext <- "(\\w+$)"                                           # \\7
  regex <- paste0(site, productCode, name, month, type, timestamp, ext)
  regex
}
#' Show tables that have been downloaded to the neon store
#' 
#' @details
#' The table names displayed can be read in using [neon_read]. 
#' Optionally, specify a NEON productCode to view only tables associated
#' with a specific product. 
#' 
#' Only downloaded tables will be displayed.  Users can view all available
#' NEON data products using [neon_products] to choose which ones to download
#' into the store.
#' 
#' `neon_store()` does not need to access the API and thus does not require
#' an internet connection or incur rate limiting on requests.
#' 
#' @seealso [neon_products], [neon_download], [neon_index]
#' @inheritParams neon_index
#' @export
#' @examples
#' 
#' neon_store()
#' 
#' 
neon_store <- function(product = NULL, table = NULL, dir = neon_dir()){
  meta <- neon_index(product = product, 
                     table = table, 
                     hash = NULL,
                     dir = dir)
  unique(meta$table)
}





#' read in neon tabular data
#' 
#' @details
#' NEON's tabular data files are separated out into separate .csv
#' files for each site for each month of sampling.  In principle,
#' each file has identical columns.  [vroom::vroom] can read in a
#' data table that has been sharded into many files like this much
#' much faster than other parsers can read in each table iteratively, 
#' (and thus can greatly out-perform the 'stacking" methods in `neonUtilities`).
#'
#' Unfortunately, not all datasets are entirely consistent in their use
#' of columns.  `neon_read` works around this by parsing such tables in
#' groups of matching schema, which is still reasonably fast.
#' 
#' For convenience, `neon_read` takes the name of a table in the local store.
#' 
#' @param table the name of a downloaded NEON table in the store,
#'  see [neon_store]
#' @param ... additional arguments to [vroom::vroom], can usually be omitted.
#' @param files optionally, specify a vector of file paths directly (e.g. as
#' provided from [neon_index]) and specify `table` argument as NULL.
#' @inheritParams neon_download
#' @importFrom vroom vroom spec
#' @export
#' 
#' @examples 
#' 
#' neon_read("brd_countdata-expanded")
#' 
#' ## Read in specific files from the neon_index():
#' files <- neon_index(table = "brd_countdata-expanded")$path
#' neon_read(files = files)
#' 
neon_read <- function(table = NULL, ..., files = NULL, dir = neon_dir()){
  
  if(is.null(files)){
    meta <- neon_index(table = table, hash = NULL, dir = dir)
    files <- meta$path
  }
  
  if(length(files) == 0){
    if(is.null(table)) table <- "unspecified tables"
    warning(paste("no files found for", table, "in", dir, "\n",
                  "perhaps you need to download them first?"))
    return(NULL)
  }
  
  ## vroom can read in a list of files, but only if columns are consistent
  tryCatch(vroom::vroom(files, ...),
           error = function(e) vroom_ragged(files, ...),
           finally = NULL)
}



#' @importFrom vroom vroom spec
vroom_ragged <- function(files){

  ## We read the 1st line of every file to determine schema  
  suppressMessages(
    schema <- lapply(files, vroom::vroom, n_max = 1, altrep = FALSE)
  )
  
  
  ## Now, we read in tables in groups of matching schema,
  ## filling in additional columns as in bind_rows.
  
  col_schemas <- lapply(schema, colnames)
  u_schemas <- unique(col_schemas)
  tbl_list <- vector("list", length=length(u_schemas))
  
  all_cols <- unique(unlist(u_schemas))
  
  i <- 1
  for(s in u_schemas){

    ## select tables that have matching schemas
    index <- vapply(col_schemas, identical, logical(1L), s)
    col_types <- vroom::spec(schema[index][[1]])
    
    ## Read in all those tables
    tbl <- vroom::vroom(files[index], col_types = col_types)
    
    ## append any columns missing from all_cols set
    missing <- all_cols[ !(all_cols %in% colnames(tbl)) ]
    tbl[ missing ] <- NA
    tbl_list[[i]] <- tbl
    i <- i+1
    
  }
  do.call(rbind, tbl_list)
  
}




#' Generate the appropriate citation for your data
#' 
#' @inheritParams neon_download
#' @param  download_date Date of download to be included in citation.
#'  default is today's date, see details. 
#' 
#' @references <https://www.neonscience.org/data/about-data/data-policies>
#' @return returns a [utils::bibentry] object, which can be used as text
#' or formatted for bibtex.
#' @details
#' Note that the `neon_download()` does not record download date for each file.
#' Citing a single product download date is after all rather meaningless, as 
#' parts of a products may not have all been downloaded on different dates.
#' Indeed, `neon_download()` is designed in precisely this way, to allow easy
#' updating of downloads without re-downloading older data.
#' 
#' @importFrom utils bibentry person
#' @export
#' @examples 
#' 
#' neon_citation("DP1.10003.001")
#' 
#' ## or the citation for all products in store:
#' neon_citation()
#' 
#' ## as bibtex
#' format(neon_citation("DP1.10003.001"), "bibtex")
#' 
neon_citation <- function(product = NULL, 
                          download_date = Sys.Date(),
                          dir = neon_dir()){
  
  download_date <- as.Date(download_date)
  year <-  format(Sys.Date(), "%Y")
  
  if(is.null(product)){
    meta <- neon_index(hash = NULL, dir = dir)
    product <- unique(meta$product)
  }
  
  product_list <- ""
  if(length(product) < 6)
    product_list <- paste("Data Products:", 
                           paste0("NEON.", product, collapse = " "),
                          ". ")
  
  
  author <- "National Ecological Observatory Network"
  year <- year
  title <- paste0(product_list, 
    "Provisional data downloaded from http://data.neonscience.org on ",
    format(download_date, "%d %b %Y"))  
  publisher = "Battelle"
  location = "Boulder, CO, USA"
  
  txt <- paste(author, year, title, 
               paste(publisher, location, sep = ", "), sep = ". ")
  
  utils::bibentry("Misc", 
                  author = utils::person(family = author), 
                  year = year, 
                  title = title, 
                  publisher = publisher, 
                  location = location,
                  textVersion = txt)
  
  
}



