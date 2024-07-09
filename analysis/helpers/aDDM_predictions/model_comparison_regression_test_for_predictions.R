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
.datetime = readLines("most_recent_simulation.txt")

.figdir = file.path("../../outputs/figures")
.tempdir = file.path("../../outputs/temp/model_free_model_comparison")
.optdir = file.path("../plot_options/")
source(file.path(.optdir, "GainLossColorPalette.R"))
source(file.path(.optdir, "MyPlotOptions.R"))

.nSims = 10

# BRMS settings
cc = 3
iter = 18000
brm <- function(...)
  brms::brm(
    ...,
    iter = iter,
    warmup = floor(iter/2),
    chains = cc,
    cores = cc,
    seed = seed,
    refresh = T,
    file_refit = "always")


##############################################################################
# Function to load data and run regressions
##############################################################################

regression_test = function() {
  
  ## Simulated data
  
  # Number of subjects
  
  SimEst = read.csv(.estFN)
  subjects = unique(SimEst$subject)
  
  # study 1
  simData_raw = data.frame()
  for (j in subjects) {
    for (k in 1:.nSims) {
      
      expdataLoss = read.csv(file.path(.simdir, glue("sim_data_beh_{j}_{k}_Loss.csv")))
      fixationsLoss = read.csv(file.path(.simdir, glue("sim_data_fix_{j}_{k}_Loss.csv")))
      simDataLoss = merge(expdataLoss, fixationsLoss, by=c("parcode","condition","trial","sim"))
      simDataLoss$trial = simDataLoss$trial + 200
      
      simData_raw = do.call("bind_rows", list(simData_raw, simDataLoss))
    }
  }
  
  simData = simData_raw[simData_raw$fix_item!=0,] %>% # exclude simulated latency & saccades
    mutate(
      subject = parcode,
      condition = factor(condition, levels=c("Gain","Loss"), labels=c("Gain", "Loss")),
      trial = trial,
      sim = sim,
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
    group_by(sim, subject, condition, trial) %>%
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
  
  # simData_rt_oV = brm(
  #   log(rt) ~ 1 + nabsvDiff + noV + (1 + nabsvDiff + noV | subject),
  #   data = simData,
  #   family = gaussian(),
  #   prior = c(
  #     prior(normal(0,1.0), class=Intercept),
  #     prior(normal(0,1.0), class="b", coef="nabsvDiff"),
  #     prior(normal(0,0.5), class="b", coef="noV")
  #     #prior(normal(0, 0.5), class = "sd", group = "subject", coef = "Intercept"),
  #     #prior(normal(0, 0.1), class = "sd", group = "subject", coef = "nabsvDiff"),
  #     #prior(normal(0, 0.05), class = "sd", group = "subject", coef = "noV")
  #   ),
  #   file = file.path(.tempdir, paste0(.regFN, ds))
  # )
  # summary(simData_rt_oV)
  # formatted_estimates <- sprintf("%.6f", simData_rt_oV$fixed[, "Estimate"])
  # formatted_errors <- sprintf("%.6f", simData_rt_oV$fixed[, "Est.Error"])
  # formatted_output <- data.frame(Estimate = formatted_estimates, Est.Error = formatted_errors)
  # print(formatted_output)
  
}



##############################################################################
# aDDM
##############################################################################

#--------------------------
.simdir = file.path(paste0("../../outputs/temp/model_predictions/", .datetime, "/aDDM"))
.estFN = "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_predictions/SimIndividualEstimates_aDDM.csv"
.regFN = "aDDM_sim_rt_oV"
#---------------------------------------------------------------
aDDM_test = regression_test()
summary(aDDM_test)
confint(aDDM_test, method="Wald")


##############################################################################
# AddDDM
##############################################################################

#--------------------------
.simdir = file.path(paste0("../../outputs/temp/model_predictions/", .datetime, "/AddDDM"))
.estFN = "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_predictions/SimIndividualEstimates_AddDDM.csv"
.regFN = "AddDDM_sim_rt_oV"
#---------------------------------------------------------------
AddDDM_test = regression_test()
summary(AddDDM_test)
confint(AddDDM_test, method="Wald")



##############################################################################
# RaDDM
##############################################################################

#--------------------------
.simdir = file.path(paste0("../../outputs/temp/model_predictions/", .datetime, "/RaDDM"))
.estFN = "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_predictions/SimIndividualEstimates_RaDDM.csv"
.regFN = "RaDDM_sim_rt_oV"
#---------------------------------------------------------------
RaDDM_test = regression_test()
summary(RaDDM_test)
confint(RaDDM_test, method="Wald")
