library(neonstore)


index <- neon_index(product="DP4.00200.001", ext = "h5", deprecated = FALSE)

df <- as_tibble(neonstore:::read_eddy(index$path[[1]]))
out <- neonstore:::stack_eddy(index$path[1:4])
df <- neonstore:::neon_stack(index$path)

## Manual extraction
ex <- index$path[[1]]
level <- "dp04"

meta <- tibble::as_tibble(rhdf5::h5ls(ex))
data <- meta[meta$otype == "H5I_DATASET",]
series <- unique(base::paste(data$group, data$name, sep = "/"))
series <- unique(series)
series <- series[ grepl(level, series) ]
series <- series[ !grepl("foot/grid", series) ]
dat <- lapply(series, function(x) rhdf5::h5read(ex, x, read.attributes=T))
## and merge these data tables, 
## adjusting `flux` column name to reflect series name
## Propagate the units information in attributes
## convert datetimes from character strings
rhdf5::h5closeAll()

