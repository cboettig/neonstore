context("eddy covariance")

test_that("read_eddy",{

  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("rhdf5")
  
  x <- neonstore::neon_download(product="DP4.00200.001", 
                                site = "BART", 
                                type="basic",
                                start_date = "2020-04-01",
                                end_date = "2020-08-01")
  
  index <- neon_index(product="DP4.00200.001", 
                      site = "BART", 
                      type="basic",
                      ext = "h5",
                      start_date = "2020-04-01",
                      end_date = "2020-08-01")
  h5 <- index$path[1:4]
  
  df <- neonstore:::read_eddy(h5[[1]])
  expect_is(df, "data.frame")
  expect_equal(dim(df), c(1392, 36))
  
  df <- neonstore:::stack_eddy(h5)
  expect_is(df, "data.frame")
  expect_equal(dim(df), c(5760, 36))
  df <- neonstore:::neon_stack(h5)
  expect_is(df, "data.frame")
  expect_equal(dim(df), c(5760, 36))
  
  
  
})
