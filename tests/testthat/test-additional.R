context("s3")



test_that("neon_download_s3()", {
  
  
  skip_on_cran()
  skip_if_offline()
  
  x <- neon_download_s3(product = "DP1.10003.001",
                     site = "YELL",
                     start_date = "2018-01-01",
                     end_date = "2019-01-01")
  expect_is(x, "data.frame")
  expect_gt(nrow(x), 0)
  
  
})



test_that("beetles", {
  
  
  skip_on_cran()
  skip_if_offline()
  
  x <- neon_download("DP1.10022.001",
                      site = "ORNL",
                      start_date = "2018-01-01",
                      end_date = "2019-01-01")
  expect_is(x, "data.frame")
  expect_gt(nrow(x), 0)
  
  df <- neon_read("bet_sorting")
  expect_is(df, "data.frame")
  
  
})

test_that("Aquatic sensor data", {
  
  skip_on_cran()
  skip_if_offline()
  
  neon_download("DP1.20288.001", site = c("CRAM","SUGG"), type="basic")
  df <- neon_read("waq_instantaneous")
  expect_true("siteID" %in% colnames(df))

  df <- neon_read("waq_instantaneous", sensor_metadata = FALSE)
  
  expect_false("siteID" %in% colnames(df))

  
})


test_that("ECdata", {
  
  
  skip_on_cran()
  skip_if_offline()
  

  x <- neon_download(product = "DP4.00200.001",
                     site = "BART",
                     start_date = "2020-06-01",
                     end_date = "2020-07-01",
                     type = "basic")
  expect_is(x, "data.frame")
  expect_gt(nrow(x), 0)
  
  df <- neon_index(product = "DP4.00200.001",
                                      start_date = "2020-06-01",
                                      ext = "h5")
  expect_is(df, "data.frame")
  expect_gt(nrow(df), 0)
  
  path_gz <- df$path[grepl("[.]gz", df$path)]
  path_h5 <- df$path[grepl("[.]h5", df$path)]
  
  expect_equal(length(path_gz), 0)
  expect_gt(length(path_h5), 0)
  
  
  
  

})
