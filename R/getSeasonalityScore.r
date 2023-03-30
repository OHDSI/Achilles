#'@title Get the seasonality score for a given monthly time series
#'
#'@description The seasonality score of a monthly time series is computed as its departure from a uniform distribution.
#'
#'@usage  tsData.ss <- getSeasonalityScore(tsData)
#'
#'@details
#' The degree of seasonality of a monthly time series is based on its departure from a uniform distribution.
#' If the number of cases for a given concept is uniformly distributed across all time periods (in this case, all months), 
#' then its monthly proportion would be approximately constant.  In this case, the time series would be
#' considered "strictly non-seasonal" and its "seasonality score" would be zero.
#' Similarly, if all cases recur at a single point in time (that is, in a single month), such a time series would be considered
#' "strictly seasonal" and its seasonality score would be 1.  All other time series would have
#' a seasonality score between 0 and 1.  Currently, only monthly time series are supported.
#'    
#'@param tsData  A time series object.
#'
#'@return A numeric value between 0 and 1 (inclusive) representing the seasonality of a time series.
#'
#'@export

getSeasonalityScore <- function(tsData)
{
	unifDist  <- 1/12
	a         <- c(1,rep(0,11))
	maxDist   <- sum(abs(a-unifDist))
	
	tsObj <- tsData
	tsObj <- Achilles::tsCompleteYears(tsObj)
	
	# Matrix version: switch to and update this version once the rare-events issue is corrected
	# NB: Remember to avoid dividing by zero with the matrix approach
	# M <- matrix(data=tsObj, ncol=12, byrow=TRUE)
	# ss <- sum(abs(t((rep(1,dim(M)[1]) %*% M)/as.integer(rep(1,dim(M)[1]) %*% M %*% rep(1,12))) - unifDist))/maxDist

	# Original version using sum across years 
	tsObj.yrProp <- Achilles::sumAcrossYears(tsObj)$PROP
	tsObj.ss <- round(sum(abs(tsObj.yrProp-unifDist))/maxDist,2)

	tsObj.ss <- round(tsObj.ss,2)

	return (tsObj.ss)
}