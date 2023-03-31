#'@title  Trim a monthly time series object to so that partial years are removed
#'
#'@usage  tsData <- tsCompleteYears(tsData)
#'
#'@details This function is only supported for monthly time series
#'
#'@param tsData  A time series object
#'
#'@return A time series with partial years removed.
#'
#'@export

tsCompleteYears <- function(tsData)
{

	if (frequency(tsData) != 12) {
		stop("This function is only supported for monthly time series.")
	}

	origStartMonth <- start(tsData)[2]
	origStartYear  <- start(tsData)[1]
	origEndMonth   <- end(tsData)[2]
	origEndYear    <- end(tsData)[1]

	newStartMonth <- 1
	newEndMonth   <- 12

	tsObj <- tsData

	if (origStartMonth > 1) tsObj <- window(tsObj, start=c(origStartYear+1,newStartMonth))
	if (origEndMonth < 12)  tsObj <- window(tsObj, end=c(origEndYear-1,newEndMonth))

	return (tsObj)
}
