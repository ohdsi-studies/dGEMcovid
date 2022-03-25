Instructions To Run Study
===================
- This study requires running multiple steps and submitting results to https://pda-ota.pdamethods.org/ 


## Step 1 - Register (skip this if you already have an account)
- register an account at https://pda-ota.pdamethods.org/

## Step 2 - Sign Up for a study
- Get the `project name` and `inviation code` from the study lead.  This will then enable you to download the control json for the study.  Please place the control.json file into the `outputFolder`.

## Step 3 - Initialize
- run the following code to create the patient level data (this is not shared) and the summary.  You need to specify the database details for the OMOP CDM database you are analyzing, `siteId` the unique reference for your site and `outputFolder` the directory you saved the control.json to.  After running the code you will see a new file in `outputFolder` called `data.csv` and `<siteId>_initialize.json`.

- You now need to inspect the `<siteId>_initialize.json` and if happy log into https://pda-ota.pdamethods.org/  and upload the file.

- after submitting the file, please wait for an email from the study lead before moving to step 4

```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "C:/dGEMcovidResults"


# Details for connecting to the server:
dbms <- "you dbms"
user <- 'your username'
pw <- 'your password'
server <- 'your server'
port <- 'your port'

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'cdm database schema'

# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'work database schema'

tempEmulationSchema <- NULL

# table name where the cohorts will be generated
cohortTable <- 'SkeletonPredictionStudyCohort'

databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
  connectionDetails = connectionDetails, 
  cdmDatabaseSchema = cdmDatabaseSchema, 
  cdmDatabaseName = cdmDatabaseSchema,
  tempEmulationSchema = tempEmulationSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outcomeDatabaseSchema = cohortDatabaseSchema,
  outcomeTable = cohortTable,
  cdmVersion = 5
)


# replace NULL with number to sample if needed
sampleSize <- NULL
#=======================

execute(
  databaseDetails = databaseDetails,
  siteId = siteId,
  outputFolder = outputFolder,
  createCohorts = T,
  createData = T,
  runInitialize = T,
  verbosity = "INFO"
        )
```


## Step 4 - Derive
- If you have an email from the study lead telling you to progress to the derive step, please log into https://pda-ota.pdamethods.org/ and download the new control.json into `outputFolder`.

- You can now run the following code to create the `<siteId>_derive.json` 

- You now need to inspect the `<siteId>_derive.json` and if happy log into https://pda-ota.pdamethods.org/  and upload the file.

- after submitting the file, please wait for an email from the study lead before moving to step 5

```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "C:/dGEMcovidResults"


#=======================

execute(
  siteId = siteId,
  outputFolder = outputFolder,
  runDerive = T,
  verbosity = "INFO"
        )
```

## Step 5 - Estimate
- If you have an email from the study lead telling you to progress to the estimate step, please log into https://pda-ota.pdamethods.org/ and download the new control.json into `outputFolder`.

- You can now run the following code to create the `<siteId>_estimate.json` 

- You now need to inspect the `<siteId>_estimate.json` and if happy log into https://pda-ota.pdamethods.org/  and upload the file.

- after submitting the file, please wait for an email from the study lead before moving to step 6

```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "C:/dGEMcovidResults"


#=======================

execute(
  siteId = siteId,
  outputFolder = outputFolder,
  runEstimate = T,
  verbosity = "INFO"
        )
```

## Step 5 - Synthesize
- If you have an email from the study lead telling you to progress to the synthesize step, please log into https://pda-ota.pdamethods.org/ and download the new control.json into `outputFolder`.

- You can now run the following code to apply the model to your data.  

- You now need to inspect the object and if happy log into https://pda-ota.pdamethods.org/  and upload the file.


```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "C:/dGEMcovidResults"


#=======================

execute(
  siteId = siteId,
  outputFolder = outputFolder,
  runSynthesize = T,
  verbosity = "INFO"
        )
```