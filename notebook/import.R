
#```{r birds}
bench_time(
  neon_download("DP1.10003.001", file_regex = ".*basic.*[.]csv")
)
#```



#```{r  beetles}
bench::bench_time(
  neon_download("DP1.10022.001")
)
#```

#```{r mozzies}
bench_time(
  neon_download("DP1.10043.001")
)
#```


#```{r ticks}
bench_time(
  neon_download("DP1.10093.001")
)

#```