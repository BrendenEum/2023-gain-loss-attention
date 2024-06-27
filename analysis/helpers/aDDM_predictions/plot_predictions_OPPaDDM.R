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
.colors = list(Gain="Green4", Loss="Red3")
.datetime = readLines("most_recent_simulation.txt")

#------------- Things you should edit at the start -------------
.simdir = file.path(paste0("../../outputs/temp/model_predictions/", .datetime, "/OPPaDDM"))
.estFN = "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_predictions/SimIndividualEstimates_OPPaDDM.csv"
.finalFigFN = "ModelPredictions_OPPaDDM.pdf"
.nSims = 10
#---------------------------------------------------------------

.figdir = file.path("../../outputs/figures")
.optdir = file.path("../plot_options/")
source(file.path(.optdir, "GainLossColorPalette.R"))
source(file.path(.optdir, "MyPlotOptions.R"))


##############################################################################
# Load Data
##############################################################################

## Simulated data

# Number of subjects

SimEst = read.csv(.estFN)
subjects = unique(SimEst$subject)

# study 1
simData = data.frame()
for (j in subjects) {
  for (k in 1:.nSims) {
    
    expdataGain = read.csv(file.path(.simdir, glue("sim_data_beh_{j}_{k}_Gain.csv")))
    fixationsGain = read.csv(file.path(.simdir, glue("sim_data_fix_{j}_{k}_Gain.csv")))
    simDataGain = merge(expdataGain, fixationsGain, by=c("parcode","condition","trial","sim"))
    simDataGain$trial = simDataGain$trial
    
    expdataLoss = read.csv(file.path(.simdir, glue("sim_data_beh_{j}_{k}_Loss.csv")))
    fixationsLoss = read.csv(file.path(.simdir, glue("sim_data_fix_{j}_{k}_Loss.csv")))
    simDataLoss = merge(expdataLoss, fixationsLoss, by=c("parcode","condition","trial","sim"))
    simDataLoss$trial = simDataLoss$trial + 200
    
    simData = do.call("bind_rows", list(simData, simDataGain, simDataLoss))
  }
}

simData = simData[simData$fix_item!=0,] %>% # exclude simulated latency & saccades
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
    location = factor(fix_item, levels = c(1, 2), labels = c("Left", "Right")),
    fix_dur = fix_time/1000,
    simulated = 1
  )
# net fixation
simData = simData %>%
  mutate(net_fix = ifelse(location=="Left", fix_dur, -fix_dur)) %>%
  group_by(sim, subject, condition, trial) %>%
  mutate(
    net_fix = cumsum(net_fix),
    net_fix = last(net_fix)
  )
# first and last fixations
simData = simData %>%
  group_by(sim, subject, condition, trial) %>%
  mutate(
    firstFix = as.numeric(row_number()==1),
    lastFix = as.numeric(row_number()==n()),
  )
# corrected choice
simData = simData %>%
  group_by(sim, subject, condition, nvDiff) %>%
  mutate(
    nchoice.corr = choice - mean(choice)
  )

## combine

simData$condition = factor(simData$condition, levels=c("Gain","Loss"), labels=c("Gain","Loss")) #reorder



##############################################################################
# Psychometric Curve
##############################################################################

## Data

pdata = simData[simData$firstFix == T,] %>%
  group_by(subject, condition, nvDiff) %>%
  summarize(
    meanChoice = mean(choice)
  ) %>% ungroup() %>%
  group_by(condition, nvDiff) %>%
  summarize(
    y = mean(meanChoice),
    se = std.error(meanChoice)
  )

## Plot

plt.choice = ggplot(pdata, aes(x=nvDiff, y=y)) +
  myPlot + 
  geom_vline(xintercept = 0, color = "grey85") +
  geom_hline(yintercept = .5, color = "grey85") +
  
  geom_line(aes(color = condition), linewidth = 1.5) +
  geom_errorbar(
    aes(ymin = y-se, ymax = y+se, color = condition), 
    width = 0, position = position_dodge(width=.05), linewidth = 1
  ) +
  
  labs(
    y = "Pr(Choose Left)", 
    x = "Norm. Left - Right E[v]"
  ) +
  scale_y_continuous(breaks=c(0,.5,1)) +
  scale_x_continuous(breaks=c(-1,0,1)) +
  coord_cartesian(ylim = c(-.05, 1.05), expand=T) +
  theme(
    legend.title = element_blank(),
    legend.position = c(0,.8),
    legend.justification = c(0,1)
  )


##############################################################################
# RT Curve
##############################################################################

## Data

pdata = simData[simData$firstFix == T, ] %>%
  group_by(subject, condition, nvDiff) %>%
  summarize(
    meanRT = mean(rt)
  ) %>% ungroup() %>%
  group_by(condition, nvDiff) %>%
  summarize(
    y = mean(meanRT),
    se = std.error(meanRT)
  )

## Plot

plt.rt = ggplot(pdata, aes(x=nvDiff, y=y)) +
  myPlot + 
  
  geom_vline(xintercept = 0, color = "grey85") +
  
  geom_line(aes(color = condition), linewidth = 1.5) +
  geom_errorbar(
    aes(ymin = y-se, ymax = y+se, color = condition), 
    width = 0, position = position_dodge(width=.05), linewidth = 1
  ) +
  
  labs(
    y = "RT (s)", 
    x = "Norm. Left - Right E[v]"
  ) +
  coord_cartesian(expand=T) +
  scale_x_continuous(breaks=c(-1,0,1)) +
  theme(
    legend.position = "none"
  ) 


##############################################################################
# Net Fixation Curve
##############################################################################

## Data

breaks <- seq(-1.625,1.625,.250)
labels <- seq(-1.500,1.500,.250)
simData$net_fix <- cut(simData$net_fix, breaks=breaks, labels=labels) %>%
  as.character() %>%
  as.numeric()

pdata = simData[simData$lastFix == T,] %>%
  group_by(subject, condition, net_fix) %>%
  summarize(
    meanChoice = mean(nchoice.corr)
  ) %>% ungroup() %>% na.omit() %>%
  group_by(condition, net_fix) %>%
  summarize(
    y = mean(meanChoice),
    se = std.error(meanChoice)
  )

## Plot

plt.net = ggplot(pdata, aes(x=net_fix, y=y)) +
  myPlot + 
  geom_vline(xintercept = 0, color = "grey85") +
  geom_hline(yintercept = 0, color = "grey85") +
  
  geom_line(aes(color = condition), linewidth = 1.5) +
  geom_errorbar(
    aes(ymin = y-se, ymax = y+se, color = condition), 
    width = 0, position = position_dodge(width=.05), linewidth = 1
  ) +
  
  labs(
    y = "Corr. Pr(Choose Left)", 
    x = "Net Fixation (L-R, s)"
  ) +
  coord_cartesian(xlim = c(-1.5, 1.5), expand=T) +
  scale_x_continuous(breaks=c(-1,0,1)) +
  theme(
    legend.position = "none"
  ) 


##############################################################################
# Last Fixation Curve
##############################################################################

## Data

simData$choiceFactor = factor(simData$choice, levels = c(1,0), labels = c("Left", "Right"))

pdata = simData[simData$lastFix == T,] %>%
  mutate(
    lastSeenChosen = (choiceFactor==location),
    lastOtherVDiff = ifelse(location=="Left", vL-vR, vR-vL),
    nlastOtherVDiff = as.numeric(as.character(cut(round(lastOtherVDiff,3), seq(-10.5,10.5,1), labels=seq(-10,10,1))))/4 ,
  ) %>%
  group_by(subject, condition, nlastOtherVDiff) %>%
  summarize(
    meanChoice = mean(lastSeenChosen)
  ) %>% ungroup() %>%
  group_by(condition, nlastOtherVDiff) %>%
  summarize(
    y = mean(meanChoice),
    se = std.error(meanChoice)
  )

## Plot

plt.last = ggplot(pdata, aes(x=nlastOtherVDiff, y=y)) +
  myPlot + 
  geom_vline(xintercept = 0, color = "grey85") +
  geom_hline(yintercept = .5, color = "grey85") +
  
  geom_line(aes(color = condition), linewidth = 1.5) +
  geom_errorbar(
    aes(ymin = y-se, ymax = y+se, color = condition), 
    width = 0, position = position_dodge(width=.05), linewidth = 1
  ) +
  
  labs(
    y = "Pr(Choose Last Fix. Option)", 
    x = "Norm. Last - Other E[V]"
  ) +
  coord_cartesian(xlim = c(-1, 1), ylim = c(0,1), expand=T) +
  scale_x_continuous(breaks=c(-1,0,1)) +
  scale_y_continuous(breaks=c(0,.5,1)) +
  theme(
    legend.position = "none"
  ) 


##############################################################################
# Combine plots
##############################################################################

plt.outsample <- grid.arrange(
  plt.choice, plt.rt, 
  plt.net, plt.last,
  ncol = 4
)

plot(plt.outsample)

ggsave(file.path(.figdir, .finalFigFN), plt.outsample, height=3.8, width=14.5, units="in")

