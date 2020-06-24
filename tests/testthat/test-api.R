context("api")


test_that("neon_dir()", {
  
  x <- neon_dir()
  expect_equal(x, Sys.getenv("NEONSTORE_HOME"))
  
})



test_that("neon_sites()", {
  
  skip_on_cran()
  skip_if_offline()
  
  x <- neon_sites()
  expect_is(x, "data.frame")
  expect_match(colnames(x), "siteCode", all=FALSE)
  expect_gt(nrow(x), 10)
})



test_that("neon_products()", {

  skip_on_cran()
  skip_if_offline()
    
  x <- neon_products()
  expect_is(x, "data.frame")
  expect_match(colnames(x), "productCode", all=FALSE)  
  expect_gt(nrow(x), 10)
  
  
})




test_that("neon_data()", {
  
  skip_on_cran()
  skip_if_offline()

  x <- neon_data("DP1.10003.001",
                 site = "YELL",
                 start_date = "2019-06-01",
                 end_date = "2019-08-01")
  
  expect_is(x, "data.frame")
  expect_gt(nrow(x), 1)
  
})



test_that("take_first_match()", {
  
  
  df <- data.frame(A = c(1,1,2,2), 
                   B = c("a", "b", "c", "d"),
                   row.names = NULL)
  out <- take_first_match(df, "A")
  
  expect_equal(dim(out), c(2,2))

})


test_that("neon_download()", {
  
  
  skip_on_cran()
  skip_if_offline()
  
  x <- neon_download("DP1.10003.001",
                     site = "YELL",
                     start_date = "2018-01-01",
                     end_date = "2019-01-01")
  expect_is(x, "data.frame")
  expect_gt(nrow(x), 0)
  
  
})



