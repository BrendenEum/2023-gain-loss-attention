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


###############
# Grids
###############

# Step sizes
stepsize = data.frame(
  d = .00125,
  sigma = .01,
  theta = .05,
  bias = .1,
  eta = .00125,
  reference = .5
)

# Function to make grid
makeGrid_aDDM = function(bestEst, stepsize) {
  grid = list(
    d = unique(c(
      max(bestEst$d-stepsize$d, 0), 
      bestEst$d, 
      bestEst$d+stepsize$d
    )),
    sigma = unique(c(
      max(bestEst$sigma-stepsize$sigma, 0), 
      bestEst$sigma, 
      bestEst$sigma+stepsize$sigma
    )),
    theta = unique(c(
      max(bestEst$theta-stepsize$theta, 0), 
      bestEst$theta,
      min(bestEst$theta+stepsize$theta, 1)
    )),
    bias = unique(c(bestEst$bias-stepsize$bias, bestEst$bias, bestEst$bias))
  )
  grid = expand.grid(grid)
  return(grid)
}
makeGrid_AddDDM = function(bestEst, stepsize) {
  grid = list(
    d = unique(c(
      max(bestEst$d-stepsize$d, 0), 
      bestEst$d, 
      bestEst$d+stepsize$d
    )),
    sigma = unique(c(
      max(bestEst$sigma-stepsize$sigma, 0), 
      bestEst$sigma, 
      bestEst$sigma+stepsize$sigma
    )),
    eta = unique(c(bestEst$eta-stepsize$eta, bestEst$eta, bestEst$eta+stepsize$eta)),
    bias = unique(c(bestEst$bias-stepsize$bias, bestEst$bias, bestEst$bias))
  )
  grid = expand.grid(grid)
  return(grid)
}
makeGrid_RaDDM = function(bestEst, stepsize) {
  grid = list(
    d = unique(c(
      max(bestEst$d-stepsize$d, 0), 
      bestEst$d, 
      bestEst$d+stepsize$d
    )),
    sigma = unique(c(
      max(bestEst$sigma-stepsize$sigma, 0), 
      bestEst$sigma, 
      bestEst$sigma+stepsize$sigma
    )),
    theta = unique(c(
      max(bestEst$theta-stepsize$theta, 0), 
      bestEst$theta,
      min(bestEst$theta+stepsize$theta, 1)
    )),
    bias = unique(c(bestEst$bias-stepsize$bias, bestEst$bias, bestEst$bias)),
    reference = unique(c(
      bestEst$reference-stepsize$reference, 
      bestEst$reference,
      bestEst$reference+stepsize$reference
    ))
  )
  grid = expand.grid(grid)
  return(grid)
}

####################################
# Standard aDDM
####################################

for (j in study1participants) {
  bestEst = getEst(study1dir, "Gain", j, "aDDM_likelihood")
  grid = makeGrid_aDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/aDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study1dir, "Loss", j, "aDDM_likelihood")
  grid = makeGrid_aDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/aDDM_Loss.csv"), row.names=F)
}

for (j in study2participants) {
  bestEst = getEst(study2dir, "Gain", j, "aDDM_likelihood")
  grid = makeGrid_aDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/aDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study2dir, "Loss", j, "aDDM_likelihood")
  grid = makeGrid_aDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/aDDM_Loss.csv"), row.names=F)
}

####################################
# Additive aDDM
####################################

for (j in study1participants) {
  bestEst = getEst(study1dir, "Gain", j, "AddDDM_likelihood")
  grid = makeGrid_AddDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/AddDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study1dir, "Loss", j, "AddDDM_likelihood")
  grid = makeGrid_AddDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/AddDDM_Loss.csv"), row.names=F)
}

for (j in study2participants) {
  bestEst = getEst(study2dir, "Gain", j, "AddDDM_likelihood")
  grid = makeGrid_AddDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/AddDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study2dir, "Loss", j, "AddDDM_likelihood")
  grid = makeGrid_AddDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/AddDDM_Gain.csv"), row.names=F)
}


####################################
# Reference-Dependent aDDM in Study 1
####################################

for (j in study1participants) {
  bestEst = getEst(study1dir, "Gain", j, "RaDDM_likelihood")
  grid = makeGrid_RaDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/RaDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study1dir, "Loss", j, "RaDDM_likelihood")
  grid = makeGrid_RaDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/RaDDM_Loss.csv"), row.names=F)
}

for (j in study2participants) {
  bestEst = getEst(study2dir, "Gain", j, "RaDDM_likelihood")
  grid = makeGrid_RaDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/RaDDM_Gain.csv"), row.names=F)
  
  bestEst = getEst(study2dir, "Loss", j, "RaDDM_likelihood")
  grid = makeGrid_RaDDM(bestEst, stepsize)
  write.csv(grid, file=paste0("stage3_parameter_grids/", j, "/RaDDM_Loss.csv"), row.names=F)
}

#print("Warnings about incomplete final line and directory already existing are fine.")
