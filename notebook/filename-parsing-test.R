
cper_data <- readr::read_csv("https://minio.thelio.carlboettiger.info/shared-data/neon_data_catalog.csv.gz")
x <- cper_data$name
df <- neonstore:::neon_filename_parser(x)

unparsed <- x[ !(x %in% df$name) ] 

## Omit some specific cases
table(fs::path_ext(unparsed))
unparsed <- unparsed[! grepl("readme", unparsed)]
## .NEF files and others that don't start with NEON, we ignore for now:
unparsed <- unparsed[grepl("^NEON", unparsed)]
## Weird creatures:
table(fs::path_ext(unparsed))
