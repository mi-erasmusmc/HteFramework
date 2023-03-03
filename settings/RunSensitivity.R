#!/usr/bin/env Rscript

# ==============================================================
# Description:
#   Script to run the application in one database
# Depends:
# Output:
#   data/results/$(database)/
# Note:
#   Needs a database as input
# ==============================================================

args <- commandArgs(trailingOnly = TRUE)
# if (length(args) != 2"Thiazide or thiazide-like diuretics" ,"ACE inhibitors") stop("Requires database and max days at risk")
# args <- c("mdcr", "with_cvd", "730")
library(AceBeta9Outcomes)
library(dplyr)

# readr::read_csv("https://raw.githubusercontent.com/OHDSI/Legend/master/inst/settings/OutcomesOfInterest.csv") %>% filter(indicationId == "Hypertension") %>%
#   rename(c("outcome" = "cohortId", "outcome_name" = "name")) %>%
#   select(outcome, outcome_name) %>%
#   filter(outcome %in% c(2, 52, 18, 41, 32, 9, 28, 39, 54, 55, 11, 12)) %>%
#   arrange(outcome) %>%
#   mutate(stratification_outcome = as.numeric(outcome %in% c(2, 52, 18))) %>%
#   readr::write_csv("inst/settings/map_outcomes.csv")

databaseName                   <- as.character(args[1])
sensitivity                    <- as.character(args[2])
maxDaysAtRisk                  <- as.numeric(args[3])
removeSubjectsWithPriorOutcome <- as.logical(args[4])
useCustomLimits                <- ifelse(is.na(args[5]), FALSE, as.logical(args[5]))
customLimits <- NULL
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


# if (sensitivity == "with_cvd") {
#   treatmentCohortId  <- 10764
#   comparatorCohortId <- 10763
# } else if (sensitivity == "without_cvd") {
#   treatmentCohortId  <- 10772
#   comparatorCohortId <- 10773
# }

options(
  andromedaTempFolder = "tmp"
)


# database <- "truven_ccae"
# databaseVersion <- "v2045"
# databaseName <- "ccae"
# cdmDatabaseSchema <- paste("cdm", database, databaseVersion, sep = "_")
# scratchSchema <- Sys.getenv("SCRATCH_SCHEMA")
# outcomeDatabaseSchema <- "scratch_arekkas"
# resultsDatabaseSchema <- "scratch_arekkas"
# exposureDatabaseSchema <- "scratch_arekkas"
# cohortDatabaseSchema <- "scratch_arekkas"
# server <- file.path(
#   Sys.getenv("OHDA_URL"),
#   database
# )
# connectionDetails <- DatabaseConnector::createConnectionDetails(
#   dbms = 'redshift',
#   server = server,
#   port = 5439,
#   user = Sys.getenv("OHDA_USER"),
#   password = Sys.getenv("OHDA_PASSWORD"),
#   extraSettings = "ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory",
#   pathToDriver = Sys.getenv("REDSHIFT_DRIVER")
# )

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

# if (useCustomLimits) {
#   message(crayon::green("Defined custom risk function"))
#   customRisk <- function(limit) {
#     f <- function(prediction) {
#       prediction %>%
#         dplyr::mutate(
#           riskstratum = dplyr::case_when(
#             value <= .02  ~ 1,
#             true          ~ 2
#           ),
#           labels = case_when(
#             riskstratum == 1 ~ "lower risk",
#             riskstratum == 2 ~ "higher risk"
#           )
#         )
#     }
#     return(f)
#   }
#   attr(customRisk, "metaData") <- "customRiskFunction"
# }


execute(
  analysisId = analysisId,
  connectionDetails = connectionDetails,
  databaseSettings = databaseSettings,
  treatmentCohortId = 15,
  comparatorCohortId = 1,
  negativeControlThreads = 20,
  fitOutcomeModelsThreads = 20,
  createPsThreads = 20,
  # customRisk = customRisk,
  maxDaysAtRisk = maxDaysAtRisk,
  balanceThreads = 10,
  removeSubjectsWithPriorOutcome = removeSubjectsWithPriorOutcome,
  customLimits = customLimits
)

