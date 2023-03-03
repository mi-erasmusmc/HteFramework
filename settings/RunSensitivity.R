# ==============================================================================
# RUN SENSITVITY ANALYSES
#
#
# To run this file, you first need to extract the cohorts in a table in the
# scratch space.
# ==============================================================================

library(HteFramework)
library(dplyr)

databaseName <- as.character(args[1])
sensitivity <- as.character(args[2])
maxDaysAtRisk <- as.numeric(args[3])
removeSubjectsWithPriorOutcome <- as.logical(args[4])
useCustomLimits <- ifelse(is.na(args[5]), FALSE, as.logical(args[5]))


if (useCustomLimits) customLimits <- .02

analysisId  <- paste(
  databaseName,
  sensitivity,
  maxDaysAtRisk,
  "analysis",
  sep = "_"
)

if (is.na(removeSubjectsWithPriorOutcome))
  removeSubjectsWithPriorOutcome <- TRUE
if (!removeSubjectsWithPriorOutcome)
  analysisId <- paste(analysisId, "no_prior", sep = "_")

print(paste("Remove prior outcomes:", removeSubjectsWithPriorOutcome))
message(paste(crayon::bgCyan("Running analysis:"), analysisId))


databaseSettings <- RiskStratifiedEstimation::createDatabaseSettings(
  databaseName = databaseName,
  cdmDatabaseSchema = "",
  cohortDatabaseSchema = "",
  resultsDatabaseSchema = "",
  exposureDatabaseSchema = "",
  outcomeDatabaseSchema = "",
  cohortTable = "legend_hypertension_exp_cohort",
  outcomeTable = "legend_hypertension_out_cohort",
  exposureTable = "legend_hypertension_exp_cohort",
  mergedCohortTable = "legend_hypertension_merged"
)


execute(
	analysisId = analysisId,
	connectionDetails = connectionDetails,
	databaseSettings = databaseSettings,
	removeSubjectsWithPriorOutcome = removeSubjectsWithPriorOutcome,
	maxDaysAtRisk = maxDaysAtRisk,
	customLimits = customLimits,
	treatmentCohortId = 15,  # thiazides ID
	comparatorCohortId = 1,  # ACE inhibitors ID
	negativeControlThreads = 1,
	fitOutcomeModelsThreads = 1,
	createPsThreads = 1,
	balanceThreads = 1
)

