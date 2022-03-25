dataSummary <- function(
  dataCovariateSettings,
  databaseDetails
){
  
  conn <- DatabaseConnector::connect(connectionDetails = databaseDetails$connectionDetails)
  on.exit(DatabaseConnector::disconnect(conn))
  
  resultSummary <- c()
  
  # code to get the data summary variables
  if(dataCovariateSettings$numberOfVisits){
  sql <- paste0(
    "SELECT count(*) N from @cdm_database_Schema.visit_occurrence ",
    " where  visit_end_date >= CAST('@study_start_date' AS DATE)",
    " and visit_start_date <= CAST('@study_end_date' AS DATE);"
  )
  
  sql <- SqlRender::render(
    sql, 
    cdm_database_Schema = databaseDetails$cdmDatabaseSchema,
    study_start_date = dataCovariateSettings$startDate,
    study_end_date = dataCovariateSettings$endDate
    )
  
  sql <- SqlRender::translate(
    sql = sql, 
    targetDialect = databaseDetails$connectionDetails$dbms, 
    tempEmulationSchema = databaseDetails$tempEmulationSchema
    )
  
  result <- DatabaseConnector::querySql(sql, connection = conn)
  
  resultSummary <- c(visitCount = result$N)
  
  }
  
  if(dataCovariateSettings$visitTypeCount){
  sql <- paste0(
    "select b.concept_name as name, a.N from ",
    "(SELECT visit_concept_id, count(*) N from @cdm_database_Schema.visit_occurrence ",
  " where  visit_end_date >= CAST('@study_start_date' AS DATE)",
  " and visit_start_date <= CAST('@study_end_date' AS DATE)",
    " group by visit_concept_id) a",
    " inner join @cdm_database_Schema.concept b ",
    " on a.visit_concept_id = b.concept_id;"
  )
  
  sql <- SqlRender::render(
    sql, 
    cdm_database_Schema = databaseDetails$cdmDatabaseSchema,
    study_start_date = dataCovariateSettings$startDate,
    study_end_date = dataCovariateSettings$endDate
  )
  
  sql <- SqlRender::translate(
    sql = sql, 
    targetDialect = databaseDetails$connectionDetails$dbms, 
    tempEmulationSchema = databaseDetails$tempEmulationSchema
  )
  
  result <- DatabaseConnector::querySql(sql, connection = conn)
  
  resultSummary <- c(result$N,resultSummary)
  names(resultSummary)[1:length(result)] <- result$NAME

  }
  
  return(resultSummary)
  
}