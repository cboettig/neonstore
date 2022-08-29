## 02_generate_targets_aquatics
## Process the raw data into the target variable produc
library(neonstore)
library(tidyverse)

# aquatics
sites <- read_csv("https://raw.githubusercontent.com/eco4cast/neon4cast-aquatics/master/Aquatic_NEON_Field_Site_Metadata_20210928.csv")
aq_sites <- sites$field_site_id
neonstore::neon_download("DP1.20288.001", site = aq_sites) # water quality
neonstore::neon_download("DP1.20264.001", table ='30', site =  aq_sites)
neonstore::neon_download("DP1.20053.001", table ='30', site =  aq_sites)
neonstore::neon_store(table = "waq_instantaneous", n = 50)
neonstore::neon_store(table = "TSD_30_min")
neonstore::neon_store(table = "TSW_30min")

# beetles
neonstore::neon_download(product="DP1.10022.001", type = "expanded")
neonstore::neon_store(product = "DP1.10022.001")

## Terrestrial
sites <- read_csv("https://raw.githubusercontent.com/eco4cast/neon4cast-terrestrial/master/Terrestrial_NEON_Field_Site_Metadata_20210928.csv")
ter_sites <- sites$field_site_id
print("Downloading: DP4.00200.001")
neonstore::neon_download(product = "DP4.00200.001", site = ter_sites, type = "basic")
neonstore::neon_store(product = "DP4.00200.001") 

#  Ticks
product <- "DP1.10093.001"
sites.df <- read_csv("https://raw.githubusercontent.com/eco4cast/neon4cast-ticks/master/Ticks_NEON_Field_Site_Metadata_20210928.csv")
tick_sites <- sites.df %>% pull(field_site_id)
neon_download(product = product, site = tick_sites)
neonstore::neon_store(product =  "DP1.10093.001") 


# Terrestrial covariates

neon_download(product = "DP1.00006.001", site = ter_sites, table = "THRPRE_30min-basic") # Precip, thoughfall
neon_download(product = "DP1.00098.001", site = ter_sites, table = "RH_30min") # Humidity, note two different sensor positions
neon_download(product = "DP1.00003.001", site = ter_sites, table= "TAAT_30min") # Temp (triple-aspirated)
neon_download(product = "DP1.00002.001", site = ter_sites, table="SAAT_30min-basic") #Temp single aspirated
neon_download(product = "DP1.00023.001", site = ter_sites, table = "SLRNR_30min-basic") # Short and long wave radiation
neon_download(product = "DP1.00006.001", site = ter_sites, table = "SECPRE_30min-basic") # Precipitation secondary
neon_download(product = "DP1.00100.001") #empty?

neon_store(product = "DP1.00006.001", table = "THRPRE_30min-basic") # Precip, thoughfall
neon_store(product = "DP1.00098.001", table = "RH_30min") # Humidity, note two different sensor positions
neon_store(product = "DP1.00003.001", table= "TAAT_30min") # Temp (triple-aspirated)
neon_store(product = "DP1.00002.001", table="SAAT_30min-basic") #Temp single aspirated
neon_store(product = "DP1.00023.001", table = "SLRNR_30min-basic") # Short and long wave radiation
neon_store(product = "DP1.00006.001", table = "SECPRE_30min-basic") # Precipitation secondary
neon_store(product = "DP1.00100.001") #empty?


# Aquatic covariates:
neon_download(product = "DP1.20059.001", site = aq_sites) # Wind Speed
neon_download(product = "DP1.20004.001", site = aq_sites) # pressure
neon_download(product = "DP1.20046.001", site = aq_sites) # temperature
neon_download(product = "DP1.20042.001", site = aq_sites) # PAR surface
neon_download(product = "DP1.20261.001", site = aq_sites) # PAR below
neon_download(product = "DP1.20016.001", site = aq_sites) # Elevation of surface water
neon_download(product = "DP1.20217.001", site = aq_sites) # Groundwater temperature
neon_download(product = "DP1.20033.001", site = aq_sites) # Nitrate
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
neon_download(product = "DP4.00001.001") # Summary weather
neon_download("DP1.00003.001", table = "30") # Temp
neon_download("DP1.00006.001", table = "30") # Precipitation (terrestrial sites)
neon_download("DP1.00098.001", table = "30") # Humidity (includes temp)
neon_store(product = "DP4.00001.001") # Summary weather
neon_store("DP1.00003.001") # Temp
neon_store("DP1.00006.001") # Precipitation (terrestrial sites)
neon_store("DP1.00098.001") # Humidity (includes temp)
