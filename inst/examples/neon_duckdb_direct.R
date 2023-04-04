# Grab URLs for a product
library(neonstore)
library(dplyr)

#tblname <- "brd_countdata"
tblname <- "waq_instantaneous"
df <- neonstore:::neon_data(product = "DP1.20288.001",
                            start_date = "2021-01-01",  # subset for demo purposes
                            site = c("BARC"),
                            type="basic") 
format_urls <- function(x) {
  paste(paste0("'", x, "'"),  sep="", collapse = ", ")
}
files <- df |>
  filter(grepl(tblname, name)) |>
  pull(url) |> format_urls()


# access by duckdb
conn <- DBI::dbConnect(duckdb::duckdb())
DBI::dbExecute(conn, "INSTALL 'httpfs';")
DBI::dbExecute(conn, "LOAD 'httpfs';")


view_query <- glue::glue("CREATE VIEW '{tblname}' ",
                         "AS SELECT * FROM read_csv_auto([{files}],IGNORE_ERRORS=1);")
bench::bench_time({
  DBI::dbSendQuery(conn, view_query)
  df <- tbl(conn, tblname) 
  print(df) 
})





df <- neonstore:::neon_data(product = "DP4.00200.001",
                            start_date = "2023-01-01",
                            site = c("BART", "YELL"),
                            type="basic") |>
  filter(grepl("nsae", name)) 

library(stars)
url <- df$url[[1]]
download.file(url, basename(url))
r <- stars::read_stars(paste0("/vsigzip//vsicurl/", url))

stars::read_ncdf("NEON.D01.BART.DP4.00200.001.nsae.2023-01.basic.20230207T201518Z.h5")
