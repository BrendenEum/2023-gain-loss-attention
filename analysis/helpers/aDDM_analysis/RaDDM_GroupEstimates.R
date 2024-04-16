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
library(effsize)

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
  warning("You have some duplicate study-subject-condition observations.")  
} else {
  print("You don't have any duplicate observations. It's safe to continue!")
}

# If you got the duplicate observation warning, first check if any estimated thetas are 1. This can result in multiple reference points since our approximate estimation doesn't have the resolution to tease these apart (SUPER subtle differences). If so, you'll usually want to keep the highest reference point since thats usually the closest to the minimum value in a context.
.duplicate_rows = duplicated(data[,c("study","subject","condition")])
data = data[!.duplicate_rows,]

##############################################################################
# Group Averages Table
##############################################################################

tdata = data %>% 
  group_by(study, condition) %>%
  summarize(
    d_mean = mean(d) %>% round(4),
    d_se = std.error(d) %>% round(4),
    s_mean = mean(sigma) %>% round(3),
    s_se = std.error(sigma) %>% round(3),
    t_mean = mean(theta) %>% round(2),
    t_se = std.error(theta) %>% round(2),
    b_mean = mean(bias) %>% round(2),
    b_se = std.error(bias) %>% round(2),
    r_mean = mean(reference) %>% round(2),
    r_se = std.error(reference) %>% round(2)
  )
tdata

##############################################################################
# t-tests for parameters
##############################################################################

## Study 1

print("Study1 d")
t.test(data$d[data$study==1 & data$condition=="Gain"] - data$d[data$study==1 & data$condition=="Loss"])
cohen.d(data$d[data$study==1 & data$condition=="Gain"], data$d[data$study==1 & data$condition=="Loss"])

print("Study1 sigma")
t.test(data$sigma[data$study==1 & data$condition=="Gain"] - data$sigma[data$study==1 & data$condition=="Loss"])
cohen.d(data$sigma[data$study==1 & data$condition=="Gain"], data$sigma[data$study==1 & data$condition=="Loss"])

print("Study1 bias")
t.test(data$bias[data$study==1 & data$condition=="Gain"])
cohen.d(data$bias[data$study==1 & data$condition=="Gain"], rep(0,length(data$bias[data$study==1 & data$condition=="Gain"])))
t.test(data$bias[data$study==1 & data$condition=="Gain"] - data$bias[data$study==1 & data$condition=="Loss"])
cohen.d(data$bias[data$study==1 & data$condition=="Gain"], data$bias[data$study==1 & data$condition=="Loss"])

print("Study1 theta")
t.test(data$theta[data$study==1 & data$condition=="Gain"] - data$theta[data$study==1 & data$condition=="Loss"])
cohen.d(data$theta[data$study==1 & data$condition=="Gain"], data$theta[data$study==1 & data$condition=="Loss"])

print("Study1 reference")
t.test(data$reference[data$study==1 & data$condition=="Gain"] - data$reference[data$study==1 & data$condition=="Loss"])
cohen.d(data$reference[data$study==1 & data$condition=="Gain"], data$reference[data$study==1 & data$condition=="Loss"])
t.test(data$reference[data$study==1 & data$condition=="Gain"])
cohen.d(data$reference[data$study==1 & data$condition=="Gain"], rep(0,length(data$reference[data$study==1 & data$condition=="Gain"])))

## Study 2

print("Study2 d")
t.test(data$d[data$study==2 & data$condition=="Gain"] - data$d[data$study==2 & data$condition=="Loss"])
cohen.d(data$d[data$study==2 & data$condition=="Gain"], data$d[data$study==2 & data$condition=="Loss"])

print("Study2 sigma")
t.test(data$sigma[data$study==2 & data$condition=="Gain"] - data$sigma[data$study==2 & data$condition=="Loss"])
cohen.d(data$sigma[data$study==2 & data$condition=="Gain"], data$sigma[data$study==2 & data$condition=="Loss"])

print("Study2 bias")
t.test(data$bias[data$study==2 & data$condition=="Gain"])
cohen.d(data$bias[data$study==2 & data$condition=="Gain"], rep(0,length(data$bias[data$study==2 & data$condition=="Gain"])))
t.test(data$bias[data$study==2 & data$condition=="Loss"])
cohen.d(data$bias[data$study==2 & data$condition=="Loss"], rep(0,length(data$bias[data$study==2 & data$condition=="Loss"])))

print("Study2 theta")
t.test(data$theta[data$study==2 & data$condition=="Gain"] - data$theta[data$study==2 & data$condition=="Loss"])
cohen.d(data$theta[data$study==2 & data$condition=="Gain"], data$theta[data$study==2 & data$condition=="Loss"])

print("Study2 reference")
t.test(data$reference[data$study==2 & data$condition=="Gain"] - data$reference[data$study==2 & data$condition=="Loss"])
cohen.d(data$reference[data$study==2 & data$condition=="Gain"], data$reference[data$study==2 & data$condition=="Loss"])


##############################################################################
# t-tests: reference points vs minimum value
##############################################################################

# Study 1 Gain
est = data$reference[data$study==1 & data$condition=="Gain"]
minV = rep(4.5, length(est))
t.test(est - minV)
cohen.d(est, minV)

# Study 1 Loss
est = data$reference[data$study==1 & data$condition=="Loss"]
minV = rep(-5.5, length(est))
t.test(est - minV)
cohen.d(est, minV)

# Study 2 Gain
est = data$reference[data$study==2 & data$condition=="Gain"]
minV = rep(1, length(est))
t.test(est - minV)
cohen.d(est, minV)

# Study 2 Loss
est = data$reference[data$study==2 & data$condition=="Loss"]
minV = rep(-6, length(est))
t.test(est - minV)
cohen.d(est, minV)



##############################################################################
# reg: theta ~ reference-point
##############################################################################

# Study 1 Gain
test1 = data$reference[data$study==1 & data$condition=="Gain"]
test2 = data$theta[data$study==1 & data$condition=="Gain"]
lm(test1 ~ test2) %>% summary()

# Study 1 Loss
test1 = data$reference[data$study==1 & data$condition=="Loss"]
test2 = data$theta[data$study==1 & data$condition=="Loss"]
lm(test1 ~ test2) %>% summary()


# Study 2 Gain
test1 = data$reference[data$study==2 & data$condition=="Gain"]
test2 = data$theta[data$study==2 & data$condition=="Gain"]
lm(test1 ~ test2) %>% summary()


# Study 2 Loss
test1 = data$reference[data$study==2 & data$condition=="Loss"]
test2 = data$theta[data$study==2 & data$condition=="Loss"]
lm(test1 ~ test2) %>% summary()
