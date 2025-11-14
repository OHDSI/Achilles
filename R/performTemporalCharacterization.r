# @file performTemporalCharacterization
#
# Copyright 2023 Observational Health Data Sciences and Informatics
#
# This file is part of Achilles
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Observational Health Data Sciences and Informatics
# @author Martijn Schuemie
# @author Patrick Ryan
# @author Frank DeFalco
# @author Vojtech Huser
# @author Chris Knoll
# @author Ajit Londhe
# @author Taha Abdul-Basser
# @author Anthony Molinaro

#'@title performTemporalCharacterization
#'
#' @description
#' \code{performTemporalCharacterization} Perform temporal characterization on a concept or family of concepts belonging to a supported Achilles analysis.
#'
#' @details
#' \code{performTemporalAnalyses} Assumes \code{achilles} has been run.
#' \preformatted{Currently supported Achilles analyses for temporal analyses are:
#' 202  - Visit Occurrence
#' 402  - Condition occurrence
#' 602  - Procedure Occurrence
#' 702  - Drug Exposure
#' 802  - Observation
#' 1802 - Measurement
#' 2102 - Device}
#'
#' @param connectionDetails       An R object of type \code{connectionDetails} created using the
#'                                function \code{createConnectionDetails} in the
#'                                \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema       Fully qualified name of database schema that contains OMOP CDM
#'                                schema. On SQL Server, this should specifiy both the database and the
#'                                schema, so for example, on SQL Server, 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema   Fully qualified name of database schema that we can write final
#'                                results to. Default is cdmDatabaseSchema. On SQL Server, this should
#'                                specifiy both the database and the schema, so for example, on SQL
#'                                Server, 'cdm_results.dbo'.
#' @param analysisIds             (OPTIONAL) A vector containing the set of Achilles analysisIds for
#'                                which results will be returned. The following are supported: \code{202,402,602,702,802,1802,2102}.
#'                                If not specified, data for all analysis will be returned. Ignored if \code{conceptId} is given. 
#' @param conceptId               (OPTIONAL) A SNOMED concept_id from the \code{CONCEPT} table for which a monthly Achilles analysis exists.
#'                                If not specified, all concepts for a given analysis will be returned.
#' @param outputFile              CSV file where temporal characterization will be written. Default is temporal-characterization.csv.
#'
#' @return
#' A csv file with temporal analyses for each time series
#'
#' @examples
#' \dontrun{
#' # Example 1:
#' pneumonia <- 255848
#' performTemporalCharacterization(
#' 	connectionDetails     = connectionDetails,
#' 	cdmDatabaseSchema     = "cdm",
#' 	resultsDatabaseSchema = "results",
#' 	conceptId             = pneumonia,
#'  outputFolder          = "output/pneumoniaTemporalChar.csv")
#'
#' # Example 2:
#' performTemporalCharacterization(
#' 	connectionDetails     = connectionDetails,
#' 	cdmDatabaseSchema     = "cdm",
#' 	resultsDatabaseSchema = "results",
#' 	analysisIds           = c(402,702),
#'  outputFolder          = "output/conditionAndDrugTemporalChar.csv")
#'
#' # Example 3:
#' performTemporalCharacterization(
#' 	connectionDetails     = connectionDetails,
#' 	cdmDatabaseSchema     = "cdm",
#' 	resultsDatabaseSchema = "results",
#'  outputFolder          = "output/CompleteTemporalChar.csv")
#' }
#'
#'@export

performTemporalCharacterization <- function(
									connectionDetails,
									cdmDatabaseSchema, 
									resultsDatabaseSchema, 
									analysisIds = NULL, 
									conceptId   = NULL,
									outputFile  = "temporal-characterization.csv")
{

	# Minimum number of months of data to perform temporal characterization
	minMonths <- 36 
	
	# Pull temporal data from Achilles and get list of unique concept_ids
	temporalData <- Achilles::getTemporalData(connectionDetails,cdmDatabaseSchema,resultsDatabaseSchema,analysisIds,conceptId)
	
	if (nrow(temporalData) == 0) {
		stop("CANNOT PERFORM TEMPORAL CHARACTERIZATION: NO ACHILLES DATA FOUND")
	}
	
	allConceptIds <- unique(temporalData$CONCEPT_ID)
	print(paste0("Attempting temporal characterization on ", length(allConceptIds), " individual concepts"))
	
	# Loop through temporal data, perform temporal characterization, and write out results
	rowData <-
		temporalData %>%
		tidyr::nest(
			tempData = c(
				"START_DATE",
				"COUNT_VALUE",
				"PREVALENCE",
				"PROPORTION_WITHIN_YEAR"
			)
		) %>%
		## rowwise allows to work with nested list vars as with usual ones
		dplyr::rowwise() %>%
		dplyr::mutate(
			tempData.ts = list(
				Achilles::createTimeSeries(.data$tempData)
			),
			tempData.ts = list(
				.data$tempData.ts[, "PREVALENCE"]
			),
			tempData.ts = list(
				Achilles::tsCompleteYears(.data$tempData.ts)
			)
		) %>%
		dplyr::filter(
			length(.data$tempData.ts) >= minMonths
		) %>%
		dplyr::mutate(
			tempData.ts.ss = Achilles::getSeasonalityScore(.data$tempData.ts),
			tempData.ts.is = Achilles::isStationary(.data$tempData.ts)
		) %>%
		## now we don't need to handle variables row wise
		dplyr::ungroup() %>%
		dplyr::select(
			DB_NAME = .data$DB_NAME,
			CDM_TABLE_NAME = .data$CDM_TABLE_NAME,
			CONCEPT_ID = .data$CONCEPT_ID,
			CONCEPT_NAME = .data$CONCEPT_NAME,
			SEASONALITY_SCORE = .data$tempData.ts.ss,
			IS_STATIONARY = .data$tempData.ts.is,
		) %>%
		dplyr::collect()
	write.csv(rowData,outputFile,row.names = FALSE)
	print(paste0("Temporal characterization complete.  Results can be found in ", outputFile))
	invisible(rowData)
}
