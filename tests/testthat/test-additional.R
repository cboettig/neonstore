context("s3")



test_that("neon_download_s3()", {
  
  
  skip_on_cran()
  skip_if_offline()
  
  x <- neon_download_s3("DP1.10003.001",
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

