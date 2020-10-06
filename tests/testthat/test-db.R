context("db")

## setup so we have something in the store



test_that("neon_db", {
  
  
  db <- neon_db()
  expect_is(db, "DBIConnection")

  neon_delete_db(ask = FALSE)
  
})


test_that("neon_store error handling", {
  
  
  db <- neon_store(table = "brd_countdata-expanded",
                   dir = tempdir())
  
  db <- neon_store(product = "not-a-product",
                   dir = tempdir())
})
  

test_that("neon_store", {

  skip_if_offline()
  skip_on_cran()
  
  x <- neon_download(product = "DP1.10003.001",
                     site = "YELL",
                     start_date = "2018-05-01",
                     end_date = "2018-08-01")
  
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

test_that("neon_table", {
  
  skip_if_offline()
  skip_on_cran()
  
  x <- neon_download(product = "DP1.10003.001",
                     site = "YELL",
                     start_date = "2018-05-01",
                     end_date = "2018-08-01")
  
  
  db <- neon_store(table = "brd_countdata-expanded")
  expect_is(db, "DBIConnection")
  x <- DBI::dbListTables(db)
  expect_true("brd_countdata-expanded" %in% x)

  
  tbl <- neon_table("brd_countdata-expanded")
  expect_is(tbl, "data.frame")
  expect_true(nrow(tbl) > 0)
  expect_true(any(grepl("observerDistance", colnames(tbl))))
  
  ## Confirm no duplicates
  expect_identical(tbl, unique(tbl))
  
  ## Compare to neon_read
  tbl2 <- neon_read("brd_countdata-expanded")
  
  ## neon_read won't have the "file" column on obs data
  tbl1 <- tbl[!colnames(tbl) == "file"]
  expect_identical(colnames(tbl1), colnames(tbl2))
  expect_identical(dim(tbl1), dim(tbl2))
  
  
  
  tbl <- neon_table("brd_countdata-expanded", site="YELL")
  expect_is(tbl, "data.frame")
  expect_true(nrow(tbl) > 0)

  tbl <- neon_table("brd_countdata-expanded", site="not-a-site")
  expect_is(tbl, "data.frame")
  expect_true(nrow(tbl) == 0)
  
  
})


test_that("check_tablename", {
  
  expect_error(check_tablename("A", c("B", "D")))
  expect_error(check_tablename("A", c("A-basic", "A-expanded")))
  
  x <- check_tablename("A-expan", c("A-basic", "A-expanded"))
  expect_equal(x, "A-expanded")
  
})


