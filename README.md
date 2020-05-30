
<!-- README.md is generated from README.Rmd. Please edit that file -->

# neonstore

<!-- badges: start -->

<!-- badges: end -->

The goal of neonstore is to provide access and persistent storage of
NEON data tables.

## Installation

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/neonstore")
```

## Example

Download all CSV files in the bird survey data products. This will omit
downloads of any existing data files.

``` r
library(neonstore)
neon_download("DP1.10003.001", file_regex = "[.]csv")
```

Now, view your library of NEON products. These will persist between
sessions, so you only need to download once, or to retrieve updates.

``` r
neon_tables()
#>  [1] "validation"                      "categoricalCodes"               
#>  [3] "brd_countdata"                   "brd_perpoint"                   
#>  [5] "brd_references"                  "variables"                      
#>  [7] "bet_archivepooling"              "bet_expertTaxonomistIDProcessed"
#>  [9] "bet_fielddata"                   "bet_parataxonomistID"           
#> [11] "bet_sorting"                     "mos_archivepooling"             
#> [13] "mos_barcoding"                   "mos_expertTaxonomistIDProcessed"
#> [15] "mos_expertTaxonomistIDRaw"       "mos_sorting"                    
#> [17] "mos_trapping"                    "mam_perplotnight"               
#> [19] "mam_pertrapnight"                "tck_fielddata"                  
#> [21] "tck_taxonomyProcessed"           "tck_taxonomyRaw"                
#> [23] "inv_fieldData"                   "inv_persample"                  
#> [25] "inv_pervial"                     "inv_taxonomyProcessed"          
#> [27] "inv_taxonomyRaw"                 "zoo_fieldData"                  
#> [29] "zoo_perVial"                     "zoo_taxonomyProcessed"          
#> [31] "zoo_taxonomyRaw"
```

See files associated with a given table,

``` r
meta <- neon_index("brd_countdata") 
meta
#> # A tibble: 204 x 8
#>    site    product   table   month  type  timestamp  ext   path                 
#>    <chr>   <chr>     <chr>   <chr>  <chr> <chr>      <chr> <chr>                
#>  1 NEON.D… DP1.1000… brd_co… 2015-… expa… 20191107T… csv   /home/cboettig/.loca…
#>  2 NEON.D… DP1.1000… brd_co… 2016-… expa… 20191107T… csv   /home/cboettig/.loca…
#>  3 NEON.D… DP1.1000… brd_co… 2017-… expa… 20191107T… csv   /home/cboettig/.loca…
#>  4 NEON.D… DP1.1000… brd_co… 2018-… expa… 20191107T… csv   /home/cboettig/.loca…
#>  5 NEON.D… DP1.1000… brd_co… 2019-… expa… 20191205T… csv   /home/cboettig/.loca…
#>  6 NEON.D… DP1.1000… brd_co… 2015-… expa… 20191107T… csv   /home/cboettig/.loca…
#>  7 NEON.D… DP1.1000… brd_co… 2015-… expa… 20191107T… csv   /home/cboettig/.loca…
#>  8 NEON.D… DP1.1000… brd_co… 2016-… expa… 20191107T… csv   /home/cboettig/.loca…
#>  9 NEON.D… DP1.1000… brd_co… 2017-… expa… 20191107T… csv   /home/cboettig/.loca…
#> 10 NEON.D… DP1.1000… brd_co… 2018-… expa… 20191107T… csv   /home/cboettig/.loca…
#> # … with 194 more rows
```

Read in all the component tables into a single data.frame

``` r
brd_countdata <- neon_read(meta)
brd_countdata
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
