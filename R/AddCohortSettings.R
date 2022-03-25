addCohortSettings <- function(
  covariateSettings, 
  cohortDatabaseSchema, 
  cohortTable
){
  
  if(class(covariateSettings) == 'covariateSettings'){
    covariateSettings <- list(covariateSettings)
  }
  
  # set the cohort table and database to the settings where the cohorts were generated
  for(i in 1:length(covariateSettings)){
    
    if('cohortTable' %in% names(covariateSettings[[i]])){
      covariateSettings[[i]]$cohortTable <- cohortTable
    }
    
    if('cohortDatabaseSchema' %in% names(covariateSettings[[i]])){
      covariateSettings[[i]]$cohortDatabaseSchema <- cohortDatabaseSchema
    }
    
  }
  
  return(covariateSettings)
}