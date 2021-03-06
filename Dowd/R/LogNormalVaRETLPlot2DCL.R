#' Plots log normal VaR and ETL against confidence level
#' 
#' Plots the VaR and ETL of a portfolio against confidence level assuming that geometric
#'  returns are normally distributed, for specified confidence level and 
#'  holding period.
#' 
#' @param ... The input arguments contain either return data or else mean and 
#'  standard deviation data. Accordingly, number of input arguments is either 4
#'  or 5. In case there are 4 input arguments, the mean and standard deviation of 
#'  data is computed from return data. See examples for details.
#'  
#'  returns Vector of daily geometric return data
#' 
#'  mu Mean of daily geometric return data
#' 
#'  sigma Standard deviation of daily geometric return data
#' 
#'  investment Size of investment
#' 
#'  cl VaR confidence level and must be a vector
#' 
#'  hp VaR holding period and must be a scalar
#'  
#' @references Dowd, K. Measuring Market Risk, Wiley, 2007.
#'
#' @author Dinesh Acharya
#' @examples
#' 
#'    # Plots VaR and ETL against confidene level given geometric return data
#'    data <- runif(5, min = 0, max = .2)
#'    LogNormalVaRETLPlot2DCL(returns = data, investment = 5, cl = seq(.85,.99,.01), hp = 60)
#'    
#'    # Computes VaR against confidence level given mean and standard deviation of return data
#'    LogNormalVaRETLPlot2DCL(mu = .012, sigma = .03, investment = 5, cl = seq(.85,.99,.01), hp = 40)
#'
#'
#' @export
LogNormalVaRETLPlot2DCL<- function(...){
  # Determine if there are four or five arguments, and ensure that arguments are read as intended
  if (nargs() < 4) {
    stop("Too few arguments")
  }
  if (nargs() > 5) {
    stop("Too many arguments")
  }
  args <- list(...)
  if (nargs() == 5) {
    mu <- args$mu
    investment <- args$investment
    cl <- args$cl
    sigma <- args$sigma
    hp <- args$hp
  }
  if (nargs() == 4) {
    mu <- mean(args$returns)
    investment <- args$investment
    cl <- args$cl
    sigma <- sd(args$returns)
    hp <- args$hp
  }
  
  # Check that inputs have correct dimensions
  mu <- as.matrix(mu)
  mu.row <- dim(mu)[1]
  mu.col <- dim(mu)[2]
  if (max(mu.row, mu.col) > 1) {
    stop("Mean must be a scalar")
  }
  sigma <- as.matrix(sigma)
  sigma.row <- dim(sigma)[1]
  sigma.col <- dim(sigma)[2]
  if (max(sigma.row, sigma.col) > 1) {
    stop("Standard deviation must be a scalar")
  }
  cl <- as.matrix(cl)
  cl.row <- dim(cl)[1]
  cl.col <- dim(cl)[2]
  if (min(cl.row, cl.col) > 1) {
    stop("Confidence level must be a vector")
  }
  hp <- as.matrix(hp)
  hp.row <- dim(hp)[1]
  hp.col <- dim(hp)[2]
  if (max(hp.row, hp.col) > 1) {
    stop("Holding period must be a scalar")
  }
  
  # Check that cl is read as row vector
  if (cl.row > cl.col) {
    cl <- t(cl)
  }
  
  # Check that inputs obey sign and value restrictions
  if (sigma < 0) {
    stop("Standard deviation must be non-negative")
  }
  if (max(cl) >= 1){
    stop("Confidence level(s) must be less than 1")
  }
  if (min(cl) <= 0){
    stop("Confidence level(s) must be greater than 0")
  }
  if (min(hp) <= 0){
    stop("Holding period must be greater than 0")
  }
  # VaR estimation  
  cl.row <- dim(cl)[1]
  cl.col <- dim(cl)[2]
  VaR <- investment - exp(sigma[1,1] * sqrt(hp[1,1]) * qnorm(1 - cl, 0, 1)+mu[1,1]*hp[1,1]*matrix(1,cl.row,cl.col) + log(investment)) # VaR
  
  # ES estimation
  n <- 1000 # Number of slices into which tail is divided
  cl0 <- cl # Initial confidence level
  delta.cl <- (1 - cl) / n # Increment to confidence level as each slice is taken
  v <- VaR
  for (i in 1:(n-1)) {
    cl <- cl0 + i * delta.cl # Revised cl
    v <- v + investment - exp(sigma[1,1] * sqrt(hp[1,1]) * 
                                      qnorm(1 - cl, 0, 1) + mu[1,1] * hp[1,1] * 
                                      matrix(1, cl.row, cl.col) + log(investment))
  }
  v <- v/n
  
  
  # Plotting
  ymin <- min(VaR, v)
  ymax <- max(VaR, v)
  xmin <- min(cl0)
  xmax <- max(cl0)
  
  plot(cl0, VaR, type = "l", xlim = c(xmin, xmax), ylim = c(ymin, ymax), xlab = "Confidence level", ylab = "VaR/ETL")
  par(new=TRUE)
  plot(cl0, v, type = "l", xlim = c(xmin, xmax), ylim = c(ymin, ymax), xlab = "Confidence level", ylab = "VaR/ETL")
  
  title("Lognormal VaR and ETL against confidence level")
  xmin <- min(cl0)+.3*(max(cl0)-min(cl0))
  text(xmin,max(VaR)-.1*(max(VaR)-min(VaR)),
       'Input parameters', cex=.75, font = 2)
  text(xmin,max(VaR)-.15*(max(VaR)-min(VaR)),
       paste('Daily mean geometric return = ',round(mu[1,1],3)),cex=.75)
  text(xmin,max(VaR)-.2*(max(VaR)-min(VaR)),
       paste('Stdev. of daily geometric returns = ',round(sigma[1,1],3)),cex=.75)
  text(xmin,max(VaR)-.25*(max(VaR)-min(VaR)),
       paste('Investment size = ',investment),cex=.75)
  text(xmin,max(VaR)-.3*(max(VaR)-min(VaR)),
       paste('Holding period = ',hp,'days'),cex=.75)
  # VaR and ETL labels
  text(max(cl0)-.4*(max(cl0)-min(cl0)),min(VaR)+.3*(max(VaR)-min(VaR)),'Upper line - ETL',cex=.75);
  text(max(cl0)-.4*(max(cl0)-min(cl0)),min(VaR)+.2*(max(VaR)-min(VaR)),'Lower line - VaR',cex=.75);
       
}
