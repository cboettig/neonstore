
Sys.setenv(NEONSTORE_HOME = "/minio/neonstore")
library(neonstore)

## birds, beetles, ticks (all sites)
neon_download(c("DP1.10003.001", "DP1.10022.001", "DP1.10093.001"))


#Terrestrial
ter_sites <- c("BART", "KONZ", "SRER", "OSBS")
neonstore::neon_download(product="DP4.00200.001", type = "basic", site = ter_sites)
neonstore::neon_download(product="DP1.00094.001", site = ter_sites, type="basic")

#Aquatic
aq_sites <- c("BARC", "FLNT")

# no data?
#neonstore::neon_download(product="DP1.20053.001",site = aq_sites)  

neonstore::neon_download(product="DP1.20288.001",site = aq_sites, type = "basic")
neonstore::neon_download("DP1.20264.001", site =  aq_sites, type = "basic")

## import into local database
neon_store(product = "DP1.00094.001", table = "SWS_30") # must specify which table!
neon_store(product="DP1.20264.001", table = "TSD_30_min-basic")
neon_store(product = "DP1.10003.001")
neon_store(product = "DP1.10022.001")
neon_store(product = "DP1.10093.001")
neon_store(product ="DP1.20288.001", table = "waq_instantaneous-basic", n = 10)
neon_store(product ="DP1.20288.001", table = "sensor_positions")
neon_store(product="DP4.00200.001", type = "basic") # hdf5


neon_store(product ="DP1.20053.001")  # no data to download for these sites?

# library(dplyr)
# neon_index(product ="DP1.20053.001") %>% count(table)
# neon_index(product = "DP1.10093.001") %>% count(table)
#neon_index(product = "DP1.20264.001") %>% count(table)
