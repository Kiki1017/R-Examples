    ols<-function(formula,data,contrasts,number.perms=5000,quant,
test=FALSE,all.quants=FALSE,weights){
  Call<-match.call()
  temp<-as.list(Call)
  temp[[1]]<-as.name("lad")
  temp$OLS<-TRUE
  olsOut<-eval(as.call(temp))
  olsOut@Call=Call
  olsOut
  }