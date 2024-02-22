####################################################
## PREAMBLE
####################################################

rm(list=ls())
library(tidyverse)
library(effsize)
library(plotrix)
library(ggsci)
library(ggplot2)
library(latex2exp)
library(gridExtra)

datadir = "../../data/processed_data/e"
figdir = "../../outputs/figures"
fitdir = "../../outputs/temp"
tempdir = "../../outputs/temp"
optdir = "../plot_options"

source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))
source("get_estimates_likelihoods.R")


####################################################
## ESTIMATES
####################################################

.dots_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="AddDDM", dataset="e")
.dots_e_estimates$study = "Dots"
.numeric_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="AddDDM", dataset="e")
.numeric_e_estimates$study = "Numeric"
pdata = rbind(.dots_e_estimates, .numeric_e_estimates)
pdata$study = factor(pdata$study, levels=c("Dots","Numeric"), labels=c(1,2))


####################################################
## PLOT OPTIONS
####################################################

gradient_resolution = 100
exact = 'grey40'
close = 'grey70'
far = 'white'

# Color palette
my_colors = list(
  #gain_loss_colors = c("red3", "green4", "blue2", "purple2", "orange2", "deeppink", "cyan3", "bisque3")
  gain_loss_colors = c("dodgerblue3", "deeppink4", "orange2", "deeppink", "blue2", "bisque3")
)
cvi_palettes = function(name, n, all_palettes = my_colors, type = c("discrete", "continuous")) {
  palette = all_palettes[[name]]
  if (missing(n)) {
    n = length(palette)
  }
  type = match.arg(type)
  out = switch(type,
               continuous = grDevices::colorRampPalette(palette)(n),
               discrete = palette[1:n]
  )
  structure(out, name = name, class = "palette")
}
scale_color_glcolor = function(name) {
  ggplot2::scale_colour_manual(values = cvi_palettes(name,
                                                     type = "discrete"))
}
scale_fill_glcolor = function(name) {
  ggplot2::scale_fill_manual(values = cvi_palettes(name,
                                                   type = "discrete"))
}

ggplot <- function(...) ggplot2::ggplot(...) + 
  theme_bw() +
  scale_color_glcolor("gain_loss_colors") +
  scale_fill_glcolor("gain_loss_colors") +
  coord_cartesian(expand=FALSE) +
  theme(
    legend.position = "none",
    legend.background=element_blank(),
    legend.key = element_rect(fill = NA),
    legend.spacing.x = unit(0.01, 'cm'),
    legend.spacing.y = unit(0.01, 'cm'),
    plot.margin = unit(c(.62,.62,.62,.62), "cm"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size = 12),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 9)
  ) +
  guides(color=guide_legend(override.aes=list(fill=NA)))

markersize = 1.5


####################################################
## PLOTS
####################################################

coord.lim <- .02
d_gradient <- expand.grid(x=seq(0,coord.lim,coord.lim/gradient_resolution), y=seq(0,coord.lim,coord.lim/gradient_resolution))
plt.compare.d.e <- ggplot(data=pdata) +
  geom_tile(data=d_gradient, aes(x=x, y=y, fill=abs(y-x))) + #add gradient background
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_point(aes(x=d.gain, y=d.loss, color=study), size=markersize, alpha=.7) +
  xlim(c(0,coord.lim)) +
  ylim(c(0,coord.lim)) +
  labs(x = TeX(r"(Gain $d$)"), y = TeX(r"(Loss $d$)")) +
  scale_y_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", "0.01", "0.02")) +
  scale_x_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", "0.01", "0.02"))  

coord.lim <- .12
sig_gradient <- expand.grid(x=seq(0,coord.lim,coord.lim/gradient_resolution), y=seq(0,coord.lim,coord.lim/gradient_resolution))
plt.compare.s.e <- ggplot(data=pdata) +
  geom_tile(data=sig_gradient, aes(x=x, y=y, fill=abs(y-x))) +
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_point(aes(x=s.gain, y=s.loss, color=study), size=markersize, alpha=.7) +
  xlim(c(0,coord.lim)) +
  ylim(c(0,coord.lim)) +
  labs(x = TeX(r"(Gain $\sigma$)"), y = TeX(r"(Loss $\sigma$)")) +
  scale_y_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", "0.06", "0.12")) +
  scale_x_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", "0.06", "0.12")) 

coord.lim <- 1
bias_gradient <- expand.grid(x=seq(-coord.lim,coord.lim,coord.lim/gradient_resolution), y=seq(-coord.lim,coord.lim,coord.lim/gradient_resolution))
plt.compare.b.e <- ggplot(data=pdata) +
  geom_tile(data=bias_gradient, aes(x=x, y=y, fill=abs(y-x)), show.legend=F) +
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_point(aes(x=b.gain, y=b.loss, color=study), size=markersize, alpha=.7) +
  xlim(c(-coord.lim,coord.lim)) +
  ylim(c(-coord.lim,coord.lim)) +
  labs(x = TeX(r"(Gain $b$)"), y = TeX(r"(Loss $b$)"), color = "Study") +
  scale_y_continuous(breaks = c(-coord.lim, 0, coord.lim), labels=c("-1.0", "0.0", "1.0")) +
  scale_x_continuous(breaks = c(-coord.lim, 0, coord.lim), labels=c("-1.0", "0.0", "1.0")) +
  theme(
    legend.position = c(.11,.7)
  )

coord.lim <- 5
theta_gradient <- expand.grid(x=seq(0,coord.lim,coord.lim/gradient_resolution), y=seq(0,coord.lim,coord.lim/gradient_resolution))
scaleFUN <- function(x) sprintf("%.2f", x)
plt.compare.k.e <- ggplot(data=pdata) +
  geom_tile(data=theta_gradient, aes(x=x, y=y, fill=abs(y-x))) +
  scale_fill_gradient(low='orange', high=far) +
  geom_abline(intercept=0, slope=1, color='grey30') +
  geom_point(aes(x=k.gain, y=k.loss, color=study), size=markersize, alpha=.7) +
  xlim(c(0,coord.lim)) +
  ylim(c(0,coord.lim)) +
  labs(x = TeX(r"(Gain $k$)"), y = TeX(r"(Loss $k$)")) +
  scale_y_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", "2.5", "5.0")) +
  scale_x_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", "2.5", "5.0")) 

plt.compare.param.e <- grid.arrange(plt.compare.d.e, plt.compare.s.e, plt.compare.b.e, plt.compare.k.e, nrow=2)

ggsave(file.path(figdir, "AddDDM_IndividualEstimates.pdf"), plt.compare.param.e,
       width=figw*1.1, height=figh*1.1, units="in")