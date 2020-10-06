
read_eddy <- function(x, progress = FALSE, ...){
  progress_sink <- tempfile()
  suppressMessages({
    sink(progress_sink) ## ugh, neonUtilities uses print()
    out <- neonUtilities::stackEddy(x, ...)
    sink()
  })
  ## FIXME extract data from the other tables too
  df <- out[[1]]
  df$siteID <- names(out[1])
  df$file <- basename(x)
  df
}  

stack_eddy <- function(files, ...){
  requireNamespace("neonUtilities", quietly = TRUE)
  groups <-  lapply(files, read_eddy, ...)
  df <- ragged_bind(groups)
  suppressWarnings(sink()) # make sure sink is off!
}