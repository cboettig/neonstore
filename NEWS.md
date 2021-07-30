# v0.4.4

- Use vroom >= 1.5.1 and avoid verbose vroom messages in vroom >= 1.5.0; [#53]

# v0.4.3

- allow `neon_index()` to run on read-only filesystems
- fix updated parsing of lab names [#52]

# v0.4.2

- Bugfix de-duplication within `neon_store()` [#50]
- Fix paths on unparse-able names [#51]

# v0.4.1

- More robust de-duplication (even if `neon_store()` import terminates prematurely, [#48])

# v0.4.0

- A new function, `show_deprecated_data()`, shows which if any local data files have been updated in the NEON API.  Such files have changed both the timestamp in their filename and changed content, and older versions are no longer returned by the NEON API.  The warning only appears if the deprecated data files are still available in the local store. 
- Backend database (for `neon_store()`) is now pluggable: you can pass any valid `DBIConnection` to a SQL database of your choice in favor of the default `duckdb` connection provided by `neon_db()`.  This may be valuable in cases where concurrent write access to the database is desired.  ([#39])
- Compatibility update for significant changes to the NEON API, including dropping the use of the `.zip` file packaging in favor of requests to individual files. ([#34])
- Support for version tracking of NEON's new RELEASE tags, see: <https://www.neonscience.org/data-samples/data-management/data-revisions-releases>
- `neon_download()`, `neon_index()`, `neon_read()` gain a `release` argument ([#36]).  Release tags associated with each file are recorded in the database, but database functions `neon_store()` and `neon_table()` do not directly filter by release tag since the database holds all current data.  
- `neon_download()` now creates and maintains a 'manifest' tracking the release tag associated with each file by content hash. 
- We also use the same manifest to filter out downloads where the timestamp changed but the content did not, without having to compute hashes locally. 
- `neon_index()` gains a `release` column, as well as displaying NEON's `md5` (non-AOP data) or `crc32` (AOP only) hashes recorded in the manifest.  Note: With the `.h5.gz` files we record the hash of the compressed file even though we don't keep the .gz version around, which is a bit of a slight-of-hand. This means that consecutive calls to neon_download() will no longer perform any downloads whenever the data remains unchanged. 
- Improvements to `neon_db()` handle multiple connections better
- Some minor tweaks have been made to how files are mapped to subdirectories in the store, 
- tables in the database are now named with both the file description and product number to avoid namespace collision

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