getCVPartition <- function(Y, cv_fold, stratify){
task_num = length(Y);

cvPar = {};
for (cv_idx in 1: cv_fold){
    # buid cross validation data splittings for each task.
    cvTrain = {};
    cvTest = {};

    randIdx <- lapply(Y, function(x) sample(1:length(x),
                   length(x), replace = FALSE))        
        
    #stratified cross validation
    for (t in 1: task_num){
        task_sample_size <- length(Y[[t]]);

        if (stratify){
            ct <- which(Y[[t]][randIdx[[t]]]<1);
            cs <- which(Y[[t]][randIdx[[t]]]>=1);
            ct_idx <- seq(cv_idx, length(ct), cv_fold);
            cs_idx <- seq(cv_idx, length(cs), cv_fold);
            te_idx <- c(ct[ct_idx], cs[cs_idx]);
            tr_idx <- seq(1,task_sample_size)[
                !is.element(1:task_sample_size, te_idx)];

        } else {
            te_idx <- seq(cv_idx, task_sample_size, by=cv_fold)
            tr_idx <- seq(1,task_sample_size)[
                !is.element(1:task_sample_size, te_idx)];

        }

        cvTrain[[t]] = randIdx[[t]][tr_idx]
        cvTest[[t]] = randIdx[[t]][te_idx]

   }
    
    cvPar[[cv_idx]]=list(cvTrain, cvTest);
}
return(cvPar)
}

