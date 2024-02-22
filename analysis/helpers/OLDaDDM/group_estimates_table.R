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



for (study in c("dots","numeric")) {
  
  ################
  # Get Estimates
  ################
  
  # Standard aDDM
  
  aDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="aDDM", dataset="e")
  
  # Unbounded aDDM
  
  UaDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="UaDDM", dataset="e")
  
  # AddDDM
  
  AddDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="AddDDM", dataset="e")
  
  # cbAddDDM
  
  cbAddDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="cbAddDDM", dataset="e")
  
  # AddaDDM
  
  AddaDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="AddaDDM", dataset="e")
  
  # DNaDDM
  
  DNaDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="DNaDDM", dataset="e")
  
  # GDaDDM
  
  GDaDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="GDaDDM", dataset="e")
  
  # GDaDDM
  
  cbGDaDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="cbGDaDDM", dataset="e")
  
  # RNaDDM
  
  RNaDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="RNaDDM", dataset="e")
  
  # RNPaDDM
  
  RNPaDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="RNPaDDM", dataset="e")
  
  # DRNPaDDM
  
  DRNPaDDM_e_estimates = read_estimates(fitdir=fitdir, study=study, model="DRNPaDDM", dataset="e")
  
  
  ################
  # Means and Standard Errors
  ################
  
  output = data.frame(aDDM_mean = apply(aDDM_e_estimates, 2, mean))
  output$aDDM_se = apply(aDDM_e_estimates, 2, std.error)
  
  output$UaDDM_mean = apply(UaDDM_e_estimates, 2, mean)
  output$UaDDM_se = apply(UaDDM_e_estimates, 2, std.error)
  
  output$AddDDM_mean = apply(AddDDM_e_estimates, 2, mean)
  output$AddDDM_se = apply(AddDDM_e_estimates, 2, std.error)
  
  output$cbAddDDM_mean = apply(cbAddDDM_e_estimates, 2, mean)
  output$cbAddDDM_se = apply(cbAddDDM_e_estimates, 2, std.error)
  
  output$AddaDDM_mean = apply(AddaDDM_e_estimates, 2, mean)
  output$AddaDDM_se = apply(AddaDDM_e_estimates, 2, std.error)
  
  output$DNaDDM_mean = apply(DNaDDM_e_estimates, 2, mean)
  output$DNaDDM_se = apply(DNaDDM_e_estimates, 2, std.error)
  
  output$GDaDDM_mean = apply(GDaDDM_e_estimates, 2, mean)
  output$GDaDDM_se = apply(GDaDDM_e_estimates, 2, std.error)
  
  output$cbGDaDDM_mean = apply(cbGDaDDM_e_estimates, 2, mean)
  output$cbGDaDDM_se = apply(cbGDaDDM_e_estimates, 2, std.error)
  
  output$RNaDDM_mean = apply(RNaDDM_e_estimates, 2, mean)
  output$RNaDDM_se = apply(RNaDDM_e_estimates, 2, std.error)
  
  output$RNPaDDM_mean = apply(RNPaDDM_e_estimates, 2, mean)
  output$RNPaDDM_se = apply(RNPaDDM_e_estimates, 2, std.error)
  
  output$DRNPaDDM_mean = apply(DRNPaDDM_e_estimates, 2, mean)
  output$DRNPaDDM_se = apply(DRNPaDDM_e_estimates, 2, std.error)
  
  
  ################
  # Formatting
  ################
  
  output = t(output)
  table = output
  
  #round
  table[,1:2] = formatC(output[,1:2], format="e", digits=0) #d
  table[,3:4] = format(round(output[,3:4], 3), nsmall = 3) #s
  table[,5:6] = format(round(output[,5:6], 2), nsmall = 2) #b
  table[,7:8] = format(round(output[,7:8], 2), nsmall = 2) #t
  table[,9:10] = format(round(output[,9:10], 1), nsmall = 1) #k
  table[,11:12] = formatC(output[,11:12], format="e", digits=0) #c
  
  #model names
  models = c(
    "aDDM","",
    "UaDDM","",
    "AddDDM","",
    "cbAddDDM","",
    "AddaDDM","",
    "DNaDDM","",
    "GDaDDM","",
    "cbGDaDDM","",
    "RNaDDM","",
    "RNPaDDM","",
    "DRNPaDDM",""
  )
  table = cbind(models, table)
  
  #add parentheses around SEs
  for (row in seq(2, nrow(table),2)) {
    table[row,] = paste0("(", table[row,], ")")
    table[row,] = gsub(" ","",table[row,])
  }
  
  #remove NA and blanks
  table[grepl("NA",table)] = ""
  table[table=="()"] = ""
  
  
  ################
  # Save (LaTeX)
  ################
  
  .csvfile = file.path(tabdir, paste0(study, "_group_estimates_raw.csv"))
  write.csv(output, file=.csvfile)
  
  .texfile = file.path(tabdir, paste0(study, "_group_estimates_raw.tex"))
  
  if (study=="dots"){
    caption = "Study 1"
  } else if (study=="numeric") {
    caption = "Study 2"
  }
  
  hlines = c(2,4,6,8,10)
  hlines = seq(2,nrow(output),2)
  
  print(
    xtable(
      table, 
      align = "|r|r|cc|cc|cc|cc|cc|cc|",
      digits = c(0,0,-0,-0,2,2,2,2,2,2,1,1,-0,-0),
      caption = caption
    ), 
    hline.after = hlines,
    include.rownames = FALSE,
    file = .texfile
  )
  
}


