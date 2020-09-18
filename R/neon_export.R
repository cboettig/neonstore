
#' export local neon store as a zip archive
#' 
#' Export all or select files from your neon store as a zip archive.
#' This can be useful if you want to bypass accessing the API, such as for
#' archiving the files required for your analysis so that they can be 
#' re-created by other users without an API key, or without waiting for
#' the individual download, or any other tiem you want to share or 
#' distribute your local store. 
#' 
#' @return table of selected files and metadata, from [neon_index()], invisibly.
#' @param archive path to the zip archive to be created.#' 
#' @inheritParams neon_index
#' @importFrom zip zip unzip
#' @export
#' @seealso [neon_import()], [neon_citation()]
#' @examples 
#' 
#' archive <- tempfile()
#' dir <- tempdir()
#' neon_export(archive, dir = dir)
#' 
neon_export <-  function(archive = paste(Sys.Date(), "neonstore.zip", sep="-"),
                         product = NA, 
                         table = NA, 
                         site = NA,
                         start_date = NA,
                         end_date = NA,
                         type = NA,
                         ext = NA,
                         timestamp = NA,
                         hash = NULL,
                         dir = neon_dir()){
  
  meta <- neon_index(product = product,
                     table = table, 
                     site = site, 
                     start_date = start_date,
                     end_date = end_date,
                     type = type,
                     ext = ext,
                     timestamp = timestamp,
                     hash = hash, 
                     dir = dir)
  
  if(is.null(meta)){
    message("No files found.")
    return(invisible(NULL))
  }
  
  if(nrow(meta) == 0){
    message("No files found.")
    return(invisible(NULL))
  }
  
  
  zip::zipr(zipfile = archive, 
            files = meta$path, 
            root = dir, 
            include_directories = TRUE)
  invisible(meta)
}

#' Import a previously exported zip archive of raw NEON files
#' 
#' [neon_import()] only reads in previously saved archives from [neon_export()].
#' This can be useful in cases where 
#' see [neon_download()] to download data directly from NEON.
#' @param archive path to the zip archive to be imported
#' @param overwrite should we overwrite any existing files?
#' @inheritParams neon_index
#' @seealso [neon_export()]
#' @export
#' @examples 
#' 
#' archive <- tempfile()
#' neon_export(archive)
#' neon_import(archive)
#' 
neon_import <- function(archive, overwrite = TRUE, dir = neon_dir()){
  if(!file.exists(archive)){
    warning(paste(archive, "not found"), call. = FALSE)
    return(invisible(NULL))
  }
  if(!dir.exists(dir)) dir.create(dir, FALSE, TRUE)
  zip::unzip(archive, overwrite = overwrite, exdir = dir)
}
