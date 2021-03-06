#' @title Assessing the performance of acoustic distance measurements
#' 
#' @description \code{compare.methods} create graphs to visually assess performance of acoustic distance measurements 
#' @usage compare.methods(X = NULL, flim = c(0, 22), bp = c(0, 22), mar = 0.1, wl = 512, ovlp = 90, 
#' res = 150, n = 10, length.out = 30, methods = c("XCORR", 
#' "dfDTW", "ffDTW", "SP"),it = "jpeg", parallel = 1)
#' @param X Data frame with results from \code{\link{manualoc}} function, \code{\link{autodetec}} 
#' function, or any data frame with columns for sound file name (sound.files), 
#' selection number (selec), and start and end time of signal (start and end).
#' Default \code{NULL}. 
#' @param flim A numeric vector of length 2 for the frequency limit in kHz of 
#'   the spectrogram, as in \code{\link[seewave]{spectro}}. Default is c(0, 22).
#' @param bp numeric vector of length 2 giving the lower and upper limits of the 
#' frequency bandpass filter (in kHz) used in the acoustic distance methods. Default is c(0, 22).
#' @param mar Numeric vector of length 1. Specifies plot margins around selection in seconds. Default is 0.1.
#' @param wl A numeric vector of length 1 specifying the window length of the spectrogram, default 
#'   is 512.
#' @param ovlp Numeric vector of length 1 specifying the percent overlap between two 
#'   consecutive windows, as in \code{\link[seewave]{spectro}}. Default is 90.
#' @param res Numeric argument of length 1. Controls image resolution.
#'   Default is 150.
#' @param n Numeric argument of length 1. Defines the number of plots to be produce. 
#' Default is 10.
#' @param length.out A character vector of length 1 giving the number of measurements of fundamental or dominant
#' frequency desired (the length of the time series). Default is 30.
#' @param methods A character vector of length 2 giving the names of the acoustic distance
#' methods that would be compared. The methods available are: cross-correlation (XCORR, from
#' \code{xcorr}), dynamic time warping on dominant frequency time series (dfDTW, from
#'  \code{\link[dtw]{dtw}} applied on \code{dfts} output), dynamic time warping on dominant 
#'  frequency time series (ffDTW, from \code{\link[dtw]{dtw}} applied on \code{ffts} output),
#'   spectral parameters (SP, from \code{specan}).
#' @param it A character vector of length 1 giving the image type to be used. Currently only
#' "tiff" and "jpeg" are admitted. Default is "jpeg".
#' @param parallel Numeric. Controls whether parallel computing is applied.
#'  It specifies the number of cores to be used. Default is 1 (e.i. no parallel computing).
#'  windows OS users need to install \code{warbleR} from github to run parallel. 
#'   Note that creating images is not compatible with parallel computing 
#'   (parallel > 1) in OSX (mac).  
#' @return Image files with 4 spectrograms of the selection being compared and scatterplots 
#' of the acoustic space of all signals in the input data frame 'X'.  
#' @export
#' @name compare.methods
#' @details This function produces graphs with spectrograms from 4 selections that allow visual inspection of the performance of acoustic distance methods at comparing those selections. The spectrograms are all plotted with the same frequency and time scales. The function compares 2 methods at a time. The methods available are: cross
#' -correlation (XCORR, from \code{xcorr}), dynamic time warping on dominant frequency time 
#' series (dfDTW, from \code{\link[dtw]{dtw}} applied on \code{dfts} output), dynamic time 
#' warping on dominant frequency time series (ffDTW, from \code{\link[dtw]{dtw}} applied on 
#' \code{ffts} output), spectral parameters (SP, from \code{specan}). The graph also 
#' contains 2 scatterplots (1 for each method) of the acoustic space of all signals in the 
#' input data frame 'X'. The compared selections are randomly picked up from the pool of 
#' selections in the input data frame. The argument 'n' defines the number of comparison (e
#' .i. graphs) to be produced. The acoustic pairwise distance between signals is shown next 
#' to the arrows linking them. The font color of a distance value correspond to the font 
#' color of the method that generetad it, as shown in the scatterplots. Distances are 
#' standardize, being 0 the distance of a signal to itself and 1 the farthest pairwise 
#' distance in the pool of signals. Principal Component Analysis (\code{\link[stats]{princomp}}) 
#' is applied to calculate distances when using spectral parameters (SP). In that case the first 2 PC's are used. Classical 
#' Multidimensional Scalling (also knwon as Principal Coordinates Analysis, 
#' (\code{\link[stats]{cmdscale}})) is used for all other methods. Note that SP can only be used with at least 22 selections (number of rows in input data frame) as PCA only works with more units than variables. The graphs are return as image files in the 
#' working directory. The file name contains the methods being compared and the 
#' rownumber of the selections. This function uses internally a modified version
#' of the \code{\link[seewave]{spectro}} function from seewave package to create spectrograms. 
#'   
#' @examples
#' \dontrun{
#' # First create empty folder
#' setwd(tempdir())
#' 
#' data(list = c("Phae.long1", "Phae.long2", "Phae.long3", "Phae.long4", "manualoc.df"))
#' writeWave(Phae.long1,"Phae.long1.wav")
#' writeWave(Phae.long2,"Phae.long2.wav")
#' writeWave(Phae.long3,"Phae.long3.wav")
#' writeWave(Phae.long4,"Phae.long4.wav") 
#'
#' compare.methods(X = manualoc.df, flim = c(0, 10), bp = c(0, 10), mar = 0.1, wl = 512, 
#' ovlp = 90, res = 200, n = 10, length.out = 30, 
#' methods = c("XCORR", "dfDTW"), parallel = 1, it = "tiff")
#' 
#' #check this folder!!
#' getwd()
#' }
#' 
#' @author Marcelo Araya-Salas (\email{araya-salas@@cornell.edu}). It uses 
#' internally a modified version of the \code{\link[seewave]{spectro}} function from 
#' seewave package to create spectrograms.

compare.methods <- function(X = NULL, flim = c(0, 22), bp = c(0, 22), mar = 0.1, wl = 512, ovlp = 90, 
    res = 150, n = 10, length.out = 30, methods = c("XCORR",
"dfDTW", "ffDTW", "SP"), 
 
    it = "jpeg", parallel = 1){  
  #if parallel is not numeric
  if(!is.numeric(parallel)) stop("'parallel' must be a numeric vector of length 1") 
  if(any(!(parallel %% 1 == 0),parallel < 1)) stop("'parallel' should be a positive integer")
  
  # methods 
  if(any(!is.character(methods),length(methods) > 2)) stop("'methods' must be a character vector of length 2")
  if(length(methods[!methods %in% c("XCORR", "dfDTW", "ffDTW", "SP")]) > 0) 
    stop(paste(methods[!methods %in% c("XCORR", "dfDTW", "ffDTW", "SP")],"is (are) not valid method"))
  
  #if flim is not vector or length!=2 stop
  if(!is.null(flim))
  {if(!is.vector(flim)) stop("'flim' must be a numeric vector of length 2") else{
    if(!length(flim) == 2) stop("'flim' must be a numeric vector of length 2")}}    
 
  #if bp is not vector or length!=2 stop
  if(!is.null(bp))
  {if(!is.vector(bp)) stop("'bp' must be a numeric vector of length 2") else{
    if(!length(bp) == 2) stop("'bp' must be a numeric vector of length 2")}} 
  
  #if wl is not vector or length!=1 stop
  if(is.null(wl)) stop("'wl' must be a numeric vector of length 1") else {
    if(!is.vector(wl)) stop("'wl' must be a numeric vector of length 1") else{
      if(!length(wl) == 1) stop("'wl' must be a numeric vector of length 1")}}  
  
  #if res is not vector or length!=1 stop
  if(is.null(res)) stop("'res' must be a numeric vector of length 1") else {
    if(!is.vector(res)) stop("'res' must be a numeric vector of length 1") else{
      if(!length(res) == 1) stop("'res' must be a numeric vector of length 1")}}  
  
  #if there are NAs in start or end stop
  if(any(is.na(c(X$end, X$start)))) stop("NAs found in start and/or end")  
  
  #if any start higher than end stop
  if(any(X$end - X$start<0)) stop(paste("The start is higher than the end in", length(which(X$end - X$start<0)), "case(s)"))  
  
  #if any selections longer than 20 secs stop
  if(any(X$end - X$start>20)) stop(paste(length(which(X$end - X$start>20)), "selection(s) longer than 20 sec"))  
  options( show.error.messages = TRUE)

  # If n is not numeric
  if(!is.numeric(n)) stop("'n' must be a numeric vector of length 1") 
  if(any(!(n %% 1 == 0),n < 1)) stop("'n' should be a positive integer")

  # If length.out is not numeric
  if(!is.numeric(length.out)) stop("'length.out' must be a numeric vector of length 1") 
  if(any(!(length.out %% 1 == 0),length.out < 1)) stop("'length.out' should be a positive integer")

    #return warning if not all sound files were found
  fs <- list.files(path = getwd(), pattern = ".wav$", ignore.case = TRUE)
  if(length(unique(X$sound.files[(X$sound.files %in% fs)])) != length(unique(X$sound.files))) 
    cat(paste(length(unique(X$sound.files))-length(unique(X$sound.files[(X$sound.files %in% fs)])), 
                  ".wav file(s) not found"))
  
  #count number of sound files in working directory and if 0 stop
  d <- which(X$sound.files %in% fs) 
  if(length(d) == 0){
    stop("The .wav files are not in the working directory")
  }  else X <- X[d,]
  
  # If SP is used need at least 22 selections
  if("SP" %in% methods)
  {if(nrow(X) < 22)  stop("SP can only be used with at least 22 selections (number of rows in input data frame) as PCA only works with more units than variables")}
  
  
  disim.mats <- list()
  
  if("XCORR" %in% methods)
  {xcmat <- xcorr(X, wl = 512, frange = bp, ovlp = ovlp, dens = 0.9, parallel = parallel)$max.xcorr.matrix

  MDSxcorr <- stats::cmdscale(1-xcmat)  
  MDSxcorr <- scale(MDSxcorr)
  disim.mats[[1]] <- MDSxcorr
  }
  
  if("dfDTW" %in% methods)
    {dtwmat <- dfts(X, wl = 512, flim = flim, ovlp = 90, img = FALSE, parallel = parallel, length.out = length.out)
    
  dm <- dtwDist(dtwmat[,3:ncol(dtwmat)],dtwmat[,3:ncol(dtwmat)])  
  
  MDSdtw <- stats::cmdscale(dm)  
  MDSdtw <- scale(MDSdtw)
  disim.mats[[length(disim.mats) + 1]] <- MDSdtw
  }

  if("ffDTW" %in% methods)
  {dtwmat <- ffts(X, wl = 512, flim = flim, ovlp = 90, img = FALSE, parallel = parallel, length.out = length.out)
  
  dm <- dtwDist(dtwmat[,3:ncol(dtwmat)],dtwmat[,3:ncol(dtwmat)],method="DTW")  
  
  MDSdtw <- stats::cmdscale(dm)  
  MDSdtw <- scale(MDSdtw)
  disim.mats[[length(disim.mats) + 1]] <- MDSdtw
  }
  
  if("SP" %in% methods)
  {spmat <- specan(X, wl = 512, bp = flim, parallel = parallel)
  
  sp <- princomp(scale(spmat[,3:ncol(spmat)]), cor = F)$scores[ ,1:2]

  PCsp <- scale(sp)
  disim.mats[[length(disim.mats) + 1]] <- PCsp
  }
  
  names(disim.mats) <- methods
  
  maxdist <-lapply(disim.mats, function(x) max(dist(x)))
  
  X$labels <- 1:nrow(X)
  
  combs <- combn(1:nrow(X), 4)
  
  if(nrow(X) == 4)  {n <- 1
  combs <- as.matrix(1:4)
  cat("Only 1 possible combination of signals")
  } else if(n > ncol(combs)) {n <- ncol(combs)
  cat(paste("Only",n, "possible combinations of signals"))
  }
  
  if(nrow(X) > 4)  combs <- as.data.frame(combs[,sample(1:ncol(combs), n)])
  
  #if parallel in OSX
  if(all(parallel > 1, !Sys.info()[1] %in% c("Linux","Windows"))) {
    parallel <- 1
    cat("creating images is not compatible with parallel computing (parallel > 1) in OSX (mac)")
  }
  
  #if on windows you need parallelsugar package
  if(parallel > 1)
  { 
    #      options(warn = -1)
    #      
    #        
    #        if(Sys.info()[1] == "Windows"){ 
    #       cat 
    #       lapp <- pbapply::pblapply} else 
    lapp <- function(X, FUN) parallel::mclapply(X, FUN, mc.cores = parallel)} else lapp <- pbapply::pblapply
  
  options(warn = 0)

  #create matrix for sppliting screen
  m <- rbind(c(0, 2.5/7, 3/10, 5/10), #1
             c(4.5/7, 1, 3/10, 5/10), #2
             c(0, 2.5/7, 0, 2/10), #3
             c(4.5/7, 1, 0, 2/10), #4
             c(0, 1/2, 5/10, 9/10), #5
             c(1/2, 1, 5/10, 9/10), #6
             c(0, 2.5/7, 2/10, 3/10), #7 
             c(2.5/7, 4.5/7, 0, 5/10), #8
             c(4.5/7, 1, 2/10, 3/10), #9
             c(0, 3.5/7, 9/10, 10/10), #10
             c(3.5/7, 1, 9/10, 10/10)) #11
     
  # screen 1:4 for spectros
  # screen 5,6 for scatterplots
  # screen 7:9 for similarities/arrows
  # screen 10:11 method labels
  
  options(warn = -1)
  
  if(parallel == 1)  cat("Saving graphs in image files")
  
  invisible(lapp(1:ncol(combs), function(u)
    {
    rs <- combs[,u]
       X <- X[rs,]
  
  if(it == "tiff") tiff(filename = paste("comp.spec-", names(disim.mats)[1],"-",names(disim.mats)[2], paste(X$labels, collapse = "-"), ".tiff", sep = ""), width = 16.25, height =  16.25, units = "cm", res = res) else 
    jpeg(filename = paste("comp.spec-", names(disim.mats)[1],"-",names(disim.mats)[2], paste(X$labels, collapse = "-"), ".jpeg", sep = ""), width =  16.25, height =  16.25, units = "cm", res = res)
  
  split.screen(m)
  
  mxdur<-max(X$end - X$start) + mar*2
  
  col <- rep("gray40", nrow(disim.mats[[1]]))
  
  col[rs] <- topo.colors(5)[1:4]
  
  invisible(lapply(c(7:9, 1:4, 5:6, 10:11), function(x)
  {
    screen(x)
    par( mar = rep(0, 4))
    if(x < 5) 
    { 
      r <- readWave(as.character(X$sound.files[x]), header = TRUE)
      tlim <- c((X$end[x] - X$start[x])/2 + X$start[x] - mxdur/2, (X$end[x] - X$start[x])/2 + X$start[x] + mxdur/2)
      
      mar1 <- X$start[x]-tlim[1]
      mar2 <- mar1 + X$end[x] - X$start[x]
      
      if (tlim[1] < 0) { tlim[2] <- abs(tlim[1]) + tlim[2] 
      mar1 <- mar1  + tlim[1]
      mar2 <- mar2  + tlim[1]
      tlim[1] <- 0
      }
      if (tlim[2] > r$samples/r$sample.rate) { tlim[1] <- tlim[1] - (r$samples/r$sample.rate - tlim[2])
      mar1 <- X$start[x]-tlim[1]
      mar2 <- mar1 + X$end[x] - X$start[x]
      tlim[2] <- r$samples/r$sample.rate}
      
      if (flim[2] > ceiling(r$sample.rate/2000) - 1) flim[2] <- ceiling(r$sample.rate/2000) - 1
      
      
      r <- tuneR::readWave(as.character(X$sound.files[x]), from = tlim[1], to = tlim[2], units = "seconds")
      
      spectro2(wave = r, f = r@samp.rate,flim = flim, wl = wl, ovlp = ovlp, axisX = F, axisY = F, tlab = F, flab = F, palette = reverse.gray.colors.2)
      box(lwd = 2)
      if(x == 1 | x == 3) 
        text(tlim[2] - tlim[1], ((flim[2] - flim[1])*0.86) + flim[1], labels = X$labels[x], col = col[rs[x]], cex = 1.5, font = 2, pos = 2) else 
          text(0, ((flim[2] - flim[1])*0.86) + flim[1], labels = X$labels[x], col = col[rs[x]], cex = 1.5, font = 2, pos = 4)  

      abline(v=c(mar1, mar2),lty = 4)
    }
    
    #upper left
    if(x == 5) {
      plot(disim.mats[[1]], col = "white", xaxt = "n", yaxt = "n", xlim = c(min(disim.mats[[1]][,1]) * 1.1, max(disim.mats[[1]][,1]) * 1.1), ylim = c(min(disim.mats[[1]][,2]) * 1.1, max(disim.mats[[1]][,2]) * 1.1))
      box(lwd = 4)
      centro <- apply(disim.mats[[1]], 2, mean)
      points(centro[1], centro[2], pch = 20, cex = 2, col = "gray3")
      cex <- rep(1, nrow(disim.mats[[1]]))
      cex[rs] <- 1.4
      text(disim.mats[[1]],  labels = 1:nrow(disim.mats[[1]]), col = col, cex =cex, font = 2)
    }
    
    #upper right
    if(x == 6) {
      plot(disim.mats[[2]], col = "white", xaxt = "n", yaxt = "n", xlim = c(min(disim.mats[[2]][,1]) * 1.1, max(disim.mats[[2]][,1]) * 1.1), ylim = c(min(disim.mats[[2]][,2]) * 1.1, max(disim.mats[[2]][,2]) * 1.1))
      box(lwd = 4)
      centro <- apply(disim.mats[[2]], 2, mean)
      points(centro[1], centro[2], pch = 20, cex = 2, col = "gray3")
      cex <- rep(1, nrow(disim.mats[[2]]))
      cex[rs] <- 1.4
      text(disim.mats[[2]],  labels = 1:nrow(disim.mats[[2]]), col = col, cex =cex, font = 2)
    }  
    
    #lower mid
    if(x == 8){
      plot(0.5, xlim = c(0,1), ylim = c(0,1), type = "n", axes = F, xlab = "", ylab = "", xaxt = "n", yaxt = "n")
      lim <- par("usr")
      rect(lim[1], lim[3]-1, lim[2], lim[4]+1, border = "#FFFFCC", col = "#FFFFCC")
      arrows(0, 5.5/7, 1, 5.5/7, code = 3, length = 0.09, lwd = 2)
      text(0.5, 5.36/7,labels =round(dist(disim.mats[[1]][rs[c(1,2)],])/maxdist[[1]],2), col = "black", font = 2, pos = 3)
      text(0.5, 5.545/7,labels =round(dist(disim.mats[[2]][rs[c(1,2)],])/maxdist[[2]],2), col = "gray50", font = 2, pos = 1)
      arrows(0, 1.5/7, 1, 1.5/7, code = 3, length = 0.09, lwd = 2)
      text(0.5, 1.4/7,labels = round(dist(disim.mats[[1]][rs[c(3,4)],])/maxdist[[1]],2), col = "black", font = 2, pos = 3)
      text(0.5, 1.63/7,labels =round(dist(disim.mats[[2]][rs[c(3,4)],])/maxdist[[2]],2), col = "gray50", font = 2, pos = 1)
      arrows(0, 2/7, 1, 5/7, code = 3, length = 0.09, lwd = 2)
      text(0.69, 4.16/7,labels =round(dist(disim.mats[[1]][rs[c(2,3)],])/maxdist[[1]],2), col = "black", font = 2, pos = 3)
      text(0.85, 4.4/7,labels =round(dist(disim.mats[[2]][rs[c(2,3)],])/maxdist[[2]],2), col = "gray50", font = 2, pos = 1)
      arrows(0, 5/7, 1, 2/7, code = 3, length = 0.09, lwd = 2)
      text(0.3, 4.16/7,labels =round(dist(disim.mats[[1]][rs[c(1,4)],])/maxdist[[1]],2), col = "black", font = 2, pos = 3)
      text(0.15, 4.4/7,labels =round(dist(disim.mats[[2]][rs[c(1,4)],])/maxdist[[2]],2), col = "gray50", font = 2, pos = 1)  
    }
    
    #in between left
    if(x == 7){
      plot(0.5, xlim = c(0,1), ylim = c(0,1), type = "n", axes = F, xlab = "", ylab = "", xaxt = "n", yaxt = "n")
      lim <- par("usr")
      rect(lim[1], lim[3]-1, lim[2], lim[4]+1, border = "#FFFFCC", col = "#FFFFCC")
      arrows(0.5, 0, 0.5, 1, code = 3, length = 0.09, lwd = 2)
      text(0.53, 0.5, labels =round(dist(disim.mats[[1]][rs[c(1,3)],])/maxdist[[1]],2), col = "black", font = 2, pos = 2)
      text(0.47, 0.5, labels =round(dist(disim.mats[[2]][rs[c(1,3)],])/maxdist[[2]],2), col = "gray50", font = 2, pos = 4)
    }
    
    #in between right
    if(x == 9){
      plot(0.5, xlim = c(0,1), ylim = c(0,1), type = "n", axes = F, xlab = "", ylab = "", xaxt = "n", yaxt = "n")
      lim <- par("usr")
      rect(lim[1], lim[3]-1, lim[2], lim[4]+1, border = "#FFFFCC", col = "#FFFFCC")
      arrows(0.5, 0, 0.5, 1, code = 3, length = 0.09, lwd = 2)
      text(0.53, 0.5,labels =round(dist(disim.mats[[1]][rs[c(2,4)],])/maxdist[[1]],2), col = "black", font = 2, pos = 2)
      text(0.47, 0.5,labels =round(dist(disim.mats[[2]][rs[c(2,4)],])/maxdist[[2]],2), col = "gray50", font = 2, pos = 4)
      
    }
    
    #top (for method labels)
    if(x == 10){
      plot(0.5, xlim = c(0,1), ylim = c(0,1), type = "n", axes = F, xlab = "", ylab = "", xaxt = "n", yaxt = "n")
      lim <- par("usr")
      rect(lim[1], lim[3]-1, lim[2], lim[4]+1, border = "black", col = "#CCFFCC")
        text(0.5, 0.5, labels = names(disim.mats)[1], col = 'black', font = 2, cex = 1.2)
        box(lwd = 4)
        }
    
    if(x == 11){
      plot(0.5, xlim = c(0,1), ylim = c(0,1), type = "n", axes = F, xlab = "", ylab = "", xaxt = "n", yaxt = "n")
      lim <- par("usr")
      rect(lim[1], lim[3]-1, lim[2], lim[4]+1, border = "black", col = "#CCFFCC")
      text(0.5, 0.5, labels = names(disim.mats)[2], col = 'gray50', font = 2, cex = 1.2)      
      box(lwd = 4)
    }
  }
  ))
  invisible(dev.off())
  on.exit(invisible(close.screen(all.screens = TRUE)))
  }))

}


#internal warbleR function called by compare.methods. Modified from \code{\link[seewave]{spectro}}  
spectro2 <-function(wave, f, wl = 512, wn = "hanning", zp = 0, ovlp = 0, 
                    complex = FALSE, norm = TRUE, fftw = FALSE, dB = "max0", 
                    dBref = NULL, plot = TRUE, grid = TRUE, 
                    cont = FALSE, collevels = NULL, palette = spectro.colors, 
                    contlevels = NULL, colcont = "black", colbg = "white", colgrid = "black", 
                    colaxis = "black", collab = "black", cexlab = 1, cexaxis = 1, 
                    tlab = "Time (s)", flab = "Frequency (kHz)", alab = "Amplitude", 
                    scalelab = "Amplitude\n(dB)", main = NULL, scalefontlab = 1, 
                    scalecexlab = 0.75, axisX = TRUE, axisY = TRUE, tlim = NULL, 
                    trel = TRUE, flim = NULL, flimd = NULL, widths = c(6, 1), 
                    heights = c(3, 1), oma = rep(0, 4), listen = FALSE, ...) 
{
  if (!is.null(dB) && all(dB != c("max0", "A", "B", "C", "D"))) 
    stop("'dB' has to be one of the following character strings: 'max0', 'A', 'B', 'C' or 'D'")
  if (complex & norm) {
    norm <- FALSE
    warning("\n'norm' was turned to 'FALSE'")
  }
  if (complex & !is.null(dB)) {
    dB <- NULL
    warning("\n'dB' was turned to 'NULL'")
  }
  input <- inputw(wave = wave, f = f)
  
  wave <- input$w
  
  f <- input$f
  rm(input)
  if (!is.null(tlim)) 
    wave <- cutw(wave, f = f, from = tlim[1], to = tlim[2])
  if (!is.null(flimd)) {
    mag <- round((f/2000)/(flimd[2] - flimd[1]))
    wl <- wl * mag
    if (ovlp == 0) 
      ovlp <- 100
    ovlp <- 100 - round(ovlp/mag)
    flim <- flimd
  }
  n <- nrow(wave)
  step <- seq(1, n - wl, wl - (ovlp * wl/100))
  z <- stft(wave = wave, f = f, wl = wl, zp = zp, step = step, 
            wn = wn, fftw = fftw, scale = norm, complex = complex)
  if (!is.null(tlim) && trel) {
    X <- seq(tlim[1], tlim[2], length.out = length(step))
  }  else {
    X <- seq(0, n/f, length.out = length(step))
  }
  if (is.null(flim)) {
    Y <- seq(0, (f/2) - (f/wl), length.out = nrow(z))/1000
  } else {
    fl1 <- flim[1] * nrow(z) * 2000/f
    fl2 <- flim[2] * nrow(z) * 2000/f
    z <- z[(fl1:fl2) + 1, ]
    Y <- seq(flim[1], flim[2], length.out = nrow(z))
  }
  if (!is.null(dB)) {
    if (is.null(dBref)) {
      z <- 20 * log10(z)
    } else {
      z <- 20 * log10(z/dBref)
    }
    if (dB != "max0") {
      if (dB == "A") 
        z <- dBweight(Y * 1000, dBref = z)$A
      if (dB == "B") 
        z <- dBweight(Y * 1000, dBref = z)$B
      if (dB == "C") 
        z <- dBweight(Y * 1000, dBref = z)$C
      if (dB == "D") 
        z <- dBweight(Y * 1000, dBref = z)$D
    }
  }
  Z <- t(z)
  
  maxz <- round(max(z, na.rm = TRUE))
  if (!is.null(dB)) {
    if (is.null(collevels)) 
      collevels <- seq(maxz - 30, maxz, by = 1)
    if (is.null(contlevels)) 
      contlevels <- seq(maxz - 30, maxz, by = 10)
  } else {
    if (is.null(collevels)) 
      collevels <- seq(0, maxz, length = 30)
    if (is.null(contlevels)) 
      contlevels <- seq(0, maxz, length = 3)
  }
  Zlim <- range(Z, finite = TRUE, na.rm = TRUE)
  
  filled.contour.modif2(x = X, y = Y, z = Z, levels = collevels, 
                        nlevels = 20, plot.title = title(main = main, 
                                                         xlab = tlab, ylab = flab), color.palette = palette, 
                        axisX = axisX, axisY = axisY, col.lab = collab, 
                        colaxis = colaxis)
  if (grid) 
    grid(nx = NA, ny = NULL, col = colgrid)
  
}

