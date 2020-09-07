# v0.2.2

- Keep .zip files so we can take advantage of not re-downloading [#13]
- drop `neon_store()` [#10]
- Document & export `neon_export()` and `neon_import()` for importing/exporting a whole neonstore [#9]
- `neon_read()` now parses additional columns into Instrumental Systems (sensor data) by default:
   DomainID, SiteID, horizontalPosition, verticalPosition, and publicationDate.
- g'zipped hdf5 products are now extracted [#12]

# v0.2.1 

- handle another change in API file naming (for eddy-covariance files [#7])

# v0.2.0 

- API queries will now automatically detect rate limiting events and pause for required time.
- Upstream API has changed how hashes are reported, `neonstore` now handles this change.
- `neon_read()` will now check if a file requested has identical product, site, month, &
  table names.  If it does, then it will use only the more recent timestamp instead of 
  reading the same file in twice.  

# v0.1.2, on CRAN 2020-08-11

initial release to CRAN