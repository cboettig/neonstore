
<!-- README.md is generated from README.Rmd. Please edit that file -->

# neonstore

<!-- badges: start -->

[![R build
status](https://github.com/cboettig/neonstore/workflows/R-CMD-check/badge.svg)](https://github.com/cboettig/neonstore/actions)
[![Codecov test
coverage](https://codecov.io/gh/cboettig/neonstore/branch/master/graph/badge.svg)](https://codecov.io/gh/cboettig/neonstore?branch=master)
<!-- badges: end -->

`neonstore` provides quick access and persistent storage of NEON data
tables.

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

Now, view your store of NEON products:

``` r
neon_store()
#> [1] "validation-"             "brd_countdata-expanded" 
#> [3] "brd_perpoint-basic"      "brd_references-expanded"
#> [5] "readme-"                 "variables-"
```

These will persist between sessions, so you only need to download once
or to retrieve updates. `neon_store()` can take arguments to filter by
product or pattern in table name, e.g. `neon_store(table = "brd")`.

Once you determine the table of interest, you can read in all the
component tables into a single `data.frame`

``` r
neon_read("brd_countdata-expanded")
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

## Provenance

Because `neonstore` only stores raw data products as returned from the
NEON API, it can easily determine which files have already been
downloaded, and only download new files without requiring the user to
specify specific dates. (It must still query the API for all the
metadata in the requested date range). This same modular approach also
makes it easy to track *data provenance*, an essential element of
reproduciblity in comparing results across other analyses of the NEON
data.

We can list precisely which component files are being read in by
`neon_read()` by consulting `neon_index()`:

``` r
raw_files <- neon_index(table = "brd_countdata-expanded")
raw_files
#> # A tibble: 204 x 9
#>    site   product  table   month  type   timestamp ext   path          hash     
#>    <chr>  <chr>    <chr>   <chr>  <chr>  <chr>     <chr> <chr>         <chr>    
#>  1 NEON.… DP1.100… brd_co… 2015-… expan… 20191107… csv   /tmp/Rtmpwrk… hash://m…
#>  2 NEON.… DP1.100… brd_co… 2016-… expan… 20191107… csv   /tmp/Rtmpwrk… hash://m…
#>  3 NEON.… DP1.100… brd_co… 2017-… expan… 20191107… csv   /tmp/Rtmpwrk… hash://m…
#>  4 NEON.… DP1.100… brd_co… 2018-… expan… 20191107… csv   /tmp/Rtmpwrk… hash://m…
#>  5 NEON.… DP1.100… brd_co… 2019-… expan… 20191205… csv   /tmp/Rtmpwrk… hash://m…
#>  6 NEON.… DP1.100… brd_co… 2015-… expan… 20191107… csv   /tmp/Rtmpwrk… hash://m…
#>  7 NEON.… DP1.100… brd_co… 2015-… expan… 20191107… csv   /tmp/Rtmpwrk… hash://m…
#>  8 NEON.… DP1.100… brd_co… 2016-… expan… 20191107… csv   /tmp/Rtmpwrk… hash://m…
#>  9 NEON.… DP1.100… brd_co… 2017-… expan… 20191107… csv   /tmp/Rtmpwrk… hash://m…
#> 10 NEON.… DP1.100… brd_co… 2018-… expan… 20191107… csv   /tmp/Rtmpwrk… hash://m…
#> # … with 194 more rows
```

`neon_read()` is a relatively trivial function that simply passes this
file list to `vroom::vroom()`, a fast, vectorized parser that can easily
read in a single table that is broken into many separate files.

Imagine instead that we use the common pattern of downloading these raw
files, stacks and possibly cleans the data, saving only this derived
product while discarding the individual files. Now imagine a second
researcher, at some later date, queries the API over the same reported
range of dates and sites, uses the same software package to stack the
tables, only to discover the resulting table is somehow different from
ours (e.g. by comparing file hashes). Pinpointing the source of the
discrepancy would be challenging and labor-intensive.

In contrast, the same detective-work would be easy with the `neonstore`
file list. We can confirm if the API had returned the same number of raw
files with the same names; and better, can verify integrity of the
contents by comparing hashes of files now being returned to those
recorded by `neon_index()`. In this way, we could determine if any
additional files had been included or pinpoint any files that may have
changed.

As such, users might want to store the `neon_index()` `data.frame` for
the table(s) they have used as part of their analysis, including the
individual file hashes. One can also generate a zip of all the data
files for archival purposes. (Note that NEON is an Open Data provider,
see
[LICENCE](https://www.neonscience.org/data/about-data/data-policies).)

``` r
write.csv(raw_files, "index.csv")
zip("brd_countdata.zip", raw_files$path)
```

## Data citation

Generate the appropriate citation for your data:

``` r
neon_citation()
#> National Ecological Observatory Network (2020). "Data Products:
#> NEON.DP0.10003.001 NEON.DP1.10003.001 . Provisional data downloaded
#> from http://data.neonscience.org on 05 Jun 2020."
```

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
