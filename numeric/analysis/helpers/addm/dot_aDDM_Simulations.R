library(optparse)
library(tidyverse)
library(ggsci)
library(plotrix)

# Note this will be run in docker container so make sure paths are mounted and defined in the env
input_path = "/Users/brenden/Desktop/2023-gain-loss-attention/numeric/data/processed_data/e"
code_path = "/Users/brenden/Desktop/2023-gain-loss-attention/numeric/analysis/helpers/aDDM"
out_path = "/Users/brenden/Desktop/2023-gain-loss-attention/numeric/analysis/outputs/temp"
palette_path = "/Users/brenden/Desktop/2023-gain-loss-attention/numeric/analysis/helpers/plot_options"
toolbox_path = "/Users/brenden/Toolboxes/ADDM.jl/docs/src"

#######################
# Read Data
#######################

load(file.path(input_path, opt$data))
load(file.path(input_path, "cfr.RData"))

#######################
# Plot Options
#######################

source(file.path(palette_path, "GainLossColorPalette.R"))

myPlot = list(
  theme_bw(),
  coord_cartesian(expand=F),
  scale_color_gl("gain_loss_colors"),
  scale_fill_gl("gain_loss_colors"),
  theme(
    legend.position="None",
    legend.background=element_blank(),
    legend.key = element_rect(fill = NA),
    legend.spacing.x = unit(0.1, 'cm'),
    legend.spacing.y = unit(0.1, 'cm'),
    plot.margin = unit(c(.5,.5,.5,.5), "cm"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size = 22),
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 14),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 12)
  ),
  guides(
    color = guide_legend(override.aes=list(fill=NA)),
    fill = guide_legend(byrow = T)
  )
)

linesize = 2
markersize = .1
ribbonalpha = 0.33
figw = 6
figh = 4

#######################
# Simulate attentional biases with discounting
#######################

# Make data

set.seed(4)
source(file.path(code_path, "dot_AddmSimFunctions.R"))

gain.sims <- data.frame()
loss.sims <- data.frame()

for (j in 1:25) {

  b = sample(c(-.02, 0, .02), 1)
  d = sample(c(.002,.003,.004), 1)
  t = sample(c(.1,.25,.5,.75,.9), 1)
  s = sample(c(.02,.03,.04), 1)

  vgain1 = seq(0,1,.25)
  vgain2 = seq(1,0,-.25)
  vloss1 = seq(-1,0,.25)
  vloss2 = seq(0,-1,-.25)

  for (i in 1:5) {
    for (k in 1:40) {

      sim.trial.gain = simulate.trial(
        b = b,
        d = d,
        t = t,
        s = s,
        vL = vgain1[i],
        vR = vgain2[i],
        prFirstLeft = .8,
        firstFix = runif(100, 400, 600),
        middleFix = runif(100, 600, 800),
        latency = runif(100, 100, 200),
        transition = c(100, 10, 30)
      )
      sim.trial.loss = simulate.trial(
        b = b,
        d = d,
        t = t,
        s = s,
        vL = vloss1[i],
        vR = vloss2[i],
        prFirstLeft = .8,
        firstFix = runif(100, 400, 600),
        middleFix = runif(100, 600, 800),
        latency = runif(100, 100, 200),
        transition = c(100, 10, 30)
      )

      sim.trial.gain$subject = j
      sim.trial.loss$subject = j
      gain.sims = rbind(gain.sims, sim.trial.gain)
      loss.sims = rbind(loss.sims, sim.trial.loss)

    }
  }
}

# Last Fixtion Plot

gain.sims$Condition = "Gain"
loss.sims$Condition = "Loss"
gain.sims$Location = gain.sims$lastFix
loss.sims$Location = loss.sims$lastFix
data <- rbind(gain.sims, loss.sims)
data$Condition <- data$Condition %>% factor(levels = c("Loss","Gain"), labels = c("Loss","Gain"))
data$Location <- data$Location %>% factor(levels = c(1,0), labels = c("Left","Right"))
data <- data[data$lastFix!=4, ]

pdata <- data %>%
  group_by(subject, Condition, Location, vDiff) %>%
  summarize(
    choice.mean = mean(choice)
  ) %>%
  ungroup() %>%
  group_by(Condition, Location, vDiff) %>%
  summarize(
    y = mean(choice.mean),
    se = std.error(choice.mean)
  )
pdata = na.omit(pdata)

plt.last.sim <- ggplot(data=pdata, aes(x=vDiff, y=y, linetype=Location)) +
  myPlot +
  geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
  geom_vline(xintercept=0, color="grey", alpha=0.75) +
  geom_line(aes(color=Condition), linewidth=linesize) +
  geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
  xlim(c(-1,1)) +
  ylim(c(-.05,1.05)) +
  labs(y="Pr(Choose Left)", x="Left - Right E[V]", linetype="Final Fixation") +
  theme(
    legend.position = c(0.12,0.75),
    legend.key.height = unit(.5, 'cm'),
    legend.key.width = unit(1.5, 'cm')
  ) +
  scale_linetype_manual(values=c("solid", "dashed")) +
  guides(linetype = guide_legend(override.aes = list(fill = c(NA, NA))))

ggsave(file.path(out_path, "SimulatedLastFixBias_Discounting.pdf"), plot=plt.last.sim, width=figw, height=figh, units="in")

# Net Fixation Plot

breaks <- seq(-1050,1050,100)
labels <- seq(-1000,1000,100)
data$net_fix = data$lr_fixDiff
data$net_fix <- cut(data$net_fix, breaks=breaks, labels=labels) %>%
  as.character() %>%
  as.numeric()

data <- data %>%
  group_by(subject, Condition, vDiff) %>%
  mutate(
    choice.corr = choice - mean(choice)
  )

pdata <- data %>%
  group_by(subject, Condition, net_fix) %>%
  summarize(
    choice.mean = mean(choice.corr)
  ) %>%
  ungroup() %>%
  group_by(Condition, net_fix) %>%
  summarize(
    y = mean(choice.mean),
    se = std.error(choice.mean)
  )

pdata$net_fix = pdata$net_fix/1000
data$Condition <- data$Condition %>% factor(levels = c("Loss","Gain"), labels = c("Loss","Gain"))

plt.net.sim <- ggplot(data=pdata, aes(x=net_fix, y=y, group=Condition)) +
  myPlot +
  geom_hline(yintercept=0, color="grey", alpha=0.75) +
  geom_vline(xintercept=0, color="grey", alpha=0.75) +
  geom_line(aes(color=Condition), linewidth=linesize) +
  geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
  labs(y="Corr. Pr(Choose Left)", x="Net Fixation (L-R, s)") +
  xlim(c(-.51,.51)) +
  ylim(c(-.4,.4))

ggsave(file.path(out_path, "SimulatedNetFixBias_Discounting.pdf"), plot=plt.net.sim, width=figw, height=figh, units="in")

#######################
# Simulate attentional biases with amplification
#######################

# Make data

set.seed(4)
source(file.path(code_path, "dot_AddmSimFunctions.R"))

gain.sims <- data.frame()
loss.sims <- data.frame()

for (j in 1:25) {

  b = sample(c(-.02, 0, .02), 1)
  d = sample(c(.002,.003,.004), 1)
  tgain = sample(c(.1,.25,.5,.75,.9), 1)
  tloss = sample(c(1.1, 1.25, 1.5, 1.75, 1.9), 1)
  s = sample(c(.02,.03,.04), 1)

  vgain1 = seq(0,1,.25)
  vgain2 = seq(1,0,-.25)
  vloss1 = seq(-1,0,.25)
  vloss2 = seq(0,-1,-.25)

  for (i in 1:5) {
    for (k in 1:40) {

      sim.trial.gain = simulate.trial(
        b = b,
        d = d,
        t = tgain,
        s = s,
        vL = vgain1[i],
        vR = vgain2[i],
        prFirstLeft = .8,
        firstFix = runif(100, 400, 600),
        middleFix = runif(100, 600, 800),
        latency = runif(100, 100, 200),
        transition = c(100, 10, 30)
      )
      sim.trial.loss = simulate.trial(
        b = b,
        d = d,
        t = tloss,
        s = s,
        vL = vloss1[i],
        vR = vloss2[i],
        prFirstLeft = .8,
        firstFix = runif(100, 400, 600),
        middleFix = runif(100, 600, 800),
        latency = runif(100, 100, 200),
        transition = c(100, 10, 30)
      )

      sim.trial.gain$subject = j
      sim.trial.loss$subject = j
      gain.sims = rbind(gain.sims, sim.trial.gain)
      loss.sims = rbind(loss.sims, sim.trial.loss)

    }
  }
}

# Last Fixtion Plot

gain.sims$Condition = "Gain"
loss.sims$Condition = "Loss"
gain.sims$Location = gain.sims$lastFix
loss.sims$Location = loss.sims$lastFix
data <- rbind(gain.sims, loss.sims)
data$Condition <- data$Condition %>% factor(levels = c("Loss","Gain"), labels = c("Loss","Gain"))
data$Location <- data$Location %>% factor(levels = c(1,0), labels = c("Left","Right"))
data <- data[data$lastFix!=4, ]

pdata <- data %>%
  group_by(subject, Condition, Location, vDiff) %>%
  summarize(
    choice.mean = mean(choice)
  ) %>%
  ungroup() %>%
  group_by(Condition, Location, vDiff) %>%
  summarize(
    y = mean(choice.mean),
    se = std.error(choice.mean)
  )
pdata = na.omit(pdata)

plt.last.sim <- ggplot(data=pdata, aes(x=vDiff, y=y, linetype=Location)) +
  myPlot +
  geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
  geom_vline(xintercept=0, color="grey", alpha=0.75) +
  geom_line(aes(color=Condition), linewidth=linesize) +
  geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
  xlim(c(-1,1)) +
  ylim(c(-.05,1.05)) +
  labs(y="Pr(Choose Left)", x="Left - Right E[V]", linetype="Final Fixation") +
  theme(
    legend.position = c(0.12,0.75),
    legend.key.height = unit(.5, 'cm'),
    legend.key.width = unit(1.5, 'cm')
  ) +
  scale_linetype_manual(values=c("solid", "dashed")) +
  guides(linetype = guide_legend(override.aes = list(fill = c(NA, NA))))

ggsave(file.path(out_path, "SimulatedLastFixBias_Amplification.pdf"), plot=plt.last.sim, width=figw, height=figh, units="in")

# Net Fixation Plot

breaks <- seq(-1050,1050,100)
labels <- seq(-1000,1000,100)
data$net_fix = data$lr_fixDiff
data$net_fix <- cut(data$net_fix, breaks=breaks, labels=labels) %>%
  as.character() %>%
  as.numeric()

data <- data %>%
  group_by(subject, Condition, vDiff) %>%
  mutate(
    choice.corr = choice - mean(choice)
  )

pdata <- data %>%
  group_by(subject, Condition, net_fix) %>%
  summarize(
    choice.mean = mean(choice.corr)
  ) %>%
  ungroup() %>%
  group_by(Condition, net_fix) %>%
  summarize(
    y = mean(choice.mean),
    se = std.error(choice.mean)
  )

pdata$net_fix = pdata$net_fix/1000
data$Condition <- data$Condition %>% factor(levels = c("Loss","Gain"), labels = c("Loss","Gain"))

plt.net.sim <- ggplot(data=pdata, aes(x=net_fix, y=y, group=Condition)) +
  myPlot +
  geom_hline(yintercept=0, color="grey", alpha=0.75) +
  geom_vline(xintercept=0, color="grey", alpha=0.75) +
  geom_line(aes(color=Condition), linewidth=linesize) +
  geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
  labs(y="Corr. Pr(Choose Left)", x="Net Fixation (L-R, s)") +
  xlim(c(-.51,.51)) +
  ylim(c(-.4,.4))

ggsave(file.path(out_path, "SimulatedNetFixBias_Amplification.pdf"), plot=plt.net.sim, width=figw, height=figh, units="in")

#######################
# Simulate attentional biases with range normalized information
#######################

# Make data

set.seed(4)
source(file.path(code_path, "dot_RNaDDMSimFunctions.R"))

# Get estimates

estG = read.csv(file.path(toolbox_path, "NumericGainFit_RN.csv"))
estL = read.csv(file.path(toolbox_path, "NumericLossFit_RN.csv"))

gain.sims <- data.frame()
loss.sims <- data.frame()

for (j in 1:nrow(est)) {
  
  bG = estG$b[j]
  dG = estG$d[j]
  tG = estG$t[j]
  sG = estG$s[j]
  
  bL = estL$b[j]
  dL = estL$d[j]
  tL = estL$t[j]
  sL = estL$s[j]
  
  vgain1 = seq(1,6,.5)
  vgain2 = seq(6,1,-.5)
  vloss1 = seq(-6,-1,.5)
  vloss2 = seq(-1,-6,-.5)
  
  for (i in 1:length(vgain1)) {
    for (k in 1:40) {
      
      sim.trial.gain = simulate.trial(
        b = bG,
        d = dG,
        t = tG,
        s = sG,
        vL = vgain1[i],
        vR = vgain2[i],
        vMin = 1,
        vMax = 6,
        prFirstLeft = .8,
        firstFix = runif(100, 300, 500),
        middleFix = runif(100, 400, 600),
        latency = runif(100, 100, 200),
        transition = c(100, 10, 30)
      )
      sim.trial.loss = simulate.trial(
        b = bL,
        d = dL,
        t = tL,
        s = sL,
        vL = vloss1[i],
        vR = vloss2[i],
        vMin = -6,
        vMax = -1,
        prFirstLeft = .8,
        firstFix = runif(100, 300, 500),
        middleFix = runif(100, 400, 600),
        latency = runif(100, 100, 200),
        transition = c(100, 10, 30)
      )
      
      sim.trial.gain$subject = j
      sim.trial.loss$subject = j
      gain.sims = rbind(gain.sims, sim.trial.gain)
      loss.sims = rbind(loss.sims, sim.trial.loss)
      
    }
  }
}

# Last Fixtion Plot

gain.sims$Condition = "Gain"
loss.sims$Condition = "Loss"
gain.sims$Location = gain.sims$lastFix
loss.sims$Location = loss.sims$lastFix
data <- rbind(gain.sims, loss.sims)
data$Condition <- data$Condition %>% factor(levels = c("Loss","Gain"), labels = c("Loss","Gain"))
data$Location <- data$Location %>% factor(levels = c(1,0), labels = c("Left","Right"))
data <- data[data$lastFix!=4, ]

pdata <- data %>%
  group_by(subject, Condition, Location, vDiff) %>%
  summarize(
    choice.mean = mean(choice)
  ) %>%
  ungroup() %>%
  group_by(Condition, Location, vDiff) %>%
  summarize(
    y = mean(choice.mean),
    se = std.error(choice.mean)
  )
pdata = na.omit(pdata)

plt.last.sim <- ggplot(data=pdata, aes(x=vDiff, y=y, linetype=Location)) +
  myPlot +
  geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
  geom_vline(xintercept=0, color="grey", alpha=0.75) +
  geom_line(aes(color=Condition), linewidth=linesize) +
  geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
  xlim(c(-4.1,4.1)) +
  ylim(c(-.05,1.05)) +
  labs(y="Pr(Choose Left)", x="Left - Right E[V]", linetype="Final Fixation") +
  theme(
    legend.position = c(0.12,0.75),
    legend.key.height = unit(.5, 'cm'),
    legend.key.width = unit(1.5, 'cm')
  ) +
  scale_linetype_manual(values=c("solid", "dashed")) +
  guides(linetype = guide_legend(override.aes = list(fill = c(NA, NA))))

ggsave(file.path(out_path, "SimulatedLastFixBias_GoalRelevant.pdf"), plot=plt.last.sim, width=figw, height=figh, units="in")

# Net Fixation Plot

breaks <- seq(-1050,1050,100)
labels <- seq(-1000,1000,100)
data$net_fix = data$lr_fixDiff
data$net_fix <- cut(data$net_fix, breaks=breaks, labels=labels) %>%
  as.character() %>%
  as.numeric()

data <- data %>%
  group_by(subject, Condition, vDiff) %>%
  mutate(
    choice.corr = choice - mean(choice)
  )

pdata <- data %>%
  group_by(subject, Condition, net_fix) %>%
  summarize(
    choice.mean = mean(choice.corr)
  ) %>%
  ungroup() %>%
  group_by(Condition, net_fix) %>%
  summarize(
    y = mean(choice.mean),
    se = std.error(choice.mean)
  )

pdata$net_fix = pdata$net_fix/1000
data$Condition <- data$Condition %>% factor(levels = c("Loss","Gain"), labels = c("Loss","Gain"))

plt.net.sim <- ggplot(data=pdata, aes(x=net_fix, y=y, group=Condition)) +
  myPlot +
  geom_hline(yintercept=0, color="grey", alpha=0.75) +
  geom_vline(xintercept=0, color="grey", alpha=0.75) +
  geom_line(aes(color=Condition), linewidth=linesize) +
  geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
  labs(y="Corr. Pr(Choose Left)", x="Net Fixation (L-R, s)") +
  xlim(c(-.51,.51)) +
  ylim(c(-.4,.4))

ggsave(file.path(out_path, "SimulatedNetFixBias_GoalRelevant.pdf"), plot=plt.net.sim, width=figw, height=figh, units="in")

#######################
# TEMP: Pull 2022 aDDM estimates and make figure comparing thetas.
#######################

# Choice
source(file.path(code_path, "CompareIndividualEstimates.R"))
ggsave(file.path(out_path, "E_CompareIndividualEstimates.pdf"), plot=plt.compareTheta.e, width=figw, height=figh, units="in")