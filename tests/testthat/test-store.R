context("store")


## setup so we have something in the store
x <- neon_download("DP1.10003.001",
                   site = "YELL",
                   start_date = "2019-06-01",
                   end_date = "2019-08-01")


test_that("neon_index()", {
  
  x <- neon_index()
  expect_is(x, "data.frame")
  expect_true(any(grepl("DP1.10003.001", x$product)))
  
})


test_that("neon_store()", {
  
  x <- neon_store()
  expect_true(any(grepl("brd_countdata", x)))
  
})


test_that("neon_read()", {
  
  x <- neon_read("brd_count")
  expect_is(x, "data.frame")
  expect_true(any(grepl("observerDistance", colnames(x))))
  
  
})