# This script will plot the model fits for all models.

# Preamble
library(tidyverse)
library(plotrix)
library(gridExtra)
figdir = "../../outputs/figures"
fitdir = "../../outputs/temp"
optdir = "../plot_options"
source(file.path(optdir, "MyPlotOptions.R"))
comparecolors = c("dots"="dodgerblue3", "numeric"="deeppink4", "food"="bisque4")
myPlot = c(
  myPlot, 
  scale_color_manual(values=comparecolors), 
  scale_fill_manual(values=comparecolors))

###################
# FUNCTIONS
###################

# Get the estimates and clean the dataset.

read_estimates <- function(study, model, dataset) {
  
  gainFileName = paste0(study, "_", model, "_GainEst_", dataset, ".csv")
  lossFileName = paste0(study, "_", model, "_LossEst_", dataset, ".csv")
  gainFit = read.csv(file.path(fitdir, gainFileName))
  lossFit = read.csv(file.path(fitdir, lossFileName))
  
  estimates = data.frame(
    d.gain = gainFit$d, #*1000
    d.loss = lossFit$d,
    s.gain = gainFit$s, #*10
    s.loss = lossFit$s,
    b.gain = gainFit$b,
    b.loss = lossFit$b,
    t.gain = gainFit$t,
    t.loss = lossFit$t)
  
  if (model %in% c("DNP", "RNP", "DRNP")) {
    estimates$k.gain = gainFit$k
    estimates$k.loss = lossFit$k}
  
  estimates$dataset = study
  return(estimates)
}

###################
# aDDM
###################