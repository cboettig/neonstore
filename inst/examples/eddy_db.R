library(neonstore)
library(neonUtilities)
library(dplyr)
library(duckdb)

index <- neon_index(product="DP4.00200.001", ext = "h5")
table <- unique(index$table)

df <- neonUtilities::stackEddy(path)

import_hd5 <- function(path, con, table){
   suppressMessages({
     out <- neonUtilities::stackEddy(path)
   })
  
   df <- out[[1]]
   df$siteID <- names(out[1])
   df$file <- basename(path)
   dbWriteTable(con, table, df, append = TRUE)

}

con <- neon_db()
lapply(index$path, import_hd5, con=con, table=table)
