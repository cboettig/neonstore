context("utilities")


test_that("neon_export()/neon_import()", {
  
  neondir1 <-  tempfile()
  
  x <- neon_download(product = "DP1.10003.001",
                     site = "YELL",
                     start_date = "2018-05-01",
                     end_date = "2018-08-01",
                     dir = neondir1)
  
  meta1 <- neon_index(dir = neondir1)
  
  archive <- tempfile(fileext = ".zip")
  suppressMessages({
    meta <- neon_export(archive, dir = neondir1)
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
  expect_equal(basename(meta1$path), basename(meta2$path))
  
  ## error handling
  x <- neon_export(product = "not-a-product")
  expect_null(x)
  
  expect_warning(
    x <- neon_import("not-a-product")
  )
  expect_null(x)
  
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
  expect_equal(dim(meta), c(7,11))
  
  expect_true(any(grepl("DP1.10003.001", meta$product)))
  expect_true(any(grepl("brd_countdata", meta$table)))
  
})


test_that("neon_citation()", {
  
  x <- neon_citation(dir = tempfile())
  expect_is(x, "bibentry")
  
  x <- neon_citation("DP1.10003.001")
  expect_is(x, "bibentry")
  expect_true(grepl("DP1.10003", x))
  
  ## shorter format
  y <- neon_citation(c("DP1.10001.001","DP1.10002.001","DP1.10003.001",
                       "DP1.10004.001","DP1.10005.001","DP1.10006.001"))
  expect_is(y, "bibentry")
  expect_false(grepl("DP1.10003", y))
  
  
})

test_that("na_bool_to_char", {
  df <- data.frame(A = 1:2, B = NA, C = "text", D = c(NA, TRUE), E = NA,
                   stringsAsFactors = FALSE)
  df2 <- na_bool_to_char(df)
  type <- vapply(df2, class, "", USE.NAMES = FALSE)
  expect_identical(type, c("integer", "character", "character",
                           "logical", "character"))
})

