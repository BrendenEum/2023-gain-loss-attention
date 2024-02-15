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
source(file.path(addmdir, "get_estimates_likelihoods.R"))
source("sim_aDDM_trial.R")

Nsim = 10


####################################################
## ESTIMATES
####################################################

dots_est = read_estimates(fitdir=fitdir, study="dots", model="GDaDDM", dataset="e")
numeric_est = read_estimates(fitdir=fitdir, study="numeric", model="GDaDDM", dataset="e")


####################################################
## GET OUT-SAMPLE DATA
####################################################

load(file.path(datadir, "ecfr.RData"))
cfr = ecfr[ecfr$trial%%2==0 & ecfr$sanity==0,] #out-sample data
cfr$minValue[cfr$condition=="Gain"] = 1
cfr$minValue[cfr$condition=="Loss"] = -6
dots = cfr[cfr$study=="dots",]
numeric = cfr[cfr$study=="numeric",]

####################################################
## SIMULATE DOTS
####################################################

dots_sim = list()
i = 0
for (subject in unique(dots$subject)) {
  i = i+1
  print(paste0("Subject ", subject, "================================"))

  # Estimates
  est = dots_est[i,]

  # Fixation Properties
  prFirstLeft = mean(abs(as.numeric(dots$location[dots$firstFix==T])-2))
  firstFix = dots$fix_dur[dots$firstFix==T]*1000 #ms
  middleFix = dots$fix_dur[dots$middleFix==T]*1000
  latency = dots$latency[dots$firstFix==T]*1000
  transition = dots$transition[dots$firstFix==F]*1000

  # Get trial data
  voi = c("studyN","subject","trial","condition","vL","vR","nvDiff","ndifficulty","fixCrossLoc","minValue","maxValue")
  subject_cfr = dots[dots$subject==subject & dots$firstFix==T, voi]

  # Loop through trials and simulate "sim" times
  subject_sim = list()
  for (iteration in c(1:Nsim)) {
    print(paste0("  Iteration ", iteration))

    iteration_sim = subject_cfr
    iteration_sim$sim = iteration
    iteration_sim$choice = NA; iteration_sim$rt = NA; iteration_sim$lastFixLoc = NA; iteration_sim$netFixLeft = NA
    iteration_sim$firstFixDur = NA; iteration_sim$firstFixLoc = NA

    for (row in c(1:nrow(iteration_sim))){
      if (row%%100==0) {print(paste0("    Trial ", row, " Completed"))}

      if (iteration_sim$condition[row]=="Gain"){
        d = est$d.gain/10 #convert to 1 ms timesteps
        s = est$s.gain/10
        b = est$b.gain
        t = est$t.gain
        k = est$k.gain
      }
      if (iteration_sim$condition[row]=="Loss"){
        d = est$d.loss/10
        s = est$s.loss/10
        b = est$b.loss
        t = est$t.loss
        k = est$k.loss
      }

      while (TRUE) {
        simulated_trial = simulate.trial(
          study = "dots", model = "GDaDDM",
          d = d, s = s, b = b, t = t, k = k,
          vL = iteration_sim$vL[row], vR = iteration_sim$vR[row], 
          vMin = iteration_sim$minValue[row], vMax = NA,
          fixCrossLoc = NA, prFirstLeft = prFirstLeft,
          firstFix = firstFix, middleFix = middleFix,
          latency = latency, transition = transition,
          maximum_rt = 20000
        )
        if (!is.na(simulated_trial$rt)) {break}
      }

      iteration_sim$choice[row] = simulated_trial$choice
      iteration_sim$rt[row] = simulated_trial$rt/1000
      iteration_sim$lastFixLoc[row] = simulated_trial$lastFixLoc
      iteration_sim$netFixLeft[row] = simulated_trial$netFixLeft/1000
      iteration_sim$firstFixDur[row] = simulated_trial$firstFixDur/1000
      iteration_sim$firstFixLoc[row] = simulated_trial$firstFixLoc
    }

    subject_sim[[iteration]] = iteration_sim
  }
  dots_sim[[i]] = subject_sim
}

fdots_sim = dots_sim[[1]][[1]][1,] 
fdots_sim[1,] = NA
for (i in c(1:length(dots_sim))) {
  for (j in c(1:length(dots_sim[[i]]))) {
    fdots_sim = rbind(fdots_sim, dots_sim[[i]][[j]])
  }
}
fdots_sim = fdots_sim[2:nrow(fdots_sim),]

save(fdots_sim, file=file.path(tempdir, "fdots_sim_GDaDDM.RData"))

####################################################
## SIMULATE NUMERIC
####################################################

numeric_sim = list()
i = 0
for (subject in unique(numeric$subject)) {
  i = i+1
  print(paste0("Subject ", subject, "================================"))
  
  # Estimates
  est = numeric_est[i,]
  
  # Fixation Properties
  prFirstLeft = mean(abs(as.numeric(numeric$location[numeric$firstFix==T & numeric$fixCrossLoc=="Center"])-2))
  firstFix = numeric$fix_dur[numeric$firstFix==T]*1000 #ms
  middleFix = numeric$fix_dur[numeric$middleFix==T]*1000
  latency = round(numeric$latency[numeric$firstFix==T],3)*1000
  transition = round(numeric$transition[numeric$firstFix==F],3)*1000
  
  # Get trial data
  voi = c("studyN","subject","trial","condition","vL","vR","nvDiff","ndifficulty","fixCrossLoc","minValue","maxValue")
  subject_cfr = numeric[numeric$subject==subject & numeric$firstFix==T, voi]
  
  # Loop through trials and simulate "sim" times
  subject_sim = list()
  for (iteration in c(1:Nsim)) {
    print(paste0("  Iteration ", iteration))
    
    iteration_sim = subject_cfr
    iteration_sim$sim = iteration
    iteration_sim$choice = NA; iteration_sim$rt = NA; iteration_sim$lastFixLoc = NA; iteration_sim$netFixLeft = NA
    iteration_sim$firstFixDur = NA; iteration_sim$firstFixLoc = NA
    
    for (row in c(1:nrow(iteration_sim))){
      if (row%%80==0) {print(paste0("    Trial ", row, " Completed"))}
      
      if (iteration_sim$condition[row]=="Gain"){
        d = est$d.gain/10 #convert to 1 ms timesteps
        s = est$s.gain/10
        b = est$b.gain
        t = est$t.gain
        k = est$k.gain
      }
      if (iteration_sim$condition[row]=="Loss"){
        d = est$d.loss/10
        s = est$s.loss/10
        b = est$b.loss
        t = est$t.loss
        k = est$k.loss
      }
      
      while (TRUE) {
        simulated_trial = simulate.trial(
          study = "numeric", model = "GDaDDM",
          d = d, s = s, b = b, t = t, k = k,
          vL = iteration_sim$vL[row], vR = iteration_sim$vR[row],
          vMin = iteration_sim$minValue[row], vMax = NA,
          fixCrossLoc = iteration_sim$fixCrossLoc[row], prFirstLeft = prFirstLeft,
          firstFix = firstFix, middleFix = middleFix,
          latency = latency, transition = transition,
          maximum_rt = 20000
        )
        if (!is.na(simulated_trial$rt)) {break}
      }
      
      iteration_sim$choice[row] = simulated_trial$choice
      iteration_sim$rt[row] = simulated_trial$rt/1000
      iteration_sim$lastFixLoc[row] = simulated_trial$lastFixLoc
      iteration_sim$netFixLeft[row] = simulated_trial$netFixLeft/1000
      iteration_sim$firstFixDur[row] = simulated_trial$firstFixDur/1000
      iteration_sim$firstFixLoc[row] = simulated_trial$firstFixLoc
    }
    
    subject_sim[[iteration]] = iteration_sim
  }
  numeric_sim[[i]] = subject_sim
}

fnumeric_sim = numeric_sim[[1]][[1]][1,] 
fnumeric_sim[1,] = NA
for (i in c(1:length(numeric_sim))) {
  for (j in c(1:length(numeric_sim[[i]]))) {
    fnumeric_sim = rbind(fnumeric_sim, numeric_sim[[i]][[j]])
  }
}
fnumeric_sim = fnumeric_sim[2:nrow(fnumeric_sim),]

save(fnumeric_sim, file=file.path(tempdir, "fnumeric_sim_GDaDDM.RData"))

