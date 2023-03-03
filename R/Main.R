#' @title Execute risk stratified analysis
#' @description Executes a risk stratified analysis for the evaluation of
#' treatment effect heterogeneity of thiazides or thiazide-like diuretics compared
#' to ACE inhibitors.
#'
#' @param connectionDetails An object of type \code{ConnectionDetails} created using
#' the \code{\link[DatabaseConnector]{createConnectionDetails}} function
#' @param analysisId Unique analysis identifier
#' @param databaseSettings Settings for locating the data in the database. Should
#' be created with the \code{\link[RiskStratifiedEstimation]{createDatabaseSettings}}
#' function.
#' @param getDataSettings Settings for the extraction of the data from the database. If
#' \code{extractData = FALSE} then it should contain the directories where the
#' generated \code{plpData} and \code{cohortMethodData} are stored. Should be created
#' with \code{\link[RiskStratifiedEstimation]{createGetDataSettings}}.
#' @param maxDaysAtRisk The maximum days at risk to be used for the analysis.
#' If patients have longer time at risk, they will be censored at the provided value
#' @param treatmentCohortId The ID of the treatment cohort in the table of the database
#' where exposures are stored
#' @param comparatorCohortId  The ID of the comparator cohort in the table of the
#' database where exposures are stored
#' @param extractData Should the cohorts be extracted from the database?
#' @param balanceThreads Number of parallel threads to be used for the evaluation
#' of covariate balance
#' @param negativeControlThreads Number of parallel threads to be used for the
#' negative control analyses
#' @param fitOutcomeModelsThreads Number of parallel threads to be used for
#' the estimation of the outcome models
#' @param createPsThreads Number of parallel threads to be used for fitting the
#' propensity score models
#' @param saveDirectory  The directory where results will be stored
#' @param removeSubjectsWithPriorOutcome Should that have had the outcome prior
#' to the risk window start?
#' @param customLimits Custom limits used for risk stratification. If \code{NULL},
#' limits are c(0.01, 0.015)
#' @importFrom magrittr %>%
#' @export
execute <- function(
  connectionDetails,
  analysisId,
  databaseSettings,
  getDataSettings = NULL,
  maxDaysAtRisk,
  treatmentCohortId,
  comparatorCohortId,
  extractData = TRUE,
  balanceThreads = 1,
  negativeControlThreads = 1,
  fitOutcomeModelsThreads = 1,
  createPsThreads = 1,
  saveDirectory = "results",
  removeSubjectsWithPriorOutcome = TRUE,
  customLimits = NULL
) {

  customRisk <- function(limits) {
    if (length(limits) == 1) {
      f <- function(prediction) {
        message("Splitting in two risk strata")
        prediction %>%
          dplyr::mutate(
            riskStratum = dplyr::case_when(
              value <= limits ~ 1,
              TRUE            ~ 2
            ),
            labels = case_when(
              riskStratum == 1 ~ "lower risk",
              riskStratum == 2 ~ "higher risk"
            )
          )
      }
    } else if (length(limits) == 2) {
      f <- function(prediction) {
        message("Splitting in three risk strata")
        prediction %>%
          dplyr::mutate(
            riskStratum = dplyr::case_when(
              value <= limits[1] ~ 1,
              value <= limits[2] ~ 2,
              TRUE               ~ 3
            ),
            labels = case_when(
              riskStratum == 1 ~ "lower risk",
              riskStratum == 2 ~ "medium risk",
              riskStratum == 3 ~ "higher risk"
            )
          )
      }
    }
    return(f)
  }

  outcomeIdsPath <- system.file(
    "settings",
    "map_outcomes.csv",
    package = "HteFramework"
  )

  mapOutcomes <- read.csv(outcomeIdsPath) %>%
    dplyr::arrange(dplyr::desc(stratification_outcome))

  outcomeIds <- mapOutcomes %>%
    dplyr::pull(outcome_id)

  negativeControlOutcomes <- read.csv(
    system.file(
      "settings",
      "negative_controls.csv",
      package = "HteFramework"
    )
  )

  excludedCovariateConceptIds <- read.csv(
    system.file(
      "settings",
      "excluded_covariate_concept_ids.csv",
      package = "HteFramework"
    )
  ) %>%
    dplyr::pull(conceptId)

  analysisSettings <- RiskStratifiedEstimation::createAnalysisSettings(
    analysisId = analysisId,
    databaseName = databaseSettings$databaseName,
    treatmentCohortId = treatmentCohortId,
    comparatorCohortId = comparatorCohortId,
    outcomeIds = outcomeIds,
    analysisMatrix = matrix(c(rep(rep(1, 13), 2), rep(rep(0, 13), 11)), ncol = 13),
    mapTreatments = read.csv(
      system.file(
        "settings",
        "map_treatments.csv",
        package = "HteFramework"
      )
    ),
    mapOutcomes = mapOutcomes,
    negativeControlOutcomes = negativeControlOutcomes %>% dplyr::pull(cohortId),
    balanceThreads = balanceThreads,
    negativeControlThreads = negativeControlThreads,
    verbosity = "INFO",
    saveDirectory = saveDirectory
  )

  if (is.null(getDataSettings)) {
    getDataSettings <- RiskStratifiedEstimation::createGetDataSettings(
      getPlpDataSettings = RiskStratifiedEstimation::createGetPlpDataArgs(
        washoutPeriod = 365
      ),
      getCmDataSettings = RiskStratifiedEstimation::createGetCmDataArgs(
        washoutPeriod = 365
      )
    )
  }

  covariateSettings <-
    RiskStratifiedEstimation::createGetCovariateSettings(
      covariateSettingsCm =
        FeatureExtraction::createCovariateSettings(
          useDemographicsGender           = TRUE,
          useDemographicsAge              = TRUE,
          useConditionOccurrenceLongTerm  = TRUE,
          useConditionOccurrenceShortTerm = TRUE,
          useDrugExposureLongTerm         = TRUE,
          useDrugExposureShortTerm        = TRUE,
          useDrugEraLongTerm              = TRUE,
          useDrugEraShortTerm             = TRUE,
          useCharlsonIndex                = TRUE,
          addDescendantsToExclude         = TRUE,
          addDescendantsToInclude         = TRUE,
          excludedCovariateConceptIds     = excludedCovariateConceptIds
        ),
      covariateSettingsPlp =
        FeatureExtraction::createCovariateSettings(
          useDemographicsGender           = TRUE,
          useDemographicsAge              = TRUE,
          useConditionOccurrenceLongTerm  = TRUE,
          useConditionOccurrenceShortTerm = TRUE,
          useDrugExposureLongTerm         = TRUE,
          useDrugExposureShortTerm        = TRUE,
          useDrugEraLongTerm              = TRUE,
          useDrugEraShortTerm             = TRUE,
          useCharlsonIndex                = TRUE,
          addDescendantsToExclude         = TRUE,
          excludedCovariateConceptIds     = excludedCovariateConceptIds
        )
    )


  populationSettings <- 	RiskStratifiedEstimation::createPopulationSettings(
    populationPlpSettings = PatientLevelPrediction::createStudyPopulationSettings(
      riskWindowStart                = 1,
      riskWindowEnd                  = maxDaysAtRisk,
      minTimeAtRisk                  = 1,
      removeSubjectsWithPriorOutcome = removeSubjectsWithPriorOutcome,
      includeAllOutcomes             = TRUE
    ),
    populationCmSettings = CohortMethod::createCreateStudyPopulationArgs(
      removeDuplicateSubjects        = "keep first",
      riskWindowStart                = 1,
      startAnchor                    = "cohort start",
      censorAtNewRiskWindow          = TRUE,
      maxDaysAtRisk                  = maxDaysAtRisk,
      removeSubjectsWithPriorOutcome = removeSubjectsWithPriorOutcome
    )
  )

  if (!is.null(customLimits)) {
    message(crayon::green("Using custom limits for acute MI"))
    analyses <- list(
      RiskStratifiedEstimation::createRunCmAnalysesArgs(
        label = paste("ps_strat_acute_myocardial_infarction",sensitivity, sep = "_"),
        riskStratificationMethod = "custom",
        riskStratificationThresholds = customRisk(customLimits),
        timePoint = maxDaysAtRisk,
        effectEstimationSettings = RiskStratifiedEstimation::createStratifyByPsArgs(numberOfStrata = 5),
        stratificationOutcomes = 2
      ),
      RiskStratifiedEstimation::createRunCmAnalysesArgs(
        label = paste("ps_strat_cardiovascular_disease", sensitivity, sep = "_"),
        riskStratificationMethod = "custom",
        riskStratificationThresholds = customRisk(c(.032, .053)),
        timePoint = maxDaysAtRisk,
        effectEstimationSettings = RiskStratifiedEstimation::createStratifyByPsArgs(numberOfStrata = 5),
        stratificationOutcomes = 36
      )
    )
  } else {
    message(crayon::green("Using pre-defined risk limits"))
    analyses <- list(
      RiskStratifiedEstimation::createRunCmAnalysesArgs(
        label = paste("ps_strat_acute_myocardial_infarction", sep = "_"),
        riskStratificationMethod = "custom",
        riskStratificationThresholds = customRisk(c(.01, .015)),
        timePoint = maxDaysAtRisk,
        effectEstimationSettings = RiskStratifiedEstimation::createStratifyByPsArgs(numberOfStrata = 5),
        stratificationOutcomes = 2
      ),
      RiskStratifiedEstimation::createRunCmAnalysesArgs(
        label = paste("ps_strat_cardiovascular_disease", sep = "_"),
        riskStratificationMethod = "custom",
        riskStratificationThresholds = customRisk(c(.032, .053)),
        timePoint = maxDaysAtRisk,
        effectEstimationSettings = RiskStratifiedEstimation::createStratifyByPsArgs(numberOfStrata = 5),
        stratificationOutcomes = 36
      )
    )
  }

  runSettings <- RiskStratifiedEstimation::createRunSettings(
    runPlpSettings = RiskStratifiedEstimation::createRunPlpSettingsArgs(
      analyses = list(
        RiskStratifiedEstimation::createRunPlpAnalysesArgs(
          outcomeId = 2,
          modelSettings = PatientLevelPrediction::setLassoLogisticRegression(),
          matchingSettings = RiskStratifiedEstimation::createMatchOnPsArgs(
            maxRatio = 1
          ),
          executeSettings = PatientLevelPrediction::createDefaultExecuteSettings(),
          timepoint = maxDaysAtRisk
        ),
        RiskStratifiedEstimation::createRunPlpAnalysesArgs(
          outcomeId = 36,
          modelSettings = PatientLevelPrediction::setLassoLogisticRegression(),
          matchingSettings = RiskStratifiedEstimation::createMatchOnPsArgs(
            maxRatio = 1
          ),
          executeSettings = PatientLevelPrediction::createDefaultExecuteSettings(),
          timepoint = maxDaysAtRisk
        )
      )
    ),
    runCmSettings = RiskStratifiedEstimation::createRunCmSettingsArgs(
      analyses = analyses,
      psSettings = RiskStratifiedEstimation::createCreatePsArgs(
        control = Cyclops::createControl(
          threads       = -1,
          maxIterations = 5e3
        ),
        prior = Cyclops::createPrior(
          priorType = "laplace"
        )
      ),
      fitOutcomeModelsThreads = fitOutcomeModelsThreads,
      balanceThreads = balanceThreads,
      negativeControlThreads = negativeControlThreads,
      createPsThreads = createPsThreads,
      runRiskStratifiedNcs = TRUE
    )
  )

  cdmDatabaseSchema <- databaseSettings$cdmDatabaseSchema
  cohortDatabaseSchema <- databaseSettings$cohortDatabaseSchema
  outputFolder <- analysisSettings$saveDirectory

  if (extractData) {
    generateAllCohorts(
      connectionDetails = connectionDetails,
      cdmDatabaseSchema = cdmDatabaseSchema,
      cohortDatabaseSchema = cohortDatabaseSchema,
      indicationId = "Hypertension",
      outputFolder = outputFolder
    )
  }

  RiskStratifiedEstimation::runRiskStratifiedEstimation(
    connectionDetails = connectionDetails,
    analysisSettings = analysisSettings,
    databaseSettings = databaseSettings,
    getDataSettings = getDataSettings,
    covariateSettings = covariateSettings,
    populationSettings = populationSettings,
    runSettings = runSettings
  )


  return(NULL)
}
