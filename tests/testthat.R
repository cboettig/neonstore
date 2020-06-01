library(testthat)
library(neonstore)

Sys.setenv("NEONSTORE_HOME" = tempfile())

test_check("neonstore")
