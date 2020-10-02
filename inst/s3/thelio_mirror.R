Sys.setenv(NEONSTORE_HOME = "/minio/neonstore")
library(neonstore)

## demo
neon_download("DP1.10003.001")

#Beetle
neonstore::neon_download(product="DP1.10022.001")

#Ticks
neonstore::neon_download(product="DP1.10093.001")

#Terrestrial
sites <- c("BART", "KONZ", "SRER", "OSBS")
neonstore::neon_download(product="DP4.00200.001", site = sites)

#Aquatic
sites <- c("BARC", "FLNT")
neonstore::neon_download(product="DP1.20053.001",site = sites)
neonstore::neon_download(product="DP1.20288.001",site = sites)

