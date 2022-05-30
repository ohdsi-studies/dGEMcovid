# Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of dGEMcovid
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

createCohorts <- function(
  databaseDetails,
  outputFolder
) {
  if (!file.exists(outputFolder)){
    dir.create(outputFolder)
  }
  
  conn <- DatabaseConnector::connect(databaseDetails$connectionDetails)
  on.exit(DatabaseConnector::disconnect(conn))
  
  .createCohorts(
    connection = conn,
    cdmDatabaseSchema = databaseDetails$cdmDatabaseSchema,
    cohortDatabaseSchema = databaseDetails$cohortDatabaseSchema,
    cohortTable = databaseDetails$cohortTable,
    oracleTempSchema = databaseDetails$tempEmulationSchema,
    outputFolder = outputFolder
  )
  
  # Check number of subjects per cohort:
  ParallelLogger::logInfo("Counting cohorts")
  sql <- SqlRender::loadRenderTranslateSql(
    "GetCounts.sql",
    "dGEMcovid",
    dbms = databaseDetails$connectionDetails$dbms,
    oracleTempSchema = databaseDetails$tempEmulationSchema,
    cdm_database_schema = databaseDetails$cdmDatabaseSchema,
    work_database_schema = databaseDetails$cohortDatabaseSchema,
    study_cohort_table = databaseDetails$cohortTable
  )
  counts <- DatabaseConnector::querySql(conn, sql)
  colnames(counts) <- SqlRender::snakeCaseToCamelCase(colnames(counts))
  counts <- addCohortNames(counts)
  utils::write.csv(counts, file.path(outputFolder, "CohortCounts.csv"), row.names = FALSE)
}

addCohortNames <- function(data) {
  pathToCsv <- system.file("Cohorts.csv", package = "dGEMcovid")

  idToName <- utils::read.csv(pathToCsv)
  idToName <- idToName[order(idToName$cohortId), ]
  idToName <- idToName[!duplicated(idToName$cohortId), ]
  data <- merge(idToName,data, all.x = TRUE)

  return(data)
}







.createCohorts <- function(
  connection,
  cdmDatabaseSchema,
  vocabularyDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema,
  cohortTable,
  oracleTempSchema,
  outputFolder
) {
  
  # Create study cohort table structure:
  sql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "CreateCohortTable.sql",
    packageName = "dGEMcovid",
    dbms = attr(connection, "dbms"),
    oracleTempSchema = oracleTempSchema,
    cohort_database_schema = cohortDatabaseSchema,
    cohort_table = cohortTable
  )
  DatabaseConnector::executeSql(connection, sql, progressBar = FALSE, reportOverallTime = FALSE)
  
  
  # Instantiate cohorts:
  pathToCsv <- system.file("Cohorts.csv", package = "dGEMcovid")
  cohortsToCreate <- utils::read.csv(pathToCsv)
  for (i in 1:nrow(cohortsToCreate)) {
    writeLines(paste("Creating cohort:", cohortsToCreate$cohortName[i]))
    sql <- SqlRender::loadRenderTranslateSql(
      sqlFilename = paste0(cohortsToCreate$cohortId[i], ".sql"),
      packageName = "dGEMcovid",
      dbms = attr(connection, "dbms"),
      oracleTempSchema = oracleTempSchema,
      cdm_database_schema = cdmDatabaseSchema,
      vocabulary_database_schema = vocabularyDatabaseSchema,
      
      target_database_schema = cohortDatabaseSchema,
      target_cohort_table = cohortTable,
      target_cohort_id = cohortsToCreate$cohortId[i]
    )
    DatabaseConnector::executeSql(connection, sql)
  }
  
}

