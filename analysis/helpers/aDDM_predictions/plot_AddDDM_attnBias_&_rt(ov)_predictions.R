#############################################################################
# Preamble
#############################################################################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(effsize)
library(plotrix)
library(ggsci)
library(brms)
source("aDDM_simulate_trial.R")
figdir = file.path("../../outputs/figures")
tempdir = file.path("../../outputs/temp/model_predictions")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))
source(file.path(optdir, "MyBrmsOptions.R"))

N = 25 # subjects
trials = 200 # trials per subject


#############################################################################
# Prepare fake subjects
#############################################################################

d_list = runif(N, min=.001, max=.004) %>% round(digits=3)
s_list = runif(N, min=.01, max=.04) %>% round(digits=2)
b_list = runif(N, min=-.15, max=.15) %>% round(digits=2)
#t_gain_list = runif(N, min=0, max=1) %>% round(digits=1)
#t_loss_list = runif(N, min=1, max=2) %>% round(digits=1)
e_list = runif(N, min=.0001, max=.02) %>% round(digits=4)

prFirstLeft_list = runif(N, min=.6, max=.8) %>% round(digits=2)
firstFix_list = runif(1000, min=300, max=600) %>% round(digits=0)
middleFix_list = runif(1000, min=400, max=800) %>% round(digits=0)
latency_list = runif(1000, min=75, max=175) %>% round(digits=0)
transition_list = runif(1000, min=20, max=75) %>% round(digits=0)


#############################################################################
# Prepare fake stimuli
#############################################################################

vL_gain_list = sample(c(1:6), trials, replace=T)
vR_gain_list = sample(c(1:6), trials, replace=T)

vL_loss_list = sample(c(-6:-1), trials, replace=T)
vR_loss_list = sample(c(-6:-1), trials, replace=T)


#############################################################################
# Simulate
#############################################################################

simData = data.frame()
for (i in 1:N){
  print(i)
  for (j in 1:trials){
    gain_trial = addm_simulate_trial(
      b=b_list[i], d=d_list[i], t=1, s=s_list[i], e=e_list[i], ref=0,
      valueL=vL_gain_list[j], valueR=vR_gain_list[j],
      prFirstLeft=prFirstLeft_list[i], 
      firstFix=firstFix_list, middleFix=middleFix_list, latency=latency_list, transition=transition_list
    )
    gain_trial$subject = i
    gain_trial$trial = j
    gain_trial$condition = "Gain"
    simData = rbind(simData, gain_trial)
  }
  for (j in (trials+1):(2*trials)){
    loss_trial = addm_simulate_trial(
      b=b_list[i], d=d_list[i], t=1, s=s_list[i], e=e_list[i], ref=0,
      valueL=vL_loss_list[j-trials], valueR=vR_loss_list[j-trials],
      prFirstLeft=prFirstLeft_list[i], 
      firstFix=firstFix_list, middleFix=middleFix_list, latency=latency_list, transition=transition_list
    )
    loss_trial$subject = i
    loss_trial$trial = j
    loss_trial$condition = "Loss"
    simData = rbind(simData, loss_trial)
  }
}

simData$studyN = factor(1)
simData$firstFix = T
simData$lastFix = T
simData$vDiff = simData$vL - simData$vR
simData$absvDiff = abs(simData$vDiff)
simData$location = factor(simData$lastFixLoc, levels=c(0,1), labels=c("Right","Left"))
simData$oV = simData$vL + simData$vR

simData = simData %>%
  group_by(studyN, subject, condition, vDiff) %>%
  mutate(
    nchoice.corr = choice - mean(choice)
  )


#############################################################################
# Plot attentional choice biases
#############################################################################

source("../model_free_analysis/ChoiceBiases_Net.R")
netfix_x_scale = c(-1.03, 1.03)
plt.netfix = bias.netfix.plt(simData, xlim=netfix_x_scale) +
  guides(linetype="none") +
  theme(legend.position=c(.25,.8))
ggsave(
  file.path(figdir, "sim_AddDDM_ChoiceBiases_Net.pdf"), 
  plot=plt.netfix, width=figw, height=figh, units="in")

source("../model_free_analysis/ChoiceBiases_Last.R")
plt.lastfix = bias.lastfix.plt(simData, xlim=c(-1.03,1.03)) +
  guides(linetype="none") +
  theme(legend.position="none")
ggsave(
  file.path(figdir, "sim_AddDDM_ChoiceBiases_Last.pdf"), 
  plot=plt.lastfix, width=figw, height=figh, units="in")

source("../model_free_analysis/ChoiceBiases_First.R")
firstfix_x_scale = c(-1.03,1.03)
plt.firstfix = bias.firstfix.plt(simData, xlim=firstfix_x_scale) +
  guides(linetype="none") +
  theme(legend.position="none")
ggsave(
  file.path(figdir, "sim_AddDDM_ChoiceBiases_First.pdf"), 
  plot=plt.firstfix, width=figw, height=figh, units="in")


#############################################################################
# Plot rt(ov)
#############################################################################

regData = simData[simData$condition=="Loss",]

fit = lm(log(rt) ~ 1 + absvDiff + oV, data=regData)
summary(fit)

sim_AddDDM_rt_oV = brm(
  log(rt) ~ 1 + absvDiff + oV + (1 + absvDiff + oV | subject),
  data = regData,
  family = gaussian(),
  prior = c(
    prior(normal(0,1), class=Intercept), 
    prior(normal(0,0.1), class="b", coef="absvDiff"),
    prior(normal(0,0.01), class="b", coef="oV")
  ),
  #control = list(adapt_delta = 0.9),
  file = file.path(tempdir, "sim_AddDDM_rt_oV")
)
summary(sim_AddDDM_rt_oV)
