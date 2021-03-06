summary.tpopt <- function(object, ...)
{
    res <- object
    cat("\n###############################################################################\n")
    cat("Call:\n\n")
    print(res$call)
    cat("\n###############################################################################\n")
    cat("Models:\n")
    print(res$eta)
    cat("Fixed parameters:\n")
    print(res$theta.fix)
    cat("\n###############################################################################\n")
    cat("Design:\n")
    print(rbind(x = res$x, w = res$w))
    cat("\n###############################################################################\n")
    cat("Efficiency by iteration:\n")
    print(res$efficiency)
    cat("\n###############################################################################\n")
    cat("Time:\n")
    print(res$time)
    cat("\n###############################################################################\n")
}
