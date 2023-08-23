#!/usr/bin/env Rscript

library(optparse)
library(dplyr)

# Note this will be run in docker container so make sure paths are mounted and defined in the env
input_path = Sys.getenv("INPUT_PATH")
code_path = Sys.getenv("CODE_PATH")
output_path = Sys.getenv("OUT_PATH")

source(file.path(code_path,'fit_addm.R'))

#######################
# Parse input arguments
#######################
option_list = list(
  make_option("--data", type="character", default='cfr_odd.RData'),
  make_option("--subnum", type="integer"),
  make_option("--model", type="character", default = "addm"),
  make_option("--grid", type="character", default='grid1_addm.csv'),
  make_option("--out_path", type="character", default = output_path)
)

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

#######################
# Initialize parameters from input arguments
#######################

#  WHERE SHOULD DATA BE PULLED FROM?
#data = read.csv(file.path(input_path , opt$data))
data = load(file.path(input_path, opt$data))

cur_sub = as.numeric(opt$subnum)

data = data %>%
  filter((subject == cur_sub)) # %>%
  #mutate(possiblePayoff_dmn = possiblePayoff - mean(possiblePayoff))

# Read in the model functions
model = opt$model
source(file.path(code_path, paste0(model, '.R')))
fit_trial_list = list()
fit_trial_list[[model]] = fit_trial


grid_addm = read.csv(file.path(input_path, opt$grid))

par_names = names(grid_addm)

# Must end with /
out_path = opt$out_path
# Make sure path exists
dir.create(out_path, showWarnings = FALSE)

#######################
# Run grid search
#######################

print(paste0("Starting grid search for sub-", cur_sub))
for(i in 1:nrow(grid_addm)) {

  print(paste0("Row num = ", i))

  par = as.numeric(grid_addm[i,])
  gs_out = get_task_nll(par_ = par, data_= data, par_names_ = par_names, model_name_ = model)

  cur_out = tibble(key = par_names, value = par)
  cur_out = cur_out %>% spread(key, value)
  cur_out$nll = gs_out
  cur_out$subnum = cur_sub
  cur_out$model = model

  if(i == 1){out = cur_out} else {out = rbind(out, cur_out)}

  #######################
  # Save output (save for each start)
  #######################

  fn = paste0("gridsearch_GL_aDDM_FIT_sub-", cur_sub, ".csv")
  write.csv(out, file.path(out_path, fn), row.names = F)
}