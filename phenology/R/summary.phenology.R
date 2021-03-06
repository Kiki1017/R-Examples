#' summary.phenology prints the information from a result object.
#' @title Print the result information from a result object.
#' @author Marc Girondot
#' @return None
#' @param object A result file generated by fit_phenology
#' @param ... Not used
#' @description The function print.phenology displays from a result.
#' @examples
#' library(phenology)
#' # Read a file with data
#' \dontrun{
#' Gratiot<-read.delim("http://max2.ese.u-psud.fr/epc/conservation/BI/Complete.txt", header=FALSE)
#' }
#' data(Gratiot)
#' # Generate a formatted list nammed data_Gratiot 
#' data_Gratiot<-add_phenology(Gratiot, name="Complete", 
#' 		reference=as.Date("2001-01-01"), format="%d/%m/%Y")
#' # Generate initial points for the optimisation
#' parg<-par_init(data_Gratiot, parametersfixed=NULL)
#' # Run the optimisation
#' \dontrun{
#' result_Gratiot<-fit_phenology(data=data_Gratiot, 
#' 		parametersfit=parg, parametersfixed=NULL, trace=1)
#' }
#' data(result_Gratiot)
#' # Display information from the result
#' summary(result_Gratiot)
#' @method summary phenology
#' @export



summary.phenology <- function(object, ...) {

	cat(paste("Number of timeseries: ", length(object$data), "\n", sep=""))
	for (i in 1:length(object$data)) {
		cat(paste(names(object$data[i]), "\n", sep=""))
	}
	cat(paste("Date uncertainty managment: ", object$method_incertitude, "\n", sep=""))
	cat(paste("Managment of zero counts: ", object$zero_counts, "\n", sep=""))
	cat("Fitted parameters:\n")
	for (i in 1:length(object$par)) {
		cat(paste(names(object$par[i]), "=", object$par[i], " SE ", object$se[i], "\n", sep=""))
	}
	cat("Fixed parameters:\n")
	for (i in 1:length(object$parametersfixed)) {
		cat(paste(names(object$parametersfixed[i]), "=", object$parametersfixed[i], "\n", sep=""))
	}
	cat(paste("Ln L: ", object$value, "\n", sep=""))
	cat(paste("Parameter number: ", length(object$par), "\n", sep=""))
	cat(paste("AIC: ", 2*object$value+2*length(object$par), "\n", sep=""))

}
