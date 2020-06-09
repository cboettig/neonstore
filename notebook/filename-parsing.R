
neon_filename_parser <- function(x){
  site_regex <- "^(NEON\\.D\\d{2}\\.\\w{4})\\.(.*)$"
  product_regex <- "^(DP\\d\\.\\d{5}\\.\\d{3})\\.(.*)$"
  ext_regex <- "(.*)(\\.\\w+$)"  
  timestamp_regex <- "(.*)\\.(:?\\d{8}T\\d{6}Z)?"
  type_regex <- "(.*)\\.(:?basic|expanded)?"
  month_regex <- "(.*)\\.(\\d{4}-\\d{2})"
  name_regex <- "(.*)\\.(:?\\w+)"
  
  site <- gsub(site_regex, "\\1", x)
  x <- gsub(site_regex, "\\2", x)
  site[x == site] <- ""  ## if string is unchanged it should mean no match
  
  product <- gsub(product_regex, "\\1", x)
  x <- gsub(product_regex, "\\2", x)
  product[x == product] <- ""  ## if string is unchanged it should mean no match
  
  
  
  ext <- gsub(ext_regex, "\\2", x)
  x <- gsub(ext_regex, "\\1", x)
  timestamp <- gsub(timestamp_regex, "\\2", x)
  x <- gsub(timestamp_regex, "\\1", x)
  timestamp[x == timestamp] <- ""
  
  
  type <- gsub(type_regex, "\\2", x)
  x <- gsub(type_regex, "\\1", x)
  type[x == type] <- ""  ## if string is unchanged it should mean no match
  
  month <- gsub(month_regex, "\\2", x)
  x <- gsub(month_regex, "\\1", x)
  month[x == month] <- ""  ## if string is unchanged it should mean no match
  
  
  name <- gsub(name_regex, "\\1", x)
  x <- gsub(name_regex, "", x)
  misc <- x
  
  data.frame(site, product, type, timestamp, month, name, misc)  
  regex <- paste0(site, productCode, name, month, type, timestamp, ext)
  regex
}