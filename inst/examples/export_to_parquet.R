library(neonstore)
library(DBI)

db <- neon_db()
dbListTables(db)

DBI::dbExecute(db, paste0("PRAGMA memory_limit='", 16, "GB'"))

# set CPU parallel
DBI::dbExecute(db, paste0("PRAGMA threads=", arrow::cpu_count()))

dir.create("neon_parquet")
DBI::dbExecute(db, "EXPORT DATABASE 'neon_parquet' (FORMAT PARQUET);")
