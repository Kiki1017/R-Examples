colevels.incidence <-
function(y) {
    n <- nrow(y)
    lev <- rep(NA, n)
    names(lev) <- rownames(y)
    i <- 1
    sub <- (1:n)[is.na(lev)]
    while(length(sub)>0) {
        tmp_z <- y[sub, sub]
        class(tmp_z) <- class(y)
        quali <- which(heights(tmp_z)==1)
        lev[sub[quali]] <- i
        i <- i + 1
        sub <- (1:n)[is.na(lev)]
    }
    lev
}
