library(tidyverse)
library(readr)
library(stringr)

##########################################
#dstbelnmr
data_generating_process = "dstm"
simCount = 8
##########################################

datadir = paste0("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp/parameter_recovery/", data_generating_process)

check_model_performance <- function(datadir, condition) {
    for (sim in 1:simCount){

        fit = data.frame(read.csv(file=file.path(datadir, paste0(condition, "_fit_",sim,".csv"))))

        modeltxt = read_file(file.path(datadir, paste0(condition, "_model_",sim,".txt")))
        modeltxt = as.numeric(unlist(regmatches(modeltxt,gregexpr("(?>-)*[[:digit:]]+\\.*[[:digit:]]*",modeltxt, perl=TRUE))))
        model = data.frame(d=modeltxt[9], sigma=modeltxt[6], theta=modeltxt[11], bias=modeltxt[8], eta=modeltxt[7], lambda=modeltxt[10], nonDecisionTime=modeltxt[5], minValue=modeltxt[4], range=modeltxt[2])

        ind = fit$d==model$d & fit$sigma==model$sigma
        if (toString(fit$theta)!="") {ind = ind & fit$theta==model$theta}
        if (toString(fit$bias)!="") {ind = ind & fit$bias==model$bias}
        if (toString(fit$eta)!="") {ind = ind & fit$eta==model$eta}
        if (toString(fit$lambda)!="") {ind = ind & fit$lambda==model$lambda}
        if (toString(fit$nonDecisionTime)!="") {ind = ind & fit$nonDecisionTime==model$nonDecisionTime}
        if (toString(fit$minValue)!="") {ind = ind & fit$minValue==model$minValue}
        if (toString(fit$range)!="") {ind = ind & fit$range==model$range}

        print(fit[ind,])
    }
}

# Print
print(paste0("== ", data_generating_process, " =="))
print("= Gain =")
check_model_performance(datadir, "Gain")
print("= Loss =")
check_model_performance(datadir, "Loss")

# Write
sink(file.path(datadir, "summary.txt"))
print(paste0("== ", data_generating_process, " =="))
print("= Gain =")
check_model_performance(datadir, "Gain")
print("= Loss =")
check_model_performance(datadir, "Loss")
sink()
