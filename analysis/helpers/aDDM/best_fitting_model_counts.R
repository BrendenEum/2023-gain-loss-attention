################
# Preamble
################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(ggplot2)
library(ggsci)
txtdir = "../../outputs/text"
fitdir = "../../outputs/temp"
datadir = "../../../data/processed_data"
source("get_estimates_likelihoods.R")

M_list = c("aDDM", "UaDDM", "AddDDM", "cbAddDDM", "AddaDDM", "DNaDDM", "GDaDDM", "cbGDaDDM", "RNaDDM", "RNPaDDM", "DRNPaDDM")
param_counts = c(4,4,4,5,5,4,4,5,4,5,5)
M = length(M_list)

################
# Get BICs
################

BICs = list()

for (m in c(1:M)) {
  
  model = M_list[m]
  parameterCount = param_counts[m]
  
  .dots = getIC(datadir=datadir, fitdir=fitdir, study="dots", model=model, dataset="e", parameterCount=parameterCount)
  .numeric = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model=model, dataset="e", parameterCount=parameterCount)
  .both = rbind(.dots$BIC, .numeric$BIC)
  .bic = apply(.both,1,sum)
  
  BICs[[m]] = .bic
}

BICs = matrix(unlist(BICs), ncol = M) %>% data.frame() # rows=subjects, cols=models
colnames(BICs) = M_list

################
# Get subject counts for each model
################

indicators = t(apply(BICs, 1, function(x) ifelse(x == min(x), 1, 0)))
indicators = as.data.frame(indicators, colnames = names(BICs))

counts = colSums(indicators)

################
# Save
################

for (m in c(1:M)) {
  fileConn<-file(file.path(txtdir, paste0(M_list[m], "_bestFitCount.txt")))
  writeLines(
    paste0(counts[m], "%"), 
    fileConn
  )
  close(fileConn)
}