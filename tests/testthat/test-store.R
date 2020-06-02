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
  
  x <- neon_read("brd_countdata-expanded")
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

test_that("neon_regex()", {
  
   x <- c(
  "NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T154457Z.csv",
  "NEON.D01.BART.DP0.10003.001.validation.20191107T152154Z.csv",
  "NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.basic.20191107T154457Z.csv",
  "NEON.D01.BART.DP1.10003.001.brd_references.expanded.20191107T152154Z.csv",
  "NEON.D01.BART.DP1.10003.001.2019-06.basic.20191205T150213Z.zip",
  "NEON.D01.HARV.DP1.10022.001.bet_sorting.2014-06.basic.20200504T173728Z.csv"
   )
  strsplit(gsub(neon_regex(), "\\1  \\2  \\3  \\5  \\6  \\7  \\8", x), "  ")
  
  
  
})


