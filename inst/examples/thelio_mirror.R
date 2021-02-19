
library(neonstore)

## birds, beetles, ticks (all sites)
neon_download_s3("DP1.10003.001")
neon_download_s3("DP1.10022.001", type = "expanded")

# Ticks
tick_sites <- c("BLAN", "ORNL", "SCBI", "SERC", "KONZ", "TALL", "UKFS")
neon_download_s3("DP1.10093.001", site = tick_sites)

#Terrestrial
ter_sites <- c("BART", "KONZ", "SRER", "OSBS")
neonstore::neon_download_s3("DP4.00200.001", table="SWS_30", site = ter_sites, type = "basic")
neonstore::neon_download_s3("DP1.00094.001", site = ter_sites, type = "basic")

#Aquatic
aq_sites <- c("BARC", "POSE")
aq_products <- c("DP1.20053.001","DP1.20288.001", "DP1.20264.001")
neon_download_s3(aq_products, site = aq_sites, type = "basic")


## import into local database
neon_store(product = "DP1.00094.001", table = "SWS_30", n = 50) # must specify which table!
neon_store(product="DP1.20264.001", table = "TSD_30_min-basic")
neon_store(product = "DP1.10003.001")
neon_store(product = "DP1.10022.001")
neon_store(product = "DP1.10093.001")
neon_store(product ="DP1.20288.001", table = "waq_instantaneous-basic", n = 10)
neon_store(product ="DP1.20288.001", table = "sensor_positions")
neon_store(product="DP4.00200.001", type = "basic") # hdf5
neon_store(product ="DP1.20053.001") 

# library(dplyr)
# neon_index(product ="DP1.20053.001") %>% count(table)
# neon_index(product = "DP1.10093.001") %>% count(table)
#neon_index(product = "DP1.20264.001") %>% count(table)
