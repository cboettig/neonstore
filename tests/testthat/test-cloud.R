


test_that("Direct cloud access", {
  
  skip_if_offline()
  skip_on_cran()
  # skip_on_os("windows")
  
  urls <-  neon_urls(table = "waq_instantaneous",
                      product = "DP1.20288.001",
                      start_date = "2023-06-01",
                      end_date = "2023-08-01",
                      type="basic"
  )
  
  format <- gsub(".*\\.(\\w+)$", "\\1", urls)
  expect_true(all(format == "csv")) 
  
  
  timestamp <- gsub(paste0(".*", GENTIME, "\\..*"), "\\1", urls)
  chrono <- order(timestamp, decreasing = TRUE)
  urls <- urls[chrono]
  
})


test_that("Direct cloud access", {
  
  skip_if_offline()
  skip_on_cran()
 # skip_on_os("windows")
  
  df <-  neon_cloud(table = "waq_instantaneous",
                               product = "DP1.20288.001",
                               start_date = "2023-06-01",
                               end_date = "2023-08-01",
                               type="basic"
  )
  
  expect_s3_class(df, "tbl_lazy")
  cols <- colnames(df)
  expect_true("siteID" %in% cols)
  
  test <- df |> 
    dplyr::select(siteID, domainID, horizontalPosition, verticalPosition) |>
    dplyr::collect()

  df_local <- dplyr::collect(df)
  expect_s3_class(df_local, "tbl")
  
  
  
  
  df <-  neon_cloud(table = "bet_sorting",
                                product = "DP1.10022.001",
                                start_date = "2020-06-01",
                                end_date = "2023-08-01",
                                type="expanded"
  )
  
  
  expect_s3_class(df, "tbl_lazy")
  cols <- colnames(df)
  expect_true("siteID" %in% cols)
  expect_s3_class(df, "tbl")
  df_local <- dplyr::collect(df)
  expect_s3_class(df_local, "tbl")
  
})  
  
  
test_that("Big (rate-limited) tests of direct cloud access", {
    
    skip_if_offline()
    skip_on_cran()
    skip("slow")
    # skip_on_os("windows")
    
  
  df <-  neon_cloud(table = "waq_instantaneous",
                                product = "DP1.20288.001",
                                start_date = "2018-01-01",
                                end_date = "2023-08-01",
                                type="basic",
                                unify_schemas = TRUE
  )
  
  expect_s3_class(df, "tbl_lazy")
  df_local <- dplyr::collect(df)
  
  
})

test_that("union", {
  
  skip_if_offline()
  skip_on_cran()
  
  df <- neon_cloud("mappingandtagging",
                   product = "DP1.10098.001",
                   site = "BART")
  
  expect_s3_class(df, "tbl_lazy")
  df_local <- dplyr::collect(df)
  expect_s3_class(df_local, "tbl")
  
  
})
