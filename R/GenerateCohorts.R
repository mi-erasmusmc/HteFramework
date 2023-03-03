#' Genarates all the cohorts of the LEGEND-hypertension study
#'
#' @param connectionDetails    Database connection details. Should be created
#'                             with \code{\link[DatabaseConnector]{createConnectionDetails}}.
#' @param cdmDatabaseSchema    The database schema where the database is stored
#' @param cohortDatabaseSchema The database schema where the cohort tables will be stored.
#' @param indicationId         Can be "Hypertension" or "Depression".Here it
#'                             should be the former
#' @param outputFolder    	    Name of local folder to place results.
#'
#' @export
generateAllCohorts <- function(
  connectionDetails,
  cdmDatabaseSchema,
  cohortDatabaseSchema,
  indicationId = "Hypertension",
  outputFolder
) {
  Legend::createExposureCohorts(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    indicationId = indicationId,
    outputFolder = outputFolder
  )

  Legend::createOutcomeCohorts(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    oracleTempSchema = NULL,
    indicationId = indicationId,
    outputFolder = outputFolder
  )

}
