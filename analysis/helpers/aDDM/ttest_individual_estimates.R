####################################################
## PREAMBLE
####################################################

rm(list=ls())
library(tidyverse)
datadir = "../../data/processed_data/e"
txtdir = "../../outputs/text"
fitdir = "../../outputs/temp"
source("get_estimates_likelihoods.R")


####################################################
## Function: WRITE TEXT FILE
####################################################

writeTxt = function(x=1, study="error", parameter="error", model="error") {
  fileConn<-file(file.path(txtdir, paste0("ttest_", study, "_", parameter, "_", model, ".txt")))
  writeLines(paste0(x, "%"),fileConn)
  close(fileConn)
}


####################################################
## TESTS
####################################################

model = "AddDDM"
dots_e_estimates = read_estimates(fitdir=fitdir, study="dots", model=model, dataset="e")
numeric_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model=model, dataset="e")

res = t.test(dots_e_estimates$d.gain-dots_e_estimates$d.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "dots", "d", model)
res = t.test(dots_e_estimates$s.gain-dots_e_estimates$s.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "dots", "s", model)
res = t.test(dots_e_estimates$b.gain-dots_e_estimates$b.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "dots", "b", model)
res = t.test(dots_e_estimates$k.gain-dots_e_estimates$k.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "dots", "k", model)

res = t.test(numeric_e_estimates$d.gain-numeric_e_estimates$d.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "numeric", "d", model)
res = t.test(numeric_e_estimates$s.gain-numeric_e_estimates$s.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "numeric", "s", model)
res = t.test(numeric_e_estimates$b.gain-numeric_e_estimates$b.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "numeric", "b", model)
res = t.test(numeric_e_estimates$k.gain-numeric_e_estimates$k.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "numeric", "k", model)


model = "GDaDDM"
dots_e_estimates = read_estimates(fitdir=fitdir, study="dots", model=model, dataset="e")
numeric_e_estimates = read_estimates(fitdir=fitdir, study="numeric", model=model, dataset="e")

res = t.test(dots_e_estimates$d.gain-dots_e_estimates$d.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "dots", "d", model)
res = t.test(dots_e_estimates$s.gain-dots_e_estimates$s.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "dots", "s", model)
res = t.test(dots_e_estimates$b.gain-dots_e_estimates$b.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "dots", "b", model)
res = t.test(dots_e_estimates$t.gain-dots_e_estimates$t.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "dots", "t", model)

res = t.test(numeric_e_estimates$d.gain-numeric_e_estimates$d.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "numeric", "d", model)
res = t.test(numeric_e_estimates$s.gain-numeric_e_estimates$s.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "numeric", "s", model)
res = t.test(numeric_e_estimates$b.gain-numeric_e_estimates$b.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "numeric", "b", model)
res = t.test(numeric_e_estimates$t.gain-numeric_e_estimates$t.loss)
writeTxt( format(round(res$p.value,3), nsmall=3), "numeric", "t", model)