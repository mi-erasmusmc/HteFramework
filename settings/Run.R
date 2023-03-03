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


execute(
  analysisId = "xxxx", # Name of the analysis
  connectionDetails = connectionDetails,
  databaseSettings = databaseSettings,
  treatmentCohortId = xxxx,  # The ID of the treatment cohort in the exposure table
  comparatorCohortId = xxxx, # The ID of the comparator cohort in the exposureTable
  maxDaysAtRisk = maxDaysAtRisk,
  negativeControlThreads = 1,
  fitOutcomeModelsThreads = 1,
  createPsThreads = 1,
  balanceThreads = 1
)

