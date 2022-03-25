createStudyJson <- function(
  packageName = 'exampleStudy',
  skeletonVersion = "v0.0.1",
  organizationName = 'add organization',
  targetId = 1,
  outcomeId = 2,
  restrictPlpDataSettings,
  populationSettings = list(),
  covariateSettings = list(),
  dataCovariateSettings = createDataCovariateSettings(),
  control = list(
    heterogeneity = FALSE,
    model = 'ODAL',
    family = 'binomial',
    optim_maxit = 100
  ),
  baseUrl
){
  
  # check inputs
  if(!class(targetId) %in% c('numeric','interger')){
    stop('Incorrect targetId')
  }
  if(!class(outcomeId) %in% c('numeric','interger')){
    stop('Incorrect outcomeId')
  }
  
  if(class(covariateSettings) == 'covariateSettings'){
    covariateSettings <- list(covariateSettings)
  }
  check <- sum(unlist(lapply(covariateSettings, function(x) class(x) == 'covariateSettings'))) == length(covariateSettings)
  if(!check){
    stop('Issue with covariateSetting class')
  }
  
  if(class(populationSettings) != 'populationSettings'){
    stop('Issue with populationSettings class')
  }
  
  if(class(restrictPlpDataSettings) != 'restrictPlpDataSettings'){
    stop('Issue with restrictPlpDataSettings class')
  }
  
  if(class(control) != 'list'){
    stop('control must be a list')
  }
  
  if(class(control$heterogeneity) != "logical"){
    stop('heterogeneity must be logical')
  }
  
  # check control$model and control$family are in set of values
  
  if(is.null(control$optim_maxit)){
    ParallelLogger::logInfo('optim_maxit not specified so defaulting to 100')
    control$optim_maxit <- 100
  }
  
  resultList <- list()
  resultList$skeletonType <-  "DistributedModelStudy"
  resultList$packageName <- packageName
  resultList$skeletonVersion <- skeletonVersion
  resultList$organizationName <- organizationName
  
  resultList$studySettings <- list()
  resultList$studySettings$targetId <- targetId
  resultList$studySettings$outcomeId <- outcomeId
  resultList$studySettings$covariateSettings <- covariateSettings
  resultList$studySettings$dataCovariateSettings <- dataCovariateSettings
  resultList$studySettings$restrictPlpDataSettings <- restrictPlpDataSettings
  resultList$studySettings$populationSettings <- populationSettings
  
  resultList$studySettings$control <- list()
  resultList$studySettings$control$heterogeneity <- control$heterogeneity
  resultList$studySettings$control$model <- control$model 
  resultList$studySettings$control$family <- control$family
  resultList$studySettings$control$optim_maxit <- control$optim_maxit
  
  resultList$cohortDefinitions <- getCohorts(
    outcomeId = outcomeId, 
    targetId = targetId,
    covariateSettings = covariateSettings,
    baseUrl = baseUrl
  )

  json <- toJsonFormat(resultList)
  
  return(json)
}

toJsonFormat <- function(resultList){
  
  # add covariate setting attributes
  resultList$studySettings$covariateSettings <- lapply(
    resultList$studySettings$covariateSettings, 
    addAttributes
    )
  
  # add population setting attributes
  resultList$studySettings$populationSettings <- addAttributes(resultList$studySettings$populationSettings)
  # add restrictPlpDataSettings attributes
  resultList$studySettings$restrictPlpDataSettings <- addAttributes(resultList$studySettings$restrictPlpDataSettings)
  
  # convert to json
  
  jsonList <- jsonlite::toJSON(
    x = resultList, 
    pretty = T, 
    digits = 23, 
    auto_unbox=TRUE, 
    null = "null",
    keep_vec_names=TRUE # fixing issue with jsonlite dropping vector names
  )
  
  return(jsonList)
}

addAttributes <- function(x){
  x$attributes <- attributes(x)
  class(x) <- 'list'
  return(x)
}

getCohorts <- function(outcomeId, targetId, covariateSettings, baseUrl){
  
  ParallelLogger::logInfo('Finding cohorts to extract')
  
  # get outcome and target ids
  allCohortIds <- c(
    outcomeId, 
    targetId,
    unlist(lapply(covariateSettings, function(x) x[grep('cohortId', names(x))]))
  )

  allCohortIds <- unique(allCohortIds)
  
  ParallelLogger::logInfo('Extracting cohorts using webapi')
  
  cohortDefinitions <- list()
  length(cohortDefinitions) <- length(allCohortIds)
  for (i in 1:length(allCohortIds)) {
    ParallelLogger::logInfo(paste("Extracting cohort:", allCohortIds[i]))
    cohortDefinitions[[i]] <- ROhdsiWebApi::getCohortDefinition(
      cohortId = allCohortIds[i], 
      baseUrl = baseUrl
    )
    
    ParallelLogger::logInfo(paste0('Extracted ', cohortDefinitions[[i]]$name ))
  }
  
  return(cohortDefinitions)
  
}


createDataCovariateSettings <- function(
  numberOfVisits = T,
  visitTypeCount = T,
  dateStart = '20050101',
  dateEnd = gsub('-','', Sys.Date())
  ){
  
  settings <- list(
    numberOfVisits = numberOfVisits,
    visitTypeCount = visitTypeCount,
    dateStart = dateStart,
    dateEnd =dateEnd
    )
  
  return(settings)
  
}

