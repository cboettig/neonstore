library(neonstore)
library(DBI)
library(glue)
library(dplyr)


## Export each table to parquet file:
db <- neon_db()
tables <- DBI::dbListTables(db)
dir.create(file.path(neon_dir(), "parquet"), FALSE, FALSE)
dir <- file.path(neon_dir(), "parquet")
## For memory management, we need to disconnect DB each time seems...
neonstore:::neon_disconnect(db)

## Really this could be built into the `neon_store` operation, and allow
## storing in separate parquet files, e.g. maybe product/table-site-month.parquet
## Naming by year/month would potentially streamline updating..
## Sharding might improve speeds too
for(tbl in tables){
  db <- neon_db()
  message(paste("importing", tbl))
  path <- file.path(dir, tbl)
  query <- glue::glue(
  "COPY (SELECT * FROM '{tbl}') TO '{path}.parquet' (FORMAT 'parquet')"
  )
  DBI::dbSendQuery(db, query)
  neonstore:::neon_disconnect(db)
  
}


## Query parquet files directly:

# e.g., beetles table: (Note, file path can be a glob pattern to multiple parquet files)
tbl <- "bet_sorting-expanded-DP1.10022.001"
path <- file.path(dir, paste0(tbl, ".parquet"))

## Use a generic connection:
conn <- dbConnect(duckdb::duckdb())

## Create a "view", leaving data inside Parquet:
query <- glue::glue("CREATE VIEW '{tbl}' AS SELECT * FROM parquet_scan('{path}');")
DBI::dbSendQuery(conn, query)

## Access the view by name:
bet_sorting <- tbl(conn, tbl)
bet_sorting 
