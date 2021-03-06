#' Check for available package updates in a miniCRAN repo.
#'
#' \code{oldPackages} indicates packages which have a (suitable) later version on the repositories whereas \code{updatePackages} offers to download and install such packages.
#'
#' These functions are based on \code{\link{update.packages}}.  However, rather than looking for locally installed packages they look for the package source and binaries in the miniCRAN repository.
#'
#' @name updatePackages
#' 
#' @inheritParams makeRepo
#' @inheritParams pkgDep
#'
#' @param method  Download method, see \code{\link{download.file}}.
#'
#' @param availableLocal all packages hosted in the miniCRAN repo, as returned by \code{\link{pkgAvail}}. A subset can be specified; currently this must be in the same (character matrix) format as returned by \code{\link{pkgAvail}}.
#'
#' @return \code{oldPackages} returns a matrix with one row per package and columns for "Package", "LocalVer", "ReposVer" and "Repository".  The matrix row names the package names.
#'
#' @seealso \code{\link{updatePackages}}, \code{\link{pkgAvail}}.
#'
#' @export
#' @family update repo functions
#'
#' @example /inst/examples/example_updatePackages.R
#'
oldPackages <- function (path = NULL, 
                         repos = getOption("repos"),
                         availPkgs = pkgAvail(repos=repos, type=type, Rversion=Rversion),
                         method, 
                         availableLocal = pkgAvail(repos=path, type=type, Rversion=Rversion), type="source",
                         Rversion = R.version) {
  if (is.null(path)) stop("path to miniCRAN repo must be specified")
  if (!missing(availPkgs)) {
    if (!is.matrix(availPkgs) || !is.character(availPkgs[, "Package"]))
      stop("ill-formed 'availPkgs' matrix")
  }
  if (NROW(availPkgs) == 0L) stop("Invalid remote repository")
  if (NROW(availableLocal) == 0L) stop("Invalid local repository")
  
  idx <- match(availableLocal[, "Package"], availPkgs[, "Package"])
  compare <- sapply(seq_along(idx), function(i){
    compareVersion(
      (availPkgs[idx[i], "Version"]),
      (availableLocal[i, "Version"])
    ) > 0
  })
  
  update <- cbind(
    availableLocal[compare, c("Package", "Version"), drop=FALSE],
    availPkgs[idx[compare], c("Version", "Repository"), drop=FALSE]
  )
  colnames(update) <- c("Package", "LocalVer", "ReposVer", "Repository")
  update
}




#' @inheritParams makeRepo
#'
#' @param oldPkgs if specified as non-NULL, \code{updatePackages()} only considers these packages for updating. This may be a character vector of package names or a matrix as returned by \code{oldPackages()}.
#'
#' @param ask logical indicating whether to ask user before packages are actually downloaded and installed, or the character string "\code{graphics}", which brings up a widget to allow the user to (de-)select from the list of packages which could be updated or added. The latter value only works on systems with a GUI version of \code{\link{select.list}}, and is otherwise equivalent to \code{ask = TRUE}.
#'
#' @return \code{updatePackages} returns \code{NULL} invisibly.
#'
#' @export
#'
updatePackages <- function (path=NULL, repos=getOption("repos"),
                            method, ask=TRUE, 
                            availPkgs=pkgAvail(repos=repos, type=type, Rversion=Rversion),
                            oldPkgs=NULL, type="source",
                            Rversion=R.version,
                            quiet=FALSE) {
  force(ask)
  simplifyRepos <- function(repos, type) {
    tail <- substring(contribUrl("---", type=type, Rversion=Rversion), 4)
    ind <- regexpr(tail, repos, fixed=TRUE)
    ind <- ifelse(ind > 0, ind-1, nchar(repos, type="c"))
    substr(repos, 1, ind)
  }
  text.select <- function(old) {
    update <- NULL
    for (k in seq_len(nrow(old))) {
      cat(old[k, "Package"], ":\n",
          "Local Version", old[k, "LocalVer"], "\n",
          "Repos Version", old[k, "ReposVer"],
          "available at", simplifyRepos(old[k, "Repository"], type))
      cat("\n")
      answer <- substr(readline("Update (y/N/c)?  "), 1L, 1L)
      if (answer == "c" | answer == "C") {
        cat("cancelled by user\n")
        return(invisible())
      }
      if (answer == "y" | answer == "Y") update <- rbind(update, old[k, ])
    }
    update
  }
  if (is.null(path)) stop("path to miniCRAN repo must be specified")
  if (!is.matrix(oldPkgs) && is.character(oldPkgs)) {
    subset <- oldPkgs
    oldPkgs <- NULL
  } else {
    subset <- NULL
  }
  if (is.null(oldPkgs)) {
    oldPkgs <- oldPackages(path=path, repos=repos, 
                           method=method, availPkgs=availPkgs, type=type,
                           Rversion=Rversion)
    if (is.null(oldPkgs)) {
      message("All packages are up to date from repos: ", names(repos))
      return(invisible())
    }
  } else if (!(is.matrix(oldPkgs) && is.character(oldPkgs))) {
    stop("invalid 'oldPkgs'; must be a character vector or a result from oldPackages()")
  }
  if (!is.null(subset)) {
    oldPkgs <- oldPkgs[rownames(oldPkgs) %in% subset, , drop = FALSE]
    if (nrow(oldPkgs)==0) return(invisible())
  }
  update <- if (is.character(ask) && ask == "graphics") {
    if (.Platform$OS.type=="windows" || .Platform$GUI ==
          "AQUA" || (capabilities("tcltk") && capabilities("X11"))) {
      k <- select.list(oldPkgs[, 1L], oldPkgs[, 1L], multiple=TRUE,
                       title="Packages to be updated", graphics = TRUE)
      oldPkgs[match(k, oldPkgs[, 1L]), , drop = FALSE]
    } else {
      text.select(oldPkgs)
    }
  } else if (isTRUE(ask)) {
    text.select(oldPkgs)
  } else {
    oldPkgs
  }
  if (length(update[,"Package"])) {
    addPackage(update[,"Package"], path=path, repos=repos, type=type, quiet=quiet, deps=FALSE, Rversion=Rversion)
  }
}
