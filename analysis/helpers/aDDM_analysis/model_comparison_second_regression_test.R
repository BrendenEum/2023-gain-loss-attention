################################################################################
# Preamble
################################################################################

# Libraries
rm(list=ls())
seed = 4
library(tidyverse)
library(brms)
library(bayesplot)

# Directories
.datadir = file.path("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/datasets")
.tempdir = file.path("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp/model_free_model_comparison")

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
    refresh = F,
    file_refit = "always")

# Data
# -------------------------------------------------------------------------------------------
ds = "_C"
load(file.path(.datadir, "ccfr.RData"))
cfr = ccfr
# -------------------------------------------------------------------------------------------
cfr = cfr[cfr$firstFix==T,]

cfr = cfr[cfr$vDiff==0,] # Smith and Krajbich (2019) had a second RT(OV) test for when vDiff = 0.

cfr$oV = cfr$vL + cfr$vR

study1 = cfr[cfr$studyN==1,]
study2 = cfr[cfr$studyN==2,]
study1G = cfr[cfr$studyN==1 & cfr$condition=="Gain",]
study2G = cfr[cfr$studyN==2 & cfr$condition=="Gain",]
study1L = cfr[cfr$studyN==1 & cfr$condition=="Loss",]
study2L = cfr[cfr$studyN==2 & cfr$condition=="Loss",]

studyL = bind_rows(study1L, study2L)
studyG = bind_rows(study1G, study2G)


################################################################################
# LOSS
################################################################################

# Study 1 has 600+ obs.

# Study 2 has 24 obs in E dataset... we need to combine studies to run regression.

##########
# Combined
##########

studyL$z_oV = scale(studyL$oV)

studyL_rt_oV = brm(
  log(rt) ~ 1 + z_oV + (1 + z_oV | subject),
  data = studyL,
  family = gaussian(),
  prior = c(
    prior(normal(0,1), class=Intercept),
    prior(normal(0,0.5), class="b", coef="z_oV"),
    prior(normal(0, 0.5), class = "sd", group = "subject", coef = "Intercept"),
    prior(normal(0, 0.05), class = "sd", group = "subject", coef = "z_oV")
  ),
  file = file.path(.tempdir, paste0("studyL_rt_oV_0vDiff", ds))
)
summary(studyL_rt_oV)


if (ds == "_J") {
  
  ##########
  # Combined
  ##########
  
  studyG$z_oV = scale(studyG$oV)
  
  studyG_rt_oV = brm(
    log(rt) ~ 1 + z_oV + (1 + z_oV | subject),
    data = studyG,
    family = gaussian(),
    prior = c(
      prior(normal(0,1), class=Intercept),
      prior(normal(0,0.5), class="b", coef="z_oV"),
      prior(normal(0, 0.5), class = "sd", group = "subject", coef = "Intercept"),
      prior(normal(0, 0.05), class = "sd", group = "subject", coef = "z_oV")
    ),
    file = file.path(.tempdir, paste0("studyG_rt_oV_0vDiff", ds))
  )
  summary(studyG_rt_oV)
  
}