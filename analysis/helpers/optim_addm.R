#!/usr/bin/env Rscript

library(optparse)
library(tidyverse)

# Note this will be run in docker container so make sure paths are mounted and defined in the env
input_path = Sys.getenv("INPUT_PATH")
code_path = Sys.getenv("CODE_PATH")
output_path = Sys.getenv("OUT_PATH")

source(file.path(code_path,'fit_yn_ddm.R'))

#######################
# Parse input arguments
#######################
option_list = list(
  make_option("--data", type="character", default='data_choiceYN.csv'),
  make_option("--subnum", type="integer"),
  make_option("--day", type="integer"),
  make_option("--type", type="character"),
  make_option("--model", type="character", default = "yn_ddm"),
  make_option("--max_iter", type="integer", default = as.integer(500)),
  make_option("--num_starts", type="integer", default = as.integer(500)),
  make_option("--par_names", type="character", default = c("d", "sigma", "nonDecisionTime", "bias", "barrierDecay")),
  make_option("--out_path", type="character", default = output_path)
)

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

#######################
# Initialize parameters from input arguments
#######################

#  WHERE SHOULD DATA BE PULLED FROM?
data = read.csv(file.path(input_path , opt$data))

cur_sub = as.numeric(opt$subnum)
cur_day = as.numeric(opt$day)
cur_type = opt$type

data = data %>%
  mutate(type = ifelse(type == 1, "HT", "RE")) %>%
  filter((subnum == cur_sub) & (day == cur_day) & (type == cur_type)) %>%
  filter(reference != -99) %>%
  filter(rt > .3 & rt < 5) %>%
  mutate(possiblePayoff_dmn = possiblePayoff - mean(possiblePayoff))


model = opt$model
source(file.path(code_path, paste0(model, '.R')))
fit_trial_list = list()
fit_trial_list[[model]] = fit_trial

max_iter = opt$max_iter
num_starts = opt$num_starts

# PREVIOUSLY HAD TEXT PARSING TO PROCESS PAR_NAMES SPECIFIED IN BATCH SCRIPT BUT REMOVING IT FOR NOW UNLESS WE TRY OTHER MODELS WITH EITHER FIXED OR FEWER PARAMETERS
par_names = opt$par_names

# SHOULD I PROVIDE START VALS AS INPUT OR GENERATE THEM PRE FITTING?
# Previously provided them as inputs, I think, to make sure that there were the correct number of values for various models
# It was messy though bc I had to store starting values separately before beginning any fitting
# I should be able to make this more robust by using the par_names
# Convert to numeric so optim can work with it
# start_vals = as.numeric(strsplit(opt$start_vals, ",")[[1]])

# Must end with /
out_path = opt$out_path
# Make sure path exists
dir.create(out_path, showWarnings = FALSE)

#######################
# Run optim
#######################

print(paste0("Starting optim for sub-", cur_sub, ", day ", cur_day, ", type ", cur_type))
for(start_num in 1:num_starts){

  start_vals = c()
  for(cur_par in par_names){
    if(cur_par == "d"){
      start_d = runif(1, .001, .01)
      start_vals = c(start_vals, start_d)
    }
    if(cur_par == "sigma"){
      start_sigma = runif(1, 0.001, .01)
      start_vals = c(start_vals, start_sigma)
    }
    if(cur_par == "nonDecisionTime"){
      start_nonDecisionTime = runif(1, 10, 500)
      start_vals = c(start_vals, start_nonDecisionTime)
    }
    if(cur_par == "bias"){
      start_bias = runif(1, -.2, 2)
      start_vals = c(start_vals, start_bias)
    }
    if(cur_par == "barrierDecay"){
      start_barrierDecay = runif(1, 0, .01)
      start_vals = c(start_vals, start_barrierDecay)
    }
  }

  print(paste0("Num start = ", start_num))

  optim_out = optim(par = start_vals, get_task_nll, data_= data, par_names_ = par_names, model_name_ = model, control = list(maxit=max_iter))

  cur_out = tibble(key = par_names, value = optim_out$par)
  cur_out = cur_out %>% spread(key, value)
  cur_out$nll = optim_out$value
  cur_out$optim_iters = as.numeric(optim_out$counts[1])
  cur_out$subnum = cur_sub
  cur_out$day = cur_day
  cur_out$type = cur_type
  cur_out = cbind(cur_out, tibble(key = paste0("start_", par_names), value = start_vals) %>% spread(key, value))
  cur_out$start_num = start_num

  if(start_num == 1){
    out = cur_out
  } else{
    out = rbind(out, cur_out)
  }

  #######################
  # Save output (save for each start)
  #######################

  fn = paste0("optim_YN_DDM_FIT_sub-", cur_sub, "_", cur_type, "_day_", cur_day, ".csv")
  write.csv(out, file.path(out_path, fn), row.names = F)
}