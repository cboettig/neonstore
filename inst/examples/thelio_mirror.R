
Sys.setenv(NEONSTORE_HOME = "/minio/neonstore")
library(neonstore)

## birds, beetles, ticks (all sites)
neon_download(c("DP1.10003.001", "DP1.10022.001", "DP1.10093.001"))


#Terrestrial
ter_sites <- c("BART", "KONZ", "SRER", "OSBS")
neonstore::neon_download(product="DP4.00200.001", site = ter_sites)
neonstore::neon_download(product="DP1.00094.001", site = ter_sites, type="basic")

#Aquatic
aq_sites <- c("BARC", "FLNT")
neonstore::neon_download(product="DP1.20053.001",site = aq_sites)
neonstore::neon_download(product="DP1.20288.001",site = aq_sites)


## import into local database
neon_store(product = "DP1.00094.001", table = "SWS_30")

neon_store(product = "DP1.10003.001")
neon_store(product = "DP1.10022.001")
neon_store(product = "DP1.10093.001")
neon_store(product ="DP1.20288.001")
neon_store(product ="DP1.20053.001")
# neon_store(product="DP4.00200.001") # hdf5
