
Sys.setenv(NEONSTORE_HOME = "/minio/neonstore")
library(neonstore)


neon_download("DP1.10003.001")

start_date <- NA
#Beetle
neonstore::neon_download(product="DP1.10022.001", type = "expanded", start_date = start_date)

#Ticks
neonstore::neon_download(product="DP1.10093.001", type = "expanded", start_date = start_date)

#Terrstrial
sites <- c("BART", "KONZ", "SRER", "OSBS")
neonstore::neon_download(product="DP4.00200.001", site = sites, type = "basic", start_date = start_date)

#Aquatic
#DP1.20053.001
#DP1.20288.001

sites <- c("BARC", "FLNT")
neonstore::neon_download(product="DP1.20053.001",site = sites, type = "expanded", start_date = start_date)
neonstore::neon_download(product="DP1.20288.001",site = sites, type = "expanded", start_date = start_date)

