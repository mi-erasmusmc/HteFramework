library(HteFramework)
library(tidyverse)

maxDaysAtRisk <- 730   # Day to censor

databaseSettings <- RiskStratifiedEstimation::createDatabaseSettings(
  databaseName = databaseName,
  cdmDatabaseSchema = "xxxx", # The  database schema that contains the OMOP CDM
  cohortDatabaseSchema = "xxxx", # The database schema that contains the cohorts
  resultsDatabaseSchema = "xxxx", # The database schema where additional tables can be generated
  exposureDatabaseSchema = "xxxx", # The database schema with the exposure cohorts
  outcomeDatabaseSchema = "xxxx", # The database schema with the outcome cohorts
  cohortTable = "xxxx", # The table in the resultsDatabaseSchemea that contains cohorts
  outcomeTable = "xxxx", # The table in the outcomeDatabaseSchema that contains the outcome cohorts
  exposureTable = "xxxx", # The table in the exposureDatabaseSchema that contains the exposure cohorts
  mergedCohortTable = "xxxx" # The table in the resultsDatabaseSchema where the merged treatment and comparator cohorts will be stored
)


# Specify the details for connecting to the database
connectionDetails <- DatabaseConnector::createConnectionDetails()

# -------------------------------------------------------------------------------
# If extractData = FALSE, need to supply the location of the locally stored data.
#
# getDataSettings <- RiskStratifiedEstimation::createGetDataSettings(
#   plpDataFolder = "/path/to/plpData/folder",
#   cohortMethodDataFolder = "/path/to/cohortMethodData/folder"
# )
#
# Replace getDataSettings = NULL below with the above code
# -------------------------------------------------------------------------------


execute(
  analysisId = "xxxx", # Name of the analysis
  extractData = TRUE,
  connectionDetails = connectionDetails,
  databaseSettings = databaseSettings,
  getDataSettings = NULL,
  extractData = TRUE,
  treatmentCohortId = xxxx,  # The ID of the treatment cohort in the exposure table
  comparatorCohortId = xxxx, # The ID of the comparator cohort in the exposureTable
  maxDaysAtRisk = maxDaysAtRisk,
  negativeControlThreads = 1,
  fitOutcomeModelsThreads = 1,
  createPsThreads = 1,
  balanceThreads = 1
)

