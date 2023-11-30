## This script generates the figures for all the model free analyses: Basic Psychometrics, Fixation Process, Choice Biases. EXPLORATORY DATASET

# Preamble

rm(list=ls())
set.seed(4)
library(tidyverse)
library(effsize)
library(plotrix)
library(ggsci)
codedir = getwd()
datadir = file.path("../../../data/processed_data")
tempdir = file.path("../../outputs/temp")
figdir = file.path("../../outputs/figures")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))

# Loop through each dataset

for (dataset in c("ecfr.RData")) { #, "ccfr.RData", "jcfr.RData")) {
  
  load(file.path(datadir, dataset))
  if (dataset=="ecfr.RData") {cfr = ecfr; ext="_E.pdf"}
  else if (dataset=="ccfr.RData") {cfr = ccfr; ext="_C.pdf"}
  else {cfr=jcfr; ext="_J.pdf"}
  
  #####################
  # Basic Psychometrics
  #####################
  
  # Choice
  source(file.path(codedir, "BasicPsychometrics_Choice.R"))
  plt.dots.psycho = psycho.choice.plt(cfr[cfr$dataset=="dots",], xlim=c(-1,1))
  plt.numeric.psycho = psycho.choice.plt(cfr[cfr$dataset=="numeric",], xlim=c(-4,4))
  #plt.food.psycho = psycho.choice.plt(cfr[cfr$dataset=="food",], xlim=c(-5,5))
  ggsave(
    file.path(figdir, paste0("dots_BasicPsychometrics_Choice", ext)), 
    plot=plt.dots.psycho, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_BasicPsychometrics_Choice", ext)), 
    plot=plt.numeric.psycho, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_BasicPsychometrics_Choice", ext)),
  #  plot=plt.food.psycho, width=figw, height=figh, units="in")
  
  # RT
  source(file.path(codedir, "BasicPsychometrics_RT.R"))
  plt.dots.rt = psycho.rt.plt(cfr[cfr$dataset=="dots",], xlim=c(0,1))
  plt.numeric.rt = psycho.rt.plt(cfr[cfr$dataset=="numeric",], xlim=c(0,4))
  #plt.food.rt = psycho.rt.plt(cfr[cfr$dataset=="food",], xlim=c(0,5))
  ggsave(
    file.path(figdir, paste0("dots_BasicPsychometrics_RT", ext)), 
    plot=plt.dots.rt, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_BasicPsychometrics_RT", ext)), 
    plot=plt.numeric.rt, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_BasicPsychometrics_RT", ext)), 
  #  plot=plt.food.RT, width=figw, height=figh, units="in")
  
  # Number of Fixations
  source(file.path(codedir, "BasicPsychometrics_NumberFixations.R"))
  plt.dots.numfix = psycho.numfix.plt(cfr[cfr$dataset=="dots",], xlim=c(0,1))
  plt.numeric.numfix = psycho.numfix.plt(cfr[cfr$dataset=="numeric",], xlim=c(0,4))
  #plt.food.numfix = psycho.numfix.plt(cfr[cfr$dataset=="food",], xlim=c(0,5))
  ggsave(
    file.path(figdir, paste0("dots_BasicPsychometrics_NumberFixations", ext)),
    plot=plt.dots.numfix, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_BasicPsychometrics_NumberFixations", ext)),
    plot=plt.numeric.numfix, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_BasicPsychometrics_NumberFixations", ext)),
  #  plot=plt.food.numfix, width=figw, height=figh, units="in")
  
  
  #####################
  # Fixation Process
  #####################
  
  # First Fixation to Best
  source(file.path(codedir, "FixationProcess_FirstBest.R"))
  plt.dots.prfirst = fixprop.prfirst.plt(cfr[cfr$dataset=="dots",], xlim=c(.1,1))
  plt.numeric.prfirst = fixprop.prfirst.plt(cfr[cfr$dataset=="numeric",], xlim=c(1,4))
  #plt.food.prfirst = fixprop.prfirst.plt(cfr[cfr$dataset=="food",], xlim=c(0,5))
  ggsave(
    file.path(figdir, paste0("dots_FixationProcess_FirstBest", ext)), 
    plot=plt.dots.prfirst, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_FixationProcess_FirstBest", ext)), 
    plot=plt.numeric.prfirst, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_FixationProcess_FirstBest", ext)), 
  #  plot=plt.numeric.prfirst, width=figw, height=figh, units="in")
  
  # Fixation Duration by Type
  source(file.path(codedir, "FixationProcess_DurationType.R"))
  plt.dots.fixtype = fixprop.fixtype.plt(cfr[cfr$dataset=="dots",])
  plt.numeric.fixtype = fixprop.fixtype.plt(cfr[cfr$dataset=="numeric",])
  #plt.food.fixtype = fixprop.fixtype.plt(cfr[cfr$dataset=="food",])
  ggsave(
    file.path(figdir, paste0("dots_FixationProcess_DurationType", ext)), 
    plot=plt.dots.fixtype, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_FixationProcess_DurationType", ext)), 
    plot=plt.numeric.fixtype, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_FixationProcess_DurationType", ext)), 
  #  plot=plt.food.fixtype, width=figw, height=figh, units="in")
  
  # Middle Fixation Duration by Difficulty
  source(file.path(codedir, "FixationProcess_Middle.R"))
  plt.dots.mid = fixprop.mid.plt(cfr[cfr$dataset=="dots",], xlim=c(0,1))
  plt.numeric.mid = fixprop.mid.plt(cfr[cfr$dataset=="numeric",], xlim=c(0,4))
  #plt.food.mid = fixprop.mid.plt(cfr[cfr$dataset=="food",], xlim=c(0,5))
  ggsave(
    file.path(figdir, paste0("dots_FixationProcess_Middle", ext)), 
    plot=plt.dots.mid, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_FixationProcess_Middle", ext)), 
    plot=plt.numeric.mid, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_FixationProcess_Middle", ext)), 
  #  plot=plt.food.mid, width=figw, height=figh, units="in")
  
  # First Fixation Duration by Difficulty
  source(file.path(codedir, "FixationProcess_First.R"))
  plt.dots.first = fixprop.first.plt(cfr[cfr$dataset=="dots",], xlim=c(0,1))
  plt.numeric.first = fixprop.first.plt(cfr[cfr$dataset=="numeric",], xlim=c(0,4))
  #plt.food.first = fixprop.first.plt(cfr[cfr$dataset=="food",], xlim=c(0,5))
  ggsave(
    file.path(figdir, paste0("dots_FixationProcess_First", ext)), 
    plot=plt.dots.first, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_FixationProcess_First", ext)), 
    plot=plt.numeric.first, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_FixationProcess_First", ext)), 
  #  plot=plt.food.first, width=figw, height=figh, units="in")

  # Net Fixation Duration by Value Difference
  source(file.path(codedir, "FixationProcess_Net.R"))
  plt.dots.net = fixprop.net.plt(cfr[cfr$dataset=="dots",], xlim=c(-1,1))
  plt.numeric.net = fixprop.net.plt(cfr[cfr$dataset=="numeric",], xlim=c(-4,4))
  #plt.food.net = fixprop.net.plt(cfr[cfr$dataset=="food",], xlim=c(-5,5))
  ggsave(
    file.path(figdir, paste0("dots_FixationProcess_Net", ext)), 
    plot=plt.dots.net, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_FixationProcess_Net", ext)), 
    plot=plt.numeric.net, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_FixationProcess_Net", ext)), 
  #  plot=plt.food.net, width=figw, height=figh, units="in")
  
  
  #####################
  # Attentional Choice Biases
  #####################
  
  # Net Fixation Bias
  source(file.path(codedir, "ChoiceBiases_Net.R"))
  netfix_x_scale = c(-1.25, 1.25)
  plt.dots.netfix = bias.netfix.plt(cfr[cfr$dataset=="dots",], xlim=netfix_x_scale)
  plt.numeric.netfix = bias.netfix.plt(cfr[cfr$dataset=="numeric",], xlim=netfix_x_scale)
  #plt.food.netfix = bias.netfix.plt(cfr[cfr$dataset=="food",], xlim=netfix_x_scale)
  ggsave(
    file.path(figdir, paste0("dots_ChoiceBiases_Net", ext)), 
    plot=plt.dots.netfix, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_ChoiceBiases_Net", ext)), 
    plot=plt.numeric.netfix, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_ChoiceBiases_Net", ext)), 
  #  plot=plt.food.netfix, width=figw, height=figh, units="in")
  
  # Last Fixation Bias
  source(file.path(codedir, "ChoiceBiases_Last.R"))
  plt.dots.lastfix = bias.lastfix.plt(cfr[cfr$dataset=="dots",], xlim=c(-1,1))
  plt.numeric.lastfix = bias.lastfix.plt(cfr[cfr$dataset=="numeric",], xlim=c(-4,4))
  #plt.food.lastfix = bias.lastfix.plt(cfr[cfr$dataset=="food",], xlim=c(0,5))
  ggsave(
    file.path(figdir, paste0("dots_ChoiceBiases_Last", ext)), 
    plot=plt.dots.lastfix, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_ChoiceBiases_Last", ext)), 
    plot=plt.numeric.lastfix, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_ChoiceBiases_Last", ext)), 
  #  plot=plt.food.lastfix, width=figw, height=figh, units="in")
  
  # First Fixation Bias
  source(file.path(codedir, "ChoiceBiases_First.R"))
  firstfix_x_scale = c(.2,1)
  plt.dots.firstfix = bias.firstfix.plt(cfr[cfr$dataset=="dots",], xlim=firstfix_x_scale)
  plt.numeric.firstfix = bias.firstfix.plt(cfr[cfr$dataset=="numeric",], xlim=firstfix_x_scale)
  #plt.food.firstfix = bias.firstfix.plt(cfr[cfr$dataset=="food",], xlim=firstfix_x_scale)
  ggsave(
    file.path(figdir, paste0("dots_ChoiceBiases_First", ext)), 
    plot=plt.dots.firstfix, width=figw, height=figh, units="in")
  ggsave(
    file.path(figdir, paste0("numeric_ChoiceBiases_First", ext)), 
    plot=plt.numeric.firstfix, width=figw, height=figh, units="in")
  #ggsave(
  #  file.path(figdir, paste0("food_ChoiceBiases_Last", ext)), 
  #  plot=plt.food.firstfix, width=figw, height=figh, units="in")  
  
   
}