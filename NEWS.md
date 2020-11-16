# v0.3.3

- Allow concurrent connections for reading from database.  
- Allow users to specify an alternative location for the database, see `neon_db_dir()`.  Note that in multi-user environments,
  users may prefer to share a file store but utilize separate databases that they can write to independently. 
- `neon_read()` gains the argument `keep_filename`, to always add a column with the filename of the original source data. Filenames may contain important metadata (such as `siteID`) that is not always included in the tables themselves.
- bugfix for solaris test

# v0.3.2

- improving type inference in `neon_store()` (some more)
- improved messaging / progress bars for `neon_store()`

# v0.3.1

- improve type inference in `neon_store()`
- support eddy covariance (.h5) imports (experimental)

# v0.3.0

- add support for a relational database storage via `neon_store()`, `neon_table()`, and `neon_db()` (see README and docs for examples) [#23]
- minor bugfixes

# v0.2.3

- Use subdir structure (product/site/month) inside the neon directory [#17]
- extend `neon_index()` defaults to include `horizontalPosition` and `verticalPosition`  & `samplingInterval` metadata from filename for sensor data [#11]
- bugfix for reading most recent files only when working with sensor data. 
- bugfix for potential error when no new files to download are found [#19]
- bugfix for altrep defaults, see `?neon_read`

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