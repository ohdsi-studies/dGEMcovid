# demo code to create a study package:

## Make sure you have the latest Hydra
##devtools::install_github('ohdsi/Hydra')

outputFolder <- file.path('D:/testing', 'packages')
baseUrl <- ''

json <- createStudyJson(
  packageName = 'dGEMcovid',
  skeletonVersion = "v0.0.1",
  organizationName = 'testOrganization',
  targetId = 5859,
  outcomeId = 5861,
  restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(),
  populationSettings = PatientLevelPrediction::createStudyPopulationSettings(
    firstExposureOnly = T, 
    requireTimeAtRisk = F, 
    riskWindowStart = 0, startAnchor = 'cohort start',
    riskWindowEnd = 7, endAnchor = 'cohort end'
  ), 
  dataCovariateSettings = createDataCovariateSettings(
    numberOfVisits = T, 
    visitTypeCount = T, 
    dateStart = '20200101'
    ),
  covariateSettings = list(
    
    FeatureExtraction::createCovariateSettings(
      useDemographicsAgeGroup = T,
      useDemographicsGender = T,
      useDemographicsRace = T, 
      useVisitCountLongTerm = T, 
      useVisitConceptCountLongTerm = T, 
      useCharlsonIndex = T
      ),
    
    PatientLevelPrediction::createCohortCovariateSettings(
    cohortName = 'COPD', 
    cohortDatabaseSchema = '', cohortTable = '',
    settingId = 1, 
    cohortId = 5863, 
    startDay = -365*100, 
    endDay = -1,
    analysisId = 566
      ),
    PatientLevelPrediction::createCohortCovariateSettings(
      cohortName = 'Cancer', 
      cohortDatabaseSchema = '', cohortTable = '',
      settingId = 1, 
      cohortId = 5864, 
      startDay = -365*99, 
      endDay = -1,
      analysisId = 566
    ),
    PatientLevelPrediction::createCohortCovariateSettings(
      cohortName = 'Diabetes', 
      cohortDatabaseSchema = '', cohortTable = '',
      settingId = 1, 
      cohortId = 5865, 
      startDay = -365*99, 
      endDay = -1,
      analysisId = 566
    ),
    PatientLevelPrediction::createCohortCovariateSettings(
      cohortName = 'Heart disease', 
      cohortDatabaseSchema = '', cohortTable = '',
      settingId = 1, 
      cohortId = 5866, 
      startDay = -365*99, 
      endDay = -1,
      analysisId = 566
    ),
    PatientLevelPrediction::createCohortCovariateSettings(
      cohortName = 'Hyperlipidemia', 
      cohortDatabaseSchema = '', cohortTable = '',
      settingId = 1, 
      cohortId = 5867, 
      startDay = -365*99, 
      endDay = -1,
      analysisId = 566
    ),
    PatientLevelPrediction::createCohortCovariateSettings(
      cohortName = 'Hypertension', 
      cohortDatabaseSchema = '', cohortTable = '',
      settingId = 1, 
      cohortId = 5868, 
      startDay = -365*99, 
      endDay = -1,
      analysisId = 566
    ),
    PatientLevelPrediction::createCohortCovariateSettings(
      cohortName = 'Kidney disease',
      cohortDatabaseSchema = '', cohortTable = '',
      settingId = 1, 
      cohortId = 5869, 
      startDay = -365*99, 
      endDay = -1,
      analysisId = 566
    ),
    PatientLevelPrediction::createCohortCovariateSettings(
      cohortName = 'Obesity', 
      cohortDatabaseSchema = '', cohortTable = '',
      settingId = 1, 
      cohortId = 5870, 
      startDay = -365*99, 
      endDay = -1,
      analysisId = 566
    )
    ),
  control = list(
    heterogeneity = FALSE,
    model = 'ODAL',
    family = 'binomial',
    optim_maxit = 100
  ),
  baseUrl = baseUrl
)

# Hydra the package:
Hydra::hydrate(
  specifications = json, 
  outputFolder = outputFolder
  )

