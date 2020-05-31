
#' @export
neon_index <- function(table = NULL, dir = neon_dir()){
  into <- c("site", "product", "table", "month", "type", "timestamp", "ext")    
  
  site <- "(NEON\\.D\\d\\d\\.\\w{4})"                     # \\1
  product <- "(DP\\d\\.\\d{5}\\.\\d{3})"                  # \\2
  name <- "(\\w+)"                                        # \\3 
  month <- "(:?\\d{4}-\\d{2})?\\.?"                       # \\5
  type <- "(:?basic|expanded)?\\.?"                       # \\6
  timestamp <- "(\\d{8}T\\d{6}Z)"                         # \\7
  stamp <- paste0("(:?", month, type, ")?", timestamp)    # \\4
  ext <- "(csv)"                                          # \\8
  
  regex <- paste(site, product, name, stamp, ext, sep = "\\.")

    
  files <- list.files(neon_dir())
  meta <- strsplit(gsub(regex, "\\1  \\2  \\3  \\5  \\6  \\7  \\8", files), "  ")
  
  parts <- vapply(meta, length, integer(1L))
  meta <- meta[parts == length(into)]
  filenames <- files[parts == length(into)]
  
  dropped <- files[parts != length(into)]
  
  meta_b <- jsonlite::fromJSON(jsonlite::toJSON(meta))
  colnames(meta_b) <- into
  meta_c <- as.data.frame(meta_b)
  
  meta_c$path <- file.path(dir, filenames)
  
  if(!is.null(table)){
    meta_c <- meta_c[grepl(table, meta_c$table), ]
    meta_c <- meta_c[!grepl("basic", meta_c$type), ]
  }
  meta_c

}

#' @export
neon_tables <- function(dir = neon_dir()){
  meta <- neon_index()
  unique(meta$table)
}

#' @export
neon_products <- function(dir = neon_dir()){
  meta <- neon_index()
  unique(meta$product)
}

## Consider using conditionally

#' @export
neon_read <- function(files){
  
  ## What about .zip files?
  
  ## allow files to be a data.frame, e.g. from neon_index()
  if(is.data.frame(files)) files <- files$path
  
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


# x <- c(
# "NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T154457Z.csv",
# "NEON.D01.BART.DP0.10003.001.validation.20191107T152154Z.csv",
# "NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.basic.20191107T154457Z.csv",
# "NEON.D01.BART.DP1.10003.001.brd_references.expanded.20191107T152154Z.csv"
# )
# strsplit(gsub(regex, "\\1  \\2  \\3  \\5  \\6  \\7  \\8", x), "  ")


