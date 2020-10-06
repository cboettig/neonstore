library(neonstore)


index <- neon_index(product="DP4.00200.001", ext = "h5", deprecated = FALSE)



df <- neonstore:::stack_eddy(index$path)

