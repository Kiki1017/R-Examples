#' @export
#' @importFrom utils head tail 
#' @importFrom graphics par axis title plot rect legend
#' @importFrom mhsmm simulate.hmmspec hmmspec dnorm.hsmm rnorm.hsmm
#' @importFrom zoo rollmean rollsum rollmedian
#' @importFrom PhysicalActivity dataCollapser
accSummary <- function(data, tri='FALSE', axis='NULL',
                       spuriousDef=20, nonwearDef=60, minWear=600, 
                       patype=c('MVPA'),pacut=c(1952), 
                       boutsize=10, tolerance='TRUE', returnbout='TRUE'){
  
  if(tri=='TRUE' & is.null(axis)){stop("Please choose an option for 'axis'. Choose from options 'vm', 'sum', 'x', 'y', or 'z'.")}
  if(tri=='TRUE' & !is.null(axis)){
    if(axis=='vm'){data$counts <- sqrt(data[,2]^2+data[,3]^2+data[,4]^2)}
    if(axis=='sum'){data$counts <- sqrt(data[,2]+data[,3]+data[,4])}
    if(axis=='x'){data$counts <- data[,2]}
    if(axis=='y'){data$counts <- data[,3]}
    if(axis=='z'){data$counts <- data[,4]}
  }
  
  if(length(patype)>1){
    stop("Please specify one patype. Please use function acc to obtain summary for multiple physical activities")}
  
  epoch <- mean(c(as.numeric(difftime(strptime(data$TimeStamp[2],format='%Y-%m-%d %H:%M:%S'),
                               strptime(data$TimeStamp[1],format='%Y-%m-%d %H:%M:%S'),
                               units = c("secs"))),
           as.numeric(difftime(strptime(data$TimeStamp[3],format='%Y-%m-%d %H:%M:%S'),
                               strptime(data$TimeStamp[2],format='%Y-%m-%d %H:%M:%S'),
                               units = c("secs"))),
           as.numeric(difftime(strptime(data$TimeStamp[4],format='%Y-%m-%d %H:%M:%S'),
                               strptime(data$TimeStamp[3],format='%Y-%m-%d %H:%M:%S'),
                               units = c("secs")))),na.rm=TRUE)
  
  if(epoch<60){data <- dataCollapser(data, TS = "TimeStamp", col = "counts", by = 60)}
  if(epoch>60){stop("Epoch is larger than 60 seconds. Please provide a dataset with epoch of 1 minutes or less")}
  
  value  <- rep(rle(as.numeric(data$counts))$values, 
                rle(as.numeric(data$counts))$lengths)
  length <- rep(rle(as.numeric(data$counts))$lengths, 
                rle(as.numeric(data$counts))$lengths)
  d1.lag <- cbind(data,value,length,
                  head=head(c(0,length),-1),
                  tail=tail(c(length,0),-1),
                  dif1=head(c(0,length),-1)-length,
                  dif2=tail(c(length,0),-1)-length,
                  actb=head(c(0,data$counts),-1),
                  acta=tail(c(data$counts,0),-1))
  spDef <- spuriousDef -1
  d1s <- cbind(d1.lag,spurious=ifelse(d1.lag$dif1>=spDef & d1.lag$dif2>=spDef & 
                                        d1.lag$actb==0 & d1.lag$acta==0,1,0))
  d1s$counts2 <- ifelse(d1s$spurious==1, 0, d1s$counts) 
  d2 <- data.frame(TimeStamp=d1s$TimeStamp,counts=d1s$counts2)
  value2  <- rep(rle(as.numeric(d2$counts))$values, 
                 rle(as.numeric(d2$counts))$lengths)
  length2 <- rep(rle(as.numeric(d2$counts))$lengths, 
                 rle(as.numeric(d2$counts))$lengths)
  d2w <- cbind(d2,value2,length2)
  nonwear <- ifelse(d2w$value2 == 0 & d2w$length > nonwearDef, 1, 0)
  d2nw <- cbind(d2w,nonwear)
  d3 <- data.frame(TimeStamp = d2nw$TimeStamp, counts = d2nw$counts, nonwear = d2nw$nonwear)
  d3$countsWear <- ifelse(d3$nonwear == 1, NA, d3$counts)
  d3$mydates <- as.factor(as.numeric(strptime(d3$TimeStamp,format='%Y-%m-%d')))
  uniqueDates <- unique(strptime(d3$TimeStamp,format='%Y-%m-%d'))
  
  # Summarizing wear time
  d3$wear <- ifelse(d3$nonwear==1,0,1)
  dts <- strptime(d3$TimeStamp,format='%Y-%m-%d %H:%M:%S')
  wearSum <- tapply(d3$wear, format(dts, format="%Y-%m-%d"), sum)
  wearTime <- data.frame(Date=names(wearSum), wearTime = wearSum)
  
  if(tolerance=='TRUE'){tolerance <- 2}
  if(tolerance=='FALSE'){tolerance <- 0}
  
  value  <- rep(rle(as.numeric(data$counts))$values, 
                rle(as.numeric(data$counts))$lengths)
  length <- rep(rle(as.numeric(data$counts))$lengths, 
                rle(as.numeric(data$counts))$lengths)
  
  d1.lag <- cbind(data,value,length,
                  head=head(c(0,length),-1),
                  tail=tail(c(length,0),-1),
                  dif1=head(c(0,length),-1)-length,
                  dif2=tail(c(length,0),-1)-length,
                  actb=head(c(0,data$counts),-1),
                  acta=tail(c(data$counts,0),-1))
  spDef <- spuriousDef -1
  d1s <- cbind(d1.lag,spurious=ifelse(d1.lag$dif1>=spDef & d1.lag$dif2>=spDef & 
                                        d1.lag$actb==0 & d1.lag$acta==0,1,0))
  d1s$counts2 <- ifelse(d1s$spurious==1, 0, d1s$counts) 
  d2 <- data.frame(TimeStamp=d1s$TimeStamp,counts=d1s$counts2)
  value2  <- rep(rle(as.numeric(d2$counts))$values, 
                 rle(as.numeric(d2$counts))$lengths)
  length2 <- rep(rle(as.numeric(d2$counts))$lengths, 
                 rle(as.numeric(d2$counts))$lengths)
  d2w <- cbind(d2,value2,length2)
  nonwear <- ifelse(d2w$value2 == 0 & d2w$length > nonwearDef, 1, 0)
  d2nw <- cbind(d2w,nonwear)
  d3 <- data.frame(TimeStamp = d2nw$TimeStamp, counts = d2nw$counts, nonwear = d2nw$nonwear)
  d3$countsWear <- ifelse(d3$nonwear == 1, NA, d3$counts)
  d3$inPA <- ifelse(d3$countsWear >= as.numeric(pacut[1]) & d3$countsWear <= as.numeric(pacut[2]), 1, 0) 
  d3$inPA2 <- ifelse(is.na(d3$countsWear), 0, d3$inPA)
  d3$mydates <- as.factor(as.numeric(strptime(d3$TimeStamp,format='%Y-%m-%d')))
  uniqueDates <- unique(strptime(d3$TimeStamp,format='%Y-%m-%d'))
  
  myRollSum<- function(x, k) { 
    rs <- rollsum(x, k)
    rsp <- c(rs,rep(NA,k-1))
    return(rsp)
  }
  
  myLag<- function(x, k) {
    c(rep(NA, k), x)[1 : length(x)] 
  }
  
  myLagUp<- function(x, k) {
    c(x[(k+1): (length(x))],rep(NA,k))
  }
  
  mybPA <- boutsize - tolerance
  
  
  ##
  ## Get bout calculations by day: PA time
  ##
  
  mylistPA <- list() 
  dSplitPA <- split(d3,d3$mydates)    
  
  for(k in 1:length(dSplitPA)){
    dsiPA <- data.frame(dSplitPA[k]) 
    dsidPA <- data.frame(TimeStamp = dsiPA[,1], counts = dsiPA[,2], nonwear = dsiPA[,3], inPA2 = dsiPA[,6])
    dsidPA$mvpaB <- myRollSum(dsidPA$inPA2, boutsize)
    dsidPA$mvB <- ifelse(dsidPA$mvpaB >= mybPA, 1, 0)
    
    suppressWarnings(rm(bm))
    bm <- matrix(NA, nrow = nrow(dsidPA), ncol = (boutsize+1))
    bm[,1] <- dsidPA$mvB
    
    for(i in 1:(boutsize-1)){
      bm[,(i+1)] <- myLag(dsidPA$mvB,i)
    }
    
    bm[,ncol(bm)] <- rowSums(bm[,1:(ncol(bm)-1)], na.rm=TRUE)  
    
    dsidPA$inbout <- ifelse(bm[,ncol(bm)]>=1, 1, 0)   
    
    dsidPA$inboutLagb1 <- myLag(dsidPA$inbout,1)
    dsidPA$inboutLagb2 <- myLag(dsidPA$inbout,2)
    dsidPA$PALagb1 <- myLag(dsidPA$inPA2,1)
    dsidPA$inboutUpLagb1 <- myLagUp(dsidPA$inbout,1)
    dsidPA$inboutUpLagb2 <- myLagUp(dsidPA$inbout,2)
    dsidPA$PALagUpb1 <- myLagUp(dsidPA$inPA2,1)
    
    dsidPA$inbout[dsidPA$inbout==1 & dsidPA$inboutLagb1==0 & dsidPA$inPA2==0] <- 0    
    dsidPA$inbout[dsidPA$inbout==1 & dsidPA$inboutLagb2==0 & dsidPA$PALagb1==0 & dsidPA$inPA2==0] <- 0 
    
    dsidPA$inbout[dsidPA$inbout==1 & dsidPA$inboutUpLagb1==0 & dsidPA$inPA2==0] <- 0    
    dsidPA$inbout[dsidPA$inbout==1 & dsidPA$inboutUpLagb2==0 & dsidPA$PALagUpb1==0 & dsidPA$inPA2==0] <- 0 
    
    dsidPA$value  <- rep(rle(as.numeric(dsidPA$inbout))$values, 
                         rle(as.numeric(dsidPA$inbout))$lengths)
    dsidPA$length <- rep(rle(as.numeric(dsidPA$inbout))$lengths, 
                         rle(as.numeric(dsidPA$inbout))$lengths)
    dsidPA$valueLag <- myLag(dsidPA$value)
    dsidPA$lengthLag <- myLag(dsidPA$length)
    dsidPA$first <- ifelse(dsidPA$value == dsidPA$valueLag & dsidPA$length == dsidPA$lengthLag , 0, 1)
    dsidPA$first[1] <- ifelse(dsidPA$inbout[1] == 1, 1, 0)
    dsidPA$wear <- ifelse(dsidPA$nonwear==0,1,0)
    dsidPA$firstBout <- ifelse(dsidPA$first == 1& dsidPA$inbout == 1 & dsidPA$wear == 1 & dsidPA$length>=boutsize, 1, 0)
    mylistPA[[k]] <- dsidPA
    rm(dsidPA)
  }
  dfPA <- do.call("rbind",mylistPA) 
  boutsPA <- data.frame(TimeStamp = dfPA$TimeStamp, 
                        counts = dfPA$counts, 
                        inPA = dfPA$inPA2,
                        nonwear = dfPA$nonwear,
                        inboutPA = dfPA$inbout)
  
  dfPA$inPABout <- ifelse(dfPA$inbout==1 & dfPA$wear==1, 1, 0)
  d4.tempPA <- dfPA[ which(dfPA$firstBout==1 & dfPA$wear == 1), ]
  boutSumPA <- tapply(d4.tempPA$firstBout, format(strptime(d4.tempPA$TimeStamp,format='%Y-%m-%d %H:%M:%S'), format="%Y-%m-%d"), sum)
  numBoutsPA <- data.frame(Date=names(boutSumPA), numberOfBoutsPA = boutSumPA)
  d4PA <- data.frame(TimeStamp = d4.tempPA$TimeStamp, paMinutes = d4.tempPA$length) 
  dts2PA <- strptime(d4PA$TimeStamp,format='%Y-%m-%d %H:%M:%S')
  d4PA$Date <- format(dts2PA, format="%Y-%m-%d")
  d4PA$TimeStamp <- NULL
  daySumPA <- tapply(d4PA$paMinutes, format(dts2PA, format="%Y-%m-%d"), sum)  
  pasummary <- data.frame(Date = rownames(daySumPA), paMinutes = daySumPA, numberOfBoutsPA = boutSumPA)
  rownames(pasummary) <- NULL 
  if(nrow(pasummary)==0){pasummary <- data.frame(format(dfPA$TimeStamp[1], format="%Y-%m-%d"),matrix(rep(NA,2),ncol=2))}
  mycolname1 <- paste(patype,".minutes",sep="")
  mycolname2 <- paste(patype,".num.bouts",sep="")
  colnames(pasummary) <- c('Date',mycolname1,mycolname2)
  
  summarized <- list()
  summarized$validDates <- pasummary
  summarized$wearTime <- wearTime
  
  summary <- Reduce(function(...) merge(..., all=TRUE),summarized)
  summary[is.na(summary)] <- 0
  summary <- summary[ which(summary$wearTime>=minWear), ]
  
  if(returnbout=='FALSE'){return(summary)}
  
  if(returnbout=='TRUE'){
    summarized <- list()
    summarized$totalDates <- uniqueDates
    summarized$validDates <- summary
    summarized$PA <- boutsPA
    return(summarized)
  }
  
}