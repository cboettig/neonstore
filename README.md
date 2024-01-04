
<!-- README.md is generated from README.Rmd. Please edit that file -->

# neonstore

<!-- badges: start -->

[![R build
status](https://github.com/cboettig/neonstore/workflows/R-CMD-check/badge.svg)](https://github.com/cboettig/neonstore/actions)
[![Codecov test
coverage](https://codecov.io/gh/cboettig/neonstore/branch/master/graph/badge.svg)](https://app.codecov.io/gh/cboettig/neonstore?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/neonstore)](https://CRAN.R-project.org/package=neonstore)
[![R-CMD-check](https://github.com/cboettig/neonstore/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cboettig/neonstore/actions/workflows/R-CMD-check.yaml)
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
library(tidyverse)
```

Discover data products of interest:

``` r
products <- neon_products()
products |>
  filter(str_detect(keywords, "bird")) |> 
  select(productName, productCode)
#> # A tibble: 1 × 2
#>   productName                    productCode  
#>   <chr>                          <chr>        
#> 1 Breeding landbird point counts DP1.10003.001
```

You may also prefer to explore the [NEON Data
Portal](https://data.neonscience.org/) website interactively.

## Download-based workflow

Once we have identified a data product code, we can download all
associated data files, e.g. in the bird survey data. Optionally, we can
restrict this download to a set of sites or date ranges of interest,
(see function documentation for details).

``` r
neon_download("DP1.10003.001")
#>   comparing hashes against local file index...
#>   updating release manifest...
```

View your store of NEON products:

``` r
neon_index()
#> # A tibble: 1,214 × 15
#>    product  site  table type  ext   month timestamp           horizontalPosition
#>    <chr>    <chr> <chr> <chr> <chr> <chr> <dttm>                           <dbl>
#>  1 DP1.100… BART  brd_… basic csv   2015… 2022-11-22 18:06:13                 NA
#>  2 DP1.100… BART  brd_… basic csv   2016… 2022-11-22 18:28:29                 NA
#>  3 DP1.100… BART  brd_… basic csv   2017… 2022-11-22 18:51:55                 NA
#>  4 DP1.100… BART  brd_… basic csv   2018… 2022-11-28 18:02:03                 NA
#>  5 DP1.100… BART  brd_… basic csv   2019… 2022-11-28 18:54:56                 NA
#>  6 DP1.100… BART  brd_… basic csv   2020… 2022-11-28 21:00:18                 NA
#>  7 DP1.100… BART  brd_… basic csv   2020… 2022-11-28 21:57:32                 NA
#>  8 DP1.100… BART  brd_… basic csv   2021… 2022-11-29 23:48:16                 NA
#>  9 DP1.100… BART  brd_… basic csv   2022… 2023-12-29 05:32:56                 NA
#> 10 DP1.100… BART  brd_… basic csv   2015… 2022-11-22 18:06:13                 NA
#> # ℹ 1,204 more rows
#> # ℹ 7 more variables: verticalPosition <dbl>, samplingInterval <chr>,
#> #   date_range <chr>, path <chr>, md5 <chr>, crc32 <chr>, release <chr>
```

These files will persist between sessions, so you only need to download
once or to retrieve updates. `neon_index()` can take arguments to filter
by product or pattern (regular expression) in table name,
e.g. `neon_index(table = "brd")`.

## Database backend

`neonstore` now supports a backend relation database as well. Import
data from the raw downloaded files using `neon_store()`:

``` r
neon_store(product = "DP1.10003.001")
#>   importing brd_countdata-basic-DP1.10003.001...
#>   importing brd_perpoint-basic-DP1.10003.001...
```

Access an imported table using `neon_table()` instead of `neon_read()`:

``` r
neon_table("brd_countdata")
#> # A tibble: 289,038 × 24
#>    uid                     namedLocation domainID siteID plotID plotType pointID
#>    <chr>                   <chr>         <chr>    <chr>  <chr>  <chr>    <chr>  
#>  1 f7fa2f5a-5b07-4ac0-83b… TREE_022.bas… D05      TREE   TREE_… distrib… 21     
#>  2 84c1e17a-945d-46fa-a1f… TREE_022.bas… D05      TREE   TREE_… distrib… 21     
#>  3 4063e302-4b9a-45ff-9a6… TREE_022.bas… D05      TREE   TREE_… distrib… 21     
#>  4 53e2c631-d1e1-4156-b1f… TREE_022.bas… D05      TREE   TREE_… distrib… 21     
#>  5 51cdba5c-64a9-4abf-aff… TREE_022.bas… D05      TREE   TREE_… distrib… 21     
#>  6 d742982a-1052-4d3f-bb6… TREE_022.bas… D05      TREE   TREE_… distrib… 21     
#>  7 2c86f910-5cba-4dc0-adf… TREE_022.bas… D05      TREE   TREE_… distrib… 21     
#>  8 dbf436ae-89af-46ac-980… TREE_022.bas… D05      TREE   TREE_… distrib… 21     
#>  9 da7d0c2a-6d06-4748-a21… TREE_022.bas… D05      TREE   TREE_… distrib… 21     
#> 10 23938ad7-76fc-4e48-a67… TREE_022.bas… D05      TREE   TREE_… distrib… 21     
#> # ℹ 289,028 more rows
#> # ℹ 17 more variables: startDate <dttm>, eventID <chr>, pointCountMinute <dbl>,
#> #   targetTaxaPresent <chr>, taxonID <chr>, scientificName <chr>,
#> #   taxonRank <chr>, vernacularName <chr>, observerDistance <dbl>,
#> #   detectionMethod <chr>, visualConfirmation <chr>, sexOrAge <chr>,
#> #   clusterSize <dbl>, clusterCode <chr>, identifiedBy <chr>,
#> #   identificationHistoryID <chr>, file <chr>
```

Note that we need to include the product name in the table name when
accessing the database, as table names alone may not be unique. RStudio
users can also list and explore all tables interactively in the
Connections pane in RStudio using the function `neon_pane()`.

## Larger-than-RAM data

When working across data from many sites or years simultaneously, it is
easy for data to be too big for R to fit into working memory. This is
especially true when working with sensor data. `neonstore` makes it easy
to work with such data using dplyr-operations though. Just include the
option `lazy = TRUE`, and [most
dplyr](https://dbplyr.tidyverse.org/reference/index.html) operations
will execute quickly on disk instead (by leveraging the `dbplyr` backend
and the power of the `duckdb` database).

``` r
brd <- neon_table("brd_countdata", lazy=TRUE)
# unique species per site?
brd |> 
  distinct(siteID, scientificName) |> 
  count(siteID, sort=TRUE) |> 
  collect()
#> # A tibble: 47 × 2
#>    siteID     n
#>    <chr>  <dbl>
#>  1 WOOD     154
#>  2 CLBJ     134
#>  3 UNDE     124
#>  4 DCFS     123
#>  5 OAES     120
#>  6 KONZ     120
#>  7 SJER     117
#>  8 ORNL     116
#>  9 HARV     111
#> 10 SRER     111
#> # ℹ 37 more rows
```

Use the function `collect()` at the end of a chain of dplyr functions to
bring the resulting data into R.

## NEW: Cloud-based workflow

It is now possible to access data directly from NEON’s cloud storage
system without downloading. (Note: this still must ping the NEON API to
obtain the most recent list of files, and this list is subject to rate
limits). Like the local database approach, this strategy works for
larger-than-RAM data, and can be substantially faster than downloading.
However, if you work frequently with the same data products and have
ample disk space available, you will find the one-time wait for
downloading to be faster.

``` r
brd <- neon_cloud("brd_countdata", product="DP1.10003.001")

brd |> 
  distinct(siteID, scientificName) |> 
  count(siteID, sort=TRUE) |> 
  collect()
#> # A tibble: 47 × 2
#>    siteID     n
#>    <chr>  <dbl>
#>  1 WOOD     154
#>  2 CLBJ     134
#>  3 UNDE     124
#>  4 DCFS     123
#>  5 OAES     120
#>  6 KONZ     120
#>  7 SJER     117
#>  8 ORNL     116
#>  9 HARV     111
#> 10 SRER     111
#> # ℹ 37 more rows
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
rather than require each month of sampling separately!)

## Non-stacking files and low-level interface

At it’s core, `neonstore` is simply a mechanism to download files from
the NEON API. While the `.csv` files from the Observation Systems (OS,
e.g. bird count surveys), and Instrument Systems (e.g. aquatic sensors)
are typically stacked into large tables, other products, such as the
`.laz` and `.tif` images produced by the airborne observation platform
(AOP) sensors such as LIDAR and cameras still require the user to work
directly with the downloaded files returned by `neon_index()`. Note that
the local database can process Eddy Covariance data (h5 files), but at
present this does not work with `neon_cloud()`.
