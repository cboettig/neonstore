





x <- c(
  "NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T154457Z.csv",
  "NEON.D01.BART.DP0.10003.001.validation.20191107T152154Z.csv",
  "NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.basic.20191107T154457Z.csv",
  "NEON.D01.BART.DP1.10003.001.brd_references.expanded.20191107T152154Z.csv",
  "NEON.D01.BART.DP1.10003.001.2019-06.basic.20191205T150213Z.zip",
  "NEON.D01.HARV.DP1.10022.001.bet_sorting.2014-06.basic.20200504T173728Z.csv",
  "NEON.D03.SUGG.DP1.20288.001.103.100.100.waq_instantaneous.2018-01.expanded.20190618T023102Z.csv",
  "NEON.D01.HARV.DP4.00200.001.nsae.2020-03-31.expanded.20200513T102531Z.h5"
)




text_extract <-
  function(
    x,
    pattern,
    ignore.case = FALSE,
    perl        = FALSE,
    fixed       = FALSE,
    useBytes    = FALSE,
    invert      = FALSE
  ){
    regmatches(
      x,
      regexpr(
        pattern     = pattern,
        text        = x,
        ignore.case = ignore.case,
        perl        = perl,
        fixed       = fixed,
        useBytes    = useBytes
      ),
      invert = invert
    )
  }




neon_filename_parser <- function(x){
  site_regex <- "^(NEON\\.D\\d{2}\\.\\w{4})\\.(.*)$"
  product_regex <- "^(DP\\d\\.\\d{5}\\.\\d{3})\\.(.*)$"
  ext_regex <- "(.*)(\\.\\w+$)"  
  timestamp_regex <- "(.*)\\.(:?\\d{8}T\\d{6}Z)?"
  type_regex <- "(.*)\\.(:?basic|expanded)?"
  month_regex <- "(.*)\\.(\\d{4}-\\d{2})"
  name_regex <- "(.*)\\.(:?\\w+)"
  
  site <- t(site_regex, "\\1", x)
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