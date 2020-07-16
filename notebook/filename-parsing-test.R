
cper_data <- readr::read_csv("https://minio.thelio.carlboettiger.info/shared-data/neon_data_catalog.csv.gz")
x <- cper_data$nam
df <- neon_filename_parser(x)
unparsed <- x[ !(x %in% df$name) ] 

## Omit some specific cases
unparsed <- unparsed[! grepl("readme", unparsed)]
unparsed <- unparsed[! grepl("[.]NEF", unparsed)]
unparsed <- unparsed[! grepl("^NEON\\..*", unparsed)]

table(fs::path_ext(unparsed))
