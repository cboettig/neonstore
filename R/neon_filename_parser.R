



# https://data.neonscience.org/file-naming-conventions


#Abbreviation 	Definition
#NEON 	A four-character alphanumeric code, denoting the organizational origin of the data product and identifying the product as operational; data collected as part of a special data collection exercise are designated by a separate, unique alphanumeric code created by the PI.
#DOM 	A three-character alphanumeric code, referring to the domain of data acquisition (D01 - D20).
#SITE 	A four-character alphanumeric code, referring to the site of data acquisition; all sites are designated by a standardized four-character alphabetic code.
#DPL 	A three-character alphanumeric code, referring to data product processing level.
#PRNUM 	A five-character numeric code, referring to the data product number (see the Data Product Catalog at http://data.neonscience.org/data-product-catalog).
#REV 	A three-digit designation, referring to the revision number of the data product. The REV value is incremented by 1 each time a major change is made in instrumentation, data collection protocol, or data processing such that data from the preceding revision is not directly comparable to the new.
#HOR 	A three-character alphanumeric code for Spatial Index #1. Refers to measurement locations within one horizontal plane. For example, if five surface measurements were taken, one at each of the five soil array plots, the number in the HOR field would range from 001-005.
#VER 	A three-character alphanumeric code for Spatial Index #2. Refers to measurement locations within one vertical plane. For example, if eight temperature measurements are collected, one at each tower vertical level, the number in the VER field would range from 010-080.
#TMI 	A three-character alphanumeric code for the Temporal Index. Refers to the temporal representation, averaging period, or coverage of the data product (e.g., minute, hour, month, year, sub-hourly, day, lunar month, single instance, seasonal, annual, multi-annual). 000 = native resolution, 001 = native resolution or 1 minute, 002 = 2 minute, 005 = 5 minute, 015 = 15 minute, 030 = 30 minute, 060 = 60 minutes or 1 hour, 101-103 = native resolution of replicate sensor 1, 2, and 3 respectively, 999 = Sensor conducts measurements at varied interval depending on air mass.
#DESC 	An abbreviated description of the data file or table.
#YYYY-MM 	Represents the year and month of the data in the file.
#PKGTYPE 	The type of data package downloaded. Options are 'basic', representing the basic download package, or 'expanded',representing the expanded download package (see more information below).
#GENTIME 	The date-time stamp when the file was generated, in UTC. The format of the date-time stamp is YYYYMMDDTHHmmSSZ.

NEON <- "(NEON)"
DOM <- "(D\\d\\d)"
SITE <- "([A-Z]{4})"
DPL <- "(DP\\d)"
PRNUM <- "(\\d{5})"
REV <- "(\\d{3})"

## I think these are actually 3-digit, not 3-alphanumeric character
HOR <- "([0-9]{3})"
VER <- "([0-9]{3})"
TMI <- "([a-zA-Z0-9]{3})"
DESC <- "(\\w+)"
YYYY_MM <- "(\\d{4}-\\d{2})"
YYYY_MM_DD <- "(\\d{4}-\\d{2}-\\d{2})"
PKGTYPE <- "(basic|expanded|)"
GENTIME <- "(\\d{4}\\d{2}\\d{2}T\\d{2}\\d{2}\\d{2}Z)"



## Most data files are observation systems or instrument systems:
OS_DATA <- paste(NEON, DOM, SITE, DPL, PRNUM, REV, DESC, 
                 YYYY_MM, PKGTYPE, GENTIME, "csv", sep = "\\.")
IS_DATA <- paste(NEON, DOM, SITE, DPL, PRNUM, REV, HOR, VER,
                 TMI, DESC, YYYY_MM, PKGTYPE, GENTIME, "csv", sep = "\\.")

## NOTE! a few OS_DATA are missing YYYY_MM!
OS_DATA2 <- paste(NEON, DOM, SITE, DPL, PRNUM, REV, DESC, 
                 PKGTYPE, GENTIME, "csv", sep = "\\.")
## GENTIME_optional <- paste0("(", "\\.", GENTIME, ")?")

## Eddy Covariance is a single product, with it's own formats:
EC_ZIP <- paste(NEON, DOM, SITE, "DP4\\.00200\\.001", 
                YYYY_MM, PKGTYPE, GENTIME, "zip", sep = "\\.")

EC_MONTHLY <- paste(NEON, DOM, SITE, "DP4\\.00200\\.001", DESC,
                    YYYY_MM, PKGTYPE, "h5", sep = "\\.")
EC_DAILY <- paste(NEON, DOM, SITE, "DP4\\.00200\\.001", DESC,
                  YYYY_MM_DD, PKGTYPE, "h5", sep = "\\.")

EC_MONTHLY2 <- paste(NEON, DOM, SITE, "DP4\\.00200\\.001", DESC,
                     YYYY_MM, PKGTYPE, GENTIME, "h5", sep = "\\.")
EC_DAILY2 <- paste(NEON, DOM, SITE, "DP4\\.00200\\.001", DESC,
                   YYYY_MM_DD, PKGTYPE, GENTIME, "h5", sep = "\\.")


## Not in standard
## There are other ZIP patterns:
## "CPER_2013_L3_Camera_Mosaic.zip"
ZIP_ISOS <- paste(NEON, DOM, SITE, DPL, PRNUM, REV, YYYY_MM,
                  PKGTYPE, GENTIME, "zip", sep = "\\.")


## Not all READMEs have GENTIME or SITE
README1 <- paste(NEON, DOM, SITE, DPL, PRNUM, REV,
                 "readme", GENTIME, "txt", sep = "\\.")
README2 <- paste(NEON, DOM, DPL, PRNUM, REV, "readme", "txt", sep = "\\.")

# README <- "readme"
META <- paste(NEON, DOM, SITE, DPL, PRNUM, REV, DESC,
              GENTIME, "csv", sep = "\\.")

EML <- paste(NEON, DOM, SITE, DPL, PRNUM, REV, "EML",
             "\\d{8}-\\d{8}", GENTIME, "xml", sep = "\\.")

## Unidentified XML formats:
# "NEON.D10.CPER.DP1.00017.001.20170101-20170201.xml" 
# "2013_CPER_1_DTM.tif.aux.xml"                    

## From the Products Table: productScienceTeamAbbr:
##  AIS and TIS are instrumented systems (IS) data.
##  AOS and TOS are observational systems (OS) data
##  AOP is airborne data
## EC is a type of TIS data


neon_filename_parser <- function(x){
  
  os_is_data <- ragged_bind(list(
  name_parse(x, OS_DATA,
        c("NEON","DOM","SITE","DPL","PRNUM","REV","DESC",
          "YYYY_MM","PKGTYPE","GENTIME", "EXT")),
  name_parse(x, OS_DATA2,
             c("NEON","DOM","SITE","DPL","PRNUM","REV","DESC",
               "PKGTYPE","GENTIME", "EXT")),
  name_parse(x, IS_DATA,
    c("NEON","DOM","SITE","DPL","PRNUM","REV","HOR","VER",
      "TMI","DESC","YYYY_MM","PKGTYPE","GENTIME", "EXT")),
  name_parse(x, ZIP_ISOS, 
    c("NEON","DOM","SITE","DPL","PRNUM","REV","YYYY_MM",
      "PKGTYPE","GENTIME", "EXT"))
  ))
 
  ec_data <- ragged_bind(list(
  name_parse(x, EC_DAILY,
    c("NEON","DOM","SITE","DPL","PRNUM","REV","DESC",
      "YYYY_MM_DD","PKGTYPE", "EXT")),
  name_parse(x, EC_MONTHLY,
    c("NEON","DOM","SITE","DPL","PRNUM","REV","DESC",
      "YYYY_MM","PKGTYPE", "EXT")),
  name_parse(x, EC_DAILY2,
             c("NEON","DOM","SITE","DPL","PRNUM","REV","DESC",
               "YYYY_MM_DD","PKGTYPE", "GENTIME", "EXT")),
  name_parse(x, EC_MONTHLY2,
             c("NEON","DOM","SITE","DPL","PRNUM","REV","DESC",
               "YYYY_MM","PKGTYPE", "GENTIME", "EXT")),
  name_parse(x, EC_ZIP,
    c("NEON","DOM","SITE","DPL","PRNUM","REV","DESC",
      "YYYY_MM","PKGTYPE", "GENTIME", "EXT"))
  ))
 
 
  misc <- ragged_bind(list(
  name_parse(x,META, 
             c("NEON","DOM","SITE","DPL","PRNUM","REV",
               "DESC","GENTIME", "EXT")),
  name_parse(x, EML,  
             c("NEON","DOM","SITE","DPL","PRNUM","REV","EML",
              "DATE_RANGE" ,"GENTIME", "EXT")),

  name_parse(x, README1, 
             c("NEON","DOM","SITE","DPL","PRNUM",
               "REV","README","GENTIME", "EXT"))
             
  ))
  
  aop_data <- aop_parser(x)
  
  ragged_bind(list(os_is_data, ec_data, misc, aop_data))
  
}

## keep full path name as column?

## Simple strplit based parser
name_parse <- function(x, pattern, col_names, split = ".", fixed = TRUE){
  x <- basename(x) # drop path before parsing
  y <- x[grepl(pattern, x)] # operate only on those matching the pattern
  tmp <- strsplit(y, split, fixed = fixed)
  out <- as_tibble(do.call("rbind", tmp), .name_repair = "minimal")
  colnames(out) <- col_names
  out$name <- y
  out
}

## Alternate strategy relying on grouping, more robust than strsplit()
## Handles case where _ is used both as sep and within a field (DESC)
name_parse_gsub <- function(x, pattern, col_names){
  x <- basename(x) # drop path before parsing
  y <- x[grepl(pattern, x)]
  tmp <- vector("list", length(col_names))
  names(tmp) <- col_names
  for(i in seq_along(col_names)){
    tmp[[i]] <- gsub(pattern, paste0("\\", as.character(i)), y)
  }
  out <- as_tibble(tmp, .name_repair = "check_unique")
  out$name <- y
  out
}




### AOP Products Only  (Airborne Observation Platform)

# FLHTDATE 	Date of flight, YYYYMMDD
# FLIGHTSTRT 	Start time of flight, YYYYMMDDHH
# FLHTSTRT 	Start time of flight, YYMMDDHH
# IMAGEDATETIME 	Date and time of image capture, YYYYMMDDHHmmSS
# CCCCCC 	Digital camera serial number
# NNNN 	Sequential number for indexing files
# NNN 	Planned flightline number
# R 	Repeat number
# FFFFFF 	Numeric code for an individual flightline
# EEEEEE 	UTM easting of lower left corner
# NNNNNNN 	UTM northing of lower left corner
FLHTDATE <- "(\\d{4}\\d{2}\\d{2})"
FLIGHTSTRT <- "(\\d{4}\\d{2}\\d{2}\\d{2})"
FLHTSTRT <- "(\\d{8})"
IMAGEDATETIME <- "(\\d{14})"
CCCCCC <-  "(\\d{6})"
NNNN <- "(\\d{4})"
NNN <- "(\\d{3})"
R <- "(\\d)"
FFFFFF <- "(\\d{6})"
EEEEEE <- "(\\d{6})"
NNNNNNN <- "(\\d{7})"
EXT <- "\\.([0-9a-z]+$)"

CAMERA <-	paste0(FLHTSTRT,"_","EH",CCCCCC, "\\(", IMAGEDATETIME, "\\)-",
                 NNNN, "_ort", EXT) #.tif
LIDAR_UNCLASSIFIED <- paste0(NEON, "_", DOM, "_", SITE, "_", DPL, "_", "L",
                             NNN,"-", R, "_", FLIGHTSTRT, "_", DESC, EXT) #
LIDAR_CLASSIFIED 	<- paste0(NEON, "_", DOM, "_", SITE, "_", DPL, "_", EEEEEE,
                            "_", NNNNNNN, "_", DESC, EXT) #"\\.laz"
L1_SPECTROMETER <-	paste0(NEON, "_", DOM, "_", SITE, "_", DPL, "_", FLHTDATE,
                          "_", FFFFFF, "_", DESC, EXT) # "\\.h5"
LIDAR_WAVEFORM <- paste0(NEON, "_", DOM, "_", SITE, "_", DPL, "_", "L", NNN,
                         "-", R, "_", FLIGHTSTRT, "_", DESC,  EXT) #"(wvz|plz)")
L2_SPECTROMETER <- paste0(NEON, "_", DOM, "_", SITE, "_", DPL, "_", FLHTDATE,
                          "_", FFFFFF, "_", DESC, EXT) # "\\.(zip|tif)")
L3_AOP <- 	paste0(NEON, "_", DOM, "_", SITE, "_", DPL, "_", EEEEEE, "_",
                  NNNNNNN, "_", DESC,  EXT) #"\\.(laz|tif|[a-z]{3})")
ZIP_AOP3 <- paste0(paste(NEON,DOM,SITE,DPL,EEEEEE, NNNNNNN,
                         DESC, sep = "_"), "\\.(zip)")
ZIP_AOP2 <- paste0(paste(NEON,DOM,SITE,DPL,FLHTDATE, FFFFFF, DESC, sep = "_"),
                   "\\.(zip)")

## descriptions often have _, preventing us from splitting on _
aop_parser <- function(x){
  A <- ragged_bind(list(
    name_parse_gsub(x, CAMERA,	
               c("FLHTSTRT","EHCCCCCC",  "IMAGEDATETIME", "NNNN", "EXT")),
    name_parse_gsub(x, LIDAR_UNCLASSIFIED, 
             c("NEON", "DOM","SITE",  "DPL", "NNN",
               "R", "FLIGHTSTRT", "DESC", "EXT")),
    name_parse_gsub(x, LIDAR_CLASSIFIED,
               c("NEON", "DOM", "SITE", "DPL", "EEEEEE",
                 "NNNNNNN", "DESC", "EXT")),
    name_parse_gsub(x, L1_SPECTROMETER,
               c("NEON", "DOM", "SITE", "DPL", "FLHTDATE",
                 "FFFFFF", "DESC", "EXT"))
  ))
  B <- ragged_bind(list(
    name_parse_gsub(x, LIDAR_WAVEFORM,
               c("NEON", "DOM", "SITE", "DPL", "NNN", "R",
                 "FLIGHTSTRT",  "DESC", "EXT")),
    name_parse_gsub(x, L2_SPECTROMETER,
              c("NEON", "DOM",  "SITE", "DPL",  "FLHTDATE",
                "FFFFFF",  "DESC", "EXT")),
    name_parse_gsub(x, L3_AOP,	
               c("NEON", "DOM",  "SITE", "DPL", "EEEEEE",
                 "NNNNNNN",  "DESC", "EXT"))
  ))
  
  ## Not yet in the standard
  ## There are other ZIP patterns: "CPER_2013_L3_Camera_Mosaic.zip"
  C <- ragged_bind(list(
    name_parse_gsub(x, ZIP_AOP3,
               c("NEON","DOM","SITE","DPL","EEEEEE",
                 "NNNNNNN", "DESC", "EXT")),
    name_parse_gsub(x, ZIP_AOP2, 
                c("NEON","DOM","SITE","DPL","FLHTDATE",
                  "FFFFFF", "DESC", "EXT"))
  ))
  out <- ragged_bind(list(A,B,C))
  
  ## distinct rows only (filenames differing only by extension match same regex)
  unique_rows <- !duplicated(out)
  out[unique_rows,]
}



