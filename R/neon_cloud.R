
#' neon cloud
#' 
#' @inheritParams neon_download
#' @param table NEON table name
#' @param unify_schemas if cloud-read fails to collect data due to miss-matched
#' schemas, set this to `TRUE`. Warning: Results in much slower reads and may
#' demand more memory due to parsing the schema of each file, especially when
#' many files are involved. 
#' @return lazy data frame
#' @export
neon_cloud <-function(table,
                      product, 
                      start_date = NA,
                      end_date = NA,
                      site = NA,
                      type = "basic",
                      release = NA,
                      quiet = FALSE,
                      api = "https://data.neonscience.org/api/v0", 
                      unify_schemas = FALSE,
                      .token = Sys.getenv("NEON_TOKEN")){
  
  df <- neon_data(product, start_date, end_date, site, type, release,
                  quiet, api, .token = .token)
  
  # df <- neon_data(product = "DP1.10003.001", type="basic")
  # table = "brd_countdata"
  
  urls <- df$url[ grepl(table, df$name) ]
  
  # Parse most recent first. Reduces the chance of int/char coercion failures
  # when hitting an all-empty column
  meta <- neon_filename_parser(urls)
  chrono <- order(meta$GENTIME, decreasing = TRUE)
  urls <- urls[chrono]
  ## discover or enforce extension
  
  ## Detect product type from `meta` and dispatch appropriately.
  
  # https://duckdb.org/docs/data/csv/overview.html
  # consider igonore_errors=1 as possible fallback? (drops those rows entirely, ick)
  # consider all_varchar=1 as possible fallback (possibly avoided by coercion after parsing in chrono order?)
  df <- duckdbfs::open_dataset(urls, format = "csv", filename = TRUE,
                               unify_schemas = unify_schemas)
  
  
  
  
}

  



neon_urls <- function(table,
                      product, 
                      start_date = NA,
                      end_date = NA,
                      site = NA,
                      type = NA,
                      release = NA,
                      quiet = FALSE,
                      api = "https://data.neonscience.org/api/v0", 
                      .token = Sys.getenv("NEON_TOKEN")){
  
  
  
}
