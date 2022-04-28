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




generateDatePlot <- function(
  databaseDetails,
  outputFolder
){
  
  conn <- DatabaseConnector::connect(connectionDetails = databaseDetails$connectionDetails)
  on.exit(DatabaseConnector::disconnect(conn))

  sql <- "select cohort_start_date from @cohortSchema.@cohortTable 
        where cohort_definition_id = @cohortId;"
  
  sql <- SqlRender::render(
    sql = sql, 
    cohortSchema = databaseDetails$cohortDatabaseSchema,
    cohortTable = databaseDetails$cohortTable,
    cohortId = 5859
  )
  
  sql <- SqlRender::translate(
    sql = sql, 
    targetDialect = databaseDetails$connectionDetails$dbms, 
    tempEmulationSchema = databaseDetails$tempEmulationSchema
  )
  
  res <- DatabaseConnector::querySql(conn, sql)

  plotDate <- ggplot2::ggplot(
    data = res %>% dplyr::group_by(.data$COHORT_START_DATE) %>% dplyr::summarise(N = dplyr::n()), 
    ggplot2::aes(x = COHORT_START_DATE, y = N, group = 1)
    ) +
    ggplot2::geom_line()+
    ggplot2::geom_point() +
    ggplot2::theme(strip.text.y.right = ggplot2::element_text(angle = 0))

  
  ggplot2::ggsave(file.path(outputFolder, "countPerDate.pdf"))
  
  return(invisible(plotDate))
}
