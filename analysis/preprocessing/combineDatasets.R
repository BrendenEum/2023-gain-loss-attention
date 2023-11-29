## This script will take all the cleaned datasets from each study and bind them together
## into one final dataset for analysis, separately for exploratory, confirmatory, and joint data.

rm(list=ls())
library(tidyverse)

edatadir.dots <- file.path("../../data/processed_data/dots/e")
cdatadir.dots <- file.path("../../data/processed_data/dots/c")
jdatadir.dots <- file.path("../../data/processed_data/dots/j")

edatadir.numeric <- file.path("../../data/processed_data/numeric/e")
cdatadir.numeric <- file.path("../../data/processed_data/numeric/c")
jdatadir.numeric <- file.path("../../data/processed_data/numeric/j")

edatadir.food <- file.path("../../data/processed_data/food/e")
cdatadir.food <- file.path("../../data/processed_data/food/c")
jdatadir.food <- file.path("../../data/processed_data/food/j")

processed.datadir = file.path("../../data/processed_data")

##########
# Exploratory
##########

load(file.path(edatadir.dots, "cfr_dots.RData"))
load(file.path(edatadir.numeric, "cfr_numeric.RData"))
load(file.path(edatadir.food, "cfr_food.RData"))
ecfr = do.call("rbind", list(cfr_dots, cfr_numeric, cfr_food))
save(ecfr, file=file.path(processed.datadir, "ecfr.RData"))

##########
# Confirmatory
##########

load(file.path(cdatadir.dots, "cfr_dots.RData"))
load(file.path(cdatadir.numeric, "cfr_numeric.RData"))
load(file.path(cdatadir.food, "cfr_food.RData"))
ccfr = do.call("rbind", list(cfr_dots, cfr_numeric, cfr_food))
save(ccfr, file=file.path(processed.datadir, "ccfr.RData"))

##########
# Joint
##########

load(file.path(jdatadir.dots, "cfr_dots.RData"))
load(file.path(jdatadir.numeric, "cfr_numeric.RData"))
load(file.path(jdatadir.food, "cfr_food.RData"))
jcfr = do.call("rbind", list(cfr_dots, cfr_numeric, cfr_food))
save(jcfr, file=file.path(processed.datadir, "jcfr.RData"))