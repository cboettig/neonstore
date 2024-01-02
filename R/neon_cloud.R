
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
  
  urls <- neon_urls(table, product, start_date, end_date, site, type, release,
                    quiet, api, .token = .token)
  
  format <- gsub(".*\\.(\\w+)$", "\\1", urls)
  if(all(format == "csv")) {
    df <- cloud_csv(urls, unify_schemas = unify_schemas)
  } else {
    stop("Only csv formatted data are accessible without download at this time.")
  }
  
  df
}
 

cloud_csv <- function(urls, unify_schemas = FALSE) {   
  # Parse most recent first. Reduces the chance of int/char coercion failures
  # when hitting an all-empty column
  #timestamp <- neon_filename_parser(urls)$GENTIME
  timestamp <- gsub(paste0(".*", GENTIME, "\\..*"), "\\1", urls)
  chrono <- order(timestamp, decreasing = TRUE)
  urls <- urls[chrono]
  ## discover or enforce extension
  ## Detect product type from `meta` and dispatch appropriately.
  
  # https://duckdb.org/docs/data/csv/overview.html
  # consider all_varchar=1 as possible fallback
  
  # (possibly avoided by coercion after parsing in chrono order?)
  df <- duckdbfs::open_dataset(urls, format = "csv", filename = TRUE,
                               unify_schemas = unify_schemas)
  cols <- colnames(df)
  
  # sensor metdata
  if(! "siteID" %in% cols) {
    df <- df |> dplyr::mutate(
      file = split_part(filename, "/", 9L), 
      siteID = regexp_extract(file, IS_DATA, 3L),
      domainID = regexp_extract(file, IS_DATA, 2L),
      horizontalPosition= regexp_extract(file, IS_DATA, 7L),
      verticalPosition = regexp_extract(file, IS_DATA, 8L)
      )
  }
  df
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
  
  cache <- cachem::cache_disk(tempdir())
  neon_data_mem <- memoise::memoise(neon_data, cache = cache)
  
  df <- neon_data_mem(product, 
                  start_date, 
                  end_date, 
                  site, 
                  type, 
                  release,
                  quiet, 
                  api, 
                  .token = .token)
  urls <- df$url[ grepl(table, df$name) ]
  
}




globalVariables(c("regexp_extract", "split_part", "filename"),
                package = "neonstore")
