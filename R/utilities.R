na_bool_to_char <- function(df){
  if(is.null(df)) return(df)
  
  types <- vapply(df, function(x) class(x)[[1]], "")
  bool <- which(types %in% "logical")
  
  if(length(bool) == 0 ){
    return(df)
  }
  ## convert  
  for(i in bool){
    if(all(is.na(df[[i]])))
      df[i] <- as.character(df[[i]])
  }
  
  df
}

