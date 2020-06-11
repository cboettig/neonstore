#
neon_dir <- function(){
  Sys.getenv("NEONSTORE_HOME", 
             rappdirs::user_data_dir("neonstore"))
}
