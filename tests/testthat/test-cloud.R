


test_that("Direct cloud access", {
  
  skip_if_offline()
  skip_on_cran()
 # skip_on_os("windows")
  
  df <-  neonstore:::neon_cloud(table = "waq_instantaneous",
                               product = "DP1.20288.001",
                               start_date = "2023-06-01",
                               end_date = "2023-08-01",
                               type="basic"
  )
  
  expect_s3_class(df, "tbl_lazy")
  
  
  df <-  neonstore:::neon_cloud(table = "bet_sorting",
                                product = "DP1.10022.001",
                                start_date = "2020-06-01",
                                end_date = "2023-08-01",
                                type="expanded"
  )
  
  
  expect_s3_class(df, "tbl_lazy")
  
  
})


