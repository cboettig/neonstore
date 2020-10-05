library(neonstore)
library(neonUtilities)

index <- neon_index(product="DP4.00200.001", ext = "h5")



import_hd5 <- function(con, path, table){
   df <- stackEddy(p)
   df$file <- p
   DBI::dbWriteTable(con, table, df)
}