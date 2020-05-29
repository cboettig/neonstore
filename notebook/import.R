
#```{r birds}
bench_time(
  neon_download("DP1.10003.001", file_regex = ".*basic.*[.]csv")
)
#```



#```{r  beetles}

#beetle_data <- neon_data("DP1.10022.001")

bench::bench_time(
  neon_download("DP1.10022.001")
)
#```

#```{r mozzies}
bench::bench_time(
  neon_download("DP1.10043.001")
)
#```


#```{r ticks}
bench::bench_time(
  neon_download("DP1.10093.001", quiet = TRUE)
)

#```


#```{r mammals}
dir.create("mammals")

bench::bench_time(
  neon_download("DP1.10072.001", dest = "mammals", file_regex = "*.basic.*[.]zip",  quiet = TRUE)
)





library(dplyr); library(vroom)
meta <- neon_index()
meta %>% count(product, name)
f <- meta %>% filter(name == "mam_perplotnight", type == "basic") %>% pull(path)

neon_read(f) # vroom with error handler

