# @file createTimeSeries
#
# Copyright 2021 Observational Health Data Sciences and Informatics
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

#' @title
#' createTimeSeries
#'
#' @description
#' \code{createTimeSeries} Creates a monthly multivariate time series object given a data frame in the
#' proper format.
#'
#' @details
#' \code{createTimeSeries} Requires the following: \preformatted{ 1. The given data frame must contain
#' four columns: START_DATE, COUNT_VALUE, PREVALENCE, and PROPORTION_WITHIN_YEAR. 2. START_DATE must
#' be in the YYYYMMDD format. 3. COUNT_VALUE, PREVALENCE, and PROPORTION_WITHIN_YEAR contain only
#' numeric data. } The individual monthly univariate time series can be extracted by specifying the
#' correct column name (see example).
#'
#'
#' @param temporalData   A data frame from which to create the time series
#'
#' @return
#' A multivariate time series object
#'
#' @examples
#' \dontrun{
#' # Example 1:
#' temporalData <- data.frame(START_DATE = seq.Date(as.Date("20210101", "%Y%m%d"),
#'                                                  as.Date("20231201",
#'   "%Y%m%d"), by = "month"), COUNT_VALUE = round(runif(36, 1, 1000)), PREVALENCE = round(runif(36,
#'   0, 10), 2), PROPORTION_WITHIN_YEAR = round(runif(36, 0, 1), 2), stringsAsFactors = FALSE)
#' dummyTs <- createTimeSeries(temporalData)
#' dummyTs.cv <- dummyTs[, "COUNT_VALUE"]
#' dummyTs.pv <- dummyTs[, "PREVALENCE"]
#' dummyTs.pwy <- dummyTs[, "PROPORTION_WITHIN_YEAR"]
#'
#' # Example 2:
#' pneumonia <- 255848
#' temporalData <- getTemporalData(connectionDetails = connectionDetails, cdmDatabaseSchema = "cdm",
#'   resultsDatabaseSchema = "results", conceptId = pneumonia)
#' pneumoniaTs <- createTimeSeries(temporalData)
#' pneumoniaTs.cv <- pneumoniaTs[, "COUNT_VALUE"]
#' pneumoniaTs.pv <- pneumoniaTs[, "PREVALENCE"]
#' pneumoniaTs.pwy <- pneumoniaTs[, "PROPORTION_WITHIN_YEAR"]
#' }
#'
#' @export

createTimeSeries <- function(temporalData) {

  requiredColumns <- c("START_DATE", "COUNT_VALUE", "PREVALENCE", "PROPORTION_WITHIN_YEAR")

  if (sum(colnames(temporalData) %in% requiredColumns) < 4)
    stop(paste0("ERROR: INVALID DATA FRAME FORMAT. The data frame must contain columns: ",
                paste(requiredColumns,
      collapse = ", ")))

  if (nrow(temporalData) == 0) {
    stop("ERROR: Cannot create time series from an empty data frame")
  }

  resultSetData <- temporalData

  # Convert YYYYMMDD string into a valid date
  resultSetData$START_DATE <- as.Date(resultSetData$START_DATE, "%Y%m%d")

  # Sort the temporal data by START_DATE rather than using an ORDER BY in the SQL
  resultSetData <- resultSetData[order(resultSetData$START_DATE), ]

  # Create a vector of dense dates to capture all dates between the start and end of the time
  # series
  lastRow <- nrow(resultSetData)

  denseDates <- seq.Date(from = as.Date(resultSetData$START_DATE[1], "%Y%m%d"),
                         to = as.Date(resultSetData$START_DATE[lastRow],
    "%Y%m%d"), by = "month")

  # Find gaps, if any, in data (e.g., dates that have no data, give that date a 0 count and 0
  # prevalence)
  denseDatesDf <- data.frame(START_DATE = denseDates, CNT = rep(0, length(denseDates)))

  joinResults <- dplyr::left_join(denseDatesDf, resultSetData, by = c(START_DATE = "START_DATE"))

  joinResults$COUNT_VALUE[which(is.na(joinResults$COUNT_VALUE))] <- 0
  joinResults$PREVALENCE[which(is.na(joinResults$PREVALENCE))] <- 0
  joinResults$PROPORTION_WITHIN_YEAR[which(is.na(joinResults$PROPORTION_WITHIN_YEAR))] <- 0

  # Now that we no longer have sparse dates, keep only necessary columns and build the time series
  joinResults <- joinResults[, c("START_DATE",
                                 "COUNT_VALUE",
                                 "PREVALENCE",
                                 "PROPORTION_WITHIN_YEAR")]

  # Find the end of the dense results
  lastRow <- nrow(joinResults)

  # Create the multivariate time series
  tsData <- data.frame(COUNT_VALUE = joinResults$COUNT_VALUE, PREVALENCE = joinResults$PREVALENCE,
    PROPORTION_WITHIN_YEAR = joinResults$PROPORTION_WITHIN_YEAR)

  resultSetDataTs <- ts(data = tsData, start = c(as.numeric(substring(joinResults$START_DATE[1], 1,
    4)), as.numeric(substring(joinResults$START_DATE[1],
                              6,
                              7))), end = c(as.numeric(substring(joinResults$START_DATE[lastRow],
    1, 4)), as.numeric(substring(joinResults$START_DATE[lastRow], 6, 7))), frequency = 12)

  return(resultSetDataTs)
}
