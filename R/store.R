

#' Show information about all files downloaded to the local store
#' 
#' @param table a table name (or regex pattern) to filter on.
#' @inheritParams neon_download
#' 
#' @export
neon_store <- function(table = NULL, dir = neon_dir()){
  
  files <- list.files(neon_dir())
  
  ## Parse metadata from NEON file names
  into <- c("site", "product", "table", "month", "type", "timestamp", "ext")    
  site <- "(NEON\\.D\\d\\d\\.\\w{4})\\."                     # \\1
  product <- "(DP\\d\\.\\d{5}\\.\\d{3})\\."                  # \\2
  name <- "(:?\\w+)?\\.?"                                    # \\3 
  month <- "(:?\\d{4}-\\d{2})?\\.?"                          # \\4
  type <- "(:?basic|expanded)?\\.?"                          # \\5
  timestamp <- "(:?\\d{8}T\\d{6}Z)?\\.?"                     # \\6
  ext <- "(\\w+$)"                                           # \\7
  regex <- paste0(site, product, name, month, type, timestamp, ext)
  meta <- strsplit(gsub(regex, "\\1  \\2  \\3  \\4  \\5  \\6  \\7", files), "  ")
  
  ## Confirm parsing was successful
  parts <- vapply(meta, length, integer(1L))
  meta <- meta[parts == length(into)]
  
  ## Drop unparse-able file names
  filenames <- files[parts == length(into)]
  dropped <- files[parts != length(into)]
  
  ## Format as tidy data.frame
  meta_b <- jsonlite::fromJSON(jsonlite::toJSON(meta))
  colnames(meta_b) <- into
  meta_c <- as.data.frame(meta_b)
  meta_c$path <- file.path(dir, filenames)
  
  if(!is.null(table)){
    meta_c <- meta_c[grepl(table, meta_c$table), ]
  }
  # Prefer 'extended' format if available
  if(any(grepl("extended", meta_c$type))){
    meta_c <- meta_c[grepl("extended", meta_c$type), ]
  }
  
  meta_c

}

#' @export
neon_stored_tables <- function(dir = neon_dir()){
  meta <- neon_index()
  unique(meta$table)
}


## Consider using conditionally

#' @export
neon_read <- function(table, dir = neon_dir()){
  
  
  meta <- neon_index(table = table, dir = dir)
  files <- meta$path
  ## What about .zip files?
  
  
  ## vroom can read in a list of files, but only if columns are consistent
  ## dplyr::bind_rows can bind and fill missing columns
  tryCatch(vroom::vroom(files),
           error = function(e){
             warning("inconsistent columns across csv files, parsing individually...")
             suppressMessages(
               dplyr::bind_rows(lapply(files, vroom::vroom)) 
             )
           },
           finally = NULL)
  
  
}

# birds <- fs::dir_ls("birds") %>% vroom::vroom()

#' x <- c(
#' "NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T154457Z.csv",
#' "NEON.D01.BART.DP0.10003.001.validation.20191107T152154Z.csv",
#' "NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.basic.20191107T154457Z.csv",
#' "NEON.D01.BART.DP1.10003.001.brd_references.expanded.20191107T152154Z.csv",
#' "NEON.D01.BART.DP1.10003.001.2019-06.basic.20191205T150213Z.zip"
#' )
#' strsplit(gsub(regex, "\\1  \\2  \\3  \\5  \\6  \\7  \\8", x), "  ")

