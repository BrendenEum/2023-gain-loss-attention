rm(list=ls())
library(tidyverse)

#####################################################################
# COMMON GRIDS
d_grid_normal = seq(.002, .008, .003)
sigma_grid = seq(.02, .08, .03)
#####################################################################

####################################
# Standard aDDM
####################################

aDDM_Gain = list(
  condition = "Gain",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  eta = "0.0"
)
aDDM_Gain = expand.grid(aDDM_Gain) %>% data.frame() %>% mutate(subject = row_number())

aDDM_Loss = list(
  condition = "Loss",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  eta = "0.0"
)
aDDM_Loss = expand.grid(aDDM_Loss) %>% data.frame() %>% mutate(subject = row_number())

aDDM_grid = bind_rows(aDDM_Gain, aDDM_Loss)
fn = paste0("SimIndividualEstimates_aDDM.csv")
write.csv(aDDM_grid, file=fn, row.names=F)

####################################
# Unbounded aDDM
####################################

UaDDM_Gain = list(
  condition = "Gain",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  eta = "0.0"
)
UaDDM_Gain = expand.grid(UaDDM_Gain) %>% data.frame() %>% mutate(subject = row_number())

UaDDM_Loss = list(
  condition = "Loss",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(1, 2, .1),
  eta = "0.0"
)
UaDDM_Loss = expand.grid(UaDDM_Loss) %>% data.frame() %>% mutate(subject = row_number())

UaDDM_grid = bind_rows(UaDDM_Gain, UaDDM_Loss)
fn = paste0("SimIndividualEstimates_UaDDM.csv")
write.csv(UaDDM_grid, file=fn, row.names=F)


####################################
# Opposite aDDM
####################################

OPPaDDM_Gain = list(
  condition = "Gain",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  eta = "0.0"
)
OPPaDDM_Gain = expand.grid(OPPaDDM_Gain) %>% data.frame() %>% mutate(subject = row_number())

OPPaDDM_Loss = list(
  condition = "Loss",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  eta = "0.0"
)
OPPaDDM_Loss = expand.grid(OPPaDDM_Loss) %>% data.frame() %>% mutate(subject = row_number())

OPPaDDM_grid = bind_rows(OPPaDDM_Gain, OPPaDDM_Loss)
fn = paste0("SimIndividualEstimates_OPPaDDM.csv")
write.csv(OPPaDDM_grid, file=fn, row.names=F)


####################################
# Transform Opposite aDDM
####################################

TrOPPaDDM_Gain = list(
  condition = "Gain",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  eta = "0.0"
)
TrOPPaDDM_Gain = expand.grid(TrOPPaDDM_Gain) %>% data.frame() %>% mutate(subject = row_number())

TrOPPaDDM_Loss = list(
  condition = "Loss",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  eta = "0.0"
)
TrOPPaDDM_Loss = expand.grid(TrOPPaDDM_Loss) %>% data.frame() %>% mutate(subject = row_number())

TrOPPaDDM_grid = bind_rows(TrOPPaDDM_Gain, TrOPPaDDM_Loss)
fn = paste0("SimIndividualEstimates_TrOPPaDDM.csv")
write.csv(TrOPPaDDM_grid, file=fn, row.names=F)


####################################
# Additive aDDM
####################################

AddDDM_Gain = list(
  condition = "Gain",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = "1.0",
  eta = seq(.001, .009, .001)
)
AddDDM_Gain = expand.grid(AddDDM_Gain) %>% data.frame() %>% mutate(subject = row_number())

AddDDM_Loss = list(
  condition = "Loss",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = "1.0",
  eta = seq(.001, .009, .001)
)
AddDDM_Loss = expand.grid(AddDDM_Loss) %>% data.frame() %>% mutate(subject = row_number())

AddDDM_grid = bind_rows(AddDDM_Gain, AddDDM_Loss)
fn = paste0("SimIndividualEstimates_AddDDM.csv")
write.csv(AddDDM_grid, file=fn, row.names=F)


####################################
# RaDDM
####################################

RaDDM_Gain = list(
  condition = "Gain",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  eta = "0.0"
)
RaDDM_Gain = expand.grid(RaDDM_Gain) %>% data.frame() %>% mutate(subject = row_number())

RaDDM_Loss = list(
  condition = "Loss",
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  eta = "0.0"
)
RaDDM_Loss = expand.grid(RaDDM_Loss) %>% data.frame() %>% mutate(subject = row_number())

RaDDM_grid = bind_rows(RaDDM_Gain, RaDDM_Loss)
fn = paste0("SimIndividualEstimates_RaDDM.csv")
write.csv(RaDDM_grid, file=fn, row.names=F)
