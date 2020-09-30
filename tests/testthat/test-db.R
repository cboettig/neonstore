context("db")

## setup so we have something in the store
testthat::setup({
  x <- neon_download(product = "DP1.10003.001",
                     site = "YELL",
                     start_date = "2018-05-01",
                     end_date = "2018-08-01")
  
})


test_that("neon_db", {
  
  
  db <- neon_db()
  expect_is(db, "DBIConnection")
  
})


test_that("neon_store", {


  db <- neon_store(table = "brd_countdata-expanded")
  expect_is(db, "DBIConnection")
  x <- DBI::dbListTables(db)
  expect_true("brd_countdata-expanded" %in% x)
  
  expect_true("provenance" %in% x)
  
  tbl <- DBI::dbReadTable(db, "brd_countdata-expanded")
  expect_is(tbl, "data.frame")
  expect_true(nrow(tbl) > 0)
  expect_true(any(grepl("observerDistance", colnames(tbl))))
  
  ## compare provenance to index
  
})