qqnl <- function(y, mu = 0, sigma = 1, alpha = 1, beta = 1,
                 param = c(mu, sigma, alpha, beta),
                 main = "Normal Laplace Q-Q Plot",
                 xlab = "Theoretical Quantiles",
                 ylab = "Sample Quantiles",
                 plot.it = TRUE, line = TRUE, ...) {

  if (has.na <- any(ina <- is.na(y))) {
    yN <- y
    y <- y[!ina]
  }

  if ((n <- length(y)) == 0)
    stop("y is empty or has only NAs")

  x <- qnl(ppoints(n), param = param)[order(order(y))]

  if (has.na) {
    y <- x
    x <- yN
    x[!ina] <- y
    y <- yN
  }

  if (plot.it) {
    plot(x, y, main = main, xlab = xlab, ylab = ylab, ...)
    title(sub = paste("param = (",
          round(param[1], 3), ", ", round(param[2], 3), ", ",
          round(param[3], 3), ", ", round(param[4], 3), ")", sep = ""))

    if (line)
      abline(0, 1)
  }

  invisible(list(x = x, y = y))
}


ppnl <- function(y, mu = 0, sigma = 1, alpha = 1, beta = 1,
                 param = c(mu, sigma, alpha, beta),
                 main = "Normal Laplace P-P Plot",
                 xlab = "Uniform Quantiles",
                 ylab = "Probability-integral-transformed Data",
                 plot.it = TRUE, line = TRUE, ...) {

  if (has.na <- any(ina <- is.na(y))) {
    yN <- y
    y <- y[!ina]
  }

  if((n <- length(y)) == 0)
    stop("data is empty")

  yvals <- pnl(y, param = param)
  xvals <- ppoints(n, a = 1 / 2)[order(order(y))]

  if (has.na) {
    y <- yvals
    x <- xvals
    yvals <- yN
    yvals[!ina] <- y
    xvals <- yN
    xvals[!ina] <- x
  }

  if (plot.it) {
    plot(xvals, yvals, main = main, xlab = xlab, ylab = ylab,
         ylim = c(0, 1), xlim = c(0, 1), ...)
    title(sub = paste("param = (",
          round(param[1], 3), ", ", round(param[2], 3), ", ",
          round(param[3], 3), ", ", round(param[4], 3), ")", sep = ""))

    if (line)
      abline(0, 1)
  }

  invisible(list(x = xvals, y = yvals))
}
