################################################################################
# Preamble
################################################################################

# Libraries
rm(list=ls())
seed = 4
library(tidyverse)
library(brms)

# Directories
.datadir = file.path("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/datasets")
.tempdir = file.path("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp/model_free_model_comparison")

# BRMS settings
cc = 3
iter = 6000
brm <- function(...)
  brms::brm(
    ...,
    iter = iter,
    warmup = floor(iter/2),
    chains = cc,
    cores = cc,
    seed = seed,
    refresh = F,
    file_refit = "on_change")

# Data
load(file.path(.datadir, "ecfr.RData"))
ecfr = ecfr[ecfr$firstFix==T,]
ecfr$oV = ecfr$vL + ecfr$vR

study1 = ecfr[ecfr$studyN==1,]
study2 = ecfr[ecfr$studyN==2,]
study1G = ecfr[ecfr$studyN==1 & ecfr$condition=="Gain",]
study2G = ecfr[ecfr$studyN==2 & ecfr$condition=="Gain",]
study1L = ecfr[ecfr$studyN==1 & ecfr$condition=="Loss",]
study2L = ecfr[ecfr$studyN==2 & ecfr$condition=="Loss",]


################################################################################
# LOSS
################################################################################

##########
# Study 1
##########

# There is not enough variation in the effect of overall value between subjects. That means sd(oV) ends up being too small and the sampler goes crazy trying to figure out how to sample from it's posterior. It causes a bunch of divergent transitions and issues with low Effective Sample Size. As soon as you take out subject-level variation in the effect of overall value on log(rt), these problems go away. That's why I've opted to only include a population-level effect of overall value. I bet this is because we have such a small range of overall value in Study 1 and the stimuli are perceptual.

study1L_rt_oV_Loss = brm(
  log(rt) ~ 1 + abs(vDiff) + oV + (1 + abs(vDiff) | subject),
  data = study1L,
  family = gaussian(),
  prior = c(
    prior(normal(0,0.5), class=Intercept),
    prior(normal(0,0.3), class="b", coef="absvDiff"),
    prior(normal(0,0.1), class="b", coef="oV")
  ),
  control = list(adapt_delta = 0.9),
  file = file.path(.tempdir, "Study1L_rt_oV_Loss")
)
summary(study1L_rt_oV_Loss)


##########
# Study 2
##########

# In Study 2, there was sufficient variation between subjects in the effect for overall value, so it was reintroduced back into the regression. This did not produce any errors or warnings like in Study 1. I bet this is because we have a larger range of overall values in this study and because the stimuli are numeric.

study2L_rt_oV_Loss = brm(
  log(rt) ~ 1 + abs(vDiff) + oV + (1 + abs(vDiff) + oV | subject),
  data = study2L,
  family = gaussian(),
  prior = c(
    prior(normal(0,0.5), class=Intercept),
    prior(normal(0,0.3), class="b", coef="absvDiff"),
    prior(normal(0,0.1), class="b", coef="oV")
  ),
  control = list(adapt_delta = 0.9),
  file = file.path(.tempdir, "Study2L_rt_oV_Loss")
)
summary(study2L_rt_oV_Loss)


################################################################################
# GAIN
################################################################################

##########
# Study 1
##########

# There is not enough variation in the effect of overall value between subjects. That means sd(oV) ends up being too small and the sampler goes crazy trying to figure out how to sample from it's posterior. It causes a bunch of divergent transitions and issues with low Effective Sample Size. As soon as you take out subject-level variation in the effect of overall value on log(rt), these problems go away. That's why I've opted to only include a population-level effect of overall value. I bet this is because we have such a small range of overall value in Study 1 and the stimuli are perceptual.

study1L_rt_oV_Gain = brm(
  log(rt) ~ 1 + abs(vDiff) + oV + (1 + abs(vDiff) | subject),
  data = study1G,
  family = gaussian(),
  prior = c(
    prior(normal(0,0.5), class=Intercept), 
    prior(normal(0,0.3), class="b", coef="absvDiff"),
    prior(normal(0,0.1), class="b", coef="oV")
  ),
  control = list(adapt_delta = 0.9),
  file = file.path(.tempdir, "Study1L_rt_oV_Gain")
)
summary(study1L_rt_oV_Gain)


##########
# Study 2
##########

# In Study 2, there was sufficient variation between subjects in the effect for overall value, so it was reintroduced back into the regression. This did not produce any errors or warnings like in Study 1. I bet this is because we have a larger range of overall values in this study and because the stimuli are numeric.

study2L_rt_oV_Gain = brm(
  log(rt) ~ 1 + abs(vDiff) + oV + (1 + abs(vDiff) + oV | subject),
  data = study2G,
  family = gaussian(),
  prior = c(
    prior(normal(0,0.5), class=Intercept), 
    prior(normal(0,0.3), class="b", coef="absvDiff"),
    prior(normal(0,0.1), class="b", coef="oV")
  ),
  control = list(adapt_delta = 0.9),
  file = file.path(.tempdir, "Study2L_rt_oV_Gain")
)
summary(study2L_rt_oV_Gain)