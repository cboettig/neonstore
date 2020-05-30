
<!-- README.md is generated from README.Rmd. Please edit that file -->

# neonstore

<!-- badges: start -->

<!-- badges: end -->

The goal of neonstore is to …

## Installation

You can install the released version of neonstore from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("neonstore")
```

And the development version from [GitHub](https://github.com/) with:

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
#>                site       product         table   month     type
#> 90    NEON.D01.BART DP1.10003.001 brd_countdata 2015-06 expanded
#> 92    NEON.D01.BART DP1.10003.001 brd_countdata 2016-06 expanded
#> 94    NEON.D01.BART DP1.10003.001 brd_countdata 2017-06 expanded
#> 96    NEON.D01.BART DP1.10003.001 brd_countdata 2018-06 expanded
#> 98    NEON.D01.BART DP1.10003.001 brd_countdata 2019-06 expanded
#> 726   NEON.D01.HARV DP1.10003.001 brd_countdata 2015-05 expanded
#> 728   NEON.D01.HARV DP1.10003.001 brd_countdata 2015-06 expanded
#> 730   NEON.D01.HARV DP1.10003.001 brd_countdata 2016-06 expanded
#> 732   NEON.D01.HARV DP1.10003.001 brd_countdata 2017-06 expanded
#> 734   NEON.D01.HARV DP1.10003.001 brd_countdata 2018-06 expanded
#> 736   NEON.D01.HARV DP1.10003.001 brd_countdata 2019-06 expanded
#> 1584  NEON.D02.BLAN DP1.10003.001 brd_countdata 2017-05 expanded
#> 1586  NEON.D02.BLAN DP1.10003.001 brd_countdata 2017-06 expanded
#> 1588  NEON.D02.BLAN DP1.10003.001 brd_countdata 2018-05 expanded
#> 1590  NEON.D02.BLAN DP1.10003.001 brd_countdata 2018-06 expanded
#> 1592  NEON.D02.BLAN DP1.10003.001 brd_countdata 2019-05 expanded
#> 1594  NEON.D02.BLAN DP1.10003.001 brd_countdata 2019-06 expanded
#> 2521  NEON.D02.SCBI DP1.10003.001 brd_countdata 2015-06 expanded
#> 2523  NEON.D02.SCBI DP1.10003.001 brd_countdata 2016-05 expanded
#> 2525  NEON.D02.SCBI DP1.10003.001 brd_countdata 2016-06 expanded
#> 2527  NEON.D02.SCBI DP1.10003.001 brd_countdata 2017-05 expanded
#> 2529  NEON.D02.SCBI DP1.10003.001 brd_countdata 2017-06 expanded
#> 2531  NEON.D02.SCBI DP1.10003.001 brd_countdata 2018-05 expanded
#> 2533  NEON.D02.SCBI DP1.10003.001 brd_countdata 2018-06 expanded
#> 2535  NEON.D02.SCBI DP1.10003.001 brd_countdata 2019-05 expanded
#> 2537  NEON.D02.SCBI DP1.10003.001 brd_countdata 2019-06 expanded
#> 3456  NEON.D02.SERC DP1.10003.001 brd_countdata 2017-05 expanded
#> 3458  NEON.D02.SERC DP1.10003.001 brd_countdata 2017-06 expanded
#> 3460  NEON.D02.SERC DP1.10003.001 brd_countdata 2018-05 expanded
#> 3462  NEON.D02.SERC DP1.10003.001 brd_countdata 2019-05 expanded
#> 4401  NEON.D03.DSNY DP1.10003.001 brd_countdata 2015-06 expanded
#> 4403  NEON.D03.DSNY DP1.10003.001 brd_countdata 2016-05 expanded
#> 4405  NEON.D03.DSNY DP1.10003.001 brd_countdata 2017-05 expanded
#> 4407  NEON.D03.DSNY DP1.10003.001 brd_countdata 2018-05 expanded
#> 4409  NEON.D03.DSNY DP1.10003.001 brd_countdata 2019-05 expanded
#> 5275  NEON.D03.JERC DP1.10003.001 brd_countdata 2016-06 expanded
#> 5277  NEON.D03.JERC DP1.10003.001 brd_countdata 2017-05 expanded
#> 5279  NEON.D03.JERC DP1.10003.001 brd_countdata 2018-06 expanded
#> 5281  NEON.D03.JERC DP1.10003.001 brd_countdata 2019-06 expanded
#> 6051  NEON.D03.OSBS DP1.10003.001 brd_countdata 2016-05 expanded
#> 6053  NEON.D03.OSBS DP1.10003.001 brd_countdata 2017-05 expanded
#> 6055  NEON.D03.OSBS DP1.10003.001 brd_countdata 2018-05 expanded
#> 6057  NEON.D03.OSBS DP1.10003.001 brd_countdata 2019-05 expanded
#> 7259  NEON.D04.GUAN DP1.10003.001 brd_countdata 2015-05 expanded
#> 7261  NEON.D04.GUAN DP1.10003.001 brd_countdata 2017-05 expanded
#> 7263  NEON.D04.GUAN DP1.10003.001 brd_countdata 2018-05 expanded
#> 7265  NEON.D04.GUAN DP1.10003.001 brd_countdata 2019-05 expanded
#> 7267  NEON.D04.GUAN DP1.10003.001 brd_countdata 2019-06 expanded
#> 7887  NEON.D04.LAJA DP1.10003.001 brd_countdata 2017-05 expanded
#> 7889  NEON.D04.LAJA DP1.10003.001 brd_countdata 2018-05 expanded
#> 7891  NEON.D04.LAJA DP1.10003.001 brd_countdata 2019-05 expanded
#> 7893  NEON.D04.LAJA DP1.10003.001 brd_countdata 2019-06 expanded
#> 8645  NEON.D05.STEI DP1.10003.001 brd_countdata 2016-05 expanded
#> 8647  NEON.D05.STEI DP1.10003.001 brd_countdata 2016-06 expanded
#> 8649  NEON.D05.STEI DP1.10003.001 brd_countdata 2017-06 expanded
#> 8651  NEON.D05.STEI DP1.10003.001 brd_countdata 2018-05 expanded
#> 8653  NEON.D05.STEI DP1.10003.001 brd_countdata 2018-06 expanded
#> 8655  NEON.D05.STEI DP1.10003.001 brd_countdata 2019-05 expanded
#> 8657  NEON.D05.STEI DP1.10003.001 brd_countdata 2019-06 expanded
#> 9192  NEON.D05.TREE DP1.10003.001 brd_countdata 2016-06 expanded
#> 9194  NEON.D05.TREE DP1.10003.001 brd_countdata 2017-06 expanded
#> 9196  NEON.D05.TREE DP1.10003.001 brd_countdata 2018-06 expanded
#> 9198  NEON.D05.TREE DP1.10003.001 brd_countdata 2019-06 expanded
#> 9741  NEON.D05.UNDE DP1.10003.001 brd_countdata 2016-06 expanded
#> 9743  NEON.D05.UNDE DP1.10003.001 brd_countdata 2016-07 expanded
#> 9745  NEON.D05.UNDE DP1.10003.001 brd_countdata 2017-06 expanded
#> 9747  NEON.D05.UNDE DP1.10003.001 brd_countdata 2018-06 expanded
#> 9749  NEON.D05.UNDE DP1.10003.001 brd_countdata 2019-06 expanded
#> 10417 NEON.D06.KONA DP1.10003.001 brd_countdata 2018-05 expanded
#> 10419 NEON.D06.KONA DP1.10003.001 brd_countdata 2018-06 expanded
#> 10421 NEON.D06.KONA DP1.10003.001 brd_countdata 2019-06 expanded
#> 10775 NEON.D06.KONZ DP1.10003.001 brd_countdata 2017-06 expanded
#> 10777 NEON.D06.KONZ DP1.10003.001 brd_countdata 2018-05 expanded
#> 10779 NEON.D06.KONZ DP1.10003.001 brd_countdata 2018-06 expanded
#> 10781 NEON.D06.KONZ DP1.10003.001 brd_countdata 2019-06 expanded
#> 11502 NEON.D06.UKFS DP1.10003.001 brd_countdata 2017-06 expanded
#> 11504 NEON.D06.UKFS DP1.10003.001 brd_countdata 2018-06 expanded
#> 11506 NEON.D06.UKFS DP1.10003.001 brd_countdata 2019-06 expanded
#> 12182 NEON.D07.GRSM DP1.10003.001 brd_countdata 2016-06 expanded
#> 12184 NEON.D07.GRSM DP1.10003.001 brd_countdata 2017-05 expanded
#> 12186 NEON.D07.GRSM DP1.10003.001 brd_countdata 2017-06 expanded
#> 12188 NEON.D07.GRSM DP1.10003.001 brd_countdata 2018-05 expanded
#> 12190 NEON.D07.GRSM DP1.10003.001 brd_countdata 2019-05 expanded
#> 12791 NEON.D07.MLBS DP1.10003.001 brd_countdata 2018-06 expanded
#> 12793 NEON.D07.MLBS DP1.10003.001 brd_countdata 2019-05 expanded
#> 13123 NEON.D07.ORNL DP1.10003.001 brd_countdata 2016-05 expanded
#> 13125 NEON.D07.ORNL DP1.10003.001 brd_countdata 2016-06 expanded
#> 13127 NEON.D07.ORNL DP1.10003.001 brd_countdata 2017-05 expanded
#> 13129 NEON.D07.ORNL DP1.10003.001 brd_countdata 2018-06 expanded
#> 13131 NEON.D07.ORNL DP1.10003.001 brd_countdata 2019-05 expanded
#> 14107 NEON.D08.DELA DP1.10003.001 brd_countdata 2015-06 expanded
#> 14109 NEON.D08.DELA DP1.10003.001 brd_countdata 2017-06 expanded
#> 14111 NEON.D08.DELA DP1.10003.001 brd_countdata 2018-05 expanded
#> 14113 NEON.D08.DELA DP1.10003.001 brd_countdata 2019-06 expanded
#> 14745 NEON.D08.LENO DP1.10003.001 brd_countdata 2017-06 expanded
#> 14747 NEON.D08.LENO DP1.10003.001 brd_countdata 2018-05 expanded
#> 14749 NEON.D08.LENO DP1.10003.001 brd_countdata 2019-06 expanded
#> 15467 NEON.D08.TALL DP1.10003.001 brd_countdata 2015-06 expanded
#> 15469 NEON.D08.TALL DP1.10003.001 brd_countdata 2016-07 expanded
#> 15471 NEON.D08.TALL DP1.10003.001 brd_countdata 2017-06 expanded
#> 15473 NEON.D08.TALL DP1.10003.001 brd_countdata 2018-06 expanded
#> 15475 NEON.D08.TALL DP1.10003.001 brd_countdata 2019-05 expanded
#> 16365 NEON.D09.DCFS DP1.10003.001 brd_countdata 2017-06 expanded
#> 16367 NEON.D09.DCFS DP1.10003.001 brd_countdata 2017-07 expanded
#> 16369 NEON.D09.DCFS DP1.10003.001 brd_countdata 2018-07 expanded
#> 16371 NEON.D09.DCFS DP1.10003.001 brd_countdata 2019-06 expanded
#> 16373 NEON.D09.DCFS DP1.10003.001 brd_countdata 2019-07 expanded
#> 16700 NEON.D09.NOGP DP1.10003.001 brd_countdata 2017-07 expanded
#> 16702 NEON.D09.NOGP DP1.10003.001 brd_countdata 2018-07 expanded
#> 16704 NEON.D09.NOGP DP1.10003.001 brd_countdata 2019-07 expanded
#> 17469 NEON.D09.WOOD DP1.10003.001 brd_countdata 2015-07 expanded
#> 17471 NEON.D09.WOOD DP1.10003.001 brd_countdata 2017-07 expanded
#> 17473 NEON.D09.WOOD DP1.10003.001 brd_countdata 2018-07 expanded
#> 17475 NEON.D09.WOOD DP1.10003.001 brd_countdata 2019-06 expanded
#> 17477 NEON.D09.WOOD DP1.10003.001 brd_countdata 2019-07 expanded
#> 18292 NEON.D10.CPER DP1.10003.001 brd_countdata 2013-06 expanded
#> 18294 NEON.D10.CPER DP1.10003.001 brd_countdata 2015-05 expanded
#> 18296 NEON.D10.CPER DP1.10003.001 brd_countdata 2016-05 expanded
#> 18298 NEON.D10.CPER DP1.10003.001 brd_countdata 2017-05 expanded
#> 18300 NEON.D10.CPER DP1.10003.001 brd_countdata 2017-06 expanded
#> 18302 NEON.D10.CPER DP1.10003.001 brd_countdata 2018-05 expanded
#> 18304 NEON.D10.CPER DP1.10003.001 brd_countdata 2019-06 expanded
#> 18916 NEON.D10.RMNP DP1.10003.001 brd_countdata 2017-06 expanded
#> 18918 NEON.D10.RMNP DP1.10003.001 brd_countdata 2017-07 expanded
#> 18920 NEON.D10.RMNP DP1.10003.001 brd_countdata 2018-06 expanded
#> 18922 NEON.D10.RMNP DP1.10003.001 brd_countdata 2018-07 expanded
#> 18924 NEON.D10.RMNP DP1.10003.001 brd_countdata 2019-06 expanded
#> 18926 NEON.D10.RMNP DP1.10003.001 brd_countdata 2019-07 expanded
#> 19227 NEON.D10.STER DP1.10003.001 brd_countdata 2013-06 expanded
#> 19229 NEON.D10.STER DP1.10003.001 brd_countdata 2015-05 expanded
#> 19231 NEON.D10.STER DP1.10003.001 brd_countdata 2016-05 expanded
#> 19233 NEON.D10.STER DP1.10003.001 brd_countdata 2017-05 expanded
#> 19235 NEON.D10.STER DP1.10003.001 brd_countdata 2018-05 expanded
#> 19237 NEON.D10.STER DP1.10003.001 brd_countdata 2019-05 expanded
#> 19239 NEON.D10.STER DP1.10003.001 brd_countdata 2019-06 expanded
#> 19853 NEON.D11.CLBJ DP1.10003.001 brd_countdata 2017-05 expanded
#> 19855 NEON.D11.CLBJ DP1.10003.001 brd_countdata 2018-04 expanded
#> 19857 NEON.D11.CLBJ DP1.10003.001 brd_countdata 2019-04 expanded
#> 19859 NEON.D11.CLBJ DP1.10003.001 brd_countdata 2019-05 expanded
#> 20556 NEON.D11.OAES DP1.10003.001 brd_countdata 2017-05 expanded
#> 20558 NEON.D11.OAES DP1.10003.001 brd_countdata 2017-06 expanded
#> 20560 NEON.D11.OAES DP1.10003.001 brd_countdata 2018-04 expanded
#> 20562 NEON.D11.OAES DP1.10003.001 brd_countdata 2018-05 expanded
#> 20564 NEON.D11.OAES DP1.10003.001 brd_countdata 2019-05 expanded
#> 21276 NEON.D12.YELL DP1.10003.001 brd_countdata 2018-06 expanded
#> 21278 NEON.D12.YELL DP1.10003.001 brd_countdata 2019-06 expanded
#> 21558 NEON.D13.MOAB DP1.10003.001 brd_countdata 2015-06 expanded
#> 21560 NEON.D13.MOAB DP1.10003.001 brd_countdata 2017-05 expanded
#> 21562 NEON.D13.MOAB DP1.10003.001 brd_countdata 2018-05 expanded
#> 21564 NEON.D13.MOAB DP1.10003.001 brd_countdata 2019-05 expanded
#> 22057 NEON.D13.NIWO DP1.10003.001 brd_countdata 2015-07 expanded
#> 22059 NEON.D13.NIWO DP1.10003.001 brd_countdata 2017-07 expanded
#> 22061 NEON.D13.NIWO DP1.10003.001 brd_countdata 2018-07 expanded
#> 22063 NEON.D13.NIWO DP1.10003.001 brd_countdata 2019-07 expanded
#> 22473 NEON.D14.JORN DP1.10003.001 brd_countdata 2017-04 expanded
#> 22475 NEON.D14.JORN DP1.10003.001 brd_countdata 2017-05 expanded
#> 22477 NEON.D14.JORN DP1.10003.001 brd_countdata 2018-04 expanded
#> 22479 NEON.D14.JORN DP1.10003.001 brd_countdata 2018-05 expanded
#> 22481 NEON.D14.JORN DP1.10003.001 brd_countdata 2019-04 expanded
#> 23047 NEON.D14.SRER DP1.10003.001 brd_countdata 2017-05 expanded
#> 23049 NEON.D14.SRER DP1.10003.001 brd_countdata 2018-04 expanded
#> 23051 NEON.D14.SRER DP1.10003.001 brd_countdata 2018-05 expanded
#> 23053 NEON.D14.SRER DP1.10003.001 brd_countdata 2019-04 expanded
#> 23642 NEON.D15.ONAQ DP1.10003.001 brd_countdata 2017-05 expanded
#> 23644 NEON.D15.ONAQ DP1.10003.001 brd_countdata 2018-05 expanded
#> 23646 NEON.D15.ONAQ DP1.10003.001 brd_countdata 2018-06 expanded
#> 23648 NEON.D15.ONAQ DP1.10003.001 brd_countdata 2019-05 expanded
#> 24267 NEON.D16.ABBY DP1.10003.001 brd_countdata 2017-05 expanded
#> 24269 NEON.D16.ABBY DP1.10003.001 brd_countdata 2017-06 expanded
#> 24271 NEON.D16.ABBY DP1.10003.001 brd_countdata 2018-06 expanded
#> 24273 NEON.D16.ABBY DP1.10003.001 brd_countdata 2018-07 expanded
#> 24275 NEON.D16.ABBY DP1.10003.001 brd_countdata 2019-05 expanded
#> 24752 NEON.D16.WREF DP1.10003.001 brd_countdata 2018-06 expanded
#> 24754 NEON.D16.WREF DP1.10003.001 brd_countdata 2019-05 expanded
#> 24756 NEON.D16.WREF DP1.10003.001 brd_countdata 2019-06 expanded
#> 25061 NEON.D17.SJER DP1.10003.001 brd_countdata 2017-04 expanded
#> 25063 NEON.D17.SJER DP1.10003.001 brd_countdata 2018-04 expanded
#> 25065 NEON.D17.SJER DP1.10003.001 brd_countdata 2019-04 expanded
#> 25579 NEON.D17.SOAP DP1.10003.001 brd_countdata 2017-05 expanded
#> 25581 NEON.D17.SOAP DP1.10003.001 brd_countdata 2018-05 expanded
#> 25583 NEON.D17.SOAP DP1.10003.001 brd_countdata 2019-05 expanded
#> 25805 NEON.D17.TEAK DP1.10003.001 brd_countdata 2017-06 expanded
#> 25807 NEON.D17.TEAK DP1.10003.001 brd_countdata 2018-06 expanded
#> 25809 NEON.D17.TEAK DP1.10003.001 brd_countdata 2019-06 expanded
#> 25811 NEON.D17.TEAK DP1.10003.001 brd_countdata 2019-07 expanded
#> 25913 NEON.D18.BARR DP1.10003.001 brd_countdata 2017-07 expanded
#> 25915 NEON.D18.BARR DP1.10003.001 brd_countdata 2018-07 expanded
#> 25917 NEON.D18.BARR DP1.10003.001 brd_countdata 2019-06 expanded
#> 26212 NEON.D18.TOOL DP1.10003.001 brd_countdata 2017-06 expanded
#> 26214 NEON.D18.TOOL DP1.10003.001 brd_countdata 2018-07 expanded
#> 26216 NEON.D18.TOOL DP1.10003.001 brd_countdata 2019-06 expanded
#> 26405 NEON.D19.BONA DP1.10003.001 brd_countdata 2017-06 expanded
#> 26407 NEON.D19.BONA DP1.10003.001 brd_countdata 2018-06 expanded
#> 26409 NEON.D19.BONA DP1.10003.001 brd_countdata 2018-07 expanded
#> 26411 NEON.D19.BONA DP1.10003.001 brd_countdata 2019-06 expanded
#> 26718 NEON.D19.DEJU DP1.10003.001 brd_countdata 2017-06 expanded
#> 26720 NEON.D19.DEJU DP1.10003.001 brd_countdata 2018-06 expanded
#> 26722 NEON.D19.DEJU DP1.10003.001 brd_countdata 2019-06 expanded
#> 27026 NEON.D19.HEAL DP1.10003.001 brd_countdata 2017-06 expanded
#> 27028 NEON.D19.HEAL DP1.10003.001 brd_countdata 2018-06 expanded
#> 27030 NEON.D19.HEAL DP1.10003.001 brd_countdata 2018-07 expanded
#> 27032 NEON.D19.HEAL DP1.10003.001 brd_countdata 2019-06 expanded
#> 27034 NEON.D19.HEAL DP1.10003.001 brd_countdata 2019-07 expanded
#> 27352 NEON.D20.PUUM DP1.10003.001 brd_countdata 2018-04 expanded
#>              timestamp ext
#> 90    20191107T154457Z csv
#> 92    20191107T152154Z csv
#> 94    20191107T153221Z csv
#> 96    20191107T153227Z csv
#> 98    20191205T150213Z csv
#> 726   20191107T153349Z csv
#> 728   20191107T152715Z csv
#> 730   20191107T153649Z csv
#> 732   20191107T153333Z csv
#> 734   20191107T154838Z csv
#> 736   20191205T150111Z csv
#> 1584  20191107T153102Z csv
#> 1586  20191107T153400Z csv
#> 1588  20191107T152442Z csv
#> 1590  20191107T153356Z csv
#> 1592  20191205T150144Z csv
#> 1594  20191205T150132Z csv
#> 2521  20191107T153547Z csv
#> 2523  20191107T154227Z csv
#> 2525  20191107T154826Z csv
#> 2527  20191107T154155Z csv
#> 2529  20191107T152550Z csv
#> 2531  20191107T154819Z csv
#> 2533  20191107T154203Z csv
#> 2535  20191205T150125Z csv
#> 2537  20191205T150114Z csv
#> 3456  20191107T154239Z csv
#> 3458  20191107T153642Z csv
#> 3460  20191107T153627Z csv
#> 3462  20191205T150228Z csv
#> 4401  20191107T153608Z csv
#> 4403  20191107T152307Z csv
#> 4405  20191107T154505Z csv
#> 4407  20191107T152419Z csv
#> 4409  20191205T150238Z csv
#> 5275  20191107T153244Z csv
#> 5277  20191107T152545Z csv
#> 5279  20191107T154342Z csv
#> 5281  20191205T150257Z csv
#> 6051  20191107T153558Z csv
#> 6053  20191107T152933Z csv
#> 6055  20191107T155025Z csv
#> 6057  20191205T150148Z csv
#> 7259  20191107T154444Z csv
#> 7261  20191107T152555Z csv
#> 7263  20191107T152322Z csv
#> 7265  20191205T150109Z csv
#> 7267  20191205T150200Z csv
#> 7887  20191107T153924Z csv
#> 7889  20191107T153017Z csv
#> 7891  20191205T150339Z csv
#> 7893  20191205T150312Z csv
#> 8645  20191107T160023Z csv
#> 8647  20191107T153303Z csv
#> 8649  20191107T153047Z csv
#> 8651  20191107T153203Z csv
#> 8653  20191107T154856Z csv
#> 8655  20191205T150216Z csv
#> 8657  20191205T150245Z csv
#> 9192  20191107T152216Z csv
#> 9194  20191107T153505Z csv
#> 9196  20191107T152516Z csv
#> 9198  20191205T150112Z csv
#> 9741  20191107T152600Z csv
#> 9743  20191107T154829Z csv
#> 9745  20191107T152339Z csv
#> 9747  20191107T153634Z csv
#> 9749  20191205T150131Z csv
#> 10417 20191107T153745Z csv
#> 10419 20191107T153716Z csv
#> 10421 20191205T150237Z csv
#> 10775 20191107T154759Z csv
#> 10777 20191107T153604Z csv
#> 10779 20191107T153236Z csv
#> 10781 20191205T150304Z csv
#> 11502 20191107T160106Z csv
#> 11504 20191107T154320Z csv
#> 11506 20191205T150132Z csv
#> 12182 20191107T154616Z csv
#> 12184 20191107T154153Z csv
#> 12186 20191107T153615Z csv
#> 12188 20191107T152303Z csv
#> 12190 20191205T150124Z csv
#> 12791 20191107T153752Z csv
#> 12793 20191205T150243Z csv
#> 13123 20191107T153415Z csv
#> 13125 20191107T154943Z csv
#> 13127 20191107T152430Z csv
#> 13129 20191107T152634Z csv
#> 13131 20191205T150235Z csv
#> 14107 20191107T153520Z csv
#> 14109 20191107T153608Z csv
#> 14111 20191107T152606Z csv
#> 14113 20191205T150231Z csv
#> 14745 20191107T155142Z csv
#> 14747 20191107T154932Z csv
#> 14749 20191205T150137Z csv
#> 15467 20191107T152611Z csv
#> 15469 20191107T152625Z csv
#> 15471 20191107T153548Z csv
#> 15473 20191107T153324Z csv
#> 15475 20191205T150252Z csv
#> 16365 20191107T153626Z csv
#> 16367 20191107T152304Z csv
#> 16369 20191107T152055Z csv
#> 16371 20191205T150320Z csv
#> 16373 20191205T150317Z csv
#> 16700 20191107T152636Z csv
#> 16702 20191107T153516Z csv
#> 16704 20191205T150301Z csv
#> 17469 20191107T152331Z csv
#> 17471 20191107T152724Z csv
#> 17473 20191107T152654Z csv
#> 17475 20191205T150306Z csv
#> 17477 20191205T150332Z csv
#> 18292 20191107T153856Z csv
#> 18294 20191107T152124Z csv
#> 18296 20191107T153639Z csv
#> 18298 20191107T152705Z csv
#> 18300 20191107T152300Z csv
#> 18302 20191107T154701Z csv
#> 18304 20191205T150209Z csv
#> 18916 20191107T154915Z csv
#> 18918 20191107T152118Z csv
#> 18920 20191107T153429Z csv
#> 18922 20191107T154906Z csv
#> 18924 20191205T150225Z csv
#> 18926 20191205T150229Z csv
#> 19227 20191107T154838Z csv
#> 19229 20191107T153555Z csv
#> 19231 20191107T154834Z csv
#> 19233 20191107T153526Z csv
#> 19235 20191107T153145Z csv
#> 19237 20191205T150240Z csv
#> 19239 20191205T150301Z csv
#> 19853 20191107T160036Z csv
#> 19855 20191107T160028Z csv
#> 19857 20191205T150226Z csv
#> 19859 20191205T150217Z csv
#> 20556 20191107T154539Z csv
#> 20558 20191107T154124Z csv
#> 20560 20191107T152227Z csv
#> 20562 20191107T155040Z csv
#> 20564 20191205T150155Z csv
#> 21276 20191107T154736Z csv
#> 21278 20191205T150206Z csv
#> 21558 20191107T152447Z csv
#> 21560 20191107T152258Z csv
#> 21562 20191107T160054Z csv
#> 21564 20191205T150307Z csv
#> 22057 20191107T154245Z csv
#> 22059 20191107T154911Z csv
#> 22061 20191107T153707Z csv
#> 22063 20191205T150140Z csv
#> 22473 20191107T155014Z csv
#> 22475 20191107T154302Z csv
#> 22477 20191107T155019Z csv
#> 22479 20191107T152739Z csv
#> 22481 20191205T150207Z csv
#> 23047 20191107T153553Z csv
#> 23049 20191107T152621Z csv
#> 23051 20191107T153543Z csv
#> 23053 20191205T150120Z csv
#> 23642 20191107T154751Z csv
#> 23644 20191107T152241Z csv
#> 23646 20191107T154356Z csv
#> 23648 20191205T150139Z csv
#> 24267 20191107T153341Z csv
#> 24269 20191107T151746Z csv
#> 24271 20191107T153424Z csv
#> 24273 20191107T153420Z csv
#> 24275 20191205T150151Z csv
#> 24752 20191107T160017Z csv
#> 24754 20191205T150243Z csv
#> 24756 20191205T150256Z csv
#> 25061 20191107T152624Z csv
#> 25063 20191107T154631Z csv
#> 25065 20191205T150154Z csv
#> 25579 20191107T155012Z csv
#> 25581 20191107T152159Z csv
#> 25583 20191205T150154Z csv
#> 25805 20191107T155116Z csv
#> 25807 20191107T153235Z csv
#> 25809 20191205T150146Z csv
#> 25811 20191205T150127Z csv
#> 25913 20191107T152405Z csv
#> 25915 20191107T153621Z csv
#> 25917 20191205T150249Z csv
#> 26212 20191107T154927Z csv
#> 26214 20191107T152007Z csv
#> 26216 20191205T150214Z csv
#> 26405 20191107T153758Z csv
#> 26407 20191107T152501Z csv
#> 26409 20191107T153736Z csv
#> 26411 20191205T150220Z csv
#> 26718 20191107T153930Z csv
#> 26720 20191107T152720Z csv
#> 26722 20191205T150251Z csv
#> 27026 20191107T153447Z csv
#> 27028 20191107T153729Z csv
#> 27030 20191107T152537Z csv
#> 27032 20191205T150203Z csv
#> 27034 20191205T150200Z csv
#> 27352 20191107T154219Z csv
#>                                                                                                                        path
#> 90    /home/cboettig/.local/share/neonstore/NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T154457Z.csv
#> 92    /home/cboettig/.local/share/neonstore/NEON.D01.BART.DP1.10003.001.brd_countdata.2016-06.expanded.20191107T152154Z.csv
#> 94    /home/cboettig/.local/share/neonstore/NEON.D01.BART.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153221Z.csv
#> 96    /home/cboettig/.local/share/neonstore/NEON.D01.BART.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153227Z.csv
#> 98    /home/cboettig/.local/share/neonstore/NEON.D01.BART.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150213Z.csv
#> 726   /home/cboettig/.local/share/neonstore/NEON.D01.HARV.DP1.10003.001.brd_countdata.2015-05.expanded.20191107T153349Z.csv
#> 728   /home/cboettig/.local/share/neonstore/NEON.D01.HARV.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T152715Z.csv
#> 730   /home/cboettig/.local/share/neonstore/NEON.D01.HARV.DP1.10003.001.brd_countdata.2016-06.expanded.20191107T153649Z.csv
#> 732   /home/cboettig/.local/share/neonstore/NEON.D01.HARV.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153333Z.csv
#> 734   /home/cboettig/.local/share/neonstore/NEON.D01.HARV.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T154838Z.csv
#> 736   /home/cboettig/.local/share/neonstore/NEON.D01.HARV.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150111Z.csv
#> 1584  /home/cboettig/.local/share/neonstore/NEON.D02.BLAN.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T153102Z.csv
#> 1586  /home/cboettig/.local/share/neonstore/NEON.D02.BLAN.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153400Z.csv
#> 1588  /home/cboettig/.local/share/neonstore/NEON.D02.BLAN.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T152442Z.csv
#> 1590  /home/cboettig/.local/share/neonstore/NEON.D02.BLAN.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153356Z.csv
#> 1592  /home/cboettig/.local/share/neonstore/NEON.D02.BLAN.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150144Z.csv
#> 1594  /home/cboettig/.local/share/neonstore/NEON.D02.BLAN.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150132Z.csv
#> 2521  /home/cboettig/.local/share/neonstore/NEON.D02.SCBI.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T153547Z.csv
#> 2523  /home/cboettig/.local/share/neonstore/NEON.D02.SCBI.DP1.10003.001.brd_countdata.2016-05.expanded.20191107T154227Z.csv
#> 2525  /home/cboettig/.local/share/neonstore/NEON.D02.SCBI.DP1.10003.001.brd_countdata.2016-06.expanded.20191107T154826Z.csv
#> 2527  /home/cboettig/.local/share/neonstore/NEON.D02.SCBI.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T154155Z.csv
#> 2529  /home/cboettig/.local/share/neonstore/NEON.D02.SCBI.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T152550Z.csv
#> 2531  /home/cboettig/.local/share/neonstore/NEON.D02.SCBI.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T154819Z.csv
#> 2533  /home/cboettig/.local/share/neonstore/NEON.D02.SCBI.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T154203Z.csv
#> 2535  /home/cboettig/.local/share/neonstore/NEON.D02.SCBI.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150125Z.csv
#> 2537  /home/cboettig/.local/share/neonstore/NEON.D02.SCBI.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150114Z.csv
#> 3456  /home/cboettig/.local/share/neonstore/NEON.D02.SERC.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T154239Z.csv
#> 3458  /home/cboettig/.local/share/neonstore/NEON.D02.SERC.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153642Z.csv
#> 3460  /home/cboettig/.local/share/neonstore/NEON.D02.SERC.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T153627Z.csv
#> 3462  /home/cboettig/.local/share/neonstore/NEON.D02.SERC.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150228Z.csv
#> 4401  /home/cboettig/.local/share/neonstore/NEON.D03.DSNY.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T153608Z.csv
#> 4403  /home/cboettig/.local/share/neonstore/NEON.D03.DSNY.DP1.10003.001.brd_countdata.2016-05.expanded.20191107T152307Z.csv
#> 4405  /home/cboettig/.local/share/neonstore/NEON.D03.DSNY.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T154505Z.csv
#> 4407  /home/cboettig/.local/share/neonstore/NEON.D03.DSNY.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T152419Z.csv
#> 4409  /home/cboettig/.local/share/neonstore/NEON.D03.DSNY.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150238Z.csv
#> 5275  /home/cboettig/.local/share/neonstore/NEON.D03.JERC.DP1.10003.001.brd_countdata.2016-06.expanded.20191107T153244Z.csv
#> 5277  /home/cboettig/.local/share/neonstore/NEON.D03.JERC.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T152545Z.csv
#> 5279  /home/cboettig/.local/share/neonstore/NEON.D03.JERC.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T154342Z.csv
#> 5281  /home/cboettig/.local/share/neonstore/NEON.D03.JERC.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150257Z.csv
#> 6051  /home/cboettig/.local/share/neonstore/NEON.D03.OSBS.DP1.10003.001.brd_countdata.2016-05.expanded.20191107T153558Z.csv
#> 6053  /home/cboettig/.local/share/neonstore/NEON.D03.OSBS.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T152933Z.csv
#> 6055  /home/cboettig/.local/share/neonstore/NEON.D03.OSBS.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T155025Z.csv
#> 6057  /home/cboettig/.local/share/neonstore/NEON.D03.OSBS.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150148Z.csv
#> 7259  /home/cboettig/.local/share/neonstore/NEON.D04.GUAN.DP1.10003.001.brd_countdata.2015-05.expanded.20191107T154444Z.csv
#> 7261  /home/cboettig/.local/share/neonstore/NEON.D04.GUAN.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T152555Z.csv
#> 7263  /home/cboettig/.local/share/neonstore/NEON.D04.GUAN.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T152322Z.csv
#> 7265  /home/cboettig/.local/share/neonstore/NEON.D04.GUAN.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150109Z.csv
#> 7267  /home/cboettig/.local/share/neonstore/NEON.D04.GUAN.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150200Z.csv
#> 7887  /home/cboettig/.local/share/neonstore/NEON.D04.LAJA.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T153924Z.csv
#> 7889  /home/cboettig/.local/share/neonstore/NEON.D04.LAJA.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T153017Z.csv
#> 7891  /home/cboettig/.local/share/neonstore/NEON.D04.LAJA.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150339Z.csv
#> 7893  /home/cboettig/.local/share/neonstore/NEON.D04.LAJA.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150312Z.csv
#> 8645  /home/cboettig/.local/share/neonstore/NEON.D05.STEI.DP1.10003.001.brd_countdata.2016-05.expanded.20191107T160023Z.csv
#> 8647  /home/cboettig/.local/share/neonstore/NEON.D05.STEI.DP1.10003.001.brd_countdata.2016-06.expanded.20191107T153303Z.csv
#> 8649  /home/cboettig/.local/share/neonstore/NEON.D05.STEI.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153047Z.csv
#> 8651  /home/cboettig/.local/share/neonstore/NEON.D05.STEI.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T153203Z.csv
#> 8653  /home/cboettig/.local/share/neonstore/NEON.D05.STEI.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T154856Z.csv
#> 8655  /home/cboettig/.local/share/neonstore/NEON.D05.STEI.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150216Z.csv
#> 8657  /home/cboettig/.local/share/neonstore/NEON.D05.STEI.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150245Z.csv
#> 9192  /home/cboettig/.local/share/neonstore/NEON.D05.TREE.DP1.10003.001.brd_countdata.2016-06.expanded.20191107T152216Z.csv
#> 9194  /home/cboettig/.local/share/neonstore/NEON.D05.TREE.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153505Z.csv
#> 9196  /home/cboettig/.local/share/neonstore/NEON.D05.TREE.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T152516Z.csv
#> 9198  /home/cboettig/.local/share/neonstore/NEON.D05.TREE.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150112Z.csv
#> 9741  /home/cboettig/.local/share/neonstore/NEON.D05.UNDE.DP1.10003.001.brd_countdata.2016-06.expanded.20191107T152600Z.csv
#> 9743  /home/cboettig/.local/share/neonstore/NEON.D05.UNDE.DP1.10003.001.brd_countdata.2016-07.expanded.20191107T154829Z.csv
#> 9745  /home/cboettig/.local/share/neonstore/NEON.D05.UNDE.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T152339Z.csv
#> 9747  /home/cboettig/.local/share/neonstore/NEON.D05.UNDE.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153634Z.csv
#> 9749  /home/cboettig/.local/share/neonstore/NEON.D05.UNDE.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150131Z.csv
#> 10417 /home/cboettig/.local/share/neonstore/NEON.D06.KONA.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T153745Z.csv
#> 10419 /home/cboettig/.local/share/neonstore/NEON.D06.KONA.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153716Z.csv
#> 10421 /home/cboettig/.local/share/neonstore/NEON.D06.KONA.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150237Z.csv
#> 10775 /home/cboettig/.local/share/neonstore/NEON.D06.KONZ.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T154759Z.csv
#> 10777 /home/cboettig/.local/share/neonstore/NEON.D06.KONZ.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T153604Z.csv
#> 10779 /home/cboettig/.local/share/neonstore/NEON.D06.KONZ.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153236Z.csv
#> 10781 /home/cboettig/.local/share/neonstore/NEON.D06.KONZ.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150304Z.csv
#> 11502 /home/cboettig/.local/share/neonstore/NEON.D06.UKFS.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T160106Z.csv
#> 11504 /home/cboettig/.local/share/neonstore/NEON.D06.UKFS.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T154320Z.csv
#> 11506 /home/cboettig/.local/share/neonstore/NEON.D06.UKFS.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150132Z.csv
#> 12182 /home/cboettig/.local/share/neonstore/NEON.D07.GRSM.DP1.10003.001.brd_countdata.2016-06.expanded.20191107T154616Z.csv
#> 12184 /home/cboettig/.local/share/neonstore/NEON.D07.GRSM.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T154153Z.csv
#> 12186 /home/cboettig/.local/share/neonstore/NEON.D07.GRSM.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153615Z.csv
#> 12188 /home/cboettig/.local/share/neonstore/NEON.D07.GRSM.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T152303Z.csv
#> 12190 /home/cboettig/.local/share/neonstore/NEON.D07.GRSM.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150124Z.csv
#> 12791 /home/cboettig/.local/share/neonstore/NEON.D07.MLBS.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153752Z.csv
#> 12793 /home/cboettig/.local/share/neonstore/NEON.D07.MLBS.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150243Z.csv
#> 13123 /home/cboettig/.local/share/neonstore/NEON.D07.ORNL.DP1.10003.001.brd_countdata.2016-05.expanded.20191107T153415Z.csv
#> 13125 /home/cboettig/.local/share/neonstore/NEON.D07.ORNL.DP1.10003.001.brd_countdata.2016-06.expanded.20191107T154943Z.csv
#> 13127 /home/cboettig/.local/share/neonstore/NEON.D07.ORNL.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T152430Z.csv
#> 13129 /home/cboettig/.local/share/neonstore/NEON.D07.ORNL.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T152634Z.csv
#> 13131 /home/cboettig/.local/share/neonstore/NEON.D07.ORNL.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150235Z.csv
#> 14107 /home/cboettig/.local/share/neonstore/NEON.D08.DELA.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T153520Z.csv
#> 14109 /home/cboettig/.local/share/neonstore/NEON.D08.DELA.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153608Z.csv
#> 14111 /home/cboettig/.local/share/neonstore/NEON.D08.DELA.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T152606Z.csv
#> 14113 /home/cboettig/.local/share/neonstore/NEON.D08.DELA.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150231Z.csv
#> 14745 /home/cboettig/.local/share/neonstore/NEON.D08.LENO.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T155142Z.csv
#> 14747 /home/cboettig/.local/share/neonstore/NEON.D08.LENO.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T154932Z.csv
#> 14749 /home/cboettig/.local/share/neonstore/NEON.D08.LENO.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150137Z.csv
#> 15467 /home/cboettig/.local/share/neonstore/NEON.D08.TALL.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T152611Z.csv
#> 15469 /home/cboettig/.local/share/neonstore/NEON.D08.TALL.DP1.10003.001.brd_countdata.2016-07.expanded.20191107T152625Z.csv
#> 15471 /home/cboettig/.local/share/neonstore/NEON.D08.TALL.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153548Z.csv
#> 15473 /home/cboettig/.local/share/neonstore/NEON.D08.TALL.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153324Z.csv
#> 15475 /home/cboettig/.local/share/neonstore/NEON.D08.TALL.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150252Z.csv
#> 16365 /home/cboettig/.local/share/neonstore/NEON.D09.DCFS.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153626Z.csv
#> 16367 /home/cboettig/.local/share/neonstore/NEON.D09.DCFS.DP1.10003.001.brd_countdata.2017-07.expanded.20191107T152304Z.csv
#> 16369 /home/cboettig/.local/share/neonstore/NEON.D09.DCFS.DP1.10003.001.brd_countdata.2018-07.expanded.20191107T152055Z.csv
#> 16371 /home/cboettig/.local/share/neonstore/NEON.D09.DCFS.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150320Z.csv
#> 16373 /home/cboettig/.local/share/neonstore/NEON.D09.DCFS.DP1.10003.001.brd_countdata.2019-07.expanded.20191205T150317Z.csv
#> 16700 /home/cboettig/.local/share/neonstore/NEON.D09.NOGP.DP1.10003.001.brd_countdata.2017-07.expanded.20191107T152636Z.csv
#> 16702 /home/cboettig/.local/share/neonstore/NEON.D09.NOGP.DP1.10003.001.brd_countdata.2018-07.expanded.20191107T153516Z.csv
#> 16704 /home/cboettig/.local/share/neonstore/NEON.D09.NOGP.DP1.10003.001.brd_countdata.2019-07.expanded.20191205T150301Z.csv
#> 17469 /home/cboettig/.local/share/neonstore/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.expanded.20191107T152331Z.csv
#> 17471 /home/cboettig/.local/share/neonstore/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2017-07.expanded.20191107T152724Z.csv
#> 17473 /home/cboettig/.local/share/neonstore/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2018-07.expanded.20191107T152654Z.csv
#> 17475 /home/cboettig/.local/share/neonstore/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150306Z.csv
#> 17477 /home/cboettig/.local/share/neonstore/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2019-07.expanded.20191205T150332Z.csv
#> 18292 /home/cboettig/.local/share/neonstore/NEON.D10.CPER.DP1.10003.001.brd_countdata.2013-06.expanded.20191107T153856Z.csv
#> 18294 /home/cboettig/.local/share/neonstore/NEON.D10.CPER.DP1.10003.001.brd_countdata.2015-05.expanded.20191107T152124Z.csv
#> 18296 /home/cboettig/.local/share/neonstore/NEON.D10.CPER.DP1.10003.001.brd_countdata.2016-05.expanded.20191107T153639Z.csv
#> 18298 /home/cboettig/.local/share/neonstore/NEON.D10.CPER.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T152705Z.csv
#> 18300 /home/cboettig/.local/share/neonstore/NEON.D10.CPER.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T152300Z.csv
#> 18302 /home/cboettig/.local/share/neonstore/NEON.D10.CPER.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T154701Z.csv
#> 18304 /home/cboettig/.local/share/neonstore/NEON.D10.CPER.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150209Z.csv
#> 18916 /home/cboettig/.local/share/neonstore/NEON.D10.RMNP.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T154915Z.csv
#> 18918 /home/cboettig/.local/share/neonstore/NEON.D10.RMNP.DP1.10003.001.brd_countdata.2017-07.expanded.20191107T152118Z.csv
#> 18920 /home/cboettig/.local/share/neonstore/NEON.D10.RMNP.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153429Z.csv
#> 18922 /home/cboettig/.local/share/neonstore/NEON.D10.RMNP.DP1.10003.001.brd_countdata.2018-07.expanded.20191107T154906Z.csv
#> 18924 /home/cboettig/.local/share/neonstore/NEON.D10.RMNP.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150225Z.csv
#> 18926 /home/cboettig/.local/share/neonstore/NEON.D10.RMNP.DP1.10003.001.brd_countdata.2019-07.expanded.20191205T150229Z.csv
#> 19227 /home/cboettig/.local/share/neonstore/NEON.D10.STER.DP1.10003.001.brd_countdata.2013-06.expanded.20191107T154838Z.csv
#> 19229 /home/cboettig/.local/share/neonstore/NEON.D10.STER.DP1.10003.001.brd_countdata.2015-05.expanded.20191107T153555Z.csv
#> 19231 /home/cboettig/.local/share/neonstore/NEON.D10.STER.DP1.10003.001.brd_countdata.2016-05.expanded.20191107T154834Z.csv
#> 19233 /home/cboettig/.local/share/neonstore/NEON.D10.STER.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T153526Z.csv
#> 19235 /home/cboettig/.local/share/neonstore/NEON.D10.STER.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T153145Z.csv
#> 19237 /home/cboettig/.local/share/neonstore/NEON.D10.STER.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150240Z.csv
#> 19239 /home/cboettig/.local/share/neonstore/NEON.D10.STER.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150301Z.csv
#> 19853 /home/cboettig/.local/share/neonstore/NEON.D11.CLBJ.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T160036Z.csv
#> 19855 /home/cboettig/.local/share/neonstore/NEON.D11.CLBJ.DP1.10003.001.brd_countdata.2018-04.expanded.20191107T160028Z.csv
#> 19857 /home/cboettig/.local/share/neonstore/NEON.D11.CLBJ.DP1.10003.001.brd_countdata.2019-04.expanded.20191205T150226Z.csv
#> 19859 /home/cboettig/.local/share/neonstore/NEON.D11.CLBJ.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150217Z.csv
#> 20556 /home/cboettig/.local/share/neonstore/NEON.D11.OAES.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T154539Z.csv
#> 20558 /home/cboettig/.local/share/neonstore/NEON.D11.OAES.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T154124Z.csv
#> 20560 /home/cboettig/.local/share/neonstore/NEON.D11.OAES.DP1.10003.001.brd_countdata.2018-04.expanded.20191107T152227Z.csv
#> 20562 /home/cboettig/.local/share/neonstore/NEON.D11.OAES.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T155040Z.csv
#> 20564 /home/cboettig/.local/share/neonstore/NEON.D11.OAES.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150155Z.csv
#> 21276 /home/cboettig/.local/share/neonstore/NEON.D12.YELL.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T154736Z.csv
#> 21278 /home/cboettig/.local/share/neonstore/NEON.D12.YELL.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150206Z.csv
#> 21558 /home/cboettig/.local/share/neonstore/NEON.D13.MOAB.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T152447Z.csv
#> 21560 /home/cboettig/.local/share/neonstore/NEON.D13.MOAB.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T152258Z.csv
#> 21562 /home/cboettig/.local/share/neonstore/NEON.D13.MOAB.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T160054Z.csv
#> 21564 /home/cboettig/.local/share/neonstore/NEON.D13.MOAB.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150307Z.csv
#> 22057 /home/cboettig/.local/share/neonstore/NEON.D13.NIWO.DP1.10003.001.brd_countdata.2015-07.expanded.20191107T154245Z.csv
#> 22059 /home/cboettig/.local/share/neonstore/NEON.D13.NIWO.DP1.10003.001.brd_countdata.2017-07.expanded.20191107T154911Z.csv
#> 22061 /home/cboettig/.local/share/neonstore/NEON.D13.NIWO.DP1.10003.001.brd_countdata.2018-07.expanded.20191107T153707Z.csv
#> 22063 /home/cboettig/.local/share/neonstore/NEON.D13.NIWO.DP1.10003.001.brd_countdata.2019-07.expanded.20191205T150140Z.csv
#> 22473 /home/cboettig/.local/share/neonstore/NEON.D14.JORN.DP1.10003.001.brd_countdata.2017-04.expanded.20191107T155014Z.csv
#> 22475 /home/cboettig/.local/share/neonstore/NEON.D14.JORN.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T154302Z.csv
#> 22477 /home/cboettig/.local/share/neonstore/NEON.D14.JORN.DP1.10003.001.brd_countdata.2018-04.expanded.20191107T155019Z.csv
#> 22479 /home/cboettig/.local/share/neonstore/NEON.D14.JORN.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T152739Z.csv
#> 22481 /home/cboettig/.local/share/neonstore/NEON.D14.JORN.DP1.10003.001.brd_countdata.2019-04.expanded.20191205T150207Z.csv
#> 23047 /home/cboettig/.local/share/neonstore/NEON.D14.SRER.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T153553Z.csv
#> 23049 /home/cboettig/.local/share/neonstore/NEON.D14.SRER.DP1.10003.001.brd_countdata.2018-04.expanded.20191107T152621Z.csv
#> 23051 /home/cboettig/.local/share/neonstore/NEON.D14.SRER.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T153543Z.csv
#> 23053 /home/cboettig/.local/share/neonstore/NEON.D14.SRER.DP1.10003.001.brd_countdata.2019-04.expanded.20191205T150120Z.csv
#> 23642 /home/cboettig/.local/share/neonstore/NEON.D15.ONAQ.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T154751Z.csv
#> 23644 /home/cboettig/.local/share/neonstore/NEON.D15.ONAQ.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T152241Z.csv
#> 23646 /home/cboettig/.local/share/neonstore/NEON.D15.ONAQ.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T154356Z.csv
#> 23648 /home/cboettig/.local/share/neonstore/NEON.D15.ONAQ.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150139Z.csv
#> 24267 /home/cboettig/.local/share/neonstore/NEON.D16.ABBY.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T153341Z.csv
#> 24269 /home/cboettig/.local/share/neonstore/NEON.D16.ABBY.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T151746Z.csv
#> 24271 /home/cboettig/.local/share/neonstore/NEON.D16.ABBY.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153424Z.csv
#> 24273 /home/cboettig/.local/share/neonstore/NEON.D16.ABBY.DP1.10003.001.brd_countdata.2018-07.expanded.20191107T153420Z.csv
#> 24275 /home/cboettig/.local/share/neonstore/NEON.D16.ABBY.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150151Z.csv
#> 24752 /home/cboettig/.local/share/neonstore/NEON.D16.WREF.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T160017Z.csv
#> 24754 /home/cboettig/.local/share/neonstore/NEON.D16.WREF.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150243Z.csv
#> 24756 /home/cboettig/.local/share/neonstore/NEON.D16.WREF.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150256Z.csv
#> 25061 /home/cboettig/.local/share/neonstore/NEON.D17.SJER.DP1.10003.001.brd_countdata.2017-04.expanded.20191107T152624Z.csv
#> 25063 /home/cboettig/.local/share/neonstore/NEON.D17.SJER.DP1.10003.001.brd_countdata.2018-04.expanded.20191107T154631Z.csv
#> 25065 /home/cboettig/.local/share/neonstore/NEON.D17.SJER.DP1.10003.001.brd_countdata.2019-04.expanded.20191205T150154Z.csv
#> 25579 /home/cboettig/.local/share/neonstore/NEON.D17.SOAP.DP1.10003.001.brd_countdata.2017-05.expanded.20191107T155012Z.csv
#> 25581 /home/cboettig/.local/share/neonstore/NEON.D17.SOAP.DP1.10003.001.brd_countdata.2018-05.expanded.20191107T152159Z.csv
#> 25583 /home/cboettig/.local/share/neonstore/NEON.D17.SOAP.DP1.10003.001.brd_countdata.2019-05.expanded.20191205T150154Z.csv
#> 25805 /home/cboettig/.local/share/neonstore/NEON.D17.TEAK.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T155116Z.csv
#> 25807 /home/cboettig/.local/share/neonstore/NEON.D17.TEAK.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153235Z.csv
#> 25809 /home/cboettig/.local/share/neonstore/NEON.D17.TEAK.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150146Z.csv
#> 25811 /home/cboettig/.local/share/neonstore/NEON.D17.TEAK.DP1.10003.001.brd_countdata.2019-07.expanded.20191205T150127Z.csv
#> 25913 /home/cboettig/.local/share/neonstore/NEON.D18.BARR.DP1.10003.001.brd_countdata.2017-07.expanded.20191107T152405Z.csv
#> 25915 /home/cboettig/.local/share/neonstore/NEON.D18.BARR.DP1.10003.001.brd_countdata.2018-07.expanded.20191107T153621Z.csv
#> 25917 /home/cboettig/.local/share/neonstore/NEON.D18.BARR.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150249Z.csv
#> 26212 /home/cboettig/.local/share/neonstore/NEON.D18.TOOL.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T154927Z.csv
#> 26214 /home/cboettig/.local/share/neonstore/NEON.D18.TOOL.DP1.10003.001.brd_countdata.2018-07.expanded.20191107T152007Z.csv
#> 26216 /home/cboettig/.local/share/neonstore/NEON.D18.TOOL.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150214Z.csv
#> 26405 /home/cboettig/.local/share/neonstore/NEON.D19.BONA.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153758Z.csv
#> 26407 /home/cboettig/.local/share/neonstore/NEON.D19.BONA.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T152501Z.csv
#> 26409 /home/cboettig/.local/share/neonstore/NEON.D19.BONA.DP1.10003.001.brd_countdata.2018-07.expanded.20191107T153736Z.csv
#> 26411 /home/cboettig/.local/share/neonstore/NEON.D19.BONA.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150220Z.csv
#> 26718 /home/cboettig/.local/share/neonstore/NEON.D19.DEJU.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153930Z.csv
#> 26720 /home/cboettig/.local/share/neonstore/NEON.D19.DEJU.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T152720Z.csv
#> 26722 /home/cboettig/.local/share/neonstore/NEON.D19.DEJU.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150251Z.csv
#> 27026 /home/cboettig/.local/share/neonstore/NEON.D19.HEAL.DP1.10003.001.brd_countdata.2017-06.expanded.20191107T153447Z.csv
#> 27028 /home/cboettig/.local/share/neonstore/NEON.D19.HEAL.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153729Z.csv
#> 27030 /home/cboettig/.local/share/neonstore/NEON.D19.HEAL.DP1.10003.001.brd_countdata.2018-07.expanded.20191107T152537Z.csv
#> 27032 /home/cboettig/.local/share/neonstore/NEON.D19.HEAL.DP1.10003.001.brd_countdata.2019-06.expanded.20191205T150203Z.csv
#> 27034 /home/cboettig/.local/share/neonstore/NEON.D19.HEAL.DP1.10003.001.brd_countdata.2019-07.expanded.20191205T150200Z.csv
#> 27352 /home/cboettig/.local/share/neonstore/NEON.D20.PUUM.DP1.10003.001.brd_countdata.2018-04.expanded.20191107T154219Z.csv
```

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

Read in all the component tables into a single data.frame

``` r
brd_countdata <- neon_read(meta)
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
```
