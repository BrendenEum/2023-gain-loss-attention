###############
# Preamble
###############

# Libraries.
library(tidyverse)

# Get relevant directories and data.
time = readLines("time2.txt", warn=F)
datadir = file.path(paste0("../../outputs/temp/model_fitting/", time, "/Stage2"))
study1dir = file.path(datadir, "Study1E")
study2dir = file.path(datadir, "Study2E")

# Make output directories
study1participants = read.csv("Study1_participants.csv")$participants
study2participants = read.csv("Study2_participants.csv")$participants

dir.create("Stage3_parameter_grids/", showWarnings=F)
for (j in study1participants){dir.create(paste0("Stage3_parameter_grids/",j,"/"), showWarnings=F)}
for (j in study2participants){dir.create(paste0("Stage3_parameter_grids/",j,"/"), showWarnings=F)}

# Function to get best fitting parameter estimates for a subject-model
getEst = function(directory, condition, participant, likelihood_fn) {
  posteriors = read.csv(file.path(directory, paste0(condition, "_modelPosteriors_", participant, ".csv")))
  posteriors = posteriors[posteriors$likelihood_fn==likelihood_fn,]
  bestEst = posteriors[(posteriors$posterior==max(posteriors$posterior)),]
  return(bestEst)
}

# Function to make and write grid
writeGrid = function(bestEst, stepsize, fn) {
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    theta = seq(bestEst$theta-stepsize$theta, bestEst$theta+stepsize$theta, stepsize$theta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=fn, row.names=F)
}

# Step sizes
stepsizes = read.csv("stepsizes.txt")
stepsize = data.frame(
  d = .00125,
  sigma = .01,
  theta = .05,
  bias = .1,
  eta = .00125,
  reference = .5
)

####################################
# Standard aDDM
####################################

for (j in study1participants) {
  bestEst = getEst(study1dir, "Gain", j, "aDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    theta = seq(bestEst$theta-stepsize$theta, bestEst$theta+stepsize$theta, stepsize$theta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/aDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study1dir, "Loss", j, "aDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    theta = seq(bestEst$theta-stepsize$theta, bestEst$theta+stepsize$theta, stepsize$theta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/aDDM_Loss.csv"), row.names=F)
}

for (j in study2participants) {
  bestEst = getEst(study2dir, "Gain", j, "aDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    theta = seq(bestEst$theta-stepsize$theta, bestEst$theta+stepsize$theta, stepsize$theta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/aDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study2dir, "Loss", j, "aDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    theta = seq(bestEst$theta-stepsize$theta, bestEst$theta+stepsize$theta, stepsize$theta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/aDDM_Loss.csv"), row.names=F)
}

####################################
# Additive aDDM
####################################

for (j in study1participants) {
  bestEst = getEst(study1dir, "Gain", j, "AddDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    eta = seq(bestEst$eta-stepsize$eta, bestEst$eta+stepsize$eta, stepsize$eta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/AddDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study1dir, "Loss", j, "AddDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    eta = seq(bestEst$eta-stepsize$eta, bestEst$eta+stepsize$eta, stepsize$eta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/AddDDM_Loss.csv"), row.names=F)
}

for (j in study2participants) {
  bestEst = getEst(study2dir, "Gain", j, "AddDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    eta = seq(bestEst$eta-stepsize$eta, bestEst$eta+stepsize$eta, stepsize$eta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/AddDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study2dir, "Loss", j, "AddDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    eta = seq(bestEst$eta-stepsize$eta, bestEst$eta+stepsize$eta, stepsize$eta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/AddDDM_Loss.csv"), row.names=F)
}


####################################
# Reference-Dependent aDDM in Study 1
####################################

for (j in study1participants) {
  bestEst = getEst(study1dir, "Gain", j, "RaDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    theta = seq(bestEst$theta-stepsize$theta, bestEst$theta+stepsize$theta, stepsize$theta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias),
    reference = seq(bestEst$reference-stepsize$reference, bestEst$reference+stepsize$reference, stepsize$reference)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/RaDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study1dir, "Loss", j, "RaDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    theta = seq(bestEst$theta-stepsize$theta, bestEst$theta+stepsize$theta, stepsize$theta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias),
    reference = seq(bestEst$reference-stepsize$reference, bestEst$reference+stepsize$reference, stepsize$reference)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/RaDDM_Loss.csv"), row.names=F)
}

for (j in study2participants) {
  bestEst = getEst(study2dir, "Gain", j, "RaDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    theta = seq(bestEst$theta-stepsize$theta, bestEst$theta+stepsize$theta, stepsize$theta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias),
    reference = seq(bestEst$reference-stepsize$reference, bestEst$reference+stepsize$reference, stepsize$reference)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/RaDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study2dir, "Loss", j, "RaDDM_likelihood")
  grid = list(
    d = seq(bestEst$d-stepsize$d, bestEst$d+stepsize$d, stepsize$d),
    sigma = seq(bestEst$sigma-stepsize$sigma, bestEst$sigma+stepsize$sigma, stepsize$sigma),
    theta = seq(bestEst$theta-stepsize$theta, bestEst$theta+stepsize$theta, stepsize$theta),
    bias = seq(bestEst$bias-stepsize$bias, bestEst$bias+stepsize$bias, stepsize$bias),
    reference = seq(bestEst$reference-stepsize$reference, bestEst$reference+stepsize$reference, stepsize$reference)
  )
  grid = expand.grid(grid)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/RaDDM_Loss.csv"), row.names=F)
}

#print("Warnings about incomplete final line and directory already existing are fine.")
