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
ds = "_J"
load(file.path(.datadir, "jcfr.RData"))
cfr = jcfr
# -------------------------------------------------------------------------------------------
cfr = cfr[cfr$firstFix==T,]
cfr$oV = cfr$vL + cfr$vR

study1 = cfr[cfr$studyN==1,]
study2 = cfr[cfr$studyN==2,]
study1G = cfr[cfr$studyN==1 & cfr$condition=="Gain",]
study2G = cfr[cfr$studyN==2 & cfr$condition=="Gain",]
study1L = cfr[cfr$studyN==1 & cfr$condition=="Loss",]
study2L = cfr[cfr$studyN==2 & cfr$condition=="Loss",]


################################################################################
# LOSS
################################################################################

##########
# Study 1
##########

study1L$z_oV = scale(study1L$oV)

study1L_rt_oV = brm(
  log(rt) ~ 1 + abs(vDiff) + z_oV + (1 + abs(vDiff) + z_oV | subject),
  data = study1L,
  family = gaussian(),
  prior = c(
    prior(normal(0,0.5), class=Intercept),
    prior(normal(0,0.3), class="b", coef="absvDiff"),
    prior(normal(0,0.1), class="b", coef="z_oV"),
    prior(normal(0, 0.5), class = "sd", group = "subject", coef = "Intercept"),
    prior(normal(0, 0.1), class = "sd", group = "subject", coef = "absvDiff"),
    prior(normal(0, 0.05), class = "sd", group = "subject", coef = "z_oV")
  ),
  file = file.path(.tempdir, paste0("study1L_rt_oV", ds))
)
summary(study1L_rt_oV)
formatted_estimates <- sprintf("%.6f", study1L_rt_oV$fixed[, "Estimate"])
formatted_errors <- sprintf("%.6f", study1L_rt_oV$fixed[, "Est.Error"])
formatted_output <- data.frame(Estimate = formatted_estimates, Est.Error = formatted_errors)
print(formatted_output)


##########
# Study 2
##########

study2L$z_oV = scale(study2L$oV)

study2L_rt_oV = brm(
  log(rt) ~ 1 + abs(vDiff) + z_oV + (1 + abs(vDiff) + z_oV | subject),
  data = study2L,
  family = gaussian(),
  prior = c(
    prior(normal(0,0.5), class=Intercept),
    prior(normal(0,0.3), class="b", coef="absvDiff"),
    prior(normal(0,0.1), class="b", coef="z_oV"),
    prior(normal(0, 0.5), class = "sd", group = "subject", coef = "Intercept"),
    prior(normal(0, 0.1), class = "sd", group = "subject", coef = "absvDiff"),
    prior(normal(0, 0.05), class = "sd", group = "subject", coef = "z_oV")
  ),
  file = file.path(.tempdir, paste0("study2L_rt_oV", ds))
)
summary(study2L_rt_oV)


if (ds == "_J") {
  ################################################################################
  # GAIN
  ################################################################################
  
  ##########
  # Study 1
  ##########
  
  study1G$z_oV = scale(study1G$oV)
  
  study1G_rt_oV = brm(
    log(rt) ~ 1 + abs(vDiff) + z_oV + (1 + abs(vDiff) + z_oV | subject),
    data = study1G,
    family = gaussian(),
    prior = c(
      prior(normal(0,0.5), class=Intercept), 
      prior(normal(0,0.3), class="b", coef="absvDiff"),
      prior(normal(0,0.1), class="b", coef="z_oV"),
      prior(normal(0, 0.5), class = "sd", group = "subject", coef = "Intercept"),
      prior(normal(0, 0.1), class = "sd", group = "subject", coef = "absvDiff"),
      prior(normal(0, 0.05), class = "sd", group = "subject", coef = "z_oV")
    ),
    file = file.path(.tempdir, paste0("study1G_rt_oV", ds))
  )
  summary(study1G_rt_oV)
  
  
  ##########
  # Study 2
  ##########
  
  study2G$z_oV = scale(study2G$oV)
  
  study2G_rt_oV = brm(
    log(rt) ~ 1 + abs(vDiff) + z_oV + (1 + abs(vDiff) + z_oV | subject),
    data = study2G,
    family = gaussian(),
    prior = c(
      prior(normal(0,0.5), class=Intercept), 
      prior(normal(0,0.3), class="b", coef="absvDiff"),
      prior(normal(0,0.1), class="b", coef="z_oV"),
      prior(normal(0, 0.5), class = "sd", group = "subject", coef = "Intercept"),
      prior(normal(0, 0.1), class = "sd", group = "subject", coef = "absvDiff"),
      prior(normal(0, 0.05), class = "sd", group = "subject", coef = "z_oV")
    ),
    file = file.path(.tempdir, paste0("study2G_rt_oV", ds))
  )
  summary(study2G_rt_oV)
}