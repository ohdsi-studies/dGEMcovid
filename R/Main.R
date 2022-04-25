# Copyright 2020 Observational Health Data Sciences and Informatics
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

#' Execute the Study
#'
#' @details
#' This function executes the dGEMcovid Study.
#' 
#' @param databaseDetails      The connection details and OMOP CDM details. Created using \code{PatientLevelPrediction::createDatabaseDetails}.
#' @param siteId               The name of your site (can be the university name, site with a number, etc.) tnis needs to be shared with the study administrator
#' @param outputFolder         Name of local folder to place results - make sure control is in here; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param createCohorts        Create the cohortTable table with the target population and outcome cohorts?
#' @param createData           Create the labelled data set (this is required before runAnalysis)
#' @param sampleSize           The number of patients in the target cohort to sample (if NULL uses all patients)
#' @param createControl        (for the lead site only) Run this code to create the study control
#' @param siteIds              (for the lead site only) vector with the names of all the sites contributing to the study. Required when createControl = TRUE
#' @param runInitialize        Runs the initialization step - this require downloading the json control from https://pda-ota.pdamethods.org/ 
#' @param runDerive            Runs the derive step - this require downloading the updated json control from https://pda-ota.pdamethods.org/ 
#' @param runEstimate          Runs the estimate step - this require downloading the updated json control from https://pda-ota.pdamethods.org/ 
#' @param runSynthesize        Once the site estimates are returned, it is now possible to apply each model to the data to calculate
#'                             predictions.  This step requires downloading the updated json control from https://pda-ota.pdamethods.org/                        
#' @param verbosity            Sets the level of the verbosity. If the log level is at or higher in priority than the logger threshold, a message will print. The levels are:
#'                                         \itemize{
#'                                         \item{DEBUG}{Highest verbosity showing all debug statements}
#'                                         \item{TRACE}{Showing information about start and end of steps}
#'                                         \item{INFO}{Show informative information (Default)}
#'                                         \item{WARN}{Show warning messages}
#'                                         \item{ERROR}{Show error messages}
#'                                         \item{FATAL}{Be silent except for fatal errors}
#'                                         }                              
#'
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms = "postgresql",
#'                                              user = "joe",
#'                                              password = "secret",
#'                                              server = "myserver")
#'
#' execute(databaseDetails,
#'         siteId = 'site_1',
#'         outputFolder = "c:/temp/study_results", 
#'         createCohorts = T,
#'         createData = T,
#'         sampleSize = 10000,
#'         createControl = F,
#'         siteIds = c('site_1', 'site_2'),
#'         leadSiteNextStep = F,
#'         runAnalysis = F,
#'         runSynthesize = F,
#'         verbosity = "INFO"
#'         )
#' }
#'
#' @export
execute <- function(databaseDetails,
                    siteId = 'site_name',
                    outputFolder,
                    createCohorts = F,
                    createData = F,
                    sampleSize = NULL,
                    createControl = F,
                    siteIds = '', # only needed if lead site
                    leadSiteNextStep = F,
                    runInitialize = F,
                    runDerive = F,
                    runEstimate = F,
                    runSynthesize = F,
                    verbosity = "INFO"
                    ) {
  
  if (!file.exists(outputFolder)){
    dir.create(outputFolder, recursive = TRUE)
  }
  
  website <- 'https://pda-ota.pdamethods.org/'
  
  # load the analysis
  analysisListFile <- system.file(
    "settings",
    "analysisList.json",
    package = "dGEMcovid"
  )
  
  if(file.exists(analysisListFile)){
    analysisList <- loadJson(analysisListFile)
    analysisList <- fromJsonFormat(analysisList)
    analysisList$studySettings$covariateSettings <- addCohortSettings(
      covariateSettings = analysisList$studySettings$covariateSettings,
      cohortDatabaseSchema = databaseDetails$cohortDatabaseSchema , 
      cohortTable = databaseDetails$cohortTable
    )
  }else{
    stop('No analysisList available')
  }
  
  if(createCohorts) {
    ParallelLogger::logInfo("Creating cohorts")
    createCohorts(
      databaseDetails = databaseDetails,
      outputFolder = outputFolder
    )
    
    ParallelLogger::logInfo('Generating date plot')
    generateDatePlot(
      databaseDetails = databaseDetails,
      outputFolder = outputFolder
      )
  } 
  
  if(createData){
    ParallelLogger::logInfo("Creating labelled dataset")

    databaseDetails$cohortId <- analysisList$studySettings$targetId
    databaseDetails$outcomeIds <- analysisList$studySettings$outcomeId
    
    plpData <- PatientLevelPrediction::getPlpData(
      databaseDetails = databaseDetails, 
      covariateSettings = analysisList$studySettings$covariateSettings, 
      restrictPlpDataSettings = analysisList$studySettings$restrictPlpDataSettings
      )

    labels <- PatientLevelPrediction::createStudyPopulation(
      plpData = plpData, 
      outcomeId = analysisList$studySettings$outcomeId, 
      populationSettings = analysisList$studySettings$populationSettings
    )
    
    # convert to matrix
    
    dataObject <- PatientLevelPrediction::toSparseM(
      plpData = plpData, 
      cohort = labels
    )
    
    #sparse matrix: dataObject$dataMatrix
    #labels: dataObject$labels
    
    columnDetails <- as.data.frame(dataObject$covariateRef)
    
    cnames <- columnDetails$covariateName[order(columnDetails$columnId)]
    
    ipMat <- as.matrix(dataObject$dataMatrix)
    ipdata <- as.data.frame(ipMat)
    colnames(ipdata) <-  makeFriendlyNames(cnames)
    ipdata$outcome <- dataObject$labels$outcomeCount
    
    # modify the covariates
    # Charlson comorbidity categories: 0-1, 2-4, and 5
    if('Charlson_index___Romano_adaptation' %in% colnames(ipdata)){
      ParallelLogger::logInfo('Processing Charlson index into categories')
      # Charlson comorbidity categories: 0-1, 2-4, and 5
      ipdata$Charlson_index___Romano_adaptation0_1 <- rep(0, nrow(ipdata))
      ipdata$Charlson_index___Romano_adaptation0_1[ipdata$Charlson_index___Romano_adaptation <= 1] <- 1
      
      ipdata$Charlson_index___Romano_adaptation2_4 <- rep(0, nrow(ipdata))
      ipdata$Charlson_index___Romano_adaptation2_4[ipdata$Charlson_index___Romano_adaptation <= 4 & ipdata$Charlson_index___Romano_adaptation >=2] <- 1
      
      ipdata$Charlson_index___Romano_adaptation5p <- rep(0, nrow(ipdata))
      ipdata$Charlson_index___Romano_adaptation5p[ipdata$Charlson_index___Romano_adaptation >= 5] <- 1
      
      ipdata <- ipdata[!colnames(ipdata) == 'Charlson_index___Romano_adaptation']
    }
    
    # Age categories: 18-65, 65-80, and 80
    if('age_in_years' %in% colnames(ipdata)){
      ParallelLogger::logInfo('Processing age into categories')
      
      ipdata$age18_64 <- rep(0, nrow(ipdata))
      ipdata$age18_64[ipdata$age_in_years >= 0 & ipdata$age_in_years <= 64] <- 1
      
      ipdata$age65_80 <- rep(0, nrow(ipdata))
      ipdata$age65_80[ipdata$age_in_years >= 65 & ipdata$age_in_years <= 79] <- 1
      
      ipdata$age80p <- rep(0, nrow(ipdata))
      ipdata$age80p[ipdata$age_in_years >= 80] <- 1
      
      ipdata <- ipdata[,colnames(ipdata) != 'age_in_years']
    }
    
    # save the data:
    utils::write.csv(
      x = ipdata, 
      file = file.path(outputFolder, 'data.csv'), 
      row.names = F
    )
    
    # add the data covariates
    
    if(!is.null(analysisList$studySettings$dataCovariateSettings)){
    dataSummary <- do.call(
      dataSummary, 
      list(
        dataCovariateSettings = analysisList$studySettings$dataCovariateSettings,
        databaseDetails = databaseDetails
        )
    )
    
    utils::write.csv(
      x = dataSummary, 
      file = file.path(outputFolder, 'dataSummary.csv'), 
      row.names = F
    )
    
    }
    
  }
  
  # Step 1: lead site creates the control
  if(createControl){
    
    ParallelLogger::logInfo('Creating the control settings')
    
    #check the data exist to get the names
    if(file.exists(file.path(outputFolder, 'dataSummary.csv'))){
      dataSummary <- utils::read.csv(file.path(outputFolder, 'dataSummary.csv'))
    } else{
      dataSummary <- NULL
    }
    
    #check the data exist to get the names
    if(file.exists(file.path(outputFolder, 'data.csv'))){
      data <- utils::read.csv(file.path(outputFolder, 'data.csv'))
    } else{
      stop('Please generate data before creating control')
    }
    
    control <- list(
      project_name = analysisList$packageName,
      step = 'initialize',
      sites = siteIds,
      heterogeneity = analysisList$studySettings$control$heterogeneity,
      model = analysisList$studySettings$control$model,
      family = analysisList$studySettings$control$family,
      outcome = "outcome",
      variables = colnames(data)[colnames(data)!='outcome'],
      variables_site_level = names(dataSummary),
      optim_maxit = analysisList$studySettings$control$optim_maxit,
      lead_site = siteId,
      upload_date = as.character(Sys.time()) 
    )
    
    control <- jsonlite::toJSON(
      x = control, 
      pretty = T, 
      digits = 23, 
      auto_unbox=TRUE, 
      null = "null"
    )
    
    write(control, file.path(outputFolder, 'control.json'))
    
    ParallelLogger::logInfo(
      paste0(
        'Initial control create at: ',
        file.path(outputFolder, 'control.json'),
        ' please upload this to ', website
        
        )
      )

  }
  
  if(runInitialize | runDerive | runEstimate | runSynthesize){
    # json control file
    jsonFileLocation <- file.path(outputFolder, 'control.json')
    
  }

  
  if(runInitialize){
    
    control <- tryCatch(
      {readChar(jsonFileLocation, file.info(jsonFileLocation)$size)},
      error= function(cond) {
        ParallelLogger::logInfo('Issue with loading json file...');
        ParallelLogger::logError(cond)
      })
    control <- jsonlite::fromJSON(control)
    
    ipdata <- utils::read.csv(file.path(outputFolder, 'data.csv'))
    
    # get summary variables
    if(file.exists(file.path(outputFolder, 'dataSummary.csv'))){
      dataSummary <- utils::read.csv(file.path(outputFolder, 'dataSummary.csv'))
    } else{
      dataSummary <- NULL
    }
    
    
    if(!is.null(control)){
      if(control$step == 'initialize'){
    
    ParallelLogger::logInfo(paste0('At step ', control$step))
      pda::pda(
        ipdata = ipdata, 
        hosdata = dataSummary,
        site_id = siteId, 
        dir = outputFolder
      )
      
      ParallelLogger::logInfo(paste0('result json ready to check in ', outputFolder))
      ParallelLogger::logInfo(paste0('If you are happy to share, please upload this to ', website))
      
    } # control exists
    } else{
      ParallelLogger::logInfo('Control is not for initialize - please check control stage')
    }
  }
  
  if(runDerive){
    
    control <- tryCatch(
      {readChar(jsonFileLocation, file.info(jsonFileLocation)$size)},
      error= function(cond) {
        ParallelLogger::logInfo('Issue with loading json file...');
        ParallelLogger::logError(cond)
      })
    control <- jsonlite::fromJSON(control)
    
    ipdata <- utils::read.csv(file.path(outputFolder, 'data.csv'))
    
    # get summary variables
    if(file.exists(file.path(outputFolder, 'dataSummary.csv'))){
      dataSummary <- utils::read.csv(file.path(outputFolder, 'dataSummary.csv'))
    } else{
      dataSummary <- NULL
    }
    
    if(!is.null(control)){
      if(control$step == 'derive'){
        
        ParallelLogger::logInfo(paste0('At step ', control$step))
        pda::pda(
          ipdata = ipdata, 
          hosdata = dataSummary,
          site_id = siteId, 
          dir = outputFolder
        )
        
        ParallelLogger::logInfo(paste0('result json ready to check in ', outputFolder))
        ParallelLogger::logInfo(paste0('If you are happy to share, please upload this to ', website))
        
      } # control exists
    } else{
      ParallelLogger::logInfo('Control is not for derive - please check control stage')
    }
  }
  
  if(runEstimate){
    
    control <- tryCatch(
      {readChar(jsonFileLocation, file.info(jsonFileLocation)$size)},
      error= function(cond) {
        ParallelLogger::logInfo('Issue with loading json file...');
        ParallelLogger::logError(cond)
      })
    control <- jsonlite::fromJSON(control)
    
    ipdata <- utils::read.csv(file.path(outputFolder, 'data.csv'))
    
    # get summary variables
    if(file.exists(file.path(outputFolder, 'dataSummary.csv'))){
      dataSummary <- utils::read.csv(file.path(outputFolder, 'dataSummary.csv'))
    } else{
      dataSummary <- NULL
    }
    
    if(!is.null(control)){
      if(control$step == 'estimate'){
        
        ParallelLogger::logInfo(paste0('At step ', control$step))
        pda::pda(
          ipdata = ipdata, 
          hosdata = dataSummary,
          site_id = siteId, 
          dir = outputFolder
        )
        
        ParallelLogger::logInfo(paste0('result json ready to check in ', outputFolder))
        ParallelLogger::logInfo(paste0('If you are happy to share, please upload this to ', website))
        
      } # control exists
    } else{
      ParallelLogger::logInfo('Control is not for estimate - please check control stage')
    }
  }
  
  if(runSynthesize){
    #ipdata <- utils::read.csv(file.path(outputFolder, 'data'))
    # do something with this?
    #cbind(b.odal=fit.odal$btilde,
    #  sd.odal=sqrt(diag(solve(fit.odal$Htilde)/nrow(ipdata))))
  
  }
  
  invisible(NULL)
}


makeFriendlyNames <- function(columnNames){
  
  columnNames <- gsub("[[:punct:]]", " ", columnNames)
  columnNames <- gsub(" ", "_", columnNames)
  return(columnNames)
  
}