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

#------------- Things you should edit at the start -------------
.dataset = "e"
.colors = list(Gain="Green4", Loss="Red3")
.simdir = file.path("../../outputs/temp/out_of_sample_simulations/2024.06.27.17.20/AddDDM")
.nSims = 10
#---------------------------------------------------------------

.cfrdir = file.path("../../../data/processed_data/datasets")
.figdir = file.path("../../outputs/figures")
.optdir = file.path("../plot_options/")
source(file.path(.optdir, "GainLossColorPalette.R"))
source(file.path(.optdir, "MyPlotOptions.R"))


##############################################################################
# Load Data
##############################################################################

## Real Data

load(file.path(.cfrdir, paste0(.dataset, "cfr.RData")))
.cfr = ecfr
cfr_out = .cfr[.cfr$trial%%10==0,]
cfr_out$simulated = 0
study1_subjects = unique(.cfr$subject[.cfr$studyN==1])
study2_subjects = unique(.cfr$subject[.cfr$studyN==2])

## Simulated data

# study 1
simData = data.frame()
for (j in study1_subjects) {
  for (k in 1:.nSims) {
    
    expdataGain = read.csv(file.path(.simdir, glue("sim_data_beh_{j}_{k}_Study1_Gain.csv")))
    fixationsGain = read.csv(file.path(.simdir, glue("sim_data_fix_{j}_{k}_Study1_Gain.csv")))
    simDataGain = merge(expdataGain, fixationsGain, by=c("studyN","parcode","condition","trial","sim"))
    simDataGain$trial = simDataGain$trial*10
    
    expdataLoss = read.csv(file.path(.simdir, glue("sim_data_beh_{j}_{k}_Study1_Loss.csv")))
    fixationsLoss = read.csv(file.path(.simdir, glue("sim_data_fix_{j}_{k}_Study1_Loss.csv")))
    simDataLoss = merge(expdataLoss, fixationsLoss, by=c("studyN","parcode","condition","trial","sim"))
    simDataLoss$trial = simDataLoss$trial*10 + 200
    
    simData = do.call("bind_rows", list(simData, simDataGain, simDataLoss))
  }
}
# study 2
for (j in study2_subjects) {
  for (k in 1:.nSims) {
    
    expdataGain = read.csv(file.path(.simdir, glue("sim_data_beh_{j}_{k}_Study2_Gain.csv")))
    fixationsGain = read.csv(file.path(.simdir, glue("sim_data_fix_{j}_{k}_Study2_Gain.csv")))
    simDataGain = merge(expdataGain, fixationsGain, by=c("studyN","parcode","condition","trial","sim"))
    simDataGain$trial = simDataGain$trial*10
    
    expdataLoss = read.csv(file.path(.simdir, glue("sim_data_beh_{j}_{k}_Study2_Loss.csv")))
    fixationsLoss = read.csv(file.path(.simdir, glue("sim_data_fix_{j}_{k}_Study2_Loss.csv")))
    simDataLoss = merge(expdataLoss, fixationsLoss, by=c("studyN","parcode","condition","trial","sim"))
    simDataLoss$trial = simDataLoss$trial*10 + 160 # 162 non-sanity trials, floored to nearest tenth
    
    simData = do.call("bind_rows", list(simData, simDataGain, simDataLoss))
  }
}

simData = simData[simData$fix_item!=0,] %>% # exclude simulated latency & saccades
  mutate(
    studyN = ifelse(studyN==1, "1", "2"),
    subject = parcode,
    condition = factor(condition, levels=c("Gain","Loss"), labels=c("Gain", "Loss")),
    trial = trial,
    sim = sim,
    choice = ifelse(choice==-1, 1, 0),
    rt = rt/1000,
    vL = LProb*LAmt,
    vR = RProb*RAmt,
    vDiff = vL - vR,
    nvDiff = ifelse( # see clean*.R in preprocessing
      studyN==1,
      as.numeric(as.character(cut(vDiff, seq(-1.125,1.125,.25), labels=seq(-1,1,.25)))), 
      as.numeric(as.character(cut(round(vDiff,3), seq(-10.5,10.5,1), labels=seq(-10,10,1))))/4
    ),
    location = factor(fix_item, levels = c(1, 2), labels = c("Left", "Right")),
    fix_dur = fix_time/1000,
    simulated = 1
  )
# net fixation
simData = simData %>%
  mutate(net_fix = ifelse(location=="Left", fix_dur, -fix_dur)) %>%
  group_by(sim, studyN, subject, condition, trial) %>%
  mutate(
    net_fix = cumsum(net_fix),
    net_fix = last(net_fix)
  )
# first and last fixations
simData = simData %>%
  group_by(sim, studyN, subject, condition, trial) %>%
  mutate(
    firstFix = as.numeric(row_number()==1),
    lastFix = as.numeric(row_number()==n()),
  )
# corrected choice
simData = simData %>%
  group_by(sim, studyN, subject, condition, nvDiff) %>%
  mutate(
    nchoice.corr = choice - mean(choice)
  )

## combine

pdata_raw = bind_rows(cfr_out, simData)
pdata_raw$simulated = factor(pdata_raw$simulated, levels=c(0,1), labels=c("Observed","Simulated"))
pdata_raw$studyN = factor(pdata_raw$studyN, levels=c(1,2), labels=c("Study 1","Study 2"))
pdata_raw$condition = factor(pdata_raw$condition, levels=c("Gain","Loss"), labels=c("Gain","Loss")) #reorder


##############################################################################
# Figuring out why attentional discounting has such a small effect in gains.
# d/sig is the same in both conditions, so why does theta have so little impact on gains in sim. behav?
# It's because the distribution of values look very different in both conditions.
##############################################################################

pd = data.frame(
  value = c(simData$item_left, simData$item_right),
  side = c(rep("Left", nrow(simData)), rep("Right", nrow(simData))),
  subject = c(simData$subject, simData$subject),
  condition = c(simData$condition, simData$condition),
  studyN = c(simData$studyN, simData$studyN)
) %>%
  group_by(studyN, subject, condition) %>%
  mutate(RNvalue = value / max(abs(value)))

ggplot(data = pd) +
  
  geom_histogram(aes(x = value, fill = condition), position = "identity", alpha = .5) +
  
  scale_fill_manual(values = c("Loss" = "red3", "Gain" = "green4")) +
  facet_grid(rows = vars(side), cols = vars(studyN)) +
  theme_bw()



pd = simData %>% 
  mutate(
    value = c(item_left - item_right)
  )

ggplot(data = pd) +
  
  geom_histogram(aes(x = value, fill = condition), position = "identity", alpha = .5) +
  
  scale_fill_manual(values = c("Loss" = "red3", "Gain" = "green4")) +
  facet_grid(cols = vars(studyN)) +
  theme_bw()




##############################################################################
# Psychometric Curve
##############################################################################

## Data

pdata = pdata_raw[pdata_raw$firstFix == T,] %>%
  group_by(simulated, studyN, subject, condition, nvDiff) %>%
  summarize(
    meanChoice = mean(choice)
  ) %>% ungroup() %>%
  group_by(simulated, studyN, condition, nvDiff) %>%
  summarize(
    y = mean(meanChoice),
    se = std.error(meanChoice)
  )

## Plot

plt.choice = ggplot(pdata, aes(x=nvDiff, y=y)) +
  myPlot + 
  geom_vline(xintercept = 0, color = "grey85") +
  geom_hline(yintercept = .5, color = "grey85") +
  
  geom_line(aes(linetype = simulated, color = condition), linewidth = 1) +
  geom_errorbar(
    aes(ymin = y-se, ymax = y+se, group = simulated, color = condition), 
    width = 0, position = position_dodge(width=.05), linewidth = 1
  ) +
  
  labs(
    y = "Pr(Choose Left)", 
    x = "Norm. Left - Right E[v]"
  ) +
  coord_cartesian(expand=T) +
  scale_y_continuous(breaks=c(0,.5,1)) +
  scale_x_continuous(breaks=c(-1,0,1)) +
  theme(
    legend.title = element_blank(),
    legend.position = c(0,1),
    legend.justification = c(0,1)
  ) +
  guides(color = "none") +
  facet_grid(rows = vars(condition), cols = vars(studyN))


##############################################################################
# RT Curve
##############################################################################

## Data

pdata = pdata_raw[pdata_raw$firstFix == T, ] %>%
  group_by(simulated, studyN, subject, condition, nvDiff) %>%
  summarize(
    meanRT = mean(rt)
  ) %>% ungroup() %>%
  group_by(simulated, studyN, condition, nvDiff) %>%
  summarize(
    y = mean(meanRT),
    se = std.error(meanRT)
  )

## Plot

plt.rt = ggplot(pdata, aes(x=nvDiff, y=y)) +
  myPlot + 
  
  geom_vline(xintercept = 0, color = "grey85") +
  
  geom_line(aes(linetype = simulated, color = condition), linewidth = 1) +
  geom_errorbar(
    aes(ymin = y-se, ymax = y+se, group = simulated, color = condition), 
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
  ) +
  guides(color = "none") +
  facet_grid(rows = vars(condition), cols = vars(studyN))


##############################################################################
# Net Fixation Curve
##############################################################################

## Data

breaks <- seq(-1.625,1.625,.250)
labels <- seq(-1.500,1.500,.250)
pdata_raw$net_fix <- cut(pdata_raw$net_fix, breaks=breaks, labels=labels) %>%
  as.character() %>%
  as.numeric()

pdata = pdata_raw[pdata_raw$lastFix == T,] %>%
  group_by(simulated, studyN, subject, condition, net_fix) %>%
  summarize(
    meanChoice = mean(nchoice.corr)
  ) %>% ungroup() %>% na.omit() %>%
  group_by(simulated, studyN, condition, net_fix) %>%
  summarize(
    y = mean(meanChoice),
    se = std.error(meanChoice)
  )

## Plot

plt.net = ggplot(pdata, aes(x=net_fix, y=y)) +
  myPlot + 
  geom_vline(xintercept = 0, color = "grey85") +
  geom_hline(yintercept = 0, color = "grey85") +
  
  geom_line(aes(linetype = simulated, color = condition), linewidth = 1) +
  geom_errorbar(
    aes(ymin = y-se, ymax = y+se, group = simulated, color = condition), 
    width = 0, position = position_dodge(width=.05), linewidth = 1
  ) +
  
  labs(
    y = "Corr. Pr(Choose Left)", 
    x = "Net Fixation (L-R, s)"
  ) +
  coord_cartesian(xlim = c(-1.5, 1.5), expand=T) +
  scale_x_continuous(breaks=c(-1,0,1)) +
  #scale_y_continuous(breaks=c(-.5,0,.5)) +
  theme(
    legend.position = "none"
  ) +
  guides(color = "none") +
  facet_grid(rows = vars(condition), cols = vars(studyN))


##############################################################################
# Last Fixation Curve
##############################################################################

## Data

pdata_raw$choiceFactor = factor(pdata_raw$choice, levels = c(1,0), labels = c("Left", "Right"))

pdata = pdata_raw[pdata_raw$lastFix == T,] %>%
  mutate(
    lastSeenChosen = (choiceFactor==location),
    lastOtherVDiff = ifelse(location=="Left", vL-vR, vR-vL),
    nlastOtherVDiff = ifelse( # see clean*.R in preprocessing
      studyN=="Study 1",
      as.numeric(as.character(cut(lastOtherVDiff, seq(-1.125,1.125,.25), labels=seq(-1,1,.25)))), 
      as.numeric(as.character(cut(round(lastOtherVDiff,3), seq(-10.5,10.5,1), labels=seq(-10,10,1))))/4
    ),
  ) %>%
  group_by(simulated, studyN, subject, condition, nlastOtherVDiff) %>%
  summarize(
    meanChoice = mean(lastSeenChosen)
  ) %>% ungroup() %>%
  group_by(simulated, studyN, condition, nlastOtherVDiff) %>%
  summarize(
    y = mean(meanChoice),
    se = std.error(meanChoice)
  )

## Plot

plt.last = ggplot(pdata, aes(x=nlastOtherVDiff, y=y)) +
  myPlot + 
  geom_vline(xintercept = 0, color = "grey85") +
  geom_hline(yintercept = .5, color = "grey85") +
  
  geom_line(aes(linetype = simulated, color = condition), linewidth = 1) +
  geom_errorbar(
    aes(ymin = y-se, ymax = y+se, group = simulated, color = condition), 
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
  ) +
  guides(color = "none") +
  facet_grid(rows = vars(condition), cols = vars(studyN))


##############################################################################
# Combine plots
##############################################################################

plt.outsample <- grid.arrange(
  plt.choice, plt.rt, 
  plt.net, plt.last,
  ncol = 2
)

plot(plt.outsample)

ggsave(file.path(.figdir, "AddDDM_OutOfSamplePredictions.pdf"), plt.outsample, height=10, width=13, units="in")

