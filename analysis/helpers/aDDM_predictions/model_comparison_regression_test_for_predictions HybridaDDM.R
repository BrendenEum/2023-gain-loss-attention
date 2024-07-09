##############################################################################
# Preamble
##############################################################################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(plotrix)
library(gridExtra)
library(grid)
library(gridtext)
library(glue)
library(lme4)
.colors = list(Gain="Green4", Loss="Red3")
.datetime = readLines("../parameter_recovery/results_HybridaDDM_Gain/most_recent_run.txt")

.figdir = file.path("../../outputs/figures")
.tempdir = file.path("../../outputs/temp/model_free_model_comparison")
.optdir = file.path("../plot_options/")
source(file.path(.optdir, "GainLossColorPalette.R"))
source(file.path(.optdir, "MyPlotOptions.R"))

# subject 5: d = .005, sigma = .05, theta = .1, eta = .001
# subject 41: d = .005, sigma = .05, theta = .5, eta = .005
# subject 77: d = .005, sigma = .05, theta = .9, eta = .009
subjects = c(5, 41, 77)


##############################################################################
# Function to load data and run regressions
##############################################################################

regression_test = function() {
  
  ## Simulated data
  
  # study 1
  simData_raw = data.frame()
  for (j in subjects) {
      
    expdata = read.csv(file.path(.simdir, glue("sim_data_beh_{j}_.csv")))
    fixations = read.csv(file.path(.simdir, glue("sim_data_fix_{j}_.csv")))
    simData = merge(expdata, fixations, by=c("parcode","condition","trial"))
    simData$trial = simData$trial + 200
    
    simData_raw = do.call("bind_rows", list(simData_raw, simData))
  }
  
  simData = simData_raw[simData_raw$fix_item!=0,] %>% # exclude simulated latency & saccades
    mutate(
      subject = parcode,
      condition = factor(condition, levels=c("Gain","Loss"), labels=c("Gain", "Loss")),
      trial = trial,
      choice = ifelse(choice==-1, 1, 0),
      rt = rt/1000,
      vL = LProb*LAmt,
      vR = RProb*RAmt,
      vDiff = vL - vR,
      nvDiff = as.numeric(as.character(cut(round(vDiff,3), seq(-10.5,10.5,1), labels=seq(-10,10,1))))/4 ,
      nabsvDiff = abs(nvDiff),
      oV = vL + vR,
      noV = oV / max(abs(oV)),
      location = factor(fix_item, levels = c(1, 2), labels = c("Left", "Right")),
      fix_dur = fix_time/1000,
      simulated = 1
    ) %>%
    group_by(subject, condition, trial) %>%
    summarize(
      rt = first(rt),
      nabsvDiff = first(nabsvDiff),
      noV = first(noV)
    )
  
  
  ####################
  # Regression Test
  ####################
  
  model = lmer(log(rt) ~ 1 + nabsvDiff + noV + (1 + nabsvDiff + noV | subject), simData)
  return(model)
  
}


##############################################################################
# RaDDM
##############################################################################

#--------------------------
.simdir = file.path("../parameter_recovery/results_HybridaDDM_Gain", .datetime)
#---------------------------------------------------------------
HybridaDDM_test = regression_test()
fixef(HybridaDDM_test)
ranef(HybridaDDM_test)
#confint(HybridaDDM_test, method="Wald")
