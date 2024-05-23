####################################
# Preamble
####################################

rm(list=ls())
library(tidyverse)
library(furrr) # parallelization of map functions from purrr, i.e. parallelize optimization
library(patchwork)
source("../plot_options/GainLossColorPalette.R")
source("../plot_options/MyPlotOptions.R")
source("../plot_options/SE.R")
.figdir = file.path("../../outputs/figures")
.tempdir = file.path("../../outputs/temp/ref_dept")

load("../../../data/processed_data/datasets/ecfr.RData")

results = list()


####################################
# Status Quo
####################################
RDRule = "StatusQuo"
cfr = ecfr %>%
  mutate(
    LRef = 0,
    RRef = 0
  )
set.seed(4)
source("FitandPlotProspectTheory.R")
results$StatusQuo = data_optim_quad_pars
RDValues$Model = RDRule
RDValuesDF = RDValues


####################################
# MaxMin
####################################
RDRule = "MaxMin"
cfr = ecfr %>% # in losses
  mutate(
    LRef = pmax(LAmt, RAmt),
    RRef = pmax(LAmt, RAmt)
  )
cfr[cfr$condition=="Gain", c("LRef", "RRef")] = 0 # in gains
set.seed(4)
source("FitandPlotProspectTheory.R")
results$MaxMin = data_optim_quad_pars
RDValues$Model = RDRule
RDValuesDF = rbind(RDValuesDF, RDValues)


####################################
# minOutcome
####################################
RDRule = "minOutcome"
min_study1L = min(ecfr$LAmt[ecfr$studyN==1 & ecfr$condition=="Loss"], ecfr$RAmt[ecfr$studyN==1 & ecfr$condition=="Loss"], 0)
min_study2L = min(ecfr$LAmt[ecfr$studyN==2 & ecfr$condition=="Loss"], ecfr$RAmt[ecfr$studyN==2 & ecfr$condition=="Loss"], 0)
min_study1G = min(ecfr$LAmt[ecfr$studyN==1 & ecfr$condition=="Gain"], ecfr$RAmt[ecfr$studyN==1 & ecfr$condition=="Gain"], 0)
min_study2G = min(ecfr$LAmt[ecfr$studyN==2 & ecfr$condition=="Gain"], ecfr$RAmt[ecfr$studyN==2 & ecfr$condition=="Gain"], 0)
cfr = ecfr %>% mutate(LRef = NA)
cfr$LRef[cfr$studyN==1 & cfr$condition=="Loss"] = min_study1L
cfr$LRef[cfr$studyN==2 & cfr$condition=="Loss"] = min_study2L
cfr$LRef[cfr$studyN==1 & cfr$condition=="Gain"] = min_study1G
cfr$LRef[cfr$studyN==2 & cfr$condition=="Gain"] = min_study2G
cfr$RRef = cfr$LRef
set.seed(4)
source("FitAndPlotMinOutcome.R")
results$minOutcome = data_optim_quad_pars
RDValues$Model = RDRule
RDValuesDF = rbind(RDValuesDF, RDValues)

####################################
# Save
####################################
save(results, file=file.path(.tempdir, "ref_dept_results.RData"))
save(RDValuesDF, file=file.path(.tempdir, "ref_dept_values.RData"))


# ----------------------------------------------------------------------------------------------------------------------------------


# ####################################
# # minEV
# ####################################
# RDRule = "minEV"
# min_study1L = -5.5 #min(ecfr$vL[ecfr$studyN==1], ecfr$vR[ecfr$studyN==1])
# min_study2L = -6 #min(ecfr$vL[ecfr$studyN==2], ecfr$vR[ecfr$studyN==2])
# min_study1G = 4.5 #min(ecfr$vL[ecfr$studyN==1 & ecfr$condition=="Gain"], ecfr$vR[ecfr$studyN==1 & ecfr$condition=="Gain"])
# min_study2G = 1 #min(ecfr$vL[ecfr$studyN==2 & ecfr$condition=="Gain"], ecfr$vR[ecfr$studyN==2 & ecfr$condition=="Gain"])
# cfr = ecfr %>% mutate(LRef = NA)
# cfr$LRef[cfr$studyN==1 & cfr$condition=="Loss"] = min_study1L
# cfr$LRef[cfr$studyN==2 & cfr$condition=="Loss"] = min_study2L
# cfr$LRef[cfr$studyN==1 & cfr$condition=="Gain"] = min_study1G
# cfr$LRef[cfr$studyN==2 & cfr$condition=="Gain"] = min_study2G
# cfr$RRef = cfr$LRef
# set.seed(4)
# source("FitandPlotProspectTheory.R")
# results$MaxMin = data_optim_quad_pars
# RDValues$Model = RDRule
# RDValuesDF = rbind(RDValuesDF, RDValues)
# 

# ####################################
# # MinMax
# ####################################
# RDRule = "MinMax"
# cfr = ecfr %>% # in gains
#   mutate(
#     LRef = pmin(LAmt, RAmt),
#     RRef = pmin(LAmt, RAmt)
#   )
# cfr[cfr$condition=="Loss", c("LRef", "RRef")] = 0 # in losses
# set.seed(4)
# source("FitandPlotProspectTheory.R")
# results$MinMax = data_optim_quad_pars
# RDValues$Model = "MinMax"
# RDValuesDF = rbind(RDValuesDF, RDValues)
# 
# 
# ####################################
# # X at Max P
# ####################################
# RDRule = "XatMaxP"
# cfr = ecfr[ecfr$firstFix==T, ] %>% mutate(LRef = NA, RRef = NA)
# for (i in 1:nrow(cfr)) {
#   probs = c(cfr$LProb[i], 1-cfr$LProb[i], cfr$RProb[i], 1-cfr$RProb[i])
#   amts = c(cfr$LAmt[i], 0, cfr$RAmt[i], 0)
#   maxP = which(probs==max(probs))
#   XatMaxP = min(amts[maxP])
#   cfr$LRef[i] = XatMaxP; cfr$RRef[i] = XatMaxP
# }
# set.seed(4)
# source("FitandPlotProspectTheory.R")
# results$XatMaxP = data_optim_quad_pars
# RDValues$Model = "XatMaxP"
# RDValuesDF = rbind(RDValuesDF, RDValues)
# 
# 
# ####################################
# # Expected Value
# ####################################
# RDRule = "ExpectedValue"
# cfr = ecfr %>%
#   mutate(
#     LRef = LAmt * LProb,
#     RRef = RAmt * RProb
#   )
# set.seed(4)
# source("FitandPlotProspectTheory.R")
# results$ExpectedValue = data_optim_quad_pars
# RDValues$Model = "Expected Value"
# RDValuesDF = rbind(RDValuesDF, RDValues)
# 
# 
# ####################################
# # Prospect Itself
# ####################################
# RDRule = "ProspectItself"
# set.seed(4)
# source("FitandPlotKozegiRabin.R")
# results$ProspectItself = data_optim_quad_pars
# RDValues$Model = "Prospect Itself"
# RDValuesDF = bind_rows(RDValuesDF, RDValues)
