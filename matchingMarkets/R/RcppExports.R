# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#' @export
stabitCpp2 <- function(Yr, Xmatchr, Cr, Cmatchr, Dr, dr, Mr, Hr, nCollegesr, nStudentsr, XXmatchr, CCr, CCmatchr, Lr, studentIdsr, collegeIdr, n, N, binary, niter, T, censored, display_progress = TRUE) {
    .Call('matchingMarkets_stabitCpp2', PACKAGE = 'matchingMarkets', Yr, Xmatchr, Cr, Cmatchr, Dr, dr, Mr, Hr, nCollegesr, nStudentsr, XXmatchr, CCr, CCmatchr, Lr, studentIdsr, collegeIdr, n, N, binary, niter, T, censored, display_progress)
}

#' @export
stabitCpp <- function(Xr, Rr, Wr, One, Two, T, offOutr, offSelr, sigmabarbetainverse, sigmabaralphainverse, niter, n, l, Pr, p, binary, selection, censored, ntu, gPrior, display_progress = TRUE) {
    .Call('matchingMarkets_stabitCpp', PACKAGE = 'matchingMarkets', Xr, Rr, Wr, One, Two, T, offOutr, offSelr, sigmabarbetainverse, sigmabaralphainverse, niter, n, l, Pr, p, binary, selection, censored, ntu, gPrior, display_progress)
}

