
<!-- README.md is generated from README.Rmd. Please edit that file -->

# neonstore

<!-- badges: start -->

[![R build
status](https://github.com/cboettig/neonstore/workflows/R-CMD-check/badge.svg)](https://github.com/cboettig/neonstore/actions)
[![Codecov test
coverage](https://codecov.io/gh/cboettig/neonstore/branch/master/graph/badge.svg)](https://codecov.io/gh/cboettig/neonstore?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/neonstore)](https://CRAN.R-project.org/package=neonstore)
<!-- badges: end -->

`neonstore` provides quick access and persistent storage of NEON data
tables. `neonstore` emphasizes simplicity and a clean data provenance
trail, see Provenance section below.

## Installation

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/neonstore")
```

## Quickstart

``` r
library(neonstore)
```

Discover data products of interest:

``` r
products <- neon_products()

i <- grepl("Populations", products$themes)
products[i, c("productCode", "productName")]
#> # A tibble: 50 x 2
#>    productCode   productName                                  
#>    <chr>         <chr>                                        
#>  1 DP1.00033.001 Phenology images                             
#>  2 DP1.10003.001 Breeding landbird point counts               
#>  3 DP1.10010.001 Coarse downed wood log survey                
#>  4 DP1.10020.001 Ground beetle sequences DNA barcode          
#>  5 DP1.10022.001 Ground beetles sampled from pitfall traps    
#>  6 DP1.10026.001 Plant foliar physical and chemical properties
#>  7 DP1.10033.001 Litterfall and fine woody debris sampling    
#>  8 DP1.10038.001 Mosquito sequences DNA barcode               
#>  9 DP1.10041.001 Mosquito-borne pathogen status               
#> 10 DP1.10043.001 Mosquitoes sampled from CO2 traps            
#> # … with 40 more rows
 
i <- grepl("bird", products$keywords)
products[i, c("productCode", "productName")]
#> # A tibble: 1 x 2
#>   productCode   productName                   
#>   <chr>         <chr>                         
#> 1 DP1.10003.001 Breeding landbird point counts
```

Download all data files in the bird survey data products.

``` r
neon_download("DP1.10003.001")
```

View your store of NEON products:

``` r
neon_index()
#> # A tibble: 1,632 x 11
#>    product site  table type  ext   month timestamp           horizontalPosit…
#>    <chr>   <chr> <chr> <chr> <chr> <chr> <dttm>              <lgl>           
#>  1 DP1.10… ABBY  brd_… expa… csv   2017… 2019-11-07 15:33:41 NA              
#>  2 DP1.10… ABBY  brd_… basic csv   2017… 2019-11-07 15:33:41 NA              
#>  3 DP1.10… ABBY  brd_… expa… csv   2017… 2019-11-07 15:17:46 NA              
#>  4 DP1.10… ABBY  brd_… basic csv   2017… 2019-11-07 15:17:46 NA              
#>  5 DP1.10… ABBY  brd_… expa… csv   2018… 2019-11-07 15:34:24 NA              
#>  6 DP1.10… ABBY  brd_… basic csv   2018… 2019-11-07 15:34:24 NA              
#>  7 DP1.10… ABBY  brd_… expa… csv   2018… 2019-11-07 15:34:20 NA              
#>  8 DP1.10… ABBY  brd_… basic csv   2018… 2019-11-07 15:34:20 NA              
#>  9 DP1.10… ABBY  brd_… expa… csv   2019… 2019-12-05 15:01:51 NA              
#> 10 DP1.10… ABBY  brd_… basic csv   2019… 2019-12-05 15:01:51 NA              
#> # … with 1,622 more rows, and 3 more variables: verticalPosition <lgl>,
#> #   samplingInterval <lgl>, path <chr>
```

These files will persist between sessions, so you only need to download
once or to retrieve updates. `neon_index()` can take arguments to filter
by product or pattern (regular expression) in table name,
e.g. `neon_index(table = "brd")`.

Once you determine the table of interest, you can read in all the
component tables into a single `data.frame`

``` r
neon_read("brd_countdata-expanded")
#> # A tibble: 164,782 x 24
#>    uid   namedLocation domainID siteID plotID plotType pointID
#>    <chr> <chr>         <chr>    <chr>  <chr>  <chr>    <chr>  
#>  1 ae11… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  2 399d… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  3 d3e0… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  4 6bab… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  5 a4ae… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  6 c663… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  7 d4b1… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  8 1a68… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  9 a823… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#> 10 0c8a… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#> # … with 164,772 more rows, and 17 more variables: startDate <dttm>,
#> #   eventID <chr>, pointCountMinute <dbl>, targetTaxaPresent <chr>,
#> #   taxonID <chr>, scientificName <chr>, taxonRank <chr>, vernacularName <chr>,
#> #   family <chr>, nativeStatusCode <chr>, observerDistance <dbl>,
#> #   detectionMethod <chr>, visualConfirmation <chr>, sexOrAge <chr>,
#> #   clusterSize <dbl>, clusterCode <chr>, identifiedBy <chr>
```

## Database backend

`neonstore` now supports a backend relation database as well. Import
data from the raw downloaded files using `neon_store()`:

``` r
neon_store(table = "brd_countdata-expanded")
```

Alternately, we could import all data tables associated with a given
product:

``` r
neon_store(product = "DP1.10003.001")
#> Some raw files were detected with updated timestamps.
#>  Using only most updated file to avoid duplicates.
```

Access an imported table using `neon_table()` instead of `neon_read()`:

``` r
neon_table("brd_countdata-expanded")
#> # A tibble: 164,782 x 25
#>    uid   namedLocation domainID siteID plotID plotType pointID
#>    <chr> <chr>         <chr>    <chr>  <chr>  <chr>    <chr>  
#>  1 ae11… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  2 399d… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  3 d3e0… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  4 6bab… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  5 a4ae… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  6 c663… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  7 d4b1… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  8 1a68… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#>  9 a823… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#> 10 0c8a… LAJA_017.bas… D04      LAJA   LAJA_… distrib… 21     
#> # … with 164,772 more rows, and 18 more variables: startDate <dttm>,
#> #   eventID <chr>, pointCountMinute <dbl>, targetTaxaPresent <chr>,
#> #   taxonID <chr>, scientificName <chr>, taxonRank <chr>, vernacularName <chr>,
#> #   family <chr>, nativeStatusCode <chr>, observerDistance <dbl>,
#> #   detectionMethod <chr>, visualConfirmation <chr>, sexOrAge <chr>,
#> #   clusterSize <dbl>, clusterCode <chr>, identifiedBy <chr>, file <chr>
```

Access the remote database using `neon_db()`. This is a `DBIConnection`
that can easily be used with `dplyr` functions like `tbl()` or
`filter()`.  
Remember that `dplyr` translates these into SQL queries that run
directly on the database.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

con <- neon_db()
brd <- tbl(con, "brd_countdata-expanded")
brd %>% filter(siteID == "ORNL")
#> # A tibble: 7,041 x 25
#>    uid   namedLocation domainID siteID plotID plotType pointID
#>    <chr> <chr>         <chr>    <chr>  <chr>  <chr>    <chr>  
#>  1 bf07… ORNL_002.bir… D07      ORNL   ORNL_… distrib… B3     
#>  2 2bec… ORNL_002.bir… D07      ORNL   ORNL_… distrib… B3     
#>  3 a384… ORNL_002.bir… D07      ORNL   ORNL_… distrib… B3     
#>  4 2a12… ORNL_002.bir… D07      ORNL   ORNL_… distrib… B3     
#>  5 cee1… ORNL_002.bir… D07      ORNL   ORNL_… distrib… B3     
#>  6 0b52… ORNL_002.bir… D07      ORNL   ORNL_… distrib… B3     
#>  7 71c7… ORNL_002.bir… D07      ORNL   ORNL_… distrib… B3     
#>  8 a62b… ORNL_002.bir… D07      ORNL   ORNL_… distrib… B3     
#>  9 3793… ORNL_002.bir… D07      ORNL   ORNL_… distrib… B3     
#> 10 364b… ORNL_002.bir… D07      ORNL   ORNL_… distrib… B3     
#> # … with 7,031 more rows, and 18 more variables: startDate <dttm>,
#> #   eventID <chr>, pointCountMinute <dbl>, targetTaxaPresent <chr>,
#> #   taxonID <chr>, scientificName <chr>, taxonRank <chr>, vernacularName <chr>,
#> #   family <chr>, nativeStatusCode <chr>, observerDistance <dbl>,
#> #   detectionMethod <chr>, visualConfirmation <chr>, sexOrAge <chr>,
#> #   clusterSize <dbl>, clusterCode <chr>, identifiedBy <chr>, file <chr>
```

## Note on API limits

If `neon_download()` exceeds the API request limit (with or without the
token), `neonstore` will simply pause for the required amount of time to
avoid rate-limit-based errors.

[The NEON API now rate-limits
requests.](https://data.neonscience.org/data-api/rate-limiting/#api-tokens).
Using a personal token will increase the number of requests you can make
before encountering this delay. See link for directions on registering
for a token. Then pass this token in `.token` argument of
`neon_download()`, or for frequent use, add this token as an
environmental variable, `NEON_DATA` to your local `.Renviron` file in
your user’s home directory. `neon_download()` must first query each the
API of each NEON site which collects that product, for each month the
product is collected.

(It would be much more efficient on the NEON server if the API could
take queries of the from `/data/<product>/<site>`, and pool the results,
rather than require each month of sampling separately\!)
