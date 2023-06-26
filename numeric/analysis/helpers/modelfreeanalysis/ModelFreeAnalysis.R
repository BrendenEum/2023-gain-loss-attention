#!/usr/bin/env Rscript

library(optparse)
library(tidyverse)
library(effsize)
library(ggsci)

# Note this will be run in docker container so make sure paths are mounted and defined in the env
input_path = Sys.getenv("INPUT_PATH")
code_path = Sys.getenv("CODE_PATH")
out_path = Sys.getenv("OUT_PATH")

#######################
# Parse Input Arguments
#######################

option_list = list(
  make_option("--data", type="character", default='cfr.RData'),
  make_option("--out_path", type="character", default = out_path)
)

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

#######################
# Read Data
#######################

load(file.path(input_path, opt$data))

#######################
# Plot Options
#######################

source(file.path(code_path, "GainLossColorPalette.R"))

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
# Useful Functions
#######################

std.error <- function(x) {
  se = sd(x)/sqrt(length(x))
  if (length(unique(x))==2) {
    if (all(unique(x)==c(0,1))) { # binomial
      se = sqrt(length(x))*sqrt(mean(x)*(1-mean(x)))
    }
  }
  return(se)
}

#######################
# Basic Psychometrics
#######################

# Choice
source(file.path(code_path, "BasicPsychometrics_Choice.R"))
ggsave(file.path(out_path, "E_BasicPsychometrics_Choice.pdf"), plot=plt.choice.e, width=figw, height=figh, units="in")

# RT
source(file.path(code_path, "BasicPsychometrics_RT.R"))
ggsave(file.path(out_path, "E_BasicPsychometrics_RT.pdf"), plot=plt.rt.e, width=figw, height=figh, units="in")

# Number of Fixations
source(file.path(code_path, "BasicPsychometrics_NumberFixations.R"))
ggsave(file.path(out_path, "E_BasicPsychometrics_NumberFixations.pdf"), plot=plt.numfix.e, width=figw, height=figh, units="in")

#######################
# Fixation Process
#######################

# First Fixation to Best
source(file.path(code_path, "FixationProcess_FirstBest.R"))
ggsave(file.path(out_path, "E_FixationProcess_FirstBest.pdf"), plot=plt.prfirst.e, width=figw, height=figh, units="in")

# Fixation Duration by Type
source(file.path(code_path, "FixationProcess_DurationType.R"))
ggsave(file.path(out_path, "E_FixationProcess_DurationType.pdf"), plot=plt.fixtype.e, width=figw, height=figh, units="in")

# Middle Fixation Duration by Difficulty
source(file.path(code_path, "FixationProcess_Middle.R"))
ggsave(file.path(out_path, "E_FixationProcess_Middle.pdf"), plot=plt.mid.e, width=figw, height=figh, units="in")

# First Fixation Duration by Difficulty
source(file.path(code_path, "FixationProcess_First.R"))
ggsave(file.path(out_path, "E_FixationProcess_First.pdf"), plot=plt.first.e, width=figw, height=figh, units="in")

# Net Fixation Duration by Value Difference
source(file.path(code_path, "FixationProcess_Net.R"))
ggsave(file.path(out_path, "E_FixationProcess_Net.pdf"), plot=plt.net.e, width=figw, height=figh, units="in")

#######################
# Choice Biases
#######################

# Last Fixation Bias
source(file.path(code_path, "ChoiceBiases_Last.R"))
ggsave(file.path(out_path, "E_ChoiceBiases_Last.pdf"), plot=plt.lastfix.e, width=figw, height=figh, units="in")

# Net Fixation Bias
source(file.path(code_path, "ChoiceBiases_Net.R"))
ggsave(file.path(out_path, "E_ChoiceBiases_Net.pdf"), plot=plt.netfix.e, width=figw, height=figh, units="in")

# First Fixation Bias
source(file.path(code_path, "ChoiceBiases_First.R"))
ggsave(file.path(out_path, "E_ChoiceBiases_First.pdf"), plot=plt.firstfix.e, width=figw, height=figh, units="in")