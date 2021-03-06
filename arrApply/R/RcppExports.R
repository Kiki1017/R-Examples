# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#' High Performance Variant of apply()
#'
#' High performance variant of apply() for a fixed set of functions.
#' However, a considerable speedup is a trade-off for universality.
#' Only the following functions can be applied: sum(), prod(), all(), any(), min(), max(),
#' mean(), median(), sd(), var().
#' 
#' RcppArmadillo is used to do the job very quickly but it commes at price
#' of not allowing NA in the input numeric array.
#' Vectors are allowed at input. They are considered as arrays of dimension 1.
#' So in this case, \code{idim} must be 1.
#' 
#' 
#' @param arr numeric array of arbitrary dimension
#' @param idim integer, dimension number along which a function must be applied
#' @param fun character string, function name to be applied
#'
#' @return output array of dimension cut by 1. Its type (nueric or logical)
#' depends on the function applied.
#' 
#' @examples
#'  arr=matrix(1:12, 3, 4)
#'  v1=arrApply(arr, 2, "mean")
#'  v2=rowMeans(arr)
#'  stopifnot(all(v1==v2))
#'  
#'  arr=array(1:24, dim=2:4) # dim(arr)=c(2, 3, 4)
#'  mat=arrApply(arr, 2, "prod") # dim(mat)=c(2, 4), the second dimension is cut out
#'  stopifnot(all(mat==apply(arr, c(1, 3), prod)))
#' 
#' @author Serguei Sokol <sokol at insa-toulouse.fr>
#' 
#' @export
arrApply <- function(arr, idim = 1L, fun = "sum") {
    .Call('arrApply_arrApply', PACKAGE = 'arrApply', arr, idim, fun)
}

