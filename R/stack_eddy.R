
read_eddy <- function(x, pb = NULL, eddy_progress = FALSE, ...){
  if(!is.null(pb)) pb$tick()
  progress_sink <- tempfile()
  suppressWarnings({
  suppressMessages({
    sink(progress_sink) ## ugh, neonUtilities uses print()
    out <- neonUtilities::stackEddy(x, ...)
    sink()
  })
  })
  ## FIXME extract data from the other tables too
  df <- out[[1]]
  df$siteID <- names(out[1])
  df$file <- basename(x)
  df
}  

stack_eddy <- function(files, progress = TRUE, ...){
  requireNamespace("neonUtilities", quietly = TRUE)
  
  pb <- NULL
  if(progress){
    pb <- progress::progress_bar$new(
      format = paste("  stacking h5 files",
                     "[:bar] :percent in :elapsed, eta: :eta"),
      total = length(files), 
      clear = FALSE, 
      width = 80)
  }
  
  
  groups <-  lapply(files, read_eddy, pb = pb, ...)
  suppressWarnings(sink()) # make sure sink is off!
  df <- ragged_bind(groups)
  df
}