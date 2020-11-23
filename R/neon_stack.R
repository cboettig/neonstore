# Internal stacking method used by both neon_read and neon_store



neon_stack <- function(files, 
                       keep_filename = FALSE,
                       sensor_metadata = TRUE, 
                       altrep = FALSE, 
                       progress = TRUE,
                       vroom_progress = FALSE,
                       ...){
  
  ## Stack H5 Files (eddy-covariance only)
  if(any(grepl("[.]h5$", files))){
    stack_eddy(files, progress = progress, ...)
  
  ## Stack sensor data    
  } else if(is_sensor_data(files) && sensor_metadata){
    df <- vroom_each(files, 
                     progress = progress,
                     altrep = altrep, 
                     vroom_progress = vroom_progress,
                     ...)
    add_sensor_columns(df)
  
  ## Stack observational data, with filename as a column    
  } else if(keep_filename) {
    ## Just keeps files names as an additional column in stacked data
    vroom_each(files, 
               progress = progress,
               altrep = altrep,
               vroom_progress = vroom_progress,
               ...)

  ## Faster stacking of observational data, no additional meta columns  
  } else {
    ## Usually much much faster if we can do this one
    vroom_many(files, 
               progress = progress,
               altrep = altrep, 
               vroom_progress = vroom_progress,
               ...)
  }
}


add_sensor_columns <- function(df){
  filename_meta <- neon_filename_parser(df$file)
  df$domainID <- filename_meta$DOM
  df$siteID <- filename_meta$SITE
  df$horizontalPosition <- filename_meta$HOR
  df$verticalPosition <- filename_meta$VER
  df$publicationDate <- as.POSIXct(filename_meta$GENTIME, 
                                   format = "%Y%m%dT%H%M%OS")
  
  df
}




## read each file in separately and then stack them.
## include file name as additional id column
vroom_each <- function(files,
                       progress = TRUE,
                       altrep = FALSE, 
                       vroom_progress = FALSE,
                       ...){
  
  if(progress){
    pb <- progress::progress_bar$new(
      format = paste("  reading files",
                     "[:bar] :percent in :elapsed, eta: :eta"),
      total = length(files), 
      clear = FALSE, 
      width = 80)
  }
  
  suppress_msg({
    groups <-  lapply(files,
                      function(x){
                        if(progress) pb$tick()
                        out <- vroom::vroom(x, guess_max = 1e5,
                                            altrep = altrep,
                                            progress = vroom_progress,
                                            ...)
                        out$file <- basename(x)
                        out
                      })
  })
  suppressWarnings({
    df <- ragged_bind(groups)
    na_bool_to_char(df)
  }) 
}



## vroom can read in a list of files, but only if columns are consistent
## So this attempts vroom over a list of files, but falls back on vroom_ragged
vroom_many <- function(files, 
                       altrep = FALSE, 
                       progress = FALSE,
                       vroom_progress = FALSE,
                       ...){
  suppress_msg({ ## We don't need vroom telling us every table spec!
    df <- tryCatch(vroom::vroom(files, 
                                guess_max = 5e4, 
                                altrep = altrep,
                                progress = vroom_progress,
                                ...),
                   error = function(e) vroom_ragged(files, 
                                                    guess_max = 5e4,
                                                    altrep = altrep,
                                                    vroom_progress = FALSE,
                                                    ...),
                   finally = NULL)
  })
  na_bool_to_char(df)
}


## Apply vroom over files that share a common schema.
vroom_ragged <- function(files, altrep = FALSE, vroom_progress = FALSE, ...){
  
  ## We read the 1st line of every file to determine schema  
  suppress_msg(
    schema <- lapply(files, 
                     vroom::vroom, 
                     n_max = 1, 
                     altrep = altrep, 
                     progress = FALSE,
                     ...)
  )
  ## Now, we read in tables in groups of matching schema,
  ## filling in additional columns as in bind_rows.
  
  col_schemas <- lapply(schema, colnames)
  u_schemas <- unique(col_schemas)
  tbl_list <- vector("list", length=length(u_schemas))
  
  all_cols <- unique(unlist(u_schemas))
  
  i <- 1
  for(s in u_schemas){
    
    ## select tables that have matching schemas
    index <- vapply(col_schemas, identical, logical(1L), s)
    col_types <- vroom::spec(schema[index][[1]])
    
    ## Read in all those tables
    tbl <- vroom::vroom(files[index], 
                        altrep = altrep,
                        progress = vroom_progress,
                        col_types = col_types)
    
    ## append any columns missing from all_cols set
    missing <- all_cols[ !(all_cols %in% colnames(tbl)) ]
    tbl[ missing ] <- NA
    tbl_list[[i]] <- tbl
    i <- i+1
    
  }
  do.call(rbind, tbl_list)
  
}


## vs do.call(rbind, x), dplyr::bind_rows will:
## - Handle differing numbers of columns
## - Handle type-coercion correctly (logical vs Date -> Date, not double) 
## - Run about 15x faster and use much less RAM



## A base-R version of (recent versions of) dplyr::bind_rows,
## which can handle varying numbers of columns
ragged_bind <- function(x){
  
  #x <- x[!is.null(x)]
  #x <- x[vapply(x, nrow, 1) > 0]
  
  col_schemas <- lapply(x, colnames)
  col_types <- lapply(x, function(df) lapply(df, function(x) class(x)[[1]]))
  u_schemas <- unique(col_schemas)
  all_cols <- unique(unlist(u_schemas))
  
  consensus_type <- vapply(all_cols, function(col)
    type_hierarchy(unique(lapply(col_types, `[[`, col))),
    ""
  )
  
  
  for(i in seq_along(x)){
    ## append any columns missing from all_cols set
    missing <- all_cols[ !(all_cols %in% colnames(x[[i]])) ]
    x[[i]][ missing ] <- NA
    x[[i]] <- set_schema_type(x[[i]], consensus_type)
  }
  do.call(rbind, x)
  
}


## Enforce column typing according to this consensus ranking
type_hierarchy <- function(x){
  
  out <- max(ordered(x, 
          c("logical", 
            "integer", 
            "numeric", 
            "character", 
            "Date", 
            "POSIXct")), na.rm = TRUE)
  
  as.character(out)
}

set_schema_type <- function(df, col_types){
  if(!all(colnames(df) %in% names(col_types))){
    stop("some column names not found in type list")
  }
  
  df_types <- vapply(df, function(x) class(x)[[1]], "")
  
  wrong <- which(df_types != col_types[colnames(df)])
  
  
  for(i in wrong){
    
    ## What do we do about non-coerce-able types?
    if(is.logical(df[[i]])  && !all(is.na(df[[i]]))){
      warning("cannot align column type", df_types[[i]],
              "with", col_types[[i]])
    }
      
    df[[i]] <- as_type(df[[i]], col_types[[i]])
  }
  df
}

## bc methods::as(NA, "Date") fail!
as_type <- function(x, type){
  switch(type,
    "Date" = as.Date(x),
    "POSIXct" = as.POSIXct(x),
    "character" = as.character(x),
    "numeric" = as.numeric(x),
    "integer" = as.integer(x),
    "logical" = as.logical(x),
    x)
}



suppress_msg <- function(expr, pattern = c("Rows:")){
  withCallingHandlers(expr,
                      message = function(e){
                        if(any(vapply(pattern, grepl, logical(1), e$message)))
                          invokeRestart("muffleMessage")
                      })
}

