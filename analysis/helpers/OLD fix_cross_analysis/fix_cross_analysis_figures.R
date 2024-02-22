## This script generates the figures for all the model free analyses: Basic Psychometrics, Fixation Process, Choice Biases. EXPLORATORY DATASET

# Preamble

rm(list=ls())
set.seed(4)
library(tidyverse)
library(effsize)
library(plotrix)
library(ggsci)
codedir = getwd()
datadir = file.path("../../../data/processed_data/numeric")
tempdir = file.path("../../outputs/temp")
figdir = file.path("../../outputs/figures")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))
figw = 10 # make the figures wider than before

# Loop through each dataset
dataset = "e/cfr_numeric.RData" #"j/cfr_numeric.RData"

load(file.path(datadir, dataset))
cfr = cfr_numeric
if (dataset=="e/cfr_numeric.RData") {ext="_E.pdf"}
if (dataset=="c/cfr_numeric.RData") {ext="_C.pdf"}
if (dataset=="j/cfr_numeric.RData") {ext="_J.pdf"}

#####################
# Basic Psychometrics
#####################

# Choice
source(file.path(codedir, "BasicPsychometrics_Choice.R"))
plt.numeric.psycho = fixCross.choice.plt(cfr[cfr$study=="numeric",], xlim=c(-1.03,1.03))
ggsave(
  file.path(figdir, paste0("fixCross_BasicPsychometrics_Choice", ext)), 
  plot=plt.numeric.psycho, width=figw, height=figh, units="in")

# RT
source(file.path(codedir, "BasicPsychometrics_RT.R"))
plt.numeric.rt = fixCross.rt.plt(cfr[cfr$study=="numeric",], xlim=c(0,4))
ggsave(
  file.path(figdir, paste0("fixCross_BasicPsychometrics_RT", ext)), 
  plot=plt.numeric.rt, width=figw, height=figh, units="in")

#####################
# Fixation Process
#####################

# First Fixation to Best
source(file.path(codedir, "FixationProcess_FirstBest.R"))
plt.numeric.prfirst = fixCross.prfirst.plt(cfr[cfr$study=="numeric",], xlim=c(1,4))
ggsave(
  file.path(figdir, paste0("fixCross_FixationProcess_FirstBest", ext)), 
  plot=plt.numeric.prfirst, width=figw, height=figh, units="in")

# First Fixation Duration by Difficulty
source(file.path(codedir, "FixationProcess_First.R"))
plt.numeric.first = fixCross.first.plt(cfr[cfr$study=="numeric",], xlim=c(0,4))
ggsave(
  file.path(figdir, paste0("fixCross_FixationProcess_First", ext)), 
  plot=plt.numeric.first, width=figw, height=figh, units="in")

# Middle Fixation Duration by Difficulty
source(file.path(codedir, "FixationProcess_Middle.R"))
plt.numeric.mid = fixCross.mid.plt(cfr[cfr$study=="numeric",], xlim=c(0,4))
ggsave(
  file.path(figdir, paste0("fixCross_FixationProcess_Middle", ext)), 
  plot=plt.numeric.mid, width=figw, height=figh, units="in")

# Net Fixation Duration by Value Difference
source(file.path(codedir, "FixationProcess_Net.R"))
plt.numeric.net = fixCross.net.plt(cfr[cfr$study=="numeric",], xlim=c(-4,4))
ggsave(
  file.path(figdir, paste0("fixCross_FixationProcess_Net", ext)), 
  plot=plt.numeric.net, width=figw, height=figh, units="in")


#####################
# Attentional Choice Biases
#####################

# Net Fixation Bias
source(file.path(codedir, "ChoiceBiases_Net.R"))
netfix_x_scale = c(-1.25, 1.25)
plt.numeric.netfix = fixCross.netfix.plt(cfr[cfr$study=="numeric",], xlim=netfix_x_scale)
ggsave(
  file.path(figdir, paste0("fixCross_ChoiceBiases_Net", ext)), 
  plot=plt.numeric.netfix, width=figw, height=figh, units="in")

# Last Fixation Bias
source(file.path(codedir, "ChoiceBiases_Last.R"))
plt.numeric.lastfix = fixCross.lastfix.plt(cfr[cfr$study=="numeric",], xlim=c(-4,4))
ggsave(
  file.path(figdir, paste0("fixCross_ChoiceBiases_Last", ext)), 
  plot=plt.numeric.lastfix, width=figw, height=figh, units="in")

# First Fixation Bias
source(file.path(codedir, "ChoiceBiases_First.R"))
firstfix_x_scale = c(.2,1)
plt.numeric.firstfix = fixCross.firstfix.plt(cfr[cfr$study=="numeric",], xlim=firstfix_x_scale)
ggsave(
  file.path(figdir, paste0("fixCross_ChoiceBiases_First", ext)), 
  plot=plt.numeric.firstfix, width=figw, height=figh, units="in")