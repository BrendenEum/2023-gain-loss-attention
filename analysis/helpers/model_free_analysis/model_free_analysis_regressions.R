## This script generates the figures for all the model free analyses: Basic Psychometrics, Fixation Process, Choice Biases. EXPLORATORY DATASET

# Preamble

rm(list=ls())
seed = 4
set.seed(seed)
library(tidyverse)
library(brms)
library(effsize)
codedir = getwd()
datadir = file.path("../../../data/processed_data/datasets")
tempdir = file.path("../../outputs/temp")
tempregdir = file.path(tempdir, "regressions")
tabdir = file.path("../../outputs/tables")

# Regression Options

refit = "on_change" # Run regressions? {always, on_change, never}
show.reg.progress = 1 # 1: Show updates. 0: Nah.
iter = 18000 # warmup + posterior samples
brm <- function(...)
  brms::brm(
    ...,
    iter = iter,#6000, #samples from the posterior
    warmup = floor(iter/2),#3000, #part of a healthy workout
    chains = 3, 
    cores = 3, 
    backend = 'rstan',
    seed = seed,
    refresh = show.reg.progress,
    file_refit = refit) 

# Loop through each dataset
dataset = "ecfr.RData"
for (dataset in c("ecfr.RData")) { #, "ccfr.RData", "jcfr.RData")) {
  
  load(file.path(datadir, dataset))
  if (dataset=="ecfr.RData") {cfr = ecfr; ext="_E.pdf"; dataset="E"}
  else if (dataset=="ccfr.RData") {cfr = ccfr; ext="_C.pdf"; dataset="C"}
  else {cfr=jcfr; ext="_J.pdf"; dataset="J"}
  
  #####################
  # Basic Psychometrics
  #####################
  
  # Choice
  source(file.path(codedir, "BasicPsychometrics_Choice.R"))
  reg.dots.psycho = psycho.choice.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.psycho = psycho.choice.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  # RT
  source(file.path(codedir, "BasicPsychometrics_RT.R"))
  reg.dots.rt = psycho.rt.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.rt = psycho.rt.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  # Number of Fixations
  source(file.path(codedir, "BasicPsychometrics_NumberFixations.R"))
  reg.dots.numfix = psycho.numfix.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.numfix = psycho.numfix.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  
  #####################
  # Fixation Process
  #####################
  
  # First Fixation to Best
  source(file.path(codedir, "FixationProcess_FirstBest.R"))
  reg.dots.prfirst = fixprop.prfirst.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.prfirst = fixprop.prfirst.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  # Fixation Duration by Type
  source(file.path(codedir, "FixationProcess_DurationType.R"))
  reg.dots.durationtype = fixprop.durationtype.ttest(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.durationtype = fixprop.durationtype.ttest(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  # Middle Fixation Duration by Difficulty
  source(file.path(codedir, "FixationProcess_Middle.R"))
  reg.dots.mid = fixprop.mid.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.mid = fixprop.mid.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  # First Fixation Duration by Difficulty
  source(file.path(codedir, "FixationProcess_First.R"))
  reg.dots.first = fixprop.first.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.first = fixprop.first.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)

  # Net Fixation Duration by Value Difference
  source(file.path(codedir, "FixationProcess_Net.R"))
  reg.dots.net = fixprop.net.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.net = fixprop.net.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  
  #####################
  # Attentional Choice Biases
  #####################
  
  # Net Fixation Bias
  source(file.path(codedir, "ChoiceBiases_Net.R"))
  reg.dots.netfix = bias.netfix.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.netfix = bias.netfix.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  # Last Fixation Bias
  source(file.path(codedir, "ChoiceBiases_Last.R"))
  reg.dots.lastfix = bias.lastfix.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.lastfix = bias.lastfix.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  # First Fixation Bias
  source(file.path(codedir, "ChoiceBiases_First.R"))
  reg.dots.firstfix = bias.firstfix.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.firstfix = bias.firstfix.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  
  #####################
  # Additional Fixation Properties
  #####################
  
  # Pr First Fix Left
  source(file.path(codedir, "AdditionalFixProp_PrFirstLeft.R"))
  reg.dots.firstLeft = addfixprop.firstLeft.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.firstLeft = addfixprop.firstLeft.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  # Second Fix Dur
  source(file.path(codedir, "AdditionalFixProp_SecondFixDur.R"))
  reg.dots.secondFixDur = addfixprop.second.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.secondFixDur = addfixprop.second.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
  # Third Fix Dur
  source(file.path(codedir, "AdditionalFixProp_ThirdFixDur.R"))
  reg.dots.thirdFixDur = addfixprop.third.reg(
    cfr[cfr$study=="dots",], 
    study="dots",
    dataset=dataset)
  reg.numeric.thirdFixDur = addfixprop.third.reg(
    cfr[cfr$study=="numeric",], 
    study="numeric",
    dataset=dataset)
  
}