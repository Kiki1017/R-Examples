# Generated by autofun (0.0.0.9000): do not edit by hand!!!
# Please edit source code in R-autofun/prepare-jittering.R
.prepare_jittering<-function(...){
expression(x.min <- schedule$x.min, y.min <- schedule$y.min, 
    aa <- is.null(schedule$x.max), bb <- is.null(schedule$y.max), 
    cc <- is.null(schedule$cellsize), if (any(c(aa, bb, cc) == TRUE)) {
      
      message("estimating jittering parameters from 'candi'...")
      x <- SpatialTools::dist1(as.matrix(candi[, "x"]))
      id <- x > 0
      x.max <- ifelse(aa, max(x) / 2, schedule$x.max)
      if (cc) { cellsize <- min(x[id]) } else { cellsize <- schedule$cellsize }
      
      y <- SpatialTools::dist1(as.matrix(candi[, "y"]))
      id <- y > 0
      y.max <- ifelse(bb, max(y) / 2, schedule$y.max)
      if (cc) { cellsize <- c(cellsize, min(y[id])) }
      
    } else {
      
      # If nothing is missing...
      x.max <- schedule$x.max
      y.max <- schedule$y.max
      cellsize <- schedule$cellsize
    }, x_max0 <- x.max, y_max0 <- y.max)
}

