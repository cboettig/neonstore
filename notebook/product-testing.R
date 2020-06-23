library(neonstore)
library(dplyr)

Sys.setenv(NEONSTORE_HOME = "/home/neonstore")

site <- neon_sites()
products <- neon_products()

products <- products %>% filter(productStatus == "ACTIVE")
codes <- products$productCode
length(codes) # 152 active products! (29 more future)


## AND HERE WE GO.  
## (will almost surely run foul of rate limiting -- work by site or something)
## or work by product code at least?
for(p in codes){
  for(s in site$siteCode){
    neon_download(p, file_regex = "[.]zip", site = s, keep_zip = TRUE)
    Sys.sleep(10)
  }
}


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
