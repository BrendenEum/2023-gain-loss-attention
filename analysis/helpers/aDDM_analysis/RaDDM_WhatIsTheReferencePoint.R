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

#------------- Things you should edit at the start -------------
.dataset = "e"
.timestamp = "2024.04.06-11.22-bounded-free-refpt/Stage3"
.colors = list(Gain="Green4", Loss="Red3")
#---------------------------------------------------------------

.codedir = getwd()
.datadir = file.path(paste0("../../outputs/temp/model_fitting/", .timestamp))
.cfrdir = file.path("../../../data/processed_data")
load(file.path(.cfrdir, paste0(.dataset, "cfr.RData")))
.figdir = file.path("../../outputs/figures")
.optdir = file.path("../plot_options/")
source(file.path(.optdir, "GainLossColorPalette.R"))
source(file.path(.optdir, "MyPlotOptions.R"))

.Study1_folder = file.path(.datadir, "Study1E")
.Study2_folder = file.path(.datadir, "Study2E")

Study1_subjects = unique(ecfr$subject[ecfr$studyN==1])
Study2_subjects = unique(ecfr$subject[ecfr$studyN==2])


##############################################################################
# Load Data
##############################################################################

getData = function(folder, subjectList) {
  gain_posterior = list()
  loss_posterior = list()
  
  for (i in subjectList) {
    gain_posterior[[i]] = read.csv(file = file.path(folder, paste0("Gain_modelPosteriors_", i, ".csv")))
    loss_posterior[[i]] = read.csv(file = file.path(folder, paste0("Loss_modelPosteriors_", i, ".csv")))
    gain_posterior[[i]]$subject = i
    loss_posterior[[i]]$subject = i
  }
  gp = do.call("rbind", gain_posterior)
  lp = do.call("rbind", loss_posterior)
  
  gp$condition = "Gain"
  lp$condition = "Loss"
  posteriors = rbind(gp, lp)
  
  posteriors$likelihood_fn = factor(
    posteriors$likelihood_fn,
    levels=c("aDDM_likelihood","AddDDM_likelihood","RaDDM_likelihood"),
    labels=c("aDDM","AddDDM","RaDDM")
  )
  
  return(posteriors)
}

Study1 = getData(.Study1_folder, Study1_subjects)
Study2 = getData(.Study2_folder, Study2_subjects)

##############################################################################
# Combine and clean the data for plotting
##############################################################################

# Study N
Study1$study = 1
Study2$study = 2

# Combine
.data = rbind(Study1, Study2)

# Factor
.data$study = factor(.data$study, levels=c(1,2), labels=c("1","2"))

# Limit to just RaDDM
.data = .data[.data$likelihood_fn=="RaDDM",]

# Get best fitting parameters for each subject
.data = .data %>%
  group_by(study, subject, condition) %>%
  mutate(best_fitting = posterior==max(posterior))
data = .data[.data$best_fitting==1,]

# Check uniqueness based on study-subject-condition.
.duplicate_rows = duplicated(data[,c("study","subject","condition")]) | duplicated(data[,c("study","subject","condition")], fromLast=T)
if (sum(.duplicate_rows) != 0) {
  warning("You have some duplicate study-subject-condition observations. Uncomment the fix on lines 104-105.")  
} else {
  print("You don't have any duplicate observations. It's safe to continue!")
}

# If you got the duplicate observation warning, first check if any estimated thetas are 1. This can result in multiple reference points since our approximate estimation doesn't have the resolution to tease these apart (SUPER subtle differences). If so, you'll usually want to keep the highest reference point since thats usually the closest to the minimum value in a context.
.duplicate_rows = duplicated(data[,c("study","subject","condition")])
data = data[!.duplicate_rows,]

# Long to wide format (1 obs should have gain and loss estiamtes)
pdata_raw = pivot_wider(
  data, 
  id_cols = c("study","subject"), 
  names_from = "condition", 
  values_from = c("d","sigma","theta","bias","reference")
)

pdata_raw = merge(pdata_raw, unique(ecfr[,c("subject", "blockOrder")], by="subject"))

##############################################################################
# How are reference and drift correlated?
##############################################################################

cor(pdata_raw$d_Gain, pdata_raw$reference_Gain)
cor(pdata_raw$d_Loss, pdata_raw$reference_Loss)

##############################################################################
# Plot options
##############################################################################

gradient_resolution = 250
exact = 'grey40'
close = 'grey68'
far = 'white'
s1c = "dodgerblue3"
s2c = "deeppink4"
dot_alpha = .45

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
  out = switch(
    type,
    continuous = grDevices::colorRampPalette(palette)(n),
    discrete = palette[1:n]
  )
  structure(out, name = name, class = "palette")
}
scale_color_glcolor = function(name) {
  ggplot2::scale_colour_manual(
    values = cvi_palettes(
      name,
      type = "discrete"
    )
  )
}
scale_fill_glcolor = function(name) {
  ggplot2::scale_fill_manual(
    values = cvi_palettes(
      name,
      type = "discrete"
    )
  )
}

ggplot <- function(...) ggplot2::ggplot(...) + 
  theme_bw() +
  scale_color_glcolor("gain_loss_colors") +
  scale_fill_glcolor("gain_loss_colors") +
  coord_cartesian(expand=F) +
  theme(
    legend.position = "none",
    legend.background=element_blank(),
    legend.key = element_rect(fill = NA),
    legend.spacing.x = unit(0.01, 'cm'),
    legend.spacing.y = unit(0.01, 'cm'),
    plot.margin = unit(rep(.6, 4), "cm"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size = 12),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 9)
  ) +
  guides(color=guide_legend(override.aes=list(fill=NA)))


##############################################################################
# Plot study 1
##############################################################################

pdata = pdata_raw[pdata_raw$study==1,]

coord.lim <- .0215
margin = .002
d_gradient <- expand.grid(x=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution), y=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution))
plt1.compare.d.e <- ggplot(data=pdata) +
  geom_tile(data=d_gradient, aes(x=x, y=y, fill=abs(y-x))) + #add gradient background
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_count(aes(x=d_Gain, y=d_Loss), alpha=dot_alpha, color=s1c) +
  labs(x = TeX(r"(Gain $d$)"), y = TeX(r"(Loss $d$)")) +
  coord_cartesian(xlim = c(0, coord.lim+margin), ylim = c(0, coord.lim+margin), expand=F) +
  scale_y_continuous(breaks = c(0, .01, .02), labels=c("0", ".010", ".020")) +
  scale_x_continuous(breaks = c(0, .01, .02), labels=c("0", ".010", ".020")) 

coord.lim <- .110
sig_gradient <- expand.grid(x=seq(0,coord.lim,coord.lim/gradient_resolution), y=seq(0,coord.lim,coord.lim/gradient_resolution))
plt1.compare.s.e <- ggplot(data=pdata) +
  geom_tile(data=sig_gradient, aes(x=x, y=y, fill=abs(y-x))) +
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_count(aes(x=sigma_Gain, y=sigma_Loss), alpha=dot_alpha, color=s1c) +
  labs(x = TeX(r"(Gain $\sigma$)"), y = TeX(r"(Loss $\sigma$)")) +
  coord_cartesian(xlim=c(0,coord.lim), ylim=c(0,coord.lim), expand=F) +
  scale_y_continuous(breaks = c(0, 0.05, 0.1), labels=c("0", ".05", ".1")) +
  scale_x_continuous(breaks = c(0, 0.05, 0.1), labels=c("0", ".05", ".1")) 

coord.lim <- .5
bias_gradient <- expand.grid(x=seq(-coord.lim,coord.lim,coord.lim/gradient_resolution), y=seq(-coord.lim,coord.lim,coord.lim/gradient_resolution))
plt1.compare.b.e <- ggplot(data=pdata) +
  geom_tile(data=bias_gradient, aes(x=x, y=y, fill=abs(y-x)), show.legend=F) +
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_count(aes(x=bias_Gain, y=bias_Loss), alpha=dot_alpha, color=s1c) +
  labs(x = TeX(r"(Gain $b$)"), y = TeX(r"(Loss $b$)")) +
  coord_cartesian(xlim=c(-coord.lim,coord.lim), ylim=c(-coord.lim,coord.lim), expand=F) +
  scale_y_continuous(breaks = c(-coord.lim, 0, coord.lim), labels=c("-.5", "0", ".5")) +
  scale_x_continuous(breaks = c(-coord.lim, 0, coord.lim), labels=c("-.5", "0", ".5"))

coord.lim <- 1
margin = .08
theta_gradient <- expand.grid(x=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution), y=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution))
plt1.compare.t.e <- ggplot(data=pdata) +
  geom_tile(data=theta_gradient, aes(x=x, y=y, fill=abs(y-x)), show.legend = F) +
  scale_fill_gradient(low='orange', high=far) +
  geom_abline(intercept=0, slope=1, color='grey30') +
  geom_count(aes(x=theta_Gain, y=theta_Loss), alpha=dot_alpha, color=s1c) +
  labs(x = TeX(r"(Gain $\theta$)"), y = TeX(r"(Loss $\theta$)"), color = "Study") +
  coord_cartesian(xlim=c(-margin,coord.lim+margin), ylim=c(-margin,coord.lim+margin), expand=F) +
  scale_y_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", ".5", "1")) +
  scale_x_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", ".5", "1"))

minValue_Gain = 4.5
minValue_Loss = -5.5
margin = 2
xbreaks = c(round(min(pdata$reference_Gain)*2)/2, minValue_Gain)
ybreaks = c(round(min(pdata$reference_Loss)*2)/2, minValue_Loss)
xlims = c(round(min(pdata$reference_Gain)*2)/2 - margin, round(max(pdata$reference_Gain)*2)/2 + margin)
ylims = c(round(min(pdata$reference_Loss)*2)/2 - margin, round(max(pdata$reference_Loss)*2)/2 + margin)
reference_gradient <- expand.grid(x=seq(xlims[1],xlims[2],(xlims[2]-xlims[1])/gradient_resolution), y=seq(ylims[1],ylims[2],(ylims[2]-ylims[1])/gradient_resolution))
plt1.compare.r.e <- ggplot(data=pdata) +
  geom_tile(data=reference_gradient, aes(x=x, y=y, fill=abs(minValue_Gain-x) + abs(minValue_Loss-y)), show.legend = F) +
  scale_fill_gradient(low=close, high=far) +
  geom_vline(xintercept = minValue_Gain, color = exact) +
  geom_hline(yintercept = minValue_Loss, color = exact) +
  geom_count(aes(x=reference_Gain, y=reference_Loss, color=d_Loss), alpha=dot_alpha)+#, color=s1c) +
  labs(x = TeX(r"(Gain $r$)"), y = TeX(r"(Loss $r$)")) +
  coord_cartesian(xlim = xlims, ylim = ylims, expand=F) +
  scale_x_continuous(breaks = xbreaks) +
  scale_y_continuous(breaks = ybreaks) +
  scale_color_gradient(low="lightblue", high="darkblue")


##############################################################################
# Plot study 2
##############################################################################

pdata = pdata_raw[pdata_raw$study==2,]

coord.lim <- .006
margin = .001
d_gradient <- expand.grid(x=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution), y=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution))
plt2.compare.d.e <- ggplot(data=pdata) +
  geom_tile(data=d_gradient, aes(x=x, y=y, fill=abs(y-x))) + #add gradient background
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_count(aes(x=d_Gain, y=d_Loss), alpha=dot_alpha, color=s2c) +
  labs(x = TeX(r"(Gain $d$)"), y = TeX(r"(Loss $d$)")) +
  coord_cartesian(xlim = c(0, coord.lim+margin), ylim = c(0, coord.lim+margin), expand=F) +
  scale_y_continuous(breaks = c(0, .003, .006), labels=c("0", ".003", ".006")) +
  scale_x_continuous(breaks = c(0, .003, .006), labels=c("0", ".003", ".006")) 

coord.lim <- .110
sig_gradient <- expand.grid(x=seq(0,coord.lim,coord.lim/gradient_resolution), y=seq(0,coord.lim,coord.lim/gradient_resolution))
plt2.compare.s.e <- ggplot(data=pdata) +
  geom_tile(data=sig_gradient, aes(x=x, y=y, fill=abs(y-x))) +
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_count(aes(x=sigma_Gain, y=sigma_Loss), alpha=dot_alpha, color=s2c) +
  labs(x = TeX(r"(Gain $\sigma$)"), y = TeX(r"(Loss $\sigma$)")) +
  coord_cartesian(xlim=c(0,coord.lim), ylim=c(0,coord.lim), expand=F) +
  scale_y_continuous(breaks = c(0, 0.05, 0.1), labels=c("0", ".05", ".1")) +
  scale_x_continuous(breaks = c(0, 0.05, 0.1), labels=c("0", ".05", ".1")) 

coord.lim <- .2
bias_gradient <- expand.grid(x=seq(-coord.lim,coord.lim,coord.lim/gradient_resolution), y=seq(-coord.lim,coord.lim,coord.lim/gradient_resolution))
plt2.compare.b.e <- ggplot(data=pdata) +
  geom_tile(data=bias_gradient, aes(x=x, y=y, fill=abs(y-x)), show.legend=F) +
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_count(aes(x=bias_Gain, y=bias_Loss), alpha=dot_alpha, color=s2c) +
  labs(x = TeX(r"(Gain $b$)"), y = TeX(r"(Loss $b$)")) +
  coord_cartesian(xlim=c(-coord.lim,coord.lim), ylim=c(-coord.lim,coord.lim), expand=F) +
  scale_y_continuous(breaks = c(-coord.lim, 0, coord.lim), labels=c("-.2", "0", ".2")) +
  scale_x_continuous(breaks = c(-coord.lim, 0, coord.lim), labels=c("-.2", "0", ".2"))

coord.lim <- 1
margin = .08
theta_gradient <- expand.grid(x=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution), y=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution))
plt2.compare.t.e <- ggplot(data=pdata) +
  geom_tile(data=theta_gradient, aes(x=x, y=y, fill=abs(y-x)), show.legend = F) +
  scale_fill_gradient(low='orange', high=far) +
  geom_abline(intercept=0, slope=1, color='grey30') +
  geom_count(aes(x=theta_Gain, y=theta_Loss), alpha=dot_alpha, color=s2c) +
  labs(x = TeX(r"(Gain $\theta$)"), y = TeX(r"(Loss $\theta$)"), color = "Study") +
  coord_cartesian(xlim=c(-margin,coord.lim+margin), ylim=c(-margin,coord.lim+margin), expand=F) +
  scale_y_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", ".5", "1")) +
  scale_x_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", ".5", "1"))

minValue_Gain = 1
minValue_Loss = -6
margin = 2
xbreaks = c(round(min(pdata$reference_Gain)*2)/2, minValue_Gain)
ybreaks = c(round(min(pdata$reference_Loss)*2)/2, minValue_Loss)
xlims = c(round(min(pdata$reference_Gain)*2)/2 - margin, round(max(pdata$reference_Gain)*2)/2 + margin)
ylims = c(round(min(pdata$reference_Loss)*2)/2 - margin, round(max(pdata$reference_Loss)*2)/2 + margin)
reference_gradient <- expand.grid(x=seq(xlims[1],xlims[2],(xlims[2]-xlims[1])/gradient_resolution), y=seq(ylims[1],ylims[2],(ylims[2]-ylims[1])/gradient_resolution))
plt2.compare.r.e <- ggplot(data=pdata) +
  geom_tile(data=reference_gradient, aes(x=x, y=y, fill=abs(minValue_Gain-x) + abs(minValue_Loss-y)), show.legend = F) +
  scale_fill_gradient(low=close, high=far) +
  geom_vline(xintercept = minValue_Gain, color = exact) +
  geom_hline(yintercept = minValue_Loss, color = exact) +
  geom_count(aes(x=reference_Gain, y=reference_Loss, color=d_Loss), alpha=dot_alpha)+#, color=s2c) +
  labs(x = TeX(r"(Gain $r$)"), y = TeX(r"(Loss $r$)")) +
  coord_cartesian(xlim = xlims, ylim = ylims, expand=F) +
  scale_x_continuous(breaks = xbreaks) +
  scale_y_continuous(breaks = ybreaks) +
  scale_color_gradient(low="lightblue", high="darkblue")


##############################################################################
# Combine plots
##############################################################################

plt.compare.param.e <- grid.arrange(
  arrangeGrob(
    plt1.compare.d.e, plt1.compare.s.e, plt1.compare.b.e, plt1.compare.t.e, plt1.compare.r.e,
    left = textGrob( expression(bold("      Study 1")), rot=90, gp=gpar(fontsize=17) ),
    ncol = 5
  ),
  arrangeGrob(
    plt2.compare.d.e, plt2.compare.s.e, plt2.compare.b.e, plt2.compare.t.e, plt2.compare.r.e, 
    left = textGrob( expression(bold("      Study 2")), rot=90, gp=gpar(fontsize=17) ),
    ncol = 5
  ),
  nrow = 2
)

# plt.compare.param.e <- grid.arrange(
#   plt1.compare.d.e, plt1.compare.s.e, plt1.compare.b.e, plt1.compare.t.e, plt1.compare.r.e,
#   plt2.compare.d.e, plt2.compare.s.e, plt2.compare.b.e, plt2.compare.t.e, plt2.compare.r.e,
#   nrow = 2)

plot(plt.compare.param.e)

ggsave(file.path(.figdir, "RaDDM_RefPt_r(d_Loss).pdf"), plt.compare.param.e, height=4, width=11, units="in")
