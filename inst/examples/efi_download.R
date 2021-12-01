library(neonstore)
library(dplyr)



## Aquatics
aq_sites <- c("BARC", "POSE")
neon_download("DP1.20288.001",site = aq_sites)
neon_store(table = "waq_instantaneous")
neon_download("DP1.20264.001", site =  aq_sites, table = "TSD_30_min") 
neon_store(table = "TSD_30_min")
neon_download("DP1.20053.001", site =  aq_sites, table = "TSW_30min")
neon_store(table = "TSW_30min")


## Beetles
neon_download(product="DP1.10022.001", type = "expanded")
neon_store(product = "DP1.10022.001")


## Ticks
# tick data product, target sites, and dates
tck_sites <- c("BLAN", "ORNL", "SCBI", "SERC", "KONZ", "TALL", "UKFS")
tck_enddate <- "2019-12-31"
neon_download(product = "DP4.00001.001", site = tck_sites, end_date = tck_enddate)
neon_download(product = "DP1.10093.001", site = tck_sites, end_date = tck_enddate)
neon_store(table = "tck_taxonomyProcessed-basic")
neon_store(table = "tck_fielddata-basic")



## Terrestrial
ter_sites <- c("BART", "KONZ", "SRER", "OSBS")
neon_download(product = "DP4.00200.001", site = ter_sites)
neon_store(product = "DP4.00200.001")
neon_download(product = "DP1.00094.001", site = ter_sites, table = "SWS_30_minute")
neon_store(table = "SWS_30_minute") 
neon_store(product = "DP1.00094.001")


