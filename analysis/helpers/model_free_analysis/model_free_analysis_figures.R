## This script generates the figures for all the model free analyses: Basic Psychometrics, Fixation Process, Choice Biases. EXPLORATORY DATASET

# Preamble

rm(list=ls())
set.seed(4)
library(tidyverse)
library(effsize)
library(plotrix)
library(ggsci)
codedir = getwd()
datadir = file.path("../../../data/processed_data/datasets")
tempdir = file.path("../../outputs/temp")
figdir = file.path("../../outputs/figures")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))

# Loop through each dataset
dataset="ecfr.RData"
for (dataset in c("ecfr.RData")) { #, "ccfr.RData", "jcfr.RData")) {
  
  load(file.path(datadir, dataset))
  if (dataset=="ecfr.RData") {cfr = ecfr; ext="_E.pdf"; color_back = color_e}
  else if (dataset=="ccfr.RData") {cfr = ccfr; ext="_C.pdf"; color_back = color_c}
  else {cfr=jcfr; ext="_J.pdf"; color_back = color_e}
  
  #####################
  # Basic Psychometrics
  #####################
  
  # Choice
  source(file.path(codedir, "BasicPsychometrics_Choice.R"))
  plt.psycho = psycho.choice.plt(cfr, xlim=c(-1.03,1.03)) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("BasicPsychometrics_Choice", ext)), 
    plot=plt.psycho, width=figw, height=figh, units="in")
  
  # RT
  source(file.path(codedir, "BasicPsychometrics_RT.R"))
  plt.rt = psycho.rt.plt(cfr, xlim=c(-.02,1.02)) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("BasicPsychometrics_RT", ext)), 
    plot=plt.rt, width=figw, height=figh, units="in")
  
  # Number of Fixations
  source(file.path(codedir, "BasicPsychometrics_NumberFixations.R"))
  plt.numfix = psycho.numfix.plt(cfr, xlim=c(-.02,1.02)) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("BasicPsychometrics_NumberFixations", ext)),
    plot=plt.numfix, width=figw, height=figh, units="in")
  
  
  #####################
  # Fixation Process
  #####################
  
  # First Fixation to Best
  source(file.path(codedir, "FixationProcess_FirstBest.R"))
  plt.prfirst = fixprop.prfirst.plt(cfr, xlim=c(.07,1.03)) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("FixationProcess_FirstBest", ext)), 
    plot=plt.prfirst, width=figw, height=figh, units="in")
  
  # Fixation Duration by Type
  source(file.path(codedir, "FixationProcess_DurationType.R"))
  plt.fixtype = fixprop.fixtype.plt(cfr, ylim=c(.3,.8)) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("FixationProcess_DurationType", ext)), 
    plot=plt.fixtype, width=figw, height=figh, units="in")
  
  # Middle Fixation Duration by Difficulty
  source(file.path(codedir, "FixationProcess_Middle.R"))
  plt.mid = fixprop.mid.plt(cfr, xlim=c(-.03,1.03)) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("FixationProcess_Middle", ext)), 
    plot=plt.mid, width=figw, height=figh, units="in")
  
  # First Fixation Duration by Difficulty
  source(file.path(codedir, "FixationProcess_First.R"))
  plt.first = fixprop.first.plt(cfr, xlim=c(-.03,1.03)) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("FixationProcess_First", ext)), 
    plot=plt.first, width=figw, height=figh, units="in")

  # Net Fixation Duration by Value Difference
  source(file.path(codedir, "FixationProcess_Net.R"))
  plt.net = fixprop.net.plt(cfr, xlim=c(-1.03,1.03)) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("FixationProcess_Net", ext)), 
    plot=plt.net, width=figw, height=figh, units="in")
  
  
  #####################
  # Attentional Choice Biases
  #####################
  
  # Net Fixation Bias
  source(file.path(codedir, "ChoiceBiases_Net.R"))
  netfix_x_scale = c(-1.3, 1.3)
  plt.netfix = bias.netfix.plt(cfr, xlim=netfix_x_scale) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("ChoiceBiases_Net", ext)), 
    plot=plt.netfix, width=figw, height=figh, units="in")
  
  # Last Fixation Bias
  source(file.path(codedir, "ChoiceBiases_Last.R"))
  plt.lastfix = bias.lastfix.plt(cfr, xlim=c(-1.03,1.03)) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("ChoiceBiases_Last", ext)), 
    plot=plt.lastfix, width=figw, height=figh, units="in")
  
  # First Fixation Bias
  source(file.path(codedir, "ChoiceBiases_First.R"))
  firstfix_x_scale = c(-1.03,1.03)
  plt.firstfix = bias.firstfix.plt(cfr, xlim=firstfix_x_scale) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("ChoiceBiases_First", ext)), 
    plot=plt.firstfix, width=figw, height=figh, units="in")
  
  
  #####################
  # Additional Fixation Properties
  #####################
  
  # Pr first fix left
  source(file.path(codedir, "AdditionalFixProp_PrFirstLeft.R"))
  x_scale = c(-1.03, 1.03)
  plt.firstLeft = addfixprop.firstLeft.plt(cfr, xlim=x_scale) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("AdditionalFixProp_PrFirstLeft", ext)), 
    plot=plt.firstLeft, width=figw, height=figh, units="in")
  
  # Fix num wrt first fix left
  source(file.path(codedir, "AdditionalFixProp_FixNumFirstFix.R"))
  plt.numFixFirstFix = psycho.numfixfirstfix.plt(cfr) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("AdditionalFixProp_FixNumFirstFix", ext)), 
    plot=plt.numFixFirstFix, width=figw, height=figh, units="in")
  
  # Second Fix Dur
  source(file.path(codedir, "AdditionalFixProp_SecondFixDur.R"))
  x_scale = c(-0.03, 1.03)
  plt.secondFixDur = addfixprop.second.plt(cfr, xlim=x_scale) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("AdditionalFixProp_SecondFixDur", ext)), 
    plot=plt.secondFixDur, width=figw, height=figh, units="in")
  
  # Third Fix Dur
  source(file.path(codedir, "AdditionalFixProp_ThirdFixDur.R"))
  x_scale = c(-0.03, 1.03)
  plt.thirdFixDur = addfixprop.third.plt(cfr, xlim=x_scale) + 
    theme(plot.background = element_rect(fill = color_back, color = color_back))
  ggsave(
    file.path(figdir, paste0("AdditionalFixProp_ThirdFixDur", ext)), 
    plot=plt.thirdFixDur, width=figw, height=figh, units="in")
  
}
