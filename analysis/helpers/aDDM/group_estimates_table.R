################
# Preamble
################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(plotrix)
library(xtable)
figdir = "../../outputs/figures"
fitdir = "../../outputs/temp"
tabdir = "../../outputs/tables"
datadir = "../../../data/processed_data"
source("get_estimates_likelihoods.R")


################
# Get Estimates
################

# Standard aDDM

dots_aDDM_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="aDDM", dataset="e")
numeric_aDDM_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="aDDM", dataset="e")
aDDM_e_estimates = rbind(dots_aDDM_e_estimates, numeric_aDDM_e_estimates)

# Unbounded aDDM

dots_UaDDM_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="UaDDM", dataset="e")
numeric_UaDDM_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="UaDDM", dataset="e")
UaDDM_e_estimates = rbind(dots_UaDDM_e_estimates, numeric_UaDDM_e_estimates)

# AddDDM

dots_AddDDM_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="AddDDM", dataset="e")
numeric_AddDDM_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="AddDDM", dataset="e")
AddDDM_e_estimates = rbind(dots_AddDDM_e_estimates, numeric_AddDDM_e_estimates)

# AddaDDM

dots_AddaDDM_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="AddaDDM", dataset="e")
numeric_AddaDDM_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="AddaDDM", dataset="e")
AddaDDM_e_estimates = rbind(dots_AddaDDM_e_estimates, numeric_AddaDDM_e_estimates)

# cbAddDDM

dots_cbAddDDM_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="cbAddDDM", dataset="e")
numeric_cbAddDDM_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="cbAddDDM", dataset="e")
cbAddDDM_e_estimates = rbind(dots_cbAddDDM_e_estimates, numeric_cbAddDDM_e_estimates)

# DNaDDM

dots_DNaDDM_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="DNaDDM", dataset="e")
numeric_DNaDDM_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="DNaDDM", dataset="e")
DNaDDM_e_estimates = rbind(dots_DNaDDM_e_estimates, numeric_DNaDDM_e_estimates)

# GDaDDM

dots_GDaDDM_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="GDaDDM", dataset="e")
numeric_GDaDDM_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="GDaDDM", dataset="e")
GDaDDM_e_estimates = rbind(dots_GDaDDM_e_estimates, numeric_GDaDDM_e_estimates)

# RNaDDM

dots_RNaDDM_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="RNaDDM", dataset="e")
numeric_RNaDDM_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="RNaDDM", dataset="e")
RNaDDM_e_estimates = rbind(dots_RNaDDM_e_estimates, numeric_RNaDDM_e_estimates)

# RNPaDDM

dots_RNPaDDM_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="RNPaDDM", dataset="e")
numeric_RNPaDDM_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="RNPaDDM", dataset="e")
RNPaDDM_e_estimates = rbind(dots_RNPaDDM_e_estimates, numeric_RNPaDDM_e_estimates)

# DRNPaDDM

dots_DRNPaDDM_e_estimates = read_estimates(fitdir=fitdir, study="dots", model="DRNPaDDM", dataset="e")
numeric_DRNPaDDM_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model="DRNPaDDM", dataset="e")
DRNPaDDM_e_estimates = rbind(dots_DRNPaDDM_e_estimates, numeric_DRNPaDDM_e_estimates)


################
# Means and Standard Errors
################

output = data.frame(aDDM_mean = apply(aDDM_e_estimates, 2, mean))
output$aDDM_se = apply(aDDM_e_estimates, 2, std.error)

output$UaDDM_mean = apply(UaDDM_e_estimates, 2, mean)
output$UaDDM_se = apply(UaDDM_e_estimates, 2, std.error)

output$AddDDM_mean = apply(AddDDM_e_estimates, 2, mean)
output$AddDDM_se = apply(AddDDM_e_estimates, 2, std.error)

output$AddaDDM_mean = apply(AddaDDM_e_estimates, 2, mean)
output$AddaDDM_se = apply(AddaDDM_e_estimates, 2, std.error)

output$cbAddDDM_mean = apply(cbAddDDM_e_estimates, 2, mean)
output$cbAddDDM_se = apply(cbAddDDM_e_estimates, 2, std.error)

output$DNaDDM_mean = apply(DNaDDM_e_estimates, 2, mean)
output$DNaDDM_se = apply(DNaDDM_e_estimates, 2, std.error)

output$GDaDDM_mean = apply(GDaDDM_e_estimates, 2, mean)
output$GDaDDM_se = apply(GDaDDM_e_estimates, 2, std.error)

output$RNaDDM_mean = apply(RNaDDM_e_estimates, 2, mean)
output$RNaDDM_se = apply(RNaDDM_e_estimates, 2, std.error)

output$RNPaDDM_mean = apply(RNPaDDM_e_estimates, 2, mean)
output$RNPaDDM_se = apply(RNPaDDM_e_estimates, 2, std.error)

output$DRNPaDDM_mean = apply(DRNPaDDM_e_estimates, 2, mean)
output$DRNPaDDM_se = apply(DRNPaDDM_e_estimates, 2, std.error)

#output[c(1:2),] = round(output, digits=4) #drift
#output[c(3:nrow(output)),] = round(output, digits=3) #everything else
output = t(output)


################
# Get Information Criteria
################

getTableIC = function(dots_IC, numeric_IC) {
  return(
    list(
      dots_totalBIC = sum(dots_IC$BIC),
      numeric_totalBIC = sum(numeric_IC$BIC),
      dots_totalAIC = sum(dots_IC$AIC),
      numeric_totalAIC = sum(numeric_IC$AIC),
      dots_gain_totalBIC = sum(dots_IC$BIC[,1]),
      numeric_gain_totalBIC = sum(numeric_IC$BIC[,1]),
      dots_loss_totalBIC = sum(dots_IC$BIC[,2]),
      numeric_loss_totalBIC = sum(numeric_IC$BIC[,2])
    )
  )
}

# Standard aDDM

dots_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="aDDM", dataset="e", parameterCount=4)
numeric_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="aDDM", dataset="e", parameterCount=4)
aDDM_IC = getTableIC(dots_IC, numeric_IC)

# Unbounded aDDM

dots_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="UaDDM", dataset="e", parameterCount=4)
numeric_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="UaDDM", dataset="e", parameterCount=4)
UaDDM_IC = getTableIC(dots_IC, numeric_IC)

# Additive aDDM

dots_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="AddDDM", dataset="e", parameterCount=4)
numeric_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="AddDDM", dataset="e", parameterCount=4)
AddDDM_IC = getTableIC(dots_IC, numeric_IC)

# Additive and multiplicative aDDM

dots_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="AddaDDM", dataset="e", parameterCount=4)
numeric_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="AddaDDM", dataset="e", parameterCount=4)
AddaDDM_IC = getTableIC(dots_IC, numeric_IC)

# collapsing bounds additive DDM

dots_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="cbAddDDM", dataset="e", parameterCount=4)
numeric_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="cbAddDDM", dataset="e", parameterCount=4)
cbAddDDM_IC = getTableIC(dots_IC, numeric_IC)

# Divisive Normalization

dots_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="DNaDDM", dataset="e", parameterCount=4)
numeric_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="DNaDDM", dataset="e", parameterCount=4)
DNaDDM_IC = getTableIC(dots_IC, numeric_IC)

# Goal-Dependent

dots_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="GDaDDM", dataset="e", parameterCount=4)
numeric_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="GDaDDM", dataset="e", parameterCount=4)
GDaDDM_IC = getTableIC(dots_IC, numeric_IC)

# Range Normalized

dots_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="RNaDDM", dataset="e", parameterCount=4)
numeric_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="RNaDDM", dataset="e", parameterCount=4)
RNaDDM_IC = getTableIC(dots_IC, numeric_IC)

# Range Normalized Plus

dots_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="RNPaDDM", dataset="e", parameterCount=5)
numeric_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="RNPaDDM", dataset="e", parameterCount=5)
RNPaDDM_IC = getTableIC(dots_IC, numeric_IC)

# Dynamic Range Normalized Plus

dots_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="DRNPaDDM", dataset="e", parameterCount=5)
numeric_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="DRNPaDDM", dataset="e", parameterCount=5)
DRNPaDDM_IC = getTableIC(dots_IC, numeric_IC)

################
# What IC's are you looking for?
################

gain_BIC = c(
  sum(aDDM_IC$dots_gain_totalBIC)+sum(aDDM_IC$numeric_gain_totalBIC), NA, 
  sum(UaDDM_IC$dots_gain_totalBIC)+sum(UaDDM_IC$numeric_gain_totalBIC), NA, 
  sum(AddDDM_IC$dots_gain_totalBIC)+sum(AddDDM_IC$numeric_gain_totalBIC), NA, 
  sum(AddaDDM_IC$dots_gain_totalBIC)+sum(AddaDDM_IC$numeric_gain_totalBIC), NA, 
  sum(cbAddDDM_IC$dots_gain_totalBIC)+sum(cbAddDDM_IC$numeric_gain_totalBIC), NA, 
  sum(DNaDDM_IC$dots_gain_totalBIC)+sum(DNaDDM_IC$numeric_gain_totalBIC), NA, 
  sum(GDaDDM_IC$dots_gain_totalBIC)+sum(GDaDDM_IC$numeric_gain_totalBIC), NA, 
  sum(RNaDDM_IC$dots_gain_totalBIC)+sum(RNaDDM_IC$numeric_gain_totalBIC), NA, 
  sum(RNPaDDM_IC$dots_gain_totalBIC)+sum(RNPaDDM_IC$numeric_gain_totalBIC), NA, 
  sum(DRNPaDDM_IC$dots_gain_totalBIC)+sum(DRNPaDDM_IC$numeric_gain_totalBIC), NA
)
loss_BIC = c(
  sum(aDDM_IC$dots_loss_totalBIC)+sum(aDDM_IC$numeric_loss_totalBIC), NA, 
  sum(UaDDM_IC$dots_loss_totalBIC)+sum(UaDDM_IC$numeric_loss_totalBIC), NA, 
  sum(AddDDM_IC$dots_loss_totalBIC)+sum(AddDDM_IC$numeric_loss_totalBIC), NA, 
  sum(AddaDDM_IC$dots_loss_totalBIC)+sum(AddaDDM_IC$numeric_loss_totalBIC), NA, 
  sum(cbAddDDM_IC$dots_gain_totalBIC)+sum(cbAddDDM_IC$numeric_gain_totalBIC), NA, 
  sum(DNaDDM_IC$dots_loss_totalBIC)+sum(DNaDDM_IC$numeric_loss_totalBIC), NA, 
  sum(GDaDDM_IC$dots_loss_totalBIC)+sum(GDaDDM_IC$numeric_loss_totalBIC), NA, 
  sum(RNaDDM_IC$dots_loss_totalBIC)+sum(RNaDDM_IC$numeric_loss_totalBIC), NA, 
  sum(RNPaDDM_IC$dots_loss_totalBIC)+sum(RNPaDDM_IC$numeric_loss_totalBIC), NA, 
  sum(DRNPaDDM_IC$dots_loss_totalBIC)+sum(DRNPaDDM_IC$numeric_loss_totalBIC), NA
)

#dots_BIC = c(dots_aDDM_totalBIC, NA, dots_UaDDM_totalBIC, NA, dots_AddDDM_totalBIC, NA, dots_DNaDDM_totalBIC, NA, dots_RNaDDM_totalBIC, NA, dots_RNPaDDM_totalBIC, NA, dots_DRNPaDDM_totalBIC, NA)
#numeric_BIC = c(numeric_aDDM_totalBIC, NA, numeric_UaDDM_totalBIC, NA, numeric_AddDDM_totalBIC, NA, numeric_DNaDDM_totalBIC, NA, numeric_RNaDDM_totalBIC, NA, numeric_RNPaDDM_totalBIC, NA, numeric_DRNPaDDM_totalBIC, NA)
#dots_AIC = c(dots_aDDM_totalAIC, NA, dots_UaDDM_totalAIC, NA, dots_AddDDM_totalAIC, NA, dots_DNaDDM_totalAIC, NA, dots_RNaDDM_totalAIC, NA, dots_RNPaDDM_totalAIC, NA, dots_DRNPaDDM_totalAIC, NA)
#numeric_AIC = c(numeric_aDDM_totalAIC, NA, numeric_UaDDM_totalAIC, NA, numeric_AddDDM_totalAIC, NA, numeric_DNaDDM_totalAIC, NA, numeric_RNaDDM_totalAIC, NA, numeric_RNPaDDM_totalAIC, NA, numeric_DRNPaDDM_totalAIC, NA)

output = cbind(output, gain_BIC)
output = cbind(output, loss_BIC)


################
# Round and Save
################

# output[,1] = round(output[,1], digits=4) #d.gain
# output[,2] = round(output[,2], digits=4) #d.loss
# output[,3] = round(output[,3], digits=3) #s.gain
# output[,4] = round(output[,4], digits=3) #s.loss
# output[,5] = round(output[,5], digits=2) #b.gain
# output[,6] = round(output[,6], digits=2) #b.loss
# output[,7] = round(output[,7], digits=2) #t.gain
# output[,8] = round(output[,8], digits=2) #t.loss
# output[,9] = round(output[,9], digits=1) #k.gain
# output[,10] = round(output[,10], digits=1) #k.loss
# output[,11] = round(output[,11], digits=0) #dotsBIC
# output[,12] = round(output[,12], digits=0) #numericBIC

write.csv(output, file=file.path(tabdir, "group_estimates.csv"))
print(xtable(output, type = "latex"), file = file.path(tabdir, "group_estimates.tex"))

