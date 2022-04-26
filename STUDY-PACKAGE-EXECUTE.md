Instructions To Run Study
===================
- This study requires running multiple steps and submitting results to https://pda-ota.pdamethods.org/ 
- Steps 1a - 3 will be done over a two week period while network sites are recruited. We will organize a 1-hour virtual meeting during this period where we will demonstrate what to do and answer any questions.
- Steps 3, 4 and 5 will each be run over a 1-week period.  Email communications will be sent out informing participants when the next step is ready to proceed. 
- After step 5 is finished, results will be generated and each site will be sent their own site ranking.  A manuscript will be written.


## Step 1a - Register (skip this if you already have an account)
- register an account at https://pda-ota.pdamethods.org/

## Step 1b - Sign Up for the Alpha wave and Delta wave studyies
- Create a director where you want to save the results to.  We will refer to this directory as `outputFolder`.  Create two folders in the `outputFolder` called `alpha` and `delta`. 

- There are two studies investigating the alpha wave and the delta wave. Get the `project name` and `inviation code` per wave from the study lead.  This will then enable you to download the control jsons for the studies. 

- Please place the alpha control.json file into the `outputFolder/alpha` and the delta control.json file into the `outputFolder/delta` folder.

## Step 2 - Feasibility 
- run the following code to create the cohorts and create a plot with the number of hospitalization on the y-axis and the date on the x-axis.  This will be used to determine the start/end of the Alpha wave and the start/end of the Delta wave.

You need to specify the database details for the OMOP CDM database you are analyzing, `siteId` the unique reference for your site and `outputFolder` the directory to saved the plot to (this should be the same place as Step 1b).  After running the code you will see a new file in `outputFolder` called `countPerDate.pdf`.

```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "your dirctory to save results" # e.g., "C:/dGEMcovidResults"

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
cohortTable <- 'dGemCohort'

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

execute(
  databaseDetails = databaseDetails,
  siteId = siteId,
  outputFolder = outputFolder,
  createCohorts = T,
  verbosity = "INFO"
        )
```

Open the `countPerDate.pdf` file to view the covid trajectory for your dataset.  Determine when the alpha wave started (ddmmyyyy) and ended (ddmmyyyy) and when the delta wave started (ddmmyyyy) and ended (ddmmyyyy).

Now run the following code to extract summary data for each wave:

```r
execute(
  databaseDetails = databaseDetails,
  siteId = siteId,
  outputFolder = outputFolder,
  createData = T,
  verbosity = "INFO",
  alphaStart = '01112020',
  alphaEnd = '01022021',
  deltaStart = '01082021',
  deltaEnd = '01102021'
        )
```

After running the code you will see two files called `data.csv` and `dataSummary.csv` in the directories `outputFolder/alpha` and `outputFolder/delta`.


## Step 3 - Initialize
- run the following code to create the json summary for each wave.  After running the code you will see a new file in `outputFolder/alpha` and `outputFolder/delta` called `<siteId>_initialize.json`.

- You now need to inspect the `<siteId>_initialize.json` and if happy log into https://pda-ota.pdamethods.org/  and upload the file to the correct study (alpha or delta).

- after submitting the files, please wait for an email from the study lead before moving to step 4

```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "your dirctory to save results" # e.g., "C:/dGEMcovidResults"

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
cohortTable <- 'dGemCohort'

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

execute(
  databaseDetails = databaseDetails,
  siteId = siteId,
  outputFolder = outputFolder,
  runInitialize = T,
  verbosity = "INFO"
        )
```


## Step 4 - Derive
- If you have an email from the study lead telling you to progress to the estimate step, please log into https://pda-ota.pdamethods.org/ and download the new control.jsons into `outputFolder/alpha` and `outputFolder/delta`.

- You can now run the following code to create the `<siteId>_estimate.json` in the `outputFolder/alpha` and `outputFolder/delta` folders.

- You now need to inspect each `<siteId>_estimate.json` and if happy log into https://pda-ota.pdamethods.org/  and upload the files.

- after submitting the file, please wait for an email from the study lead before moving to step 5

```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "your dirctory to save results" # e.g., "C:/dGEMcovidResults"

#=======================

execute(
  siteId = siteId,
  outputFolder = outputFolder,
  runDerive = T,
  verbosity = "INFO"
        )
```

## Step 5 - Estimate
- If you have an email from the study lead telling you to progress to the estimate step, please log into https://pda-ota.pdamethods.org/ and download the new control.jsons into `outputFolder/alpha` and `outputFolder/delta`.

- You can now run the following code to create the `<siteId>_estimate.json` in the `outputFolder/alpha` and `outputFolder/delta` folders.

- You now need to inspect each `<siteId>_estimate.json` and if happy log into https://pda-ota.pdamethods.org/  and upload the files.

- after submitting the file, please wait for an email from the study lead before moving to step 6

```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "your dirctory to save results" # e.g., "C:/dGEMcovidResults"


#=======================

execute(
  siteId = siteId,
  outputFolder = outputFolder,
  runEstimate = T,
  verbosity = "INFO"
        )
```

## Step 5 - Synthesize
- If you have an email from the study lead telling you to progress to the estimate step, please log into https://pda-ota.pdamethods.org/ and download the new control.jsons into `outputFolder/alpha` and `outputFolder/delta`.

- You can now run the following code to create the `<siteId>_estimate.json` in the `outputFolder/alpha` and `outputFolder/delta` folders.

- You now need to inspect each `<siteId>_estimate.json` and if happy log into https://pda-ota.pdamethods.org/  and upload the files.

- You now need to inspect the object and if happy log into https://pda-ota.pdamethods.org/  and upload the file.


```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "your dirctory to save results" # e.g., "C:/dGEMcovidResults"


#=======================

execute(
  siteId = siteId,
  outputFolder = outputFolder,
  runSynthesize = T,
  verbosity = "INFO"
        )
```