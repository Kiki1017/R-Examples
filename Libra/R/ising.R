#' Linearized Bregman solver for composite conditionally likelihood of Ising model 
#'  with lasso penalty.
#' 
#' Solver for the entire solution path of coefficients.
#' 
#' The data matrix X is assumed in \{1,-1\}. The Ising model here used is described as following:\cr
#' \deqn{P(x) \sim \exp(\sum_i \frac{a_{0i}}{2}x_i + x^T \Theta x/4)}\cr
#' where \eqn{\Theta} is p-by-p symmetric and 0 on diagnal. Then conditional on \eqn{x_{-j}}\cr
#' \deqn{\frac{P(x_j=1)}{P(x_j=-1)} = exp(\sum_i a_{0i} + \sum_{i\neq j}\theta_{ji}x_i)}\cr
#' then the composite conditional likelihood is like this:\cr
#' \deqn{- \sum_{j} condloglik(X_j | X_{-j})}
#' 
#' @param X An n-by-p matrix of variables.
#' @param kappa The damping factor of the Linearized Bregman Algorithm that is
#'  defined in the reference paper. See details. 
#' @param alpha Parameter in Linearized Bregman algorithm which controls the 
#' step-length of the discretized solver for the Bregman Inverse Scale Space. 
#' See details. 
#' @param c Normalized step-length. If alpha is missing, alpha is automatically generated by 
#' \code{alpha=c*n/(kappa*||X^T*X||_2)}. Default is 2. It should be in (0,4).
#' If beyond this range the path may be oscillated at large t values.
#' @param intercept if TRUE, an intercept is included in the model (and not 
#' penalized), otherwise no intercept is included. Default is TRUE.
#' @param tlist Parameters t along the path.
#' @param responses The type of data. c(0,1) or c(-1,1), Default is c(-1,1).
#' @param nt Number of t. Used only if tlist is missing. Default is 100.
#' @param trate tmax/tmin. Used only if tlist is missing. Default is 100.
#' @param print If TRUE, the percentage of finished computation is printed.
#' @return A "ising" class object is returned. The list contains the call, 
#'  the path, the intercept term a0 and value for alpha, kappa, t.
#' @author Jiechao Xiong
#' @keywords regression
#' @examples
#' 
#' library('Libra')
#' library('igraph')
#' data('west10')
#' X <- as.matrix(2*west10-1);
#' obj = ising(X,10,0.1,nt=1000,trate=100)
#' g<-graph.adjacency(obj$path[,,770],mode="undirected",weighted=TRUE)
#' E(g)[E(g)$weight<0]$color<-"red"
#' E(g)[E(g)$weight>0]$color<-"green"
#' V(g)$name<-attributes(west10)$names
#' plot(g,vertex.shape="rectangle",vertex.size=35,vertex.label=V(g)$name,
#' edge.width=2*abs(E(g)$weight),main="Ising Model (LB): sparsity=0.51")

ising <- function(X, kappa, alpha,c = 2, tlist,responses=c(-1,1),nt = 100,trate = 100, intercept = TRUE,print=FALSE) 
{
  np <- dim(X)
  n <- np[1]
  p <- np[2]
  
  if (missing(tlist)) tlist<-rep(-1.0,nt)
  else nt<-length(tlist)
  
  if (any(responses != c(-1,1))){
    if (all(responses == c(0,1)))
      X <- 2*X-1
    else
      stop("responses must be c(-1,1) or c(0,1)")
  }
  
  if (missing(alpha)){
    meanx <- drop(rep(1,n) %*% X)/n
    tempX <- scale(X, meanx, FALSE)
    sigma <- norm(tempX,"2")
    alpha <- c*n/kappa/sigma^2
  }
  
	intercept <- as.integer(intercept != 0)
	result_r <- vector(length = nt * p*(p + intercept))
	solution <- .C("ising",
		as.numeric(X),
		as.integer(n),
		as.integer(p),
		as.numeric(kappa),
		as.numeric(alpha),
		as.numeric(result_r),
		as.integer(intercept),
		as.numeric(tlist),
		as.integer(nt),
		as.numeric(trate),
		as.integer(print!=0)
	)
	path <- sapply(0:(nt- 1), function(x)
	  matrix(solution[[6]][(1+x*p*(p+intercept)):((x+1)*p*(p+intercept))], p, p+intercept),simplify = "array")
	
	if (intercept){
	  a0 <- path[,p+1,,drop=TRUE]
	  path <- path[,-(p+1),,drop=FALSE]
	}else{
	  a0 <- matrix(0,p,length(nt))
	}
	object <- list(call = call,family="ising", kappa = kappa, alpha = alpha, path = path, nt = nt,t=solution[[8]],a0=a0)
	class(object) <- "ising"
	object
}
