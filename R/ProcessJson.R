fromJsonFormat <- function(jsonList){
  
  json <- tryCatch(
    {jsonlite::fromJSON(
      jsonList, 
      simplifyVector = T, 
      simplifyDataFrame = F, 
      simplifyMatrix = T)
    },
    error = function(cond) {
      ParallelLogger::logInfo('Issue with parsing json object...');
      ParallelLogger::logError(cond)
    })
  
  # add attributes back
  json$studySettings$covariateSettings <- lapply(
    json$studySettings$covariateSettings, 
    extractAttributes
  )
  
  # add population setting attributes
  json$studySettings$populationSettings <- extractAttributes(json$studySettings$populationSettings)
  # add restrictPlpDataSettings attributes
  json$studySettings$restrictPlpDataSettings <- extractAttributes(json$studySettings$restrictPlpDataSettings)
  
  return(json)
}

loadJson <- function(jsonFileLocation){
  if(class(jsonFileLocation) != 'character'){
    stop('Incorrect jsonFileLocation input - must be character')
  }
  if(!file.exists(jsonFileLocation)){
    ParallelLogger::logError('Invalid directory - does not exist')
  }
  
  if(!file.exists(file.path(jsonFileLocation))){
    ParallelLogger::logError('predictionAnalysisList.json not found ')
  }
  
  
  json <- tryCatch(
    {readChar(jsonFileLocation, file.info(jsonFileLocation)$size)},
    error= function(cond) {
      ParallelLogger::logInfo('Issue with loading json file...');
      ParallelLogger::logError(cond)
    })
  
  return(json)
}

extractAttributes <- function(x){
  attr <- x$attributes
  x$attributes <- NULL
  attr$names <- names(x)
  attributes(x) <- attr
  return(x)
}