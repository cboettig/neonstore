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
  
  x <- neon_store(dir = tempfile())
  expect_null(x)
  
})

test_that("neon_read()", {
  
  x <- neon_read("brd_count")
  expect_is(x, "data.frame")
  expect_true(any(grepl("observerDistance", colnames(x))))
  
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


