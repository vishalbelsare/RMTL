LS_Lasso <- function (X, Y, lam1, lam2, opts){
#------------------------------------------------------
# private functions
l1_projection <- function (W, lambda ){
p <- abs(W) - lambda/2
p[p<0] <- 0
Wp <- sign(W) * p
return(Wp)
}

gradVal_eval <- function (W){
grad_W <- sapply(c(1:task_num),
    function(x) t(X[[x]]) %*% (X[[x]] %*% W[,x]-Y[[x]]) / nrow(X[[x]]))
return(grad_W + 2* lam2 * W)
}

funVal_eval <- function (W){
return(sum(sapply(c(1:task_num),
    function(x) 0.5 * mean((Y[[x]] - X[[x]] %*% W[,x])^2))) +
    lam2 * norm(W, 'f')^2)
}

nonsmooth_eval <- function (W, lam1){
return(lam1*sum(abs(W)))
}
#-------------------------------------------------------    

# Main algorithm
task_num <- length (X);
dimension = dim(X[[1]])[2];
Obj <- vector(); 

#precomputation
XY <- lapply(c(1:task_num), function(x)t(X[[x]]) %*% Y[[x]])
    
#initialize a starting point
if(opts$init==0){
   W0 <- matrix(0, nrow=dimension, ncol=task_num);
}else if(opts$init==1){
   W0 <- opts$W0
}    

bFlag <- 0; 
Wz <- W0;
Wz_old <- W0;

t <- 1;
t_old <- 0;
iter <- 0;
gamma <- 1;
gamma_inc <- 2;

while (iter < opts$maxIter){
    alpha <- (t_old - 1) /t;
    
    Ws <- (1 + alpha) * Wz - alpha * Wz_old;
    # compute function value and gradients of the search point
    gWs <- gradVal_eval(Ws);
    Fs <- funVal_eval(Ws)


    # the Armijo Goldstein line search scheme
    while (TRUE){
        Wzp <- l1_projection(Ws - gWs/gamma, 2 * lam1 / gamma);
        Fzp <- funVal_eval(Wzp);
        
        delta_Wzp <- Wzp - Ws;
        r_sum <- norm(delta_Wzp, 'f')^2;
        
        Fzp_gamma = Fs + sum(delta_Wzp* gWs) + 
            + gamma/2 * r_sum;
        
        if (r_sum <=1e-20){
            bFlag=1; 
            break;
        }
        
        if (Fzp <= Fzp_gamma) break else {gamma = gamma * gamma_inc}
  
    }
    
    Wz_old = Wz;
    Wz = Wzp;
    Obj = c(Obj, Fzp + nonsmooth_eval(Wz, lam1));
    
    
    #test stop condition.
    if (bFlag) break;
    if (iter>=2){
        if (abs( Obj[length(Obj)] - Obj[length(Obj)-1] ) <= opts$tol)
            break;
    }
    
    iter = iter + 1;
    t_old = t;
    t = 0.5 * (1 + (1+ 4 * t^2)^0.5);

}
W = Wzp;
return(list(W=W, Obj=Obj))
}

MTR_Lasso <- function(X, Y, ...) UseMethod("MTR_Lasso")

MTR_Lasso.default <- function(X, Y, lam1=1, lam2=0,
        opts=list(init=0,  tol=10^-3, maxIter=1000)){
    task_num <- length(X)
    features <- colnames(X[[1]])
    X <- lapply(X, function(x) as.matrix(x))
    Y <- lapply(Y, function(x) as.numeric(x))

    r <- LS_Lasso(X, Y, lam1, lam2, opts)
    r$fitted.values <- lapply(c(1:task_num), function(x) X[[x]] %*% r$W[,x])
    r$residuals <-lapply(c(1:task_num),
        function(x) Y[[x]] - r$fitted.values[[x]])
    r$call <- match.call()
    r$lam1 <- lam1
    r$lam2 <- lam2
    r$opts <- opts
    r$dim <- sapply(X, function(x)dim(x))
    r$features <- features
    class(r) <- "MTR_Lasso"
    return(r)
}

print.MTR_Lasso <- function(x)
{

    cat("\nHead Coefficients:\n")
    print(head(x$W))
    cat("Call:\n")
    print(x$call)
    cat("Formulation:\n")
    print('SUM_i Loss_i(W) + lam1*||W||_1 + lam2*||W||{_2}{^2}')
}

predict.MTR_Lasso <- function(m, newdata=NULL)
{
    if(is.null(newdata))
        y <- m$fitted.values
    else{
        task_num <- length(newdata)
        y <- lapply(c(1:task_num),
        function(x) newdata[[x]] %*% m$W[,x])
    }
    return(y)
}

cv.MTR_Lasso <- function(X, Y, lam2=0, 
             opts=list(init=0, tol=10^-3, maxIter=1000),
             nfolds=5,lam1=10^seq(3,-2, -1)){
task_num <- length(X)
X <- lapply(X, function(x) as.matrix(x))
Y <- lapply(Y, function(x) as.numeric(x))

cvPar <- getCVPartition(Y, nfolds, FALSE)
cvm <- rep(0, length(lam1));

#cv
for (i in 1:nfolds){
    cv_Xtr <- lapply(c(1:task_num),
                     function(x) X[[x]][cvPar[[i]][[1]][[x]], ])
    cv_Ytr <- lapply(c(1:task_num),
                     function(x) Y[[x]][cvPar[[i]][[1]][[x]]])
    cv_Xte <- lapply(c(1:task_num),
                     function(x) X[[x]][cvPar[[i]][[2]][[x]], ])
    cv_Yte <- lapply(c(1:task_num),
                     function(x) Y[[x]][cvPar[[i]][[2]][[x]]])


    cv_opt <- opts;
    for (p_idx in 1: length(lam1)){
        W <- LS_Lasso(cv_Xtr, cv_Ytr, lam1[p_idx], lam2, cv_opt)$W
        cv_opt$init=1;
        cv_opt$W0=W;
        cvm[p_idx] = cvm[p_idx]+
            mean(sapply(c(1:task_num),
            function(x)mean((cv_Xte[[x]] %*% W[,x]-cv_Yte[[x]])^2)))
    }
}
cvm = cvm/nfolds
best_idx <- which(cvm==min(cvm))[1]
cv <- list(lam1=lam1, lam1.min=lam1[best_idx], lam2=lam2, cvm=cvm)
class(cv) <- "cv.MTR_Lasso"
return(cv)
}

plot.cv.MTR_Lasso <- function(x){
plot(log10(x$lam1), x$cvm, xlab="log10(lambda1)", ylab="error")
}
