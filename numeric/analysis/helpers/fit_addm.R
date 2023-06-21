library(foreach)

# Parallelization setup based on this post
# https://www.blasbenito.com/post/02_parallelizing_loops_with_r/
n.cores <- parallel::detectCores() - 1

# create the cluster
my.fit.cluster <- parallel::makeCluster(
  n.cores,
  type = "PSOCK" #"FORK"
)

# register it to be used by %dopar%
doParallel::registerDoParallel(cl = my.fit.cluster)

# Function to fit ddm model to data using a model provided as a string in the model_name argument
fit_task = function(data_, model_name_, pars_, fit_trial_list_ = fit_trial_list, debug=FALSE){

  # Initialize any missing arguments. Some are useless defaults to make sure different fit_trial functions from different models can run without errors even if they don't make use of that argument
  if (!("d" %in% names(pars_))){
    pars_$d = 0
  }
  if (!("sigma" %in% names(pars_))){
    pars_$sigma = 1e-9
  }
  if (!("theta" %in% names(pars_))){
    pars_$theta = 0.5
  }
  if (!("bias" %in% names(pars_))){
    pars_$bias = 0
  }
  if (!("barrier" %in% names(pars_))){
    pars_$barrier = 1
  }
  if (!("timeStep" %in% names(pars_))){
    pars_$timeStep = 10
  }
  if (!("maxIter" %in% names(pars_))){
    pars_$maxIter = 600
  }

  # Extract the correct trial simulator for the model_name
  fit_trial = fit_trial_list_[[model_name_]]

  # Print arguments that will be used for simulation if in debug mode
  if(debug){
    print(paste0("Simulating task with parameters: d = ", kwargs$d,
                 ", sigma = ", kwargs$sigma,
                 ", theta = ", kwargs$theta,
                 ", bias = ", kwargs$bias,
                 ", maxIter = ", kwargs$maxIter,
                 ", timeStep = ", kwargs$timeStep))
  }

  # Parallel loop
  out <- foreach(
    vL = data_$vL,
    vR = data_$vR,
    choice = data_$choice,
    responseTime = data_$rt,
    fixLoc = data_$fixLoc,
    .combine = 'rbind'
  ) %dopar% {
    # Simulate RT and choice for a single trial with given DDM parameters and trial stimulus values
    fit_trial(d=pars_$d, sigma = pars_$sigma, theta = pars_$theta, bias = pars_$bias,
              barrier = pars_$barrier, timeStep = pars_$timeStep, approxStateStep = pars_$approxStateStep,
              vL = vL, vR = vR, choice = choice, responseTime = responseTime, fixLoc = fixLoc)

  }

  # Add details of the parameters used for the simulation
  out$model = model_name_

  return(out)
}

# Usage in optim
# optim(par, get_task_nll, data_, par_names, model_name)
get_task_nll = function(data_, par_, par_names_, model_name_){

  # Initialize parameters
  # Different models will have different sets of parameters. Optim will optimize over all the parameters it is passed in

  pars = setNames(as.list(par_), par_names_)

  # Get trial likelihoods for the stimuli using the initialized parameters
  out = fit_task(data_ = data_, model_name_ = model_name_, pars_ = pars)

  nll = -sum(log(out$likelihood+1e-200))

  return(nll)
}