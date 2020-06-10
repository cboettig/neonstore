## In some tables, metadata from the file name is not contained in the table
## e.g. waq_instantaneous has no indication of the "siteID"


library(neonstore)

## Use neon_index to get individual file names
sites <- c("CRAM") 
index <- neon_index(table = "waq_instantaneous", hash = NULL)

## Filter these paths into groups by site
files_by_site <- 
  lapply(sites, function(site) index$path[grepl(site, index$site)])
names(files_by_site) <- sites

## Read in by groups, using siteID as the .id column
waq <- purrr::map_dfr(files_by_site, 
        function(files) neon_read(files = files), .id="siteID")
 

