library(foreach)

# Parallelization setup based on this post
# https://www.blasbenito.com/post/02_parallelizing_loops_with_r/
# n.cores <- parallel::detectCores() - 1
n.cores <- 4

#create the cluster
my.sim.cluster <- parallel::makeCluster(
  n.cores,
  type = "FORK"
)

#register it to be used by %dopar%
doParallel::registerDoParallel(cl = my.sim.cluster)

# Function to simulate ddm process for a given set of stimuli using a model provided as a string in the model_name argument
sim_task = function(stimuli, model_name, sim_trial_list_ = sim_trial_list, ...){

  kwargs = list(...)
  #
  # Initialize any missing arguments. Some are useless defaults to make sure different sim_trial functions from different models can run without errors even if they don't make use of that argument
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
  if (!("debug" %in% names(kwargs))){
    kwargs$debug = FALSE
  }

  # Extract the correct trial simulator for the model_name
  sim_trial = sim_trial_list_[[model_name]]

  # Print arguments that will be used for simulation if in debug mode
  if(kwargs$debug){
    print(paste0("Simulating task with parameters: d = ", kwargs$d,
                 ", sigma = ", kwargs$sigma,
                 ", theta = ", kwargs$theta,
                 ", bias = ", kwargs$bias,
                 ", maxIter = ", kwargs$maxIter,
                 ", timeStep = ", kwargs$timeStep))
  }

  #register it to be used by %dopar%
  # doParallel::registerDoParallel(cl = my.sim.cluster)

  # Parallel loop
  out <- foreach(
    vL = stimuli$vL,
    vR = stimuli$vR,
    .combine = 'rbind'
  ) %dopar% {
    # Simulate RT and choice for a single trial with given DDM parameters and trial stimulus values
    sim_trial(d = kwargs$d, sigma = kwargs$sigma, theta = kwargs$theta, bias = kwargs$bias,
              barrier = kwargs$barrier, timeStep = kwargs$timeStep, maxIter = kwargs$maxIter,
              vL = vL, vR = vR,
              prFirstLeft = prFirstLeft, firstFix = firstFix, middleFix = middleFix, latency = latency, saccade = saccade)
  }

  # parallel::stopCluster(cl = my.sim.cluster)

  # Add details of the parameters used for the simulation
  out$model = model_name

  return(out)
}