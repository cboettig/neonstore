
library(neonstore)
options(duckdb_memory_limit=10)
## Birds
x <- neon_download("DP1.10003.001")

# Beetles
neon_download("DP1.10022.001", type = "expanded") 

# Ticks
tick_sites <- c("BLAN", "ORNL", "SCBI", "SERC", "KONZ", "TALL", "UKFS")
neon_download("DP1.10093.001", site = tick_sites)

#Terrestrial
ter_sites <- c("BART", "KONZ", "SRER", "OSBS")
neonstore::neon_download("DP4.00200.001", table="SWS_30", site = ter_sites, type = "basic")
neonstore::neon_download("DP1.00094.001", site = ter_sites, type = "basic")

#Aquatic
aq_sites <- c("BARC", "POSE")
aq_products <- c("DP1.20053.001","DP1.20288.001", "DP1.20264.001")
neon_download(aq_products, site = aq_sites, type = "basic")


## import into local database
neon_store(product = "DP1.00094.001", table = "SWS_30") # must specify which table!
neon_store(product="DP1.20264.001", table = "TSD_30_min-basic")
neon_store(product = "DP1.10003.001")
neon_store(product = "DP1.10022.001")
neon_store(product = "DP1.10093.001")
neon_store(product ="DP1.20288.001", table = "waq_instantaneous-basic")
neon_store(product ="DP1.20288.001", table = "sensor_positions")
neon_store(product="DP4.00200.001", type = "basic") # hdf5
neon_store(product ="DP1.20053.001") 

# library(dplyr)
# neon_index(product ="DP1.20053.001") %>% count(table)
# neon_index(product = "DP1.10093.001") %>% count(table)
#neon_index(product = "DP1.20264.001") %>% count(table)


##### Aquatics TEAM ###########
focal_sites <- c("BARC", "POSE")
# Will download everything the first time, and then only download updated files:
#Water quality
neonstore::neon_download("DP1.20288.001", site =  focal_sites, type = "basic")
#Precipiation: NOT WORKING!
#neonstore::neon_download("DP1.00006.001", site =  focal_sites, type = "basic")
# Wind Speed
neonstore::neon_download("DP1.20059.001", site =  focal_sites, type = "basic")
# Barometric Pressure
neonstore::neon_download("DP1.20004.001", site =  focal_sites, type = "basic")
# Air Temperature
neonstore::neon_download("DP1.20046.001", site =  focal_sites, type = "basic")
# PAR at water surface
neonstore::neon_download("DP1.20042.001", site =  focal_sites, type = "basic")
# PAR below water surface
neonstore::neon_download("DP1.20261.001", site =  focal_sites, type = "basic")
# Elevation of surface water
neonstore::neon_download("DP1.20016.001", site =  focal_sites, type = "basic")
# Groundwater temperature
neonstore::neon_download("DP1.20217.001", site =  focal_sites, type = "basic")
# Nitrate in surface water
neonstore::neon_download("DP1.20033.001", site =  focal_sites, type = "basic")



# will import downloaded files into local SQL DB:
neonstore::neon_store(product = "DP1.20288.001", type = "basic", n=1000) #Water Quality
#neonstore::neon_store(product = "DP1.00006.001", type = "basic") # Precip
neonstore::neon_store(product = "DP1.20059.001", type = "basic") # Wind Speed
neonstore::neon_store(product = "DP1.20004.001", type = "basic") # pressure
neonstore::neon_store(product = "DP1.20046.001", type = "basic") # temperature
neonstore::neon_store(product = "DP1.20042.001", type = "basic") # PAR surface
neonstore::neon_store(product = "DP1.20261.001", type = "basic") # PAR below
neonstore::neon_store(product = "DP1.20016.001", type = "basic") # Elevation of surface water
neonstore::neon_store(product = "DP1.20217.001", type = "basic") # Groundwater temperature
neonstore::neon_store(product = "DP1.20033.001", type = "basic") # Nitrate

