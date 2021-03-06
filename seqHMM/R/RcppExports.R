# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

EM <- function(transitionMatrix, emissionArray, initialProbs, obsArray, nSymbols, itermax, tol, trace, threads) {
    .Call('seqHMM_EM', PACKAGE = 'seqHMM', transitionMatrix, emissionArray, initialProbs, obsArray, nSymbols, itermax, tol, trace, threads)
}

EMx <- function(transitionMatrix, emissionArray, initialProbs, obsArray, nSymbols, coefs, X, numberOfStates, itermax, tol, trace, threads) {
    .Call('seqHMM_EMx', PACKAGE = 'seqHMM', transitionMatrix, emissionArray, initialProbs, obsArray, nSymbols, coefs, X, numberOfStates, itermax, tol, trace, threads)
}

forwardbackward <- function(transition, emissionArray, init, obsArray, forwardonly, threads) {
    .Call('seqHMM_forwardbackward', PACKAGE = 'seqHMM', transition, emissionArray, init, obsArray, forwardonly, threads)
}

forwardbackwardx <- function(transition, emissionArray, init, obsArray, coef, X, numberOfStates, forwardonly, threads) {
    .Call('seqHMM_forwardbackwardx', PACKAGE = 'seqHMM', transition, emissionArray, init, obsArray, coef, X, numberOfStates, forwardonly, threads)
}

log_EM <- function(transitionMatrix, emissionArray, initialProbs, obsArray, nSymbols, itermax, tol, trace, threads) {
    .Call('seqHMM_log_EM', PACKAGE = 'seqHMM', transitionMatrix, emissionArray, initialProbs, obsArray, nSymbols, itermax, tol, trace, threads)
}

log_EMx <- function(transitionMatrix, emissionArray, initialProbs, obsArray, nSymbols, coefs, X, numberOfStates, itermax, tol, trace, threads) {
    .Call('seqHMM_log_EMx', PACKAGE = 'seqHMM', transitionMatrix, emissionArray, initialProbs, obsArray, nSymbols, coefs, X, numberOfStates, itermax, tol, trace, threads)
}

log_forwardbackward <- function(transitionMatrix, emissionArray, initialProbs, obsArray, forwardonly, threads) {
    .Call('seqHMM_log_forwardbackward', PACKAGE = 'seqHMM', transitionMatrix, emissionArray, initialProbs, obsArray, forwardonly, threads)
}

log_forwardbackwardx <- function(transitionMatrix, emissionArray, initialProbs, obsArray, coef, X, numberOfStates, forwardonly, threads) {
    .Call('seqHMM_log_forwardbackwardx', PACKAGE = 'seqHMM', transitionMatrix, emissionArray, initialProbs, obsArray, coef, X, numberOfStates, forwardonly, threads)
}

log_logLikHMM <- function(transitionMatrix, emissionArray, initialProbs, obsArray, threads) {
    .Call('seqHMM_log_logLikHMM', PACKAGE = 'seqHMM', transitionMatrix, emissionArray, initialProbs, obsArray, threads)
}

log_logLikMixHMM <- function(transitionMatrix, emissionArray, initialProbs, obsArray, coef, X, numberOfStates, threads) {
    .Call('seqHMM_log_logLikMixHMM', PACKAGE = 'seqHMM', transitionMatrix, emissionArray, initialProbs, obsArray, coef, X, numberOfStates, threads)
}

log_objective <- function(transition, emissionArray, init, obsArray, ANZ, emissNZ, INZ, nSymbols, threads) {
    .Call('seqHMM_log_objective', PACKAGE = 'seqHMM', transition, emissionArray, init, obsArray, ANZ, emissNZ, INZ, nSymbols, threads)
}

log_objectivex <- function(transition, emissionArray, init, obsArray, ANZ, emissNZ, INZ, nSymbols, coef, X, numberOfStates, threads) {
    .Call('seqHMM_log_objectivex', PACKAGE = 'seqHMM', transition, emissionArray, init, obsArray, ANZ, emissNZ, INZ, nSymbols, coef, X, numberOfStates, threads)
}

logLikHMM <- function(transition, emissionArray, init, obsArray, threads) {
    .Call('seqHMM_logLikHMM', PACKAGE = 'seqHMM', transition, emissionArray, init, obsArray, threads)
}

logLikMixHMM <- function(transition, emissionArray, init, obsArray, coef, X, numberOfStates, threads) {
    .Call('seqHMM_logLikMixHMM', PACKAGE = 'seqHMM', transition, emissionArray, init, obsArray, coef, X, numberOfStates, threads)
}

logSumExp <- function(x) {
    .Call('seqHMM_logSumExp', PACKAGE = 'seqHMM', x)
}

objective <- function(transition, emissionArray, init, obsArray, ANZ, emissNZ, INZ, nSymbols, threads) {
    .Call('seqHMM_objective', PACKAGE = 'seqHMM', transition, emissionArray, init, obsArray, ANZ, emissNZ, INZ, nSymbols, threads)
}

objectivex <- function(transition, emissionArray, init, obsArray, ANZ, emissNZ, INZ, nSymbols, coef, X, numberOfStates, threads) {
    .Call('seqHMM_objectivex', PACKAGE = 'seqHMM', transition, emissionArray, init, obsArray, ANZ, emissNZ, INZ, nSymbols, coef, X, numberOfStates, threads)
}

varcoef <- function(coef, X) {
    .Call('seqHMM_varcoef', PACKAGE = 'seqHMM', coef, X)
}

viterbi <- function(transition, emissionArray, init, obsArray) {
    .Call('seqHMM_viterbi', PACKAGE = 'seqHMM', transition, emissionArray, init, obsArray)
}

viterbix <- function(transition, emissionArray, init, obsArray, coef, X, numberOfStates) {
    .Call('seqHMM_viterbix', PACKAGE = 'seqHMM', transition, emissionArray, init, obsArray, coef, X, numberOfStates)
}

