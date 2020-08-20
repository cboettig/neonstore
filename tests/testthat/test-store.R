context("store")


## setup so we have something in the store
testthat::setup({
x <- neon_download(product = "DP1.10003.001",
                   site = "YELL",
                   start_date = "2018-05-01",
                   end_date = "2018-08-01")

})

test_that("neon_index()", {
  
  x <- neon_index()
  expect_is(x, "data.frame")
  expect_true(any(grepl("DP1.10003.001", x$product)))
  x <- neon_index(dir = tempfile())
  
})


test_that("neon_index options", {
  
  x <- neon_index(hash = "md5", 
                  start_date = "2018-01-01", 
                  end_date = "2020-01-01", 
                  product =  "DP1.10003.001",
                  site = "YELL")
  expect_is(x, "data.frame")
  expect_true(any(grepl("DP1.10003.001", x$product)))
  expect_true(any(grepl("hash", colnames(x))))
  
  
  x <- neon_index(dir = tempfile())
  
})

test_that("neon_store()", {
  
  x <- neon_store()
  expect_true(any(grepl("brd_countdata", x$table)))
  d <- tempfile()
  expect_message(
    x <- neon_store(dir = d)
  )
  expect_null(x)
  
})

test_that("neon_read()", {
  
  x <- neon_read("brd_countdata-expanded")
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

test_that("filename_parser()", {

 x <- c(
"NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.expanded.20191107T154457Z.csv",
"NEON.D01.BART.DP0.10003.001.validation.20191107T152154Z.csv",
"NEON.D01.BART.DP1.10003.001.brd_countdata.2015-06.basic.20191107T154457Z.csv",
"NEON.D01.BART.DP1.10003.001.brd_references.expanded.20191107T152154Z.csv",
"NEON.D01.BART.DP1.10003.001.2019-06.basic.20191205T150213Z.zip",
"NEON.D01.HARV.DP1.10022.001.bet_sorting.2014-06.basic.20200504T173728Z.csv",
"NEON.D03.SUGG.DP1.20288.001.103.100.100.waq_instantaneous.2018-01.expanded.20190618T023102Z.csv"
)

  meta <- filename_parser(x)
  expect_is(meta, "data.frame")
  expect_equal(dim(meta), c(7,8))
  
  expect_true(any(grepl("DP1.10003.001", meta$product)))
  expect_true(any(grepl("brd_countdata", meta$table)))
  
})


test_that("neon_citation()", {
  
  
  x <- neon_citation("DP1.10003.001")
  expect_is(x, "bibentry")
  expect_true(grepl("DP1.10003", x))
  
  ## shorter format
  y <- neon_citation(c("DP1.10001.001","DP1.10002.001","DP1.10003.001",
                       "DP1.10004.001","DP1.10005.001","DP1.10006.001"))
  expect_is(y, "bibentry")
  expect_false(grepl("DP1.10003", y))
  
    
})

test_that("neon_export()/neon_import()", {
  
  archive <- tempfile(fileext = ".zip")
  suppressMessages({
    meta <- neon_export(archive)
  })
  
  expect_true(file.exists(archive))
  expect_is(meta, "data.frame")
  
  ## now restore from archive to new store
  neondir <-  tempfile()
  
  expect_null( neon_index(dir = neondir) )
  
  ## restore
  neon_import(archive, dir = neondir)
  meta2 <- neon_index(dir = neondir)
  expect_false(is.null(meta2))
  expect_equal(basename(meta$path), basename(meta2$path))
  
})



