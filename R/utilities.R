na_bool_to_char <- function(df){
  
  types <- vapply(df, class, character(1L))
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

