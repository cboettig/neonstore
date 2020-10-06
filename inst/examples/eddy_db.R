library(neonstore)


index <- neon_index(product="DP4.00200.001", ext = "h5", deprecated = FALSE)

ex <- index$path[[1]]
out <- neonUtilities::stackEddy(ex)

df <- neonstore:::stack_eddy(index$path)
df <- neonstore:::neon_stack(index$path)

