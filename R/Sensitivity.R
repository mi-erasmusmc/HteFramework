#' @title Run sensitivity analyses
#' @description Run sensitivity analyses for people with or without prior
#'              cardiovascular disease.
#' @param connectionDetails Database connection details. Should be created
#'                          with \code{\link[DatabaseConnector]{createConnectionDetails}}.
#'
#' @param databaseSettings  Information on the location of cohort tables. Should be
#'                          created with \code{\link[RiskStratifiedEstimation]{createDatabaseSettings}}
#' @param sensitivity       A string describing the type of the sensitivity analysis.
#'                          Can one of "with_cvd" or "without_cvd".
#' @param maxDaysAtRisk     Time point for prediction of absolute treatment effect.
#' @param removeSubjectsWithPriorOutcome  Should prior outcomes be excluded?
#' @param useCustomLimits   Should custom limits for risk stratification be used?
#' @param negativeControlThreads Nmber of parallel threads for the negative control analyses.
#' @param fitOutcomeModelsThreads  Number of the parallel threads for fitting the outcome
#'                                 models.
#' @param createPsThreads   Number of threads for fitting the propensity score models.
#' @param balanceThreads    Number of threads for evaluating covariate balance.
#' @export
runSensitivity <- function(
  connectionDetails,
  databaseSettings,
  sensitivity,
  maxDaysAtRisk = 730,
  removeSubjectsWithPriorOutcome,
  useCustomLimits = TRUE,
  negativeControlThreads = 1,
  fitOutcomeModelsThreads = 1,
  createPsThreads = 1,
  balanceThreads = 1
) {

 stopifnot(sensitivity %in% c("with_cvd", "without_cvd"))

 if (useCustomLimits) customLimits <- .02

 analysisId  <- paste(
  databaseSettings$databaseName,
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

}
