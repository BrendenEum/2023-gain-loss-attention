##############################################################################
# Preamble
##############################################################################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(reshape2)
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
.colors = list(Gain="Green4", Loss="Red3")
.nTrials = "146_trials"
#---------------------------------------------------------------

.codedir = getwd()
.datadir = file.path(paste0("../aDDM_fitting/results_", .nTrials))
.cfrdir = file.path("../../../data/processed_data/datasets")
load(file.path(.cfrdir, paste0(.dataset, "cfr.RData")))
cfr = ecfr
.figdir = file.path("../../outputs/figures")
.optdir = file.path("../plot_options/")
source(file.path(.optdir, "GainLossColorPalette.R"))
source(file.path(.optdir, "MyPlotOptions.R"))

.study1G_folder = file.path(.datadir, "study1G")
.study2G_folder = file.path(.datadir, "study2G")
.study1L_folder = file.path(.datadir, "study1L")
.study2L_folder = file.path(.datadir, "study2L")

study1_subjects = unique(cfr$subject[cfr$studyN==1])
study2_subjects = unique(cfr$subject[cfr$studyN==2])


##############################################################################
# Load Data
##############################################################################

getEst = function(gain_folder, loss_folder, subjectList) {
  gain_posterior = list()
  loss_posterior = list()
  
  for (i in subjectList) {
    gain_posterior[[i]] = read.csv(file = file.path(gain_folder, paste0("model_posteriors/posteriors_df_", i, ".csv")))
    loss_posterior[[i]] = read.csv(file = file.path(loss_folder, paste0("model_posteriors/posteriors_df_", i, ".csv")))
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

Study1 = getEst(.study1G_folder, .study1L_folder, study1_subjects)
Study2 = getEst(.study2G_folder, .study2L_folder, study2_subjects)

##############################################################################
# Transform data to estimates by study and condition
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
  warning("You have some duplicate study-subject-condition observations. Uncomment the duplicate rows code below.")
} else {
  print("You don't have any duplicate observations. It's safe to continue!")
}

# If you got the duplicate observation warning, first check if any estimated thetas are 1. This can result in multiple reference points since our approximate estimation doesn't have the resolution to tease these apart (SUPER subtle differences). If so, you'll usually want to keep the highest reference point since thats usually the closest to the minimum value in a context.
.duplicate_rows = duplicated(data[,c("study","subject","condition")])
data = data[!.duplicate_rows,]

# Clean it up a bit
voi = c("study", "condition", "d", "sigma", "theta", "ref")
data = data[,voi] %>% na.omit()
data$study2 = data$study # cheat way to keep study and condition inside group_by df later (2nd block in next sect.)
data$condition2 = data$condition


##############################################################################
# Transform data into correlation matrix data for plotting
##############################################################################

calculate_cor_matrix <- function(sub_data) {
  melted_cor_matrix = melt(cor(sub_data[, c("d", "sigma", "theta", "ref")]))
  melted_cor_matrix$study = unique(sub_data$study2)
  melted_cor_matrix$condition = unique(sub_data$condition2)
  return(melted_cor_matrix)
}

pdata <- data %>%
  group_by(study, condition) %>%
  group_map(~ calculate_cor_matrix(.x)) %>%
  bind_rows()

pdata$study = factor(pdata$study, levels = c(1,2), labels = c("Study 1", "Study 2"))

pdata_lowertri <- pdata %>%
  filter(as.numeric(Var1) <= as.numeric(Var2))

pdata_lowertri$Var1 = factor(pdata_lowertri$Var1, levels = c("d", "sigma", "theta", "ref"))
pdata_lowertri$Var2 = factor(pdata_lowertri$Var2, levels = c("ref", "theta", "sigma", "d"))


##############################################################################
# Plot
##############################################################################

p.par_cor = ggplot(data = pdata_lowertri, aes(x = Var1, y = Var2, fill = value)) +
  
  geom_tile() +
  scale_fill_gradient2(
    low = "blue", high = "red", mid = "white",
    midpoint = 0, limit = c(-1, 1), space = "Lab"
  ) +
  
  #scale_y_reverse() +
  theme_classic() +
  labs(
    y = "",
    x = "",
    fill = "Correlation"
  ) +
  
  facet_grid(rows = vars(condition), cols = vars(study))

ggsave(file.path(.figdir, "RaDDM_ParameterCorrelations.pdf"), p.par_cor, width = figw, height = figh)
