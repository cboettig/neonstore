bench::bench_time({
  
library(neonstore)
options(duckdb_memory_limit=10)
## Birds
new_birds <- neon_download("DP1.10003.001")

# Beetles
new_beetles <- neon_download("DP1.10022.001", type = "expanded") 

# Ticks
tick_sites <- c("BLAN", "ORNL", "SCBI", "SERC", "KONZ", "TALL", "UKFS")
new_ticks <- neon_download("DP1.10093.001", site = tick_sites)

#Terrestrial
ter_sites <- c("BART", "KONZ", "SRER", "OSBS")
new_ter_sw <- neon_download("DP1.00094.001", table = "SWS_30_minute", site = ter_sites)  ## SWS
new_ter_flux <- neon_download("DP4.00200.001", site = ter_sites) #h5

#Aquatic
aq_sites <- c("BARC", "POSE")
aq_products <- c("DP1.20053.001","DP1.20288.001")
new_aq <- neon_download(aq_products, site = aq_sites)
new_aq_tsd <- neon_download("DP1.20264.001", table = "TSD_30_min", site = aq_sites)

## SQL Import
neon_store(product = "DP1.10003.001") # Birds
neon_store(product = "DP1.10022.001") # Beetles
neon_store(product = "DP1.10093.001") # Ticks

## Aquatics SQL Import
neon_store(product = aq_products) 
neon_store(product="DP1.20264.001", table = "TSD_30")

## Terrestrial SQL Import
neon_store(product = "DP1.00094.001", table = "SWS_30")
neon_store(product="DP4.00200.001") # hdf5

# library(dplyr)
# neon_index(product ="DP1.20053.001") %>% count(table)
# neon_index(product = "DP1.10093.001") %>% count(table)
#neon_index(product = "DP1.20264.001") %>% count(table)


##### Aquatics TEAM ###########
focal_sites <- c("BARC", "POSE")
# Will download everything the first time, and then only download updated files:
#Water quality
neon_download("DP1.20288.001", site =  focal_sites)
#Precipiation: NO data at these sites?
neon_download("DP1.00006.001", site =  focal_sites)
# Wind Speed
neon_download("DP1.20059.001", site =  focal_sites)
# Barometric Pressure
neon_download("DP1.20004.001", site =  focal_sites)
# Air Temperature
neon_download("DP1.20046.001", site =  focal_sites)
# PAR at water surface
neon_download("DP1.20042.001", site =  focal_sites)
# PAR below water surface
neon_download("DP1.20261.001", site =  focal_sites)
# Elevation of surface water
neon_download("DP1.20016.001", site =  focal_sites)
# Groundwater temperature
neon_download("DP1.20217.001", site =  focal_sites)
# Nitrate in surface water
neon_download("DP1.20033.001", site =  focal_sites)



# will import downloaded files into local SQL DB:
neon_store(product = "DP1.20288.001") #Water Quality
neon_store(product = "DP1.00006.001") # Precip
neon_store(product = "DP1.20059.001") # Wind Speed
neon_store(product = "DP1.20004.001") # pressure
neon_store(product = "DP1.20046.001") # temperature
neon_store(product = "DP1.20042.001") # PAR surface
neon_store(product = "DP1.20261.001") # PAR below
neon_store(product = "DP1.20016.001") # Elevation of surface water
neon_store(product = "DP1.20217.001") # Groundwater temperature
neon_store(product = "DP1.20033.001") # Nitrate


})
