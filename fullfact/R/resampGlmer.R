resampGlmer <-
function(resamp,dam,sire,response,fam_link,start,end,quasi=F) {
  if (missing(resamp)) stop("Need the resampled data frame")
  if (missing(dam)) stop("Need the dam column name")
  if (missing(sire)) stop("Need the sire column name")
  if (missing(response)) stop("Need the response column name")
  if (missing(fam_link)) stop("Need the family(link) for the glmer")
  if (missing(start)) stop("Need the starting model number")
  if (missing(end)) stop("Need the ending model number")
  print(time1<- Sys.time()) #start time
  if(paste(fam_link)[2]== "logit") { m_err<- (pi^2)/3 }
  if(paste(fam_link)[2]== "probit") { m_err<- 1 }
  if(paste(fam_link)[2]== "sqrt") { m_err<- 0.25 }
  response2<- colnames(resamp)[grep(paste(response), colnames(resamp))]
  dam2<- colnames(resamp)[grep(paste(dam), colnames(resamp))]
  sire2<- colnames(resamp)[grep(paste(sire), colnames(resamp))]
if (quasi == F)  {
  mod<- matrix(0,ncol=3,nrow=length(response2))   #variance of random effects
  res<- matrix(0,ncol=1,nrow=length(response2))   #for poisson(log)
 for (j in start:end) {
  print(paste("Working on model: ", j, sep=""))
  m<- glmer(formula= noquote(paste(response2[j],"~ (1|",dam2[j],") + (1|",sire2[j],") + (1|",dam2[j],":",sire2[j],")",sep="")),
    family=fam_link,data=resamp)
  mod[j,]<- colSums(diag(VarCorr(m)))
  if(paste(fam_link)[2]== "log") { res[j,]<- log(1/exp(fixef(m)[1]) + 1) }
  col_names<- as.data.frame(VarCorr(m))$grp; rm(m)   } }
if (quasi == T)  {
  mod<- matrix(0,ncol=4,nrow=length(response2))   #variance of random effects + quasi
  res<- matrix(0,ncol=1,nrow=length(response2))   #for poisson(log)
  resamp$dispersion<- as.factor(1:length(resamp[,1]))
 for (j in start:end) {
  print(paste("Working on model: ", j, sep=""))
  m<- glmer(formula=
    noquote(paste(response2[j],"~ (1|",dam2[j],") + (1|",sire2[j],") + (1|",dam2[j],":",sire2[j],") + (1|dispersion)",sep="")),
    family=fam_link,data=resamp)
  mod[j,]<- colSums(diag(VarCorr(m)))
  if(paste(fam_link)[2]== "log") { res[j,]<- log(1/exp(fixef(m)[1]) + 1) }
  col_names<- as.data.frame(VarCorr(m))$grp; rm(m)   } }
   if(paste(fam_link)[2]!= "log") { comp<- as.data.frame(cbind(mod,m_err)) }
   if(paste(fam_link)[2]== "log") { comp<- as.data.frame(cbind(mod,res)) }
   colnames(comp)<- c(col_names,"Residual")
   comp$Total<- rowSums(comp)
colnames(comp)<- gsub(end,'', colnames(comp))
  colnames(comp)[which(colnames(comp)==dam)]<- "dam"
  colnames(comp)[which(colnames(comp)==sire)]<- "sire"
  colnames(comp)[which(colnames(comp)==noquote(paste(dam,":",sire,sep="")))]<- "dam:sire"
  colnames(comp)[which(colnames(comp)==noquote(paste(dam,".",sire,sep="")))]<- "dam:sire" #weird period sometimes
  comp$additive<- 4*comp$sire
  comp$nonadd<- 4*comp$'dam:sire'
  comp$maternal<- comp$dam- comp$sire
   print(Sys.time()- time1) #end time
   invisible(comp)  #after time
}
