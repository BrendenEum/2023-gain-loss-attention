##############################################################################
# Preamble
##############################################################################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(plotrix)
library(gridExtra)
library(ggpubr)
library(ggsci)
library(readr)
library(latex2exp)

#------------- Things you should edit at the start -------------
.dataset = "e"
.timestamp = "2024.04.06-11.22/Stage3"
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
  warning("You have some duplicate study-subject-condition observations. Uncomment the fix on lines 102-103.")  
} else {
  print("You don't have any duplicate observations. It's safe to continue!")
}

# If you got the duplicate observation warning, first check if any estimated thetas are 1. This can result in multiple reference points since our approximate estimation doesn't have the resolution to tease these apart (SUPER subtle differences). If so, you'll usually want to keep the highest reference point since thats usually the closest to the minimum value in a context.
.duplicate_rows = duplicated(data[,c("study","subject","condition")])
data = data[!.duplicate_rows,]

# Long to wide format (1 obs should have gain and loss estiamtes)
pdata = pivot_wider(
  data, 
  id_cols = c("study","subject"), 
  names_from = "condition", 
  values_from = c("d","sigma","theta","bias","reference")
)


##############################################################################
# Plot options
##############################################################################

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


##############################################################################
# Plot model comparison
##############################################################################

coord.lim <- .0215
margin = .0005
d_gradient <- expand.grid(x=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution), y=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution))
plt.compare.d.e <- ggplot(data=pdata) +
  geom_tile(data=d_gradient, aes(x=x, y=y, fill=abs(y-x))) + #add gradient background
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_count(aes(x=d_Gain, y=d_Loss, color=study), alpha=.7) +
  labs(x = TeX(r"(Gain $d$)"), y = TeX(r"(Loss $d$)")) +
  scale_y_continuous(breaks = c(0, .01, .02), labels=c(0, .01, .02)) +
  scale_x_continuous(breaks = c(0, .01, .02), labels=c(0, .01, .02))  

coord.lim <- .105
sig_gradient <- expand.grid(x=seq(0,coord.lim,coord.lim/gradient_resolution), y=seq(0,coord.lim,coord.lim/gradient_resolution))
plt.compare.s.e <- ggplot(data=pdata) +
  geom_tile(data=sig_gradient, aes(x=x, y=y, fill=abs(y-x))) +
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_count(aes(x=sigma_Gain, y=sigma_Loss, color=study), alpha=.7) +
  coord_cartesian(xlim=c(0,coord.lim), ylim=c(0,coord.lim), expand=F) +
  labs(x = TeX(r"(Gain $\sigma$)"), y = TeX(r"(Loss $\sigma$)")) +
  scale_y_continuous(breaks = c(0, 0.05, 0.1), labels=c(0, 0.05, 0.1)) +
  scale_x_continuous(breaks = c(0, 0.05, 0.1), labels=c(0, 0.05, 0.1)) 

coord.lim <- 1
bias_gradient <- expand.grid(x=seq(-coord.lim,coord.lim,coord.lim/gradient_resolution), y=seq(-coord.lim,coord.lim,coord.lim/gradient_resolution))
plt.compare.b.e <- ggplot(data=pdata) +
  geom_tile(data=bias_gradient, aes(x=x, y=y, fill=abs(y-x)), show.legend=F) +
  scale_fill_gradient(low=close, high=far) +
  geom_abline(intercept=0, slope=1, color=exact) +
  geom_count(aes(x=bias_Gain, y=bias_Loss, color=study), alpha=.7) +
  coord_cartesian(xlim=c(-coord.lim,coord.lim), ylim=c(-coord.lim,coord.lim), expand=F) +
  labs(x = TeX(r"(Gain $b$)"), y = TeX(r"(Loss $b$)"), color = "Study") +
  scale_y_continuous(breaks = c(-coord.lim, 0, coord.lim), labels=c("-1.0", "0.0", "1.0")) +
  scale_x_continuous(breaks = c(-coord.lim, 0, coord.lim), labels=c("-1.0", "0.0", "1.0")) +
  guides(size="none") +
  theme(
    legend.position = c(.17, .75),
    legend.background = element_rect(colour = "black", fill = "white", linewidth = .2, linetype = "solid")
  ) 

coord.lim <- 1
margin = .05
theta_gradient <- expand.grid(x=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution), y=seq(-margin,coord.lim+margin,(coord.lim+2*margin)/gradient_resolution))
plt.compare.t.e <- ggplot(data=pdata) +
  geom_tile(data=theta_gradient, aes(x=x, y=y, fill=abs(y-x)), show.legend = F) +
  scale_fill_gradient(low='orange', high=far) +
  geom_abline(intercept=0, slope=1, color='grey30') +
  geom_count(aes(x=theta_Gain, y=theta_Loss, color=study), alpha=.7) +
  labs(x = TeX(r"(Gain $\theta$)"), y = TeX(r"(Loss $\theta$)"), color = "Study") +
  scale_y_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", "0.5", "1")) +
  scale_x_continuous(breaks = c(0, coord.lim/2, coord.lim), labels=c("0", "0.5", "1")) 

# reference_gradient <- expand.grid(x=seq(-16,5,21/gradient_resolution), y=seq(-16,5,21/gradient_resolution))
# plt.compare.r.e <- ggplot(data=pdata) +
#   geom_tile(data=reference_gradient, aes(x=x, y=y, fill=abs(y-x)), show.legend = F) +
#   scale_fill_gradient(low=close, high=far) +
#   geom_abline(intercept=0, slope=1, color='grey30') +
#   geom_count(aes(x=reference_Gain, y=reference_Loss, color=study), alpha=.7) +
#   labs(x = TeX(r"(Gain $\theta$)"), y = TeX(r"(Loss $\theta$)"), color = "Study") +
#   scale_y_continuous(breaks = c(-15, -6, 1, 5), labels=c("-15", "-6", "1", "5")) +
#   scale_x_continuous(breaks = c(-15, -6, 1, 5), labels=c("-15", "-6", "1", "5"))

nBins = 10 #ceiling(max(pdata$reference_Gain) - min(pdata$reference_Gain)) + 1
plt.compare.r.e.gain <- ggplot(data=pdata) +
  geom_histogram(aes(x=reference_Gain, color=study, fill=study), bins=nBins, alpha=.7) +
  geom_vline(xintercept = 4.5, color = "dodgerblue3", linewidth = 1.5, linetype = "dotted") +
  geom_vline(xintercept = 1, color = "deeppink4", linewidth = 1.5, linetype = "dotted") + 
  coord_cartesian(ylim = c(0, 16), expand = T) +
  labs(x = TeX(r"(Gain $r$)"), y = TeX(r"(Frequency)"), color = "Study") +
  scale_x_continuous(
    breaks = c(min(pdata$reference_Gain), 1, 4.5, max(pdata$reference_Gain)), 
    labels=c(min(pdata$reference_Gain), 1, 4.5, max(pdata$reference_Gain))
  ) +
  scale_y_continuous(
    breaks = c(0, 8, 16),
    labels = c(0, 8, 16)
  )

nBins = 10 #ceiling(max(pdata$reference_Loss) - min(pdata$reference_Loss)) + 1
plt.compare.r.e.loss <- ggplot(data=pdata) +
  geom_histogram(aes(x=reference_Loss, color=study, fill=study), bins=nBins, alpha=.7) +
  geom_vline(xintercept = -5.5, color = "dodgerblue3", linewidth = 1.5, linetype = "dotted") +
  geom_vline(xintercept = -6, color = "deeppink4", linewidth = 1.5, linetype = "dotted") + 
  coord_cartesian(ylim = c(0, 16), expand = T) +
  labs(x = TeX(r"(Loss $r$)"), y = TeX(r"(Frequency)"), color = "Study") +
  scale_x_continuous(
    breaks = c(min(pdata$reference_Loss), -5.5), 
    labels=c(min(pdata$reference_Loss), -5.5)
  ) +
  scale_y_continuous(
    breaks = c(0, 8, 16),
    labels = c(0, 8, 16)
  )

plt.compare.param.e <- grid.arrange(
  plt.compare.d.e, plt.compare.s.e, plt.compare.b.e,
  plt.compare.t.e, plt.compare.r.e.gain, plt.compare.r.e.loss,
  nrow = 2, ncol = 3)

ggsave(file.path(.figdir, "RaDDM_IndividualEstimates.pdf"), plt.compare.param.e, height=figh*1.3, width=figw*1.4, units="in")