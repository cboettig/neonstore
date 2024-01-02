context("db")

## setup so we have something in the store



test_that("neon_db", {
  
  db <- neon_db()
  expect_is(db, "DBIConnection")

  db2 <- neon_db()
  
  ## Confirm cached connection
  expect_identical(db, db2)
  neon_disconnect(db)
  gc()

  
  neon_delete_db(ask = FALSE)
})


test_that("neon_store error handling", {
  
  expect_message({
  neon_store(table = "brd_countdata-expanded",
            dir = tempfile("no_files"))
  })
  expect_message({
    neon_store(product = "not-a-product",
                   dir = tempfile("no_products"))
  })
})
  

test_that("neon_store", {

  skip_if_offline()
  skip_on_cran()
  
  dir <- tempfile()
  x <- neon_download(product = "DP1.10003.001",
                     site = "YELL",
                     start_date = "2018-05-01",
                     end_date = "2018-08-01", 
                     dir = dir,
                     type = "expanded")
  db_dir <- tempfile("database")
  db <- neon_db(dir = db_dir, read_only = FALSE)
  neon_store(table = "brd_countdata-expanded", dir = dir,db = db)

  db <- neon_db(dir = db_dir)
  expect_is(db, "DBIConnection")
  x <- DBI::dbListTables(db)
  expect_true("brd_countdata-expanded-DP1.10003.001" %in% x)
  
  expect_true("provenance" %in% x)
  
  tbl <- DBI::dbReadTable(db, "brd_countdata-expanded-DP1.10003.001")
  expect_is(tbl, "data.frame")
  expect_true(nrow(tbl) > 0)
  expect_true(any(grepl("observerDistance", colnames(tbl))))
  
  neon_disconnect()
  ## compare provenance to index
  
})

test_that("neon_table", {
  
  skip_if_offline()
  skip_on_cran()
  dir <- tempfile()
  db_dir <- tempfile()
  db <- neon_db(dir = db_dir, read_only = FALSE)
  
  x <- neon_download(product = "DP1.10003.001",
                     site = "YELL",
                     start_date = "2018-05-01",
                     end_date = "2018-08-01",
                     type = "expanded",
                     dir = dir)
  
  
  neon_store(table = "brd_countdata-expanded",
             dir = dir, db = db)
  
  db <- neon_db(dir = db_dir)
  expect_is(db, "DBIConnection")
  x <- DBI::dbListTables(db)
  expect_true("brd_countdata-expanded-DP1.10003.001" %in% x)

  
  tbl <- neon_table("brd_countdata", db = db)
  expect_is(tbl, "data.frame")
  expect_true(nrow(tbl) > 0)
  expect_true(any(grepl("observerDistance", colnames(tbl))))
  
  ## Confirm no duplicates
  expect_identical(tbl, unique(tbl))
  
  ## Compare to neon_read
  tbl2 <- neon_read("brd_countdata-expanded", dir = dir)
  
  ## neon_read won't have the "file" column on obs data
  tbl1 <- tbl[!colnames(tbl) == "file"]
  expect_identical(colnames(tbl1), colnames(tbl2))
  expect_identical(dim(tbl1), dim(tbl2))
  
  
  
  tbl <- neon_table("brd_countdata-expanded", site="YELL", db = db)
  expect_is(tbl, "data.frame")
  expect_true(nrow(tbl) > 0)

  tbl <- neon_table("brd_countdata-expanded", site="not-a-site", db = db)
  expect_is(tbl, "data.frame")
  expect_true(nrow(tbl) == 0)
  
  neon_disconnect()
  
})


test_that("check_tablename", {
  
  expect_error(check_tablename("A", tables = c("B", "D")))
  expect_error(check_tablename("A", tables =  c("A-basic", "A-expanded")))
  
  x <- check_tablename("A-expan",  tables = c("A-basic", "A-expanded"))
  expect_equal(x, "A-expanded")
  
})


