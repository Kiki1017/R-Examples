#' @importFrom V8 new_context
ct <- NULL
.onLoad <- function(libname, pkgname){
  ct <<- new_context();
  ct$source(system.file("js/minimist.min.js", package = pkgname))
}
