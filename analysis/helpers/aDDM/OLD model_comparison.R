# This script will plot the model fits for all models.

# Preamble
rm(list=ls())
library(tidyverse)
library(effsize)
library(matrixTests)
figdir = "../../outputs/figures"
fitdir = "../../outputs/temp"
tempdir = "../../outputs/temp"
datadir = "../../../data/processed_data"
load(file.path(datadir, "ecfr.RData"))
load(file.path(datadir, "ccfr.RData"))
load(file.path(datadir, "jcfr.RData"))


###################
# FUNCTIONS
###################

# Get the individual likelihoods for a study-model-dataset.
read_likelihoods <- function(study="error", model="error", dataset="error") {
  gainFileName = paste0(study, "_", model, "_GainNLL_", dataset, ".csv")
  lossFileName = paste0(study, "_", model, "_LossNLL_", dataset, ".csv")
  gainFit = read.csv(file.path(fitdir, gainFileName), header=F)
  lossFit = read.csv(file.path(fitdir, lossFileName), header=F)
  likelihoods = data.frame(
    gain = gainFit[,1],
    loss = lossFit[,1])
  likelihoods$dataset = study
  return(likelihoods)}

# Make a list of dataframes containing the likelihoods across studies for a model-dataset.
NLLs_for_studies <- function(model, dataset) {
  df1 = read_likelihoods(study="dots", model=model, dataset=dataset)
  df2 = read_likelihoods(study="numeric", model=model, dataset=dataset)
  return(list(dots = df1, numeric = df2))}

# Given a vector of likelihoods, number of parameters and observations, calculate the AIC.
getAIC <- function(parameterCount, observationCount, loglikelihood) {
  #return( parameterCount*log(observationCount) - 2*loglikelihood )}
  return( parameterCount*2 - 2*loglikelihood )}

# Get the observationCount for each subject-condition in a study-dataset.
getObservationCount <- function(subject, condition, study, dataset) {
  if (dataset == "e") {cfr = ecfr}
  if (dataset == "c") {cfr = ccfr}
  if (dataset == "j") {cfr = jcfr}
  data = cfr[cfr$subject==subject & cfr$condition==condition & cfr$study==study & cfr$firstFix==T,]
  data = data[data$trial%%2==1,]
  return(nrow(data))}

# Loop through all subjects and make a list of AIC.
getAIC_all <- function(study, dataset, parameterCount, loglikelihoods) {
  if (dataset == "e") {cfr = ecfr}
  if (dataset == "c") {cfr = ccfr}
  if (dataset == "j") {cfr = jcfr}
  cfr = cfr[cfr$study==study,]
  gainAICs = c()
  lossAICs = c()
  ind = 1
  for (subject in unique(cfr$subject)) {
    observationCount = getObservationCount(subject, "Gain", study, dataset)
    gainAIC = getAIC(parameterCount, observationCount, loglikelihoods[[study]][["gain"]][[ind]])
    gainAICs[ind] = gainAIC
    observationCount = getObservationCount(subject, "Loss", study, dataset)
    lossAIC = getAIC(parameterCount, observationCount, loglikelihoods[[study]][["loss"]][[ind]])
    lossAICs[ind] = lossAIC
    ind = ind + 1}
  return(list(gain=gainAICs, loss=lossAICs))
}

# Matrix of t-tests
multi.ttest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- "1  "
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      test <- t.test(mat[, i] - mat[, j], ...)
      if (test$p.value < .05) {star="*"} else {star=" "}
      p.mat[j, i] <- paste0(
        "[",
        round(test$conf.int[1], 2),
        ", ",
        round(test$conf.int[2], 2),
        "] ",
        round(test$p.value,3),
        " ",
        star)}}
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  upper = p.mat
  upper[upper.tri(p.mat)]<-""
  as.data.frame(upper)}

###################
# Get individual likelihoods for each model-dataset
###################

aDDM_LLs = NLLs_for_studies("aDDM", "e")
addDDM_LLs = NLLs_for_studies("addDDM", "e")
DNaDDM_LLs = NLLs_for_studies("DNaDDM", "e")
RNaDDM_LLs = NLLs_for_studies("RNaDDM", "e")
RNPaDDM_LLs = NLLs_for_studies("RNPaDDM", "e")
DRNPaDDM_LLs = NLLs_for_studies("DRNPaDDM", "e")

NLL_to_LL = function(NLLs) {
  for (i in c(1:length(NLLs))) {
    NLLs[[i]][["gain"]] = -1*NLLs[[i]][["gain"]]
    NLLs[[i]][["loss"]] = -1*NLLs[[i]][["loss"]]}
  return(NLLs)}

aDDM_LLs = NLL_to_LL(aDDM_LLs)
addDDM_LLs = NLL_to_LL(addDDM_LLs)
DNaDDM_LLs = NLL_to_LL(DNaDDM_LLs)
RNaDDM_LLs = NLL_to_LL(RNaDDM_LLs)
RNPaDDM_LLs = NLL_to_LL(RNPaDDM_LLs)
DRNPaDDM_LLs = NLL_to_LL(DRNPaDDM_LLs)

###################
# Get AIC for each study-model-dataset
###################

dots_aDDM_AIC = getAIC_all(study="dots", dataset="e", parameterCount=4, loglikelihoods=aDDM_LLs)
dots_addDDM_AIC = getAIC_all(study="dots", dataset="e", parameterCount=4, loglikelihoods=addDDM_LLs)
dots_DNaDDM_AIC = getAIC_all(study="dots", dataset="e", parameterCount=4, loglikelihoods=DNaDDM_LLs)
dots_RNaDDM_AIC = getAIC_all(study="dots", dataset="e", parameterCount=4, loglikelihoods=RNaDDM_LLs)
dots_RNPaDDM_AIC = getAIC_all(study="dots", dataset="e", parameterCount=5, loglikelihoods=RNPaDDM_LLs)
dots_DRNPaDDM_AIC = getAIC_all(study="dots", dataset="e", parameterCount=5, loglikelihoods=DRNPaDDM_LLs)

numeric_aDDM_AIC = getAIC_all(study="numeric", dataset="e", parameterCount=4, loglikelihoods=aDDM_LLs)
numeric_addDDM_AIC = getAIC_all(study="numeric", dataset="e", parameterCount=4, loglikelihoods=addDDM_LLs)
numeric_DNaDDM_AIC = getAIC_all(study="numeric", dataset="e", parameterCount=4, loglikelihoods=DNaDDM_LLs)
numeric_RNaDDM_AIC = getAIC_all(study="numeric", dataset="e", parameterCount=4, loglikelihoods=RNaDDM_LLs)
numeric_RNPaDDM_AIC = getAIC_all(study="numeric", dataset="e", parameterCount=5, loglikelihoods=RNPaDDM_LLs)
numeric_DRNPaDDM_AIC = getAIC_all(study="numeric", dataset="e", parameterCount=5, loglikelihoods=DRNPaDDM_LLs)


###################
# Get AIC data ready for model comparison
###################

AICs_dotsGain = data.frame(
  aDDM = dots_aDDM_AIC$gain,
  addDDM = dots_addDDM_AIC$gain,
  DNaDDM = dots_DNaDDM_AIC$gain,
  RNaDDM = dots_RNaDDM_AIC$gain,
  RNPaDDM = dots_RNPaDDM_AIC$gain,
  DRNPaDDM = dots_DRNPaDDM_AIC$gain)

AICs_dotsLoss = data.frame(
  aDDM = dots_aDDM_AIC$loss,
  addDDM = dots_addDDM_AIC$loss,
  DNaDDM = dots_DNaDDM_AIC$loss,
  RNaDDM = dots_RNaDDM_AIC$loss,
  RNPaDDM = dots_RNPaDDM_AIC$loss,
  DRNPaDDM = dots_DRNPaDDM_AIC$loss)

AICs_numericGain = data.frame(
  aDDM = numeric_aDDM_AIC$gain,
  addDDM = numeric_addDDM_AIC$gain,
  DNaDDM = numeric_DNaDDM_AIC$gain,
  RNaDDM = numeric_RNaDDM_AIC$gain,
  RNPaDDM = numeric_RNPaDDM_AIC$gain,
  DRNPaDDM = numeric_DRNPaDDM_AIC$gain)

AICs_numericLoss = data.frame(
  aDDM = numeric_aDDM_AIC$loss,
  addDDM = numeric_addDDM_AIC$loss,
  DNaDDM = numeric_DNaDDM_AIC$loss,
  RNaDDM = numeric_RNaDDM_AIC$loss,
  RNPaDDM = numeric_RNPaDDM_AIC$loss,
  DRNPaDDM = numeric_DRNPaDDM_AIC$loss)


###################
# Model comparison
###################

ttest_dotsGain = multi.ttest(AICs_dotsGain)
ttest_dotsLoss = multi.ttest(AICs_dotsLoss)
ttest_numericGain = multi.ttest(AICs_numericGain)
ttest_numericLoss = multi.ttest(AICs_numericLoss)

write.csv(ttest_dotsGain, file=file.path(tempdir, "ttest_dotsGain.csv"))
write.csv(ttest_dotsLoss, file=file.path(tempdir, "ttest_dotsLoss.csv"))
write.csv(ttest_numericGain, file=file.path(tempdir, "ttest_numericGain.csv"))
write.csv(ttest_numericLoss, file=file.path(tempdir, "ttest_numericLoss.csv"))
