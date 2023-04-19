#'@title Determine whether or not a time series is stationary in the mean
#'
#'@description Uses the Augmented Dickey-Fuller test to determine when the time series has a unit root.
#'
#'@details
#' A time series must have a minimum of three complete years of data.
#' For details on the implementation of the Augmented Dickey-Fuller test, 
#' see the tseries package on cran.
#'
#'@param tsData  A time series object.
#'
#'@return A boolean indicating whether or not the given time series is stationary.
#'
#'@export

isStationary <- function(tsData)
{
	tsObj     <- tsData
	minMonths <- 36

	tsObj <- Achilles::tsCompleteYears(tsObj)

	if (length(tsObj) < minMonths)
		stop("ERROR: Time series must have a minimum of three complete years of data")
	
	ADF_IS_STATIONARY <- suppressWarnings(tseries::adf.test(tsObj, alternative="stationary")$p.value <= .05)

	return (ADF_IS_STATIONARY)
}