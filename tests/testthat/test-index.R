context("index")


test_that("neon_index()", {
  
  skip_if_offline()
  skip_on_cran()
  x <- neon_download(product = "DP1.10003.001",
                     site = "YELL",
                     start_date = "2018-05-01",
                     end_date = "2018-08-01")  
  
  x <- neon_index()
  expect_is(x, "data.frame")
  expect_true(any(grepl("DP1.10003.001", x$product)))

})


test_that("neon_index options", {
  
  skip_if_offline()
  skip_on_cran()
  x <- neon_download(product = "DP1.10003.001",
                     site = "YELL",
                     start_date = "2018-05-01",
                     end_date = "2018-08-01")  
  
  
  x <- neon_index(hash = "md5", 
                  start_date = "2018-01-01", 
                  end_date = "2020-01-01", 
                  product =  "DP1.10003.001",
                  site = "YELL")
  expect_is(x, "data.frame")
  expect_true(any(grepl("DP1.10003.001", x$product)))
  expect_true(any(grepl("hash", colnames(x))))
  
  ## No data expected if timestamp predates data publication times!
  x <- neon_index(timestamp = as.POSIXct("2010-01-01 01:00:00"))
  ## sometimes draws a row of all NAs
  expect_true(nrow(x) <= 1)
  
  x <- neon_index(dir = tempfile())
  expect_null(x)
  
  expect_warning({
    x <- neon_index(hash="not-a-hash")
  })
})

