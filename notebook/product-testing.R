library(neonstore)
library(dplyr)

Sys.setenv(NEONSTORE_HOME = "/minio/neonstore")

site <- neon_sites()
products <- neon_products()
products <- products %>% filter(productStatus == "ACTIVE") # 152 active products! (29 more future)

## 76 observational products
observational_data <- products %>% filter(productScienceTeamAbbr %in% c("TOS", "AOS"))
## 76 instrument products
instrument_data  <- products %>% filter(productScienceTeamAbbr %in% c("TIS", "AIS"))
## 29 Airborne products
airborne_data  <- products %>% filter(productScienceTeamAbbr == "AOP")



### Observational Data first: 
#codes <- observational_data$productCode

codes <- observational_data$productCode
length(codes) 
sites <- site$siteCode

## AND HERE WE GO.  
## (will almost surely run foul of rate limiting -- work by site or something)
## or work by product code at least?
i <- 1
datas <- vector("list", length(codes))
some_datas <- vector("list", length(sites))


## Avoid rate limiting by doing one product+site at a time,
## with 10s sleep.  for loop makes checkpoint resume easier too. 

for(p in codes){
  message(paste("product", p))
  j <- 1
  for(s in sites){
   some_datas[[j]] <- neonstore:::neon_data(p,  site = s)
   j <- j+1
   Sys.sleep(10)
  }
  datas[[i]] <- bind_rows(some_datas)
  i <- i+1
  Sys.sleep(10)
}

catalog <- dplyr::bind_rows(datas) %>% dplyr::mutate(size = fs::as_fs_bytes(size)) %>% distinct()
readr::write_csv(catalog, "neon_observation_systems.csv.gz")
catalog %>% dplyr::summarize(total = sum(size))


#for(c in codes){
#  neon_download(c, file_regex = "*", keep_zip = TRUE)
#  Sys.sleep(600)
#}



#### Inspect resulting store

#all_files <- neonstore:::neon_dir() %>% list.files()
#index <- neon_index()

#dropped <- all_files[!(all_files %in% basename(index$path))]
#dropped[!grepl("EML", dropped)]

#product_code <- regmatches(all_files, regexpr("DP\\d\\.\\d{5}\\.\\d{3}", all_files))
#code <- unique(product_code)
#parse_codes <- index %>% select(product) %>% distinct()
#testthat::expect_true( all(parse_code %in% codes) )
