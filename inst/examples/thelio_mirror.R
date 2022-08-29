bench::bench_time({

  library(neonstore)
  message(neon_dir())
  message(neon_db_dir())
  
  
  mem_limit <- function(db = neon_db(), mem_limit = 16, units = "GB"){
    DBI::dbExecute(db, paste0("PRAGMA memory_limit='", mem_limit, " ", units,"'"))
  }
  
  enable_parallel <- function(db = neon_db(), duckdb_cores = arrow::cpu_count()){
    DBI::dbExecute(db, paste0("PRAGMA threads=", arrow::cpu_count()))
  }
  
  db <- neon_db(read_only = FALSE)
  
  mem_limit(db)
  enable_parallel(db)
  
  
# neonstore::neon_delete_db()

tick_sites <- c("BLAN", "ORNL", "SCBI", "SERC", "KONZ", "TALL", "UKFS")
ter_sites <- c("BART", "KONZ", "SRER", "OSBS")
aq_sites <- c("BARC", "POSE")

new_birds <- neon_download("DP1.10003.001") # Birds
new_beetles <- neon_download("DP1.10022.001", type = "expanded")  # Beetles
new_ticks <- neon_download("DP1.10093.001", site = tick_sites)  # Ticks
new_ter_sw <- neon_download("DP1.00094.001", table = "SWS_30_minute", site = ter_sites)  ## SWS
new_ter_flux <- neon_download("DP4.00200.001", site = ter_sites) #h5
new_aq <- neon_download(c("DP1.20053.001","DP1.20288.001"), site = aq_sites)
new_aq_tsd <- neon_download("DP1.20264.001", table = "TSD_30_min", site = aq_sites)

# Aquatics Meteorology
neon_download("DP1.20288.001", site =  aq_sites) # Water quality
neon_download("DP1.20059.001", site =  aq_sites) # Wind Speed
neon_download("DP1.20004.001", site =  aq_sites) # Barometric Pressure
neon_download("DP1.20046.001", site =  aq_sites) # Air Temperature
neon_download("DP1.20042.001", site =  aq_sites) # PAR at water surface
neon_download("DP1.20261.001", site =  aq_sites) # PAR below water surface
neon_download("DP1.20016.001", site =  aq_sites) # Elevation of surface water
neon_download("DP1.20217.001", site =  aq_sites) # Groundwater temperature
neon_download("DP1.20033.001", site =  aq_sites) # Nitrate in surface water

## Terrestrial meteorology
neon_download(product = "DP1.00002.001", site = ter_sites, type = "basic", table = "30") #Temp single aspirated
neon_download(product = "DP1.00006.001", site = ter_sites, type = "basic", table = "30") #
neon_download(product = "DP1.00007.001", site = ter_sites, type = "basic") # Precip, thoughfall
neon_download(product = "DP1.00023.001", site = ter_sites, type = "basic") #
neon_download(product = "DP2.00024.001", site = ter_sites, type = "basic") #
neon_download(product = "DP1.00100.001", site = ter_sites, type = "basic") #

# Shared meteorology, 30min data (Beetles / all sites)
neon_download("DP4.00001.001") # summary weather
neon_download("DP1.00003.001", table = "30") # Temp
neon_download("DP1.00006.001", table = "30") # Precipitation (terrestrial sites)
neon_download("DP1.00098.001", table = "30") # Humidity (includes temp)

################################

## SQL Import
neon_store(product = "DP1.10003.001") # Birds
neon_store(product = "DP1.10022.001", type = "expanded") # Beetles
neon_store(product = "DP1.10093.001") # Ticks

## Aquatics SQL Import
neon_store(product =c("DP1.20053.001","DP1.20288.001"))
neon_store(product="DP1.20264.001", table = "TSD_30")

## Terrestrial SQL Import
neon_store(product = "DP1.00094.001", table = "SWS_30")
neon_store(product="DP4.00200.001") # hdf5

# Terrestrial meteorology
neon_store(product = "DP1.00006.001", table = "THRPRE_30min-basic") # Precip, thoughfall
neon_store(product = "DP1.00098.001", table = "RH_30min") # Humidity, note two different sensor positions
neon_store(product = "DP1.00003.001", table= "TAAT_30min") # Temp (triple-aspirated)
neon_store(product = "DP1.00002.001", table="SAAT_30min-basic") #Temp single aspirated
neon_store(product = "DP1.00023.001", table = "SLRNR_30min-basic") # Short and long wave radiation
neon_store(product = "DP1.00006.001", table = "SECPRE_30min-basic") # Precipitation secondary
neon_store(product = "DP1.00100.001") #empty


# Aquatic meteorology:
neon_store(product = "DP1.20288.001") #Water Quality
neon_store(product = "DP1.20059.001") # Wind Speed
neon_store(product = "DP1.20004.001") # pressure
neon_store(product = "DP1.20046.001") # temperature
neon_store(product = "DP1.20042.001") # PAR surface
neon_store(product = "DP1.20261.001") # PAR below
neon_store(product = "DP1.20016.001") # Elevation of surface water
neon_store(product = "DP1.20217.001") # Groundwater temperature
neon_store(product = "DP1.20033.001") # Nitrate

# Shared meteorology (all sites, slow!)
neon_store(product = "DP4.00001.001") # Summary weather
neon_store("DP1.00003.001", table = "30") # Temp
neon_store("DP1.00006.001", table = "30") # Precipitation (terrestrial sites)
neon_store("DP1.00098.001", table = "30") # Humidity (includes temp)


neon_export_db()

})

s3 <- arrow::s3_bucket("targets/neon", endpoint_override="data.ecoforecast.org")
neon_sync_db(s3)
s3$ls() 

## Peak at the readme for a product.  Consider a README fn?  open in viewer?
# index %>% filter(product == "DP1.00003.001", table=="readme") %>% pull(path) %>% getElement(1) %>% usethis::edit_file()
