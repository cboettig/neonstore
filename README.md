
<!-- README.md is generated from README.Rmd. Please edit that file -->

# neonstore

<!-- badges: start -->

[![R build
status](https://github.com/cboettig/neonstore/workflows/R-CMD-check/badge.svg)](https://github.com/cboettig/neonstore/actions)
[![Codecov test
coverage](https://codecov.io/gh/cboettig/neonstore/branch/master/graph/badge.svg)](https://codecov.io/gh/cboettig/neonstore?branch=master)
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
#> # A tibble: 5 x 3
#>   product       table                   n_files
#>   <chr>         <chr>                     <int>
#> 1 DP1.10003.001 brd_countdata-expanded      204
#> 2 DP1.10003.001 brd_perpoint-expanded       204
#> 3 DP1.10003.001 brd_references-expanded      47
#> 4 DP0.10003.001 validation                  204
#> 5 DP1.10003.001 variables                     1
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

Two other functions access additional API endpoints that may also be of
interest. `neon_sites()` returns a `data.frame` of site information,
including site descriptions and the ecological domain that each site
falls into:

``` r
neon_sites()
#> # A tibble: 81 x 11
#>    siteCode siteName siteDescription siteType siteLatitude siteLongitude
#>    <chr>    <chr>    <chr>           <chr>           <dbl>         <dbl>
#>  1 ABBY     Abby Ro… Abby Road       RELOCAT…         45.8        -122. 
#>  2 ARIK     Arikare… Arikaree River  CORE             39.8        -102. 
#>  3 BARC     Barco L… Barco Lake      CORE             29.7         -82.0
#>  4 BARR     Utqiaġv… Utqiaġvik       RELOCAT…         71.3        -157. 
#>  5 BART     Bartlet… Bartlett Exper… RELOCAT…         44.1         -71.3
#>  6 BIGC     Upper B… Upper Big Creek RELOCAT…         37.1        -119. 
#>  7 BLAN     Blandy … Blandy Experim… RELOCAT…         39.0         -78.0
#>  8 BLDE     Blackta… Blacktail Deer… CORE             45.0        -111. 
#>  9 BLUE     Blue Ri… Blue River      RELOCAT…         34.4         -96.6
#> 10 BLWA     Black W… Black Warrior … RELOCAT…         32.5         -87.8
#> # … with 71 more rows, and 5 more variables: stateCode <chr>, stateName <chr>,
#> #   domainCode <chr>, domainName <chr>, dataProducts <list>
```

Lastly, `neon_products()` returns a table with a list of all neon
products, which may be useful for data discovery or additional metadata
about any given product:

``` r
neon_products()
#> # A tibble: 181 x 15
#>    productCode productName productDescript… productStatus themes keywords
#>    <chr>       <chr>       <chr>            <chr>         <chr>  <chr>   
#>  1 DP1.00001.… 2D wind sp… Two-dimensional… ACTIVE        Atmos… sonic a…
#>  2 DP1.00002.… Single asp… Air temperature… ACTIVE        Atmos… air tem…
#>  3 DP1.00003.… Triple asp… Air temperature… ACTIVE        Atmos… air tem…
#>  4 DP1.00004.… Barometric… Barometric pres… ACTIVE        Atmos… aquatic…
#>  5 DP1.00005.… IR biologi… Infrared temper… ACTIVE        Atmos… leaf | …
#>  6 DP1.00006.… Precipitat… Precipitation i… ACTIVE        Atmos… precipi…
#>  7 DP1.00007.… 3D wind sp… Three-dimension… FUTURE        Atmos… sonic a…
#>  8 DP1.00010.… 3D wind at… Measurement of … FUTURE        Atmos… azimuth…
#>  9 DP1.00013.… Wet deposi… Total dissolved… ACTIVE        Atmos… precipi…
#> 10 DP1.00014.… Shortwave … Total, direct b… ACTIVE        Atmos… solar r…
#> # … with 171 more rows, and 9 more variables: productCategory <chr>,
#> #   productAbstract <chr>, productDesignDescription <chr>,
#> #   productRemarks <chr>, productSensor <chr>,
#> #   productPublicationFormatType <chr>, productHasExpanded <lgl>,
#> #   productBasicDescription <chr>, productExpandedDescription <chr>
```

## Design Details / comparison to `neonUtilities`

`neonstore` is not meant as a replacement to the `neonUtilities` package
developed by NEON staff. `neonUtilities` performs a range of
product-specific data querying, parsing, and data manipulation beyond
what is provided by NEON’s API or web interface. `neonUtilities` also
provides other utilities for working with NEON data beyond the scope of
the NEON API or the data download/ingest process. While this processing
is undoubtedly useful, it may make it difficult to compare results or
analyses based on data downloaded and accessed using `neonUtilities` R
package with analyses based on data accessed directly from the web
interface, the API, or another tool (or even a different release of the
`neonUtilities`).

By contrast, `neonstore` aims to do far less. `neonstore` merely
automates the download of individual NEON data files. In contrast to
`neonUtilities` which by default “stacks” these raw files into single
tables and discards the raw data, `neonstore` preserves only the raw
files in the store, stacking the individual tables “on demand” using
`neon_read()`. `neon_read()` is a thin wrapper around the `vroom`
package, [Hester & Wickham, 2020](https://vroom.r-lib.org), which uses
the `altrep` mechanism in R to provide very fast reads of rectangular
text data into R, and trivially handles the case of a single table being
broken across many files. Some NEON tables are not entirely consistent
in their use of columns across the individual site-month files, so
`neon_read()` transparently checks for this, reading in groups of files
sharing all matching columns with `vroom` before binding the groups
together. This makes it easier to always trace an analysis back to the
original input data, makes it easier to update input data files without
facing the challenge of either downloading & stacking the whole data
product from scratch again or having to keep track of some previously
downloaded data file.

A few other differences are also worth noting.

  - `neonstore` aims to provide persistent storage, writing raw data
    files to the appropriate app directory for your operating system
    (see `rappdirs`, [Ratnakumar et
    al 2016](https://CRAN.R-project.org/package=rappdirs)). More details
    about this can be found in Provenance, below.
  - `neon_download()` provides clean and concise progress bars for the
    two key processes involved: querying the API to obtain download URLs
    (which involves no large data transfer but counts against API rate
    limiting, see below), and the actual file downloads.
  - `neon_download()` will verify the integrity of file downloads
    against the MD5 hashes provided.
  - `neon_download()` will omit downloads of any existing data files in
    the local store.  
  - You can request multiple products at once using vector notation,
    though API rate limiting may interfere with large requests.
  - `neon_download()` uses `curl::curl_download()` instead of
    `downloadr` package used in `neonUtilities`, which can be finicky on
    Windows and older versions of R.
  - `neonstore` has slightly lighter dependencies: only `vroom` and
    `httr`, and packages already used by one of those two (`curl`,
    `openssl`).

Like `neonUtilities`, You can optionally include site and date filters,
e.g. to request only records more recent than a certain date. Doing so
will preserve API quota and improve speed (see API limits, below).
`neonUtilities` is also far more widely tested and has extensive error
handling tailored to individual data products.

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
raw_files <- neon_index(table = "brd_countdata-expanded", hash="md5")
raw_files
#> # A tibble: 204 x 10
#>    site   product  table   month  type  timestamp ext   misc  path       hash   
#>    <chr>  <chr>    <chr>   <chr>  <chr> <chr>     <chr> <chr> <chr>      <chr>  
#>  1 NEON.… DP1.100… brd_co… 2015-… expa… 20191107… csv   ""    /tmp/Rtmp… hash:/…
#>  2 NEON.… DP1.100… brd_co… 2016-… expa… 20191107… csv   ""    /tmp/Rtmp… hash:/…
#>  3 NEON.… DP1.100… brd_co… 2017-… expa… 20191107… csv   ""    /tmp/Rtmp… hash:/…
#>  4 NEON.… DP1.100… brd_co… 2018-… expa… 20191107… csv   ""    /tmp/Rtmp… hash:/…
#>  5 NEON.… DP1.100… brd_co… 2019-… expa… 20191205… csv   ""    /tmp/Rtmp… hash:/…
#>  6 NEON.… DP1.100… brd_co… 2015-… expa… 20191107… csv   ""    /tmp/Rtmp… hash:/…
#>  7 NEON.… DP1.100… brd_co… 2015-… expa… 20191107… csv   ""    /tmp/Rtmp… hash:/…
#>  8 NEON.… DP1.100… brd_co… 2016-… expa… 20191107… csv   ""    /tmp/Rtmp… hash:/…
#>  9 NEON.… DP1.100… brd_co… 2017-… expa… 20191107… csv   ""    /tmp/Rtmp… hash:/…
#> 10 NEON.… DP1.100… brd_co… 2018-… expa… 20191107… csv   ""    /tmp/Rtmp… hash:/…
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

Always remember to cite your data sources\! `neonstore` knows how to
generate the appropriate citation for the data in your local store (or
any specific product).

``` r
neon_citation()
#> National Ecological Observatory Network (2020). "Data Products:
#> NEON.DP0.10003.001 NEON.DP1.10003.001 . Provisional data downloaded
#> from http://data.neonscience.org on 11 Jun 2020."
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
collects that product, for each month the product is collected. (It
would be much more efficient on the NEON server if the API could take
queries of the from `/data/<product>/<site>`, and pool the results,
rather than require each month of sampling separately\!)
