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
library(ggpubr)
library(ggsci)
library(readr)
library(latex2exp)
library(patchwork)

#------------- Things you should edit at the start -------------
.dataset = "j"
.fn = "RaDDM_AddDDM_compare_theta_eta_J.pdf"

.cfrdir = file.path("../../../data/processed_data/datasets")
load(file.path(.cfrdir, paste0(.dataset, "cfr.RData")))
cfr = jcfr
#---------------------------------------------------------------

.codedir = getwd()
.datadir = file.path(paste0("../aDDM_fitting/results"))#, .nTrials))
.figdir = file.path("../../outputs/figures")
.optdir = file.path("../plot_options/")
source(file.path(.optdir, "GainLossColorPalette.R"))
source(file.path(.optdir, "MyPlotOptions.R"))
.colors = list(Gain="Green4", Loss="Red3")

AddDDM_est = read.csv("AddDDM_IndividualEstimates_J.csv")
RaDDM_est = read.csv("RaDDM_IndividualEstimates_J.csv")

pdata = merge(
  RaDDM_est,
  AddDDM_est[,c("study","subject","condition","eta")],
  by=c("study","subject","condition")
)

pdata$study = factor(pdata$study, levels=c(1,2), labels=c("Study 1", "Study 2"))


##############################################################################
# Plot options
##############################################################################

gradient_resolution = 250
exact = 'grey79'
dot_alpha = .4


ggplot <- function(...) ggplot2::ggplot(...) + 
  theme_bw() +
  scale_color_manual(values = c("1" = 'dodgerblue3', "2" = 'orange4')) +
  theme(
    legend.position = "none",
    legend.background=element_blank(),
    legend.key = element_rect(fill = NA),
    legend.spacing.x = unit(0.01, 'cm'),
    legend.spacing.y = unit(0.001, 'cm'),
    plot.margin = unit(rep(.6, 4), "cm"),
    #panel.grid.major = element_blank(),
    #panel.grid.minor = element_blank(),
    plot.title = element_text(size = 12),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 9),
    #strip.text = element_blank()
  ) 


##############################################################################
# Plot study
##############################################################################

plt1.compare.t.e <- ggplot(data=pdata, aes(x=eta, y=theta)) +
  
  geom_jitter( 
    fill = "black",
    alpha = dot_alpha,
    width = .0002, height = 0
  ) +
  geom_smooth(method = "lm", color = "dodgerblue", linetype = "solid", alpha = .5) +
  
  labs(x = TeX(r"($\eta$)"), y = TeX(r"($\theta$)"), size = "Number of Subjects", color = "Study") +
  coord_cartesian(xlim=c(-0.0005, 0.0105), ylim=c(-.1, 1.1), expand=F) +
  scale_y_continuous(breaks = c(0, .5, 1), labels=c("0", ".5", "1")) +
  scale_x_continuous(breaks = c(0, .005, .01), labels=c("0", ".005", ".010")) +
  theme(
    legend.position = c(0, 1.01),
    #legend.direction = "horizontal",
    legend.justification = c(0,1)
    #legend.background = element_rect(fill = "white", color = NA)
  ) +
  facet_grid(rows = vars(condition), cols = vars(study))

##############################################################################
# Combine plots
##############################################################################

combo_plot = (plt1.compare.t.e) + 
  plot_layout(guides = 'collect')

plot(combo_plot)

ggsave(file.path(.figdir, .fn), combo_plot, height=3.5, width=8, units="in")
