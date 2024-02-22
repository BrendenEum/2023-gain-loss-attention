####################################################
## PREAMBLE
####################################################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(plotrix)
library(ggsci)
library(ggplot2)
library(latex2exp)
library(gridExtra)
datadir = "../../../data/processed_data"
figdir = "../../outputs/figures"
fitdir = "../../outputs/temp"
tempdir = "../../outputs/temp"
addmdir = "../aDDM"
optdir = "../plot_options"
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))
ext=".pdf"
Nsim = 10


####################################################
## PREP DATA
####################################################

load(file.path(datadir, "ecfr.RData"))
cfr = ecfr[ecfr$trial%%2==0 & ecfr$sanity==0 & ecfr$lastFix==T,] #out-sample data
cfr$simulated = 0
cfr$lastFixLoc = abs(as.numeric(cfr$location)-2)
cfr$netFixLeft = cfr$net_fix

load(file.path(tempdir, "fdots_sim_cbGDaDDM.RData"))
load(file.path(tempdir, "fnumeric_sim_cbGDaDDM.RData"))
cfr_sim = rbind(fdots_sim, fnumeric_sim)
cfr_sim$simulated = 1

cfr_all = rbind(cfr, cfr_sim)
cfr_all$simulated = factor(cfr_all$simulated, levels=c(0,1), labels=c("Observed","Simulated"))


####################################################
## PLOT CHOICE, RT, NFB, LFB
####################################################

# Choice

source("Sim_Choice.R")
sim.choice = sim.choice.plt(cfr_all, xlim=c(-1,1))
ggsave(
  file.path(figdir, paste0("sims_choice_cbGDaDDM", ext)), 
  plot=sim.choice, width=figw*.75, height=figh*1.25, units="in")

# RT

source("Sim_RT.R")
sim.rt = sim.rt.plt(cfr_all, xlim=c(0,1))
ggsave(
  file.path(figdir, paste0("sims_rt_cbGDaDDM", ext)), 
  plot=sim.rt, width=figw*.75, height=figh*1.25, units="in")

# Net Fix

source("Sim_Net.R")
sim.net = sim.netfix.plt(cfr_all, xlim=c(-1.5,1.5))
ggsave(
  file.path(figdir, paste0("sims_net_cbGDaDDM", ext)), 
  plot=sim.net, width=figw*.75, height=figh*1.25, units="in")

# Last Fix

source("Sim_Last.R")
sim.last = sim.lastfix.plt(cfr_all, xlim=c(-1,1))
ggsave(
  file.path(figdir, paste0("sims_last_cbGDaDDM", ext)), 
  plot=sim.last, width=figw*.75, height=figh*1.25, units="in")