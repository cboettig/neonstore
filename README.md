
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
#>  6 DP1.10026.001 Plant foliar traits                                      
#>  7 DP1.10033.001 Litterfall and fine woody debris production and chemistry
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
#>   comparing hashes against local file index...
#>   updating release manifest...
```

View your store of NEON products:

``` r
neon_index()
#> # A tibble: 854 x 15
#>    product  site  table   type  ext   month timestamp           horizontalPosit…
#>    <chr>    <chr> <chr>   <chr> <chr> <chr> <dttm>                         <dbl>
#>  1 DP1.100… BART  brd_co… basic csv   2015… 2020-12-23 14:17:30               NA
#>  2 DP1.100… BART  brd_co… basic csv   2016… 2020-12-23 14:17:14               NA
#>  3 DP1.100… BART  brd_co… basic csv   2017… 2020-12-23 14:17:36               NA
#>  4 DP1.100… BART  brd_co… basic csv   2018… 2020-12-23 14:17:21               NA
#>  5 DP1.100… BART  brd_co… basic csv   2019… 2020-12-23 14:17:45               NA
#>  6 DP1.100… BART  brd_co… basic csv   2020… 2020-12-23 14:17:03               NA
#>  7 DP1.100… BART  brd_co… basic csv   2020… 2020-12-23 14:17:41               NA
#>  8 DP1.100… BART  brd_pe… basic csv   2015… 2020-12-23 14:17:30               NA
#>  9 DP1.100… BART  brd_pe… basic csv   2016… 2020-12-23 14:17:14               NA
#> 10 DP1.100… BART  brd_pe… basic csv   2017… 2020-12-23 14:17:36               NA
#> # … with 844 more rows, and 7 more variables: verticalPosition <dbl>,
#> #   samplingInterval <chr>, date_range <chr>, path <chr>, md5 <chr>,
#> #   crc32 <chr>, release <chr>
```

These files will persist between sessions, so you only need to download
once or to retrieve updates. `neon_index()` can take arguments to filter
by product or pattern (regular expression) in table name,
e.g. `neon_index(table = "brd")`.

Once you determine the table of interest, you can read in all the
component tables into a single `data.frame`

``` r
neon_read("brd_countdata-expanded")
#> NULL
```

## Database backend

`neonstore` now supports a backend relation database as well. Import
data from the raw downloaded files using `neon_store()`:

``` r
neon_store(table = "brd_countdata-expanded")
#> table brd_countdata-expanded not found, do you need to download first?
```

Alternately, we could import all data tables associated with a given
product:

``` r
neon_store(product = "DP1.10003.001")
#>   importing brd_countdata-basic-DP1.10003.001...
#>   importing brd_perpoint-basic-DP1.10003.001...
```

Access an imported table using `neon_table()` instead of `neon_read()`:

``` r
neon_table("brd_countdata")
#> # A tibble: 203,220 x 23
#>    uid                namedLocation     domainID siteID plotID plotType  pointID
#>    <chr>              <chr>             <chr>    <chr>  <chr>  <chr>     <chr>  
#>  1 01cef6c1-5851-407… HEAL_006.birdGri… D19      HEAL   HEAL_… distribu… C1     
#>  2 43990e9a-1412-427… HEAL_006.birdGri… D19      HEAL   HEAL_… distribu… C1     
#>  3 d4f59f3c-e3f1-4a7… HEAL_006.birdGri… D19      HEAL   HEAL_… distribu… C1     
#>  4 4ad44b7d-1eb6-465… HEAL_006.birdGri… D19      HEAL   HEAL_… distribu… C1     
#>  5 944a3e0e-08de-497… HEAL_006.birdGri… D19      HEAL   HEAL_… distribu… C1     
#>  6 d4cb0f22-923b-449… HEAL_006.birdGri… D19      HEAL   HEAL_… distribu… C1     
#>  7 0cc69b4f-650f-4f7… HEAL_006.birdGri… D19      HEAL   HEAL_… distribu… B1     
#>  8 c6367f2f-8b74-402… HEAL_006.birdGri… D19      HEAL   HEAL_… distribu… B1     
#>  9 406e8277-2c18-4b2… HEAL_006.birdGri… D19      HEAL   HEAL_… distribu… B1     
#> 10 ef879541-c8d5-41c… HEAL_006.birdGri… D19      HEAL   HEAL_… distribu… B1     
#> # … with 203,210 more rows, and 16 more variables: startDate <dttm>,
#> #   eventID <chr>, pointCountMinute <dbl>, targetTaxaPresent <chr>,
#> #   taxonID <chr>, scientificName <chr>, taxonRank <chr>, vernacularName <chr>,
#> #   observerDistance <dbl>, detectionMethod <chr>, visualConfirmation <chr>,
#> #   sexOrAge <chr>, clusterSize <dbl>, clusterCode <chr>, identifiedBy <chr>,
#> #   file <chr>
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
brd <- tbl(con, "brd_countdata-basic-DP1.10003.001")
brd %>% filter(siteID == "ORNL")
#> # A tibble: 8,797 x 23
#>    uid                namedLocation     domainID siteID plotID plotType  pointID
#>    <chr>              <chr>             <chr>    <chr>  <chr>  <chr>     <chr>  
#>  1 33425600-9ce1-4a9… ORNL_002.birdGri… D07      ORNL   ORNL_… distribu… A1     
#>  2 faf5ee98-43e9-40f… ORNL_002.birdGri… D07      ORNL   ORNL_… distribu… A1     
#>  3 2dc63a4a-3da1-4e0… ORNL_002.birdGri… D07      ORNL   ORNL_… distribu… A1     
#>  4 7952192b-55b4-48f… ORNL_002.birdGri… D07      ORNL   ORNL_… distribu… A1     
#>  5 41bf843e-3433-4d0… ORNL_002.birdGri… D07      ORNL   ORNL_… distribu… A1     
#>  6 e88d8ada-e43a-409… ORNL_002.birdGri… D07      ORNL   ORNL_… distribu… A1     
#>  7 04604bac-dd88-4d1… ORNL_002.birdGri… D07      ORNL   ORNL_… distribu… A1     
#>  8 05a8d535-3f59-413… ORNL_002.birdGri… D07      ORNL   ORNL_… distribu… A1     
#>  9 b5cccafa-acbf-41e… ORNL_002.birdGri… D07      ORNL   ORNL_… distribu… A1     
#> 10 63d9e30e-ab6c-41b… ORNL_002.birdGri… D07      ORNL   ORNL_… distribu… A1     
#> # … with 8,787 more rows, and 16 more variables: startDate <dttm>,
#> #   eventID <chr>, pointCountMinute <dbl>, targetTaxaPresent <chr>,
#> #   taxonID <chr>, scientificName <chr>, taxonRank <chr>, vernacularName <chr>,
#> #   observerDistance <dbl>, detectionMethod <chr>, visualConfirmation <chr>,
#> #   sexOrAge <chr>, clusterSize <dbl>, clusterCode <chr>, identifiedBy <chr>,
#> #   file <chr>
```

Note that we need to include the product name in the table name when
accessing the database, as table names alone may not be unique. RStudio
users can also list and explore all tables interactively in the
Connections pane in RStudio using `neon_pane()`.

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
