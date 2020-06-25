
NEON API BUGS:
  
  
- API has .zip and .csv files.  But some entries have .zip but not the matching .csv:  
  
```
x <- neon_download(product = "DP1.10003.001",
                      site = "YELL",
                      start_date = "2019-01-01",
                      end_date = "2020-01-01")
```

Design issues:

- Why do we need to hit the API so many times for common requests (i.e. each month and site)
- Why do download URLs have expiring cache credentials?
- Downloading only zip files means we download huge number of copies of identical
  metadata (when we query a product for all months at a site or all sites)
- We can avoid by querying csv files directly, but some are missing.
- Should individual csv files be compressed? (or does this happen on the fly?)
- Why do we have identical metadata files with differing filenames?  (minor issue)

- Why not flatter download stucture that could avoid / bypass the REST API?
