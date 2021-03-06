plotBMAgamma <-
function (WEIGHTS, MEAN, VAR, obs = NULL, exchangeable = NULL, power = 1)
{
#
# copyright 2006-present, University of Washington. All rights reserved.
# for terms of use, see the LICENSE file
#
  k <- length(WEIGHTS)

  Q <- matrix( NA, 2, k + 1)

  W <- WEIGHTS

  n <- 1000

  bot <- 1/n
  top <- (n-1)/n

  Q[1,k+1] <- quantBMAgamma( bot,  WEIGHTS, MEAN, VAR)
  Q[2,k+1] <- quantBMAgamma( top,  WEIGHTS, MEAN, VAR)

  for (j in 1:k){
     W[] <- 0
     W[j] <- 1
     Q[1,j] <- quantBMAgamma( bot, W, MEAN, VAR)
     Q[2,j] <- quantBMAgamma( top, W, MEAN, VAR)
  }

  r <- range(Q)

  if (!is.null(obs) && !is.na(obs)) r <- range(c(r,obs))

  if (is.null(exchangeable)) exchangeable <- 1:k

  tex <- table(exchangeable)
  lex <- length(tex)

  FORC <- matrix( NA, n, lex + 1)
  x <- seq(from = r[1], to = r[2], length = n)

  RATE <- MEAN/VAR
  for (l in 1:lex) {
     j <- which(exchangeable == l)[1]
     FORC[,l] <- dgamma( x, shape = RATE[j]*MEAN[j], rate = RATE[j])
     FORC[,l] <- tex[l]*WEIGHTS[j]*FORC[,l]
  }

  for (i in 1:n) FORC[i,lex+1] <- sum(FORC[i,1:lex])

#  matplot(FORC,PROB)

lo <- quantBMAgamma( .1,  WEIGHTS, MEAN, VAR)
med <- quantBMAgamma( .5,  WEIGHTS, MEAN, VAR)
up <- quantBMAgamma( .9,  WEIGHTS, MEAN, VAR)

ylim <- range(c(0,FORC))
xlim <- range(c(0,x))

  xlab <- "Wind Speed"
  if (power != 1) {
      if (power == 1/3) {
            xlab <- "Cube Root of Wind Speed"
          }
        else if (power == 1/2) {
              xlab <- "Square Root of Wind Speed"
            }
        else {
              xlab <- paste( xlab, " to the ", round(power,3), " power")
            }
    }
  
plot( c(0,x), c(0,FORC[,lex+1]), type = "l", col = "black", ylim = ylim,
      xlab = xlab, ylab = "Probability Density", lwd = 3)

abline( v = lo, col = "black", lty = 2)
abline( v = med, col = "black")
abline( v = up, col = "black", lty = 2)

if (!is.null(obs) && !is.na(obs)) abline( v = obs, col = "orange", lwd = 3)

colors <- rainbow(lex)
for (l in 1:lex) {
  lines( x, FORC[,l], col = colors[l], lty = 1)
}

lines( x, FORC[,lex+1], col = "black", lwd = 3)

invisible(FORC)
}

