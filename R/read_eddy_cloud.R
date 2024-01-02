

# Not operational until non-gz H5 versions are made available
read_eddy_cloud <- function() {

  public_S3_url <- "https://storage.googleapis.com/neon-int-sae-tmp-files/ods/dataproducts/DP4/2020-04-26/GRSM/NEON.D07.GRSM.DP4.00200.001.nsae.2020-04-26.expanded.20230921T200400Z.h5"
  #listGrp <- rhdf5::h5ls(file = public_S3_url, s3 = TRUE)
  nee <- rhdf5::h5read(file = public_S3_url,
                       name = glue::glue("{site}/dp04/data/fluxCo2/turb",
                                         site="GRSM"), 
                       s3 = TRUE) 
  le <- rhdf5::h5read(file = public_S3_url,
                      name = glue::glue("{site}/dp04/data/fluxH2o/turb",
                                        site="GRSM"), 
                      s3 = TRUE) 
  

  
}

