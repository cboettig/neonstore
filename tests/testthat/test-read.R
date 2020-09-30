context("read")


## setup so we have something in the store
testthat::setup({
x <- neon_download(product = "DP1.10003.001",
                   site = "YELL",
                   start_date = "2018-05-01",
                   end_date = "2018-08-01")

})


test_that("neon_read()", {
  
  x <- neon_read("brd_countdata-expanded")
  expect_is(x, "data.frame")
  expect_true(any(grepl("observerDistance", colnames(x))))
  
})

test_that("neon_read() args", {
  
  x <- neon_read("brd_countdata-expanded", altrep=FALSE)
  expect_is(x, "data.frame")
  expect_true(any(grepl("observerDistance", colnames(x))))
  
})

test_that("ragged_bind()", {
  
  A <- data.frame(A = 1:5, B = 1:5)
  B <- data.frame(A = 1:5, B = 1:5, C = 1:5)
  x <- list(A, B)
  df <- ragged_bind(x)
  
  expect_is(df, "data.frame")
  expect_equal(colnames(df), colnames(B))
  
})

test_that("vroom_ragged()", {
  
  A <- data.frame(A = 1:5, B = 1:5)
  B <- data.frame(A = 1:5, B = 1:5, C = 1:5)
  
  files <- c(file.path(neon_dir(), "A.txt"),
             file.path(neon_dir(), "B.txt"))
  vroom::vroom_write(A, files[[1]])
  vroom::vroom_write(B, files[[2]])
  
  out <- vroom_ragged(files)
  
  expect_is(out, "data.frame")
  expect_equal(colnames(out), colnames(B))
  
  
})
