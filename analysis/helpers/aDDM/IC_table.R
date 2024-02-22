################
# Preamble
################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(plotrix)
library(xtable)
figdir = "../../outputs/figures"
fitdir = "../../outputs/temp"
tabdir = "../../outputs/tables"
datadir = "../../../data/processed_data"
source("get_estimates_likelihoods.R")


for (study in c("dots","numeric")) {
  
  ################
  # Get Information Criteria
  ################
  
  ###
  # getIC yields a list with 3 dataframes: BIC, AIC, and log_m_hats.
  # Each dataframe has 2 columns: 1=gain, 2=loss.
  ###
  
  IC_list = list()
  
  # Standard aDDM
  
  aDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="aDDM", dataset="e", parameterCount=4)
  IC_list$aDDM = aDDM_IC
  
  # Unbounded aDDM
  
  UaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="UaDDM", dataset="e", parameterCount=4)
  IC_list$UaDDM =UaDDM_IC
  
  # Additive aDDM
  
  AddDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="AddDDM", dataset="e", parameterCount=4)
  IC_list$AddDDM = AddDDM_IC
  
  # collapsing bounds additive DDM
  
  cbAddDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="cbAddDDM", dataset="e", parameterCount=5)
  IC_list$cbAddDDM = cbAddDDM_IC
  
  # Additive and multiplicative aDDM
  
  AddaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="AddaDDM", dataset="e", parameterCount=5)
  IC_list$AddaDDM = AddaDDM_IC
  
  # Divisive Normalization
  
  DNaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="DNaDDM", dataset="e", parameterCount=4)
  IC_list$DNaDDM = DNaDDM_IC
  
  # Goal-Dependent
  
  GDaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="GDaDDM", dataset="e", parameterCount=4)
  IC_list$GDaDDM = GDaDDM_IC
  
  # collapsing bounds Goal-Dependent
  
  cbGDaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="cbGDaDDM", dataset="e", parameterCount=5)
  IC_list$cbGDaDDM = cbGDaDDM_IC
  
  # Range Normalized
  
  RNaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="RNaDDM", dataset="e", parameterCount=4)
  IC_list$RNaDDM = RNaDDM_IC
  
  # Range Normalized Plus
  
  RNPaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="RNPaDDM", dataset="e", parameterCount=5)
  IC_list$RNPaDDM = RNPaDDM_IC
  
  # Dynamic Range Normalized Plus
  
  DRNPaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study=study, model="DRNPaDDM", dataset="e", parameterCount=5)
  IC_list$DRNPaDDM = DRNPaDDM_IC
  
  ################
  # What IC's are you looking for?
  ################
  
  models = c()
  gainBIC = c()
  lossBIC = c()
  totalBIC = c()
  gainAIC = c()
  lossAIC = c()
  totalAIC = c()
  
  i = 0
  for (model in IC_list) {
    i = i+1
    models = c(models, names(IC_list)[i])
    gainBIC = c(gainBIC, sum(model$BIC[,1]))
    lossBIC = c(lossBIC, sum(model$BIC[,2]))
    totalBIC = c(totalBIC, sum(model$BIC))
    gainAIC = c(gainAIC, sum(model$AIC[,1]))
    lossAIC = c(lossAIC, sum(model$AIC[,2]))
    totalAIC = c(totalAIC, sum(model$AIC))
  }
  
  #output = model
  output = data.frame(
    gainBIC = gainBIC,
    lossBIC = lossBIC,
    totalBIC = totalBIC,
    gainAIC = gainAIC,
    lossAIC = lossAIC,
    totalAIC = totalAIC,
    row.names = models
  )
  
  
  ################
  # Save (LaTeX)
  ################
  
  if (study=="dots"){
    caption = "Study 1"
  } else if (study=="numeric") {
    caption = "Study 2"
  }
  
  .csvfile = file.path(tabdir, paste0(study, "_IC_raw.csv"))
  write.csv(output, file=.csvfile)
  .texfile = file.path(tabdir, paste0(study, "_IC_raw.tex"))
  
  print(
    xtable(
      output, 
      type = "latex",
      align = "|r|ccc|ccc|",
      digits = c(0,0,0,0,0,0,0),
      caption = caption
    ), 
    file = .texfile
  )
  
}


