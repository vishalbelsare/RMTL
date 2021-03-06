\name{MTC_Trace}
\alias{MTC_Trace}

\title{
Multi-task classification with low-rank structure
}

\description{
  This formulation constraints all models to a low-rank subspace. With
  increasing  penalty(\eqn{\lambda_1}), the correlation between models increases.
}

\usage{
MTC_Trace(X, Y, ...)
}

\arguments{
  \item{X}{
    a set of feature matrixes
}
  \item{Y}{
    a set of binary responses \eqn{\in \{-1,1\}}
}
  \item{Lam1}{
    a positive constant (\eqn{\lambda_1}) to constraint the rank
    of \eqn{W}. The default is 0.01 
}
  \item{lam2}{
    a positive constant (\eqn{\lambda_2}) to improve the
    generalization performance. The default is 0
}
  \item{opts}{
    options of the solver. The default is
    \code{list(init = 0, tol = 10^-3, maxIter = 1000)}
}
}

\details{
  \deqn{\min\limits_{W,C}
  \sum_{i}^{t}{\frac{1}{n_i}sum(log(1+e^{<-Y_i^T, X_iW_i+C_i>}))} +
  \lambda_1||W||_* + \lambda_2||W||_F^2 }

  \eqn{X} and \eqn{Y} are the sets of feature matrixes and binary responses respectively, 
  \eqn{W} is the coefficient matrix, and
  \eqn{t} is the number of tasks. Accordingly, \eqn{Y_i}, \eqn{X_i}, \eqn{W_i}
  and \eqn{n_i} refer to the  data, model parameter set and
  the number of subjects for task \eqn{i}. Note \eqn{W_i}
  is the \eqn{i}th column of \eqn{W}, and \eqn{C_i} is the \eqn{i}th
  term of \eqn{C}. \eqn{||\circ||_F} is the Frobenius norm. \eqn{||W||_*}
  is the trace norm of \eqn{W}.
}

\value{
  The function will return a trained MTC_Trace model
  \item{W}{a matrix of features' coefficients}
  \item{C}{a constant vector(intercept) of all models}
  \item{Obj}{historical record of objective values} 
  \item{fitted.values}{predictive scores(probability) of the training data.}
  \item{residuals}{the residuals of the training data. For each subject
  \eqn{i}, the residual is \eqn{y_i-\hat{y_i}}}
  \item{lam1}{\eqn{\lambda_1} value}
  \item{lam2}{\eqn{\lambda_2} value}
  \item{opts}{options of the solver}
  \item{dim}{size of feature matrix of each task}
  \item{features}{feature names}
}
\references{
Ji, S., & Ye, J. (2009, June). An accelerated gradient method for trace norm minimization. In Proceedings of the 26th annual international conference on machine learning (pp. 457-464). ACM.

Pong, T. K., Tseng, P., Ji, S., & Ye, J. (2010). Trace norm
regularization: Reformulations, algorithms, and multi-task learning. SIAM Journal on Optimization, 20(6), 3465-3489.
}

\author{han.cao@zi-mannheim.de}


\seealso{
 \code{\link{MTR_Trace}}
 \code{\link{cv.MTC_Trace}}
}

\examples{
####
#X, Y: training data
#tX, tY: test data
#W: ground truth
####
data(Simulated_Classification_Trace)

#specify parameters
opts=list(init=0,  tol=10^-6, maxIter=10000)
lam1=10^seq(2,-3, -0.05)

#perform cv
cv <- cv.MTC_Trace(X, Y, lam1=lam1, opts=opts)

#training with warm start
opt <- opts
for (i in 1: length(lam1)){
    r <- MTC_Trace(X, Y, lam1=lam1[i], opts=opt) 
    opt$init=1;
    opt$W0=r$W;
    opt$C0=r$C;
    if (lam1[i]==cv$lam1.min) break    
}

#predict on new dataset
predict(r, tX)

#compare the learnt model with the groud truth
par(mfrow=c(1,2))
library(fields)
image.plot(cor(W), xlab='tasks', ylab='tasks', main="ground truth")
image.plot(cor(opt$W0), xlab='tasks', ylab='tasks', main="Trace")

#extract more information about the model
print(r)
plotObj(r)
r$fitted.values
r$residuals
r$opts
r$features
r$dim
}

\keyword{ low-rank }
\keyword{ classification }
