#' Spectrograms of selected signals
#' 
#' \code{specreator} creates spectrograms of signals selected by \code{\link{manualoc}} or \code{\link{autodetec}}.
#' @usage specreator(X, wl = 512, flim = c(0, 22), wn = "hanning", pal
#'   = reverse.gray.colors.2, ovlp = 70, inner.mar = c(5, 4, 4, 2), outer.mar =
#'   c(0, 0, 0, 0), picsize = 1, res = 100, cexlab = 1, title = TRUE,
#'   propwidth = FALSE, xl = 1, osci = FALSE, gr = FALSE,  sc = FALSE, line = TRUE,
#'   mar = 0.05, it = "jpeg", parallel = 1)
#' @param  X Data frame with results containing columns for sound file name (sound.files), 
#' selection number (selec), and start and end time of signals (start and end).
#' The ouptut of \code{\link{manualoc}} or \code{\link{autodetec}} can be used as the input data frame. 
#' @param wl A numeric vector of length 1 specifying the window length of the spectrogram, default 
#'   is 512.
#' @param flim A numeric vector of length 2 for the frequency limit (in kHz) of 
#'   the spectrogram, as in \code{\link[seewave]{spectro}}. Default is c(0, 22).
#' @param wn Character vector of length 1 specifying window name. Default is 
#'   "hanning". See function \code{\link[seewave]{ftwindow}} for more options.
#' @param pal A color palette function to be used to assign colors in the 
#'   plot, as in \code{\link[seewave]{spectro}}. Default is reverse.gray.colors.2. 
#' @param ovlp Numeric vector of length 1 specifying the percent overlap between two 
#'   consecutive windows, as in \code{\link[seewave]{spectro}}. Default is 70.
#' @param inner.mar Numeric vector with 4 elements, default is c(5,4,4,2). 
#'   Specifies number of lines in inner plot margins where axis labels fall, 
#'   with form c(bottom, left, top, right). See \code{\link[graphics]{par}}.
#' @param outer.mar Numeric vector with 4 elements, default is c(0,0,0,0). 
#'   Specifies number of lines in outer plot margins beyond axis labels, with 
#'   form c(bottom, left, top, right). See \code{\link[graphics]{par}}.
#' @param picsize Numeric argument of length 1. Controls relative size of 
#'   spectrogram. Default is 1. Ignored when propwidth is \code{TRUE}.
#' @param res Numeric argument of length 1. Controls image resolution.
#'   Default is 100 (faster) although 300 - 400 is recommended for publication/ 
#'   presentation quality.
#' @param cexlab Numeric vector of length 1 specifying the relative size of axis 
#'   labels. See \code{\link[seewave]{spectro}}.
#' @param title Logical argument to add a title to individual spectrograms. 
#'   Default is \code{TRUE}.
#' @param propwidth Logical argument to scale the width of spectrogram 
#'   proportionally to duration of the selection. Default is \code{FALSE}.
#' @param xl Numeric vector of length 1. A constant by which to scale 
#'   spectrogram width if propwidth = \code{TRUE}. Default is 1.
#' @param osci Logical argument to add an oscillogram underneath spectrogram, as
#'   in \code{\link[seewave]{spectro}}. Default is \code{FALSE}.
#' @param gr Logical argument to add grid to spectrogram. Default is \code{FALSE}.
#' @param sc Logical argument to add amplitude scale to spectrogram, default is 
#'   \code{FALSE}.
#' @param line Logical argument to add red lines at start and end times of selection. Default is \code{TRUE}.
#' @param mar Numeric vector of length 1. Specifies the margins adjacent to the start and end points of selections, 
#' dealineating spectrogram limits. Default is 0.05.
#' @param it A character vector of length 1 giving the image type to be used. Currently only
#' "tiff" and "jpeg" are admitted. Default is "jpeg".
#' @param parallel Numeric. Controls whether parallel computing is applied.
#' It specifies the number of cores to be used. Default is 1 (e.i. no parallel computing).
#' For windows OS the \code{warbleR} from github to run parallel. 
#'   Note that creating images is not compatible with parallel computing 
#'   (parallel > 1) in OSX (mac).   
#' @return Image files containing spectrograms of the signals listed in the input data frame.
#' @family spectrogram creators
#' @seealso \code{\link{trackfreqs}} for creating spectrograms to visualize 
#'   frequency measurements by \code{\link{specan}}, \code{\link{snrspecs}} for 
#'   creating spectrograms to optimize noise margins used in \code{\link{sig2noise}}
#' @export
#' @name specreator
#' @details This function creates spectrograms for visualization of vocalizations. 
#' Setting inner.mar to c(4,4.5,2,1) and outer.mar to c(4,2,2,1) works well when picsize = 2 or 3. 
#' Title font size, inner.mar and outer.mar (from mar and oma) don't work well when osci or sc = TRUE,
#' this may take some optimization by the user.
#' @examples
#' \dontrun{ 
#' # First set empty folder
#' setwd(tempdir())

#' data(list = c("Phae.long1", "Phae.long2","manualoc.df"))
#' writeWave(Phae.long1, "Phae.long1.wav") #save sound files 
#' writeWave(Phae.long2, "Phae.long2.wav")
#' 
#' # make spectrograms
#' 
#' specreator(manualoc.df, flim = c(0, 11), inner.mar = c(4,4.5,2,1), outer.mar = c(4,2,2,1), 
#'           picsize = 2, res = 300, cexlab = 2, mar = 0.05)

#' #check this folder!!
#' getwd()
#' }
#' 
#' @author Marcelo Araya-Salas (\email{araya-salas@@cornell.edu}) and Grace Smith Vidaurre

specreator <- function(X, wl = 512, flim = c(0, 22), wn = "hanning", pal = reverse.gray.colors.2, ovlp = 70, 
                        inner.mar = c(5,4,4,2), outer.mar = c(0,0,0,0), picsize = 1, res = 100, 
                        cexlab = 1, title = TRUE, propwidth = FALSE, xl=1, osci = FALSE, 
                        gr = FALSE, sc = FALSE, line = TRUE, mar = 0.05, it = "jpeg", parallel = 1){
  
  
  if(class(X) == "data.frame") {if(all(c("sound.files", "selec", 
                                         "start", "end") %in% colnames(X))) 
  {
    start <- as.numeric(unlist(X$start))
    end <- as.numeric(unlist(X$end))
    sound.files <- as.character(unlist(X$sound.files))
    selec <- as.character(unlist(X$selec))
    selcom <- as.character(unlist(X$sel.comment))
    
  } else stop(paste(paste(c("sound.files", "selec", "start", "end", "sel.comment")[!(c("sound.files", "selec", 
                                                                                       "start", "end", "sel.comment") %in% colnames(X))], collapse=", "), "column(s) not found in data frame"))
  } else stop("X is not a data frame")
  
  #if there are NAs in start or end stop
  if(any(is.na(c(end, start)))) stop("NAs found in start and/or end")  
  
  #if end or start are not numeric stop
  if(all(class(end) != "numeric" & class(start) != "numeric")) stop("'end' and 'selec' must be numeric")
  
  #if any start higher than end stop
  if(any(end - start<0)) stop(paste("The start is higher than the end in", length(which(end - start<0)), "case(s)"))  
  
  #if any selections longer than 20 secs stop
  if(any(end - start>20)) stop(paste(length(which(end - start>20)), "selection(s) longer than 20 sec"))  
  options( show.error.messages = TRUE)
  
  #if it argument is not "jpeg" or "tiff" 
  if(!any(it == "jpeg", it == "tiff")) stop(paste("Image type", it, "not allowed"))  
  
  #return warning if not all sound files were found
  recs.wd <- list.files(path = getwd(), pattern = ".wav$", ignore.case = T)
  if(length(unique(sound.files[(sound.files %in% recs.wd)])) != length(unique(sound.files))) 
    (paste(length(unique(sound.files))-length(unique(sound.files[(sound.files %in% recs.wd)])), 
                  ".wav file(s) not found"))
  
  #count number of sound files in working directory and if 0 stop
  d <- which(sound.files %in% recs.wd) 
  if(length(d) == 0){
    stop("The .wav files are not in the working directory")
  }  else {
    start <- start[d]
    end <- end[d]
    selec <- selec[d]
    sound.files <- sound.files[d]
  }
  
  if(propwidth) picsize <- 1
  
  # If parallel is not numeric
  if(!is.numeric(parallel)) stop("'parallel' must be a numeric vector of length 1") 
  if(any(!(parallel %% 1 == 0),parallel < 1)) stop("'parallel' should be a positive integer")
  
  #if parallel in OSX
  if(all(parallel > 1, !Sys.info()[1] %in% c("Linux","Windows"))) {
    parallel <- 1
    ("creating images is not compatible with parallel computing (parallel > 1) in OSX (mac)")
  }
  
  # If parallel was called
  if(parallel > 1)
  { options(warn = -1)
     
       
        if(Sys.info()[1] == "Windows"){ 
           
          lapp <- pbapply::pblapply} else lapp <- function(X, FUN) parallel::mclapply(X, FUN, mc.cores = parallel)} else lapp <- pbapply::pblapply
  
  options(warn = 0)
  
  # Create spectrograms overlaid with start and end times from manualoc()
  if(parallel == 1) ("Creating spectrograms from selections:")
  
  
  invisible(lapp(1:length(sound.files), function(i){
    
    # Read sound files, initialize frequency and time limits for spectrogram
    r <- tuneR::readWave(file.path(getwd(), sound.files[i]), header = T)
    f <- r$sample.rate
    t <- c(start[i] - mar, end[i] + mar)
    
    mar1 <- mar
    mar2 <- mar1 + end[i] - start[i]
    
    if (t[1] < 0) { 
      mar1 <- mar1  + t[1]
      mar2 <- mar2  + t[1]
      t[1] <- 0
    }
    
    if(t[2] > r$samples/f) t[2] <- r$samples/f
    
    fl<- flim #in case flim its higher than can be due to sampling rate
    if(fl[2] > ceiling(f/2000) - 1) fl[2] <- ceiling(f/2000) - 1 
    
    
    # Spectrogram width can be proportional to signal duration
    if(propwidth){
      if(it == "tiff")  tiff(filename = paste(sound.files[i],"-", selec[i], "-", ".tiff", sep = ""), 
                             width = (10.16) * ((t[2]-t[1])/0.27) * xl * picsize, height = (10.16) * picsize, units = "cm", res = res) else
                               jpeg(filename = paste(sound.files[i],"-", selec[i], "-", ".jpeg", sep = ""), 
                                    width = (10.16) * ((t[2]-t[1])/0.27) * xl * picsize, height = (10.16) * picsize, 
                                    units = "cm", res = res) 
      
    } else {
      if(it == "tiff")  tiff(filename = paste(sound.files[i],"-", selec[i], "-", ".tiff", sep = ""), 
                             width = (10.16) * xl * picsize, height = (10.16) * picsize, units = "cm", res = res) else
                               jpeg(filename = paste(sound.files[i],"-", selec[i], "-", ".jpeg", sep = ""), 
                                    width = (10.16) * xl * picsize, height = (10.16) * picsize, units = "cm", res = res)
    }
    
    # Change relative heights of rows for spectrogram when osci = TRUE
    if(osci) hts <- c(3, 2) else hts <- NULL
    
    # Change relative widths of columns for spectrogram when sc = TRUE
    if(sc) wts <- c(3, 1) else wts <- NULL
    
    old.par <- par(no.readonly = TRUE) # par settings which could be changed.
    on.exit(par(old.par)) 
    
    # Change inner and outer plot margins
    par(mar = inner.mar)
    par(oma = outer.mar)
    
    # Generate spectrogram using seewave 
    seewave::spectro(tuneR::readWave(as.character(sound.files[i]), from = t[1], to = t[2], units = "seconds") , f = f, wl = wl, ovlp = ovlp, collevels = seq(-40, 0, 0.5), heights = hts, wn = "hanning", 
                     widths = wts, palette = pal, osc = osci, grid = gr, scale = sc, collab = "black", 
                     cexlab = cexlab, cex.axis = 1, flim = fl, tlab = "Time (s)", 
                     flab = "Frequency (kHz)", alab = "", trel = FALSE)
    
    # Add title to spectrogram
    if(title) if(!is.na(selcom[i]))
      title(paste(sound.files[i], "-", selec[i], "-", selcom[i], sep = ""), cex.main = cexlab) else
        title(paste(sound.files[i], "-", selec[i], sep = ""), cex.main = cexlab)
    
    # Plot lines to visualize selections (start and end of signal)
        abline(v = c(mar1, mar2), col = "red", lwd = 3, lty = "dashed")
    invisible() # execute par(old.par) 
    dev.off()
  }
  ))
}
