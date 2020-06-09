library(neonstore)
library(dplyr)
site <- neon_sites()
products <- neon_products()
products <- products %>% filter(productStatus == "ACTIVE")
codes <- products$productCode
length(codes) # 152 active products! (29 more future)

#neon_download(codes, start_date = "2020-01-01", site = c("HARV", "BART"))
neon_download(codes, start_date = "2020-01-01")

all_files <- neonstore:::neon_dir() %>% list.files()
product_code <- gsub(".*(DP\\d\\.\\d{5}\\.\\d{3}).*", "\\1", all_files)
code <- unique(product_code)

index <- neon_index(hash=NULL)
parse_codes <- index %>% select(product) %>% distinct()

neon_store()

#suggs <- neon_read("waq_instantaneous")

#neon_download("DP1.20288.001", site = "SUGG")
#neon_download("DP1.10045.001", site = "MLBS")
#neon_store(product = "DP1.20288.001")
#neon_store(product = "DP1.10045.001")


