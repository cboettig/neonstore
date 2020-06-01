
<!-- README.md is generated from README.Rmd. Please edit that file -->

# neonstore

<!-- badges: start -->

[![R build
status](https://github.com/cboettig/neonstore/workflows/R-CMD-check/badge.svg)](https://github.com/cboettig/neonstore/actions)
<!-- badges: end -->

The goal of neonstore is to provide quick access and persistent storage
of NEON data tables.

## Installation

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/neonstore")
```

## Quickstart

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
library(neonstore)
neon_download("DP1.10003.001")
```

Now, view your store of NEON products. These will persist between
sessions, so you only need to download once, or to retrieve updates.
(Note: the individual files making up a data product can all be listed
by `neon_index()`).

``` r
neon_store()
#>  [1] "validation"                      "categoricalCodes"               
#>  [3] "brd_countdata"                   "brd_perpoint"                   
#>  [5] "brd_references"                  "readme"                         
#>  [7] "variables"                       "mos_archivepooling"             
#>  [9] "mos_barcoding"                   "mos_expertTaxonomistIDProcessed"
#> [11] "mos_expertTaxonomistIDRaw"       "mos_sorting"                    
#> [13] "mos_trapping"                    "mam_perplotnight"               
#> [15] "mam_pertrapnight"                "tck_fielddata"                  
#> [17] "tck_taxonomyProcessed"           "tck_taxonomyRaw"                
#> [19] "inv_fieldData"                   "inv_persample"                  
#> [21] "inv_pervial"                     "inv_taxonomyProcessed"          
#> [23] "inv_taxonomyRaw"                 "zoo_fieldData"                  
#> [25] "zoo_perVial"                     "zoo_taxonomyProcessed"          
#> [27] "zoo_taxonomyRaw"
```

Read in all the component tables into a single data.frame

``` r
neon_read("brd_countdata")
#> Rows: 164,782
#> Columns: 24
#> Delimiter: ","
#> chr  [19]: uid, namedLocation, domainID, siteID, plotID, plotType, pointID, eventID, targe...
#> dbl  [ 3]: pointCountMinute, observerDistance, clusterSize
#> lgl  [ 1]: clusterCode
#> dttm [ 1]: startDate
#> 
#> Use `spec()` to retrieve the guessed column specification
#> Pass a specification to the `col_types` argument to quiet this message
#> # A tibble: 164,782 x 24
#>    uid   namedLocation domainID siteID plotID plotType pointID
#>    <chr> <chr>         <chr>    <chr>  <chr>  <chr>    <chr>  
#>  1 ad84… BART_025.bir… D01      BART   BART_… distrib… C1     
#>  2 2115… BART_025.bir… D01      BART   BART_… distrib… C1     
#>  3 0592… BART_025.bir… D01      BART   BART_… distrib… C1     
#>  4 8e5a… BART_025.bir… D01      BART   BART_… distrib… C1     
#>  5 9b07… BART_025.bir… D01      BART   BART_… distrib… C1     
#>  6 145f… BART_025.bir… D01      BART   BART_… distrib… B1     
#>  7 f70e… BART_025.bir… D01      BART   BART_… distrib… B1     
#>  8 648b… BART_025.bir… D01      BART   BART_… distrib… B1     
#>  9 2295… BART_025.bir… D01      BART   BART_… distrib… B1     
#> 10 cc6d… BART_025.bir… D01      BART   BART_… distrib… A1     
#> # … with 164,772 more rows, and 17 more variables: startDate <dttm>,
#> #   eventID <chr>, pointCountMinute <dbl>, targetTaxaPresent <chr>,
#> #   taxonID <chr>, scientificName <chr>, taxonRank <chr>, vernacularName <chr>,
#> #   family <chr>, nativeStatusCode <chr>, observerDistance <dbl>,
#> #   detectionMethod <chr>, visualConfirmation <chr>, sexOrAge <chr>,
#> #   clusterSize <dbl>, clusterCode <lgl>, identifiedBy <chr>
```

## Details

`neon_download()` will omit downloads of any existing data files. You
can request multiple products at once using vector notation. You can
optionally include date filters, e.g. to request only records more
recent than a certain date. Doing so will preserve API quota and improve
speed (see API limits, below).

Because `neonstore` only stores raw data products as returned from the
NEON API, this makes it easy to track provenance and compare results
across other analyses of the NEON data.

## Note on API limits

[The NEON API now rate-limits
requests.](https://data.neonscience.org/data-api/rate-limiting/#api-tokens).
Using a personal token will increase the number of requests you can
make. See that link for directions on registering for a token. Then pass
this token in `.token` argument of `neon_download()`, or for frequent
use, add this token as an environmental variable, `NEON_DATA` to your
local `.Renviron` file in your user’s home directory.

`neon_download()` must first query each the API of eacn NEON site which
collects that product, for each month the product is collected.  
(It would be much more efficient on the NEON server if the API could
take queries of the from \`/data/<product>/<site>, and pool the results,
rather than require each month of sampling separately\!)
