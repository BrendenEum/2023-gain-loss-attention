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
  if (!("d" %in% names(kwargs))){
    kwargs$d = 0
  }
  if (!("sigma" %in% names(kwargs))){
    kwargs$sigma = 1e-9
  }
  if (!("nonDecisionTime" %in% names(kwargs))){
    kwargs$nonDecisionTime = 0
  }
  if (!("barrier" %in% names(kwargs))){
    kwargs$barrier = 1
  }
  if (!("barrierDecay" %in% names(kwargs))){
    kwargs$barrierDecay = 0
  }
  if (!("bias" %in% names(kwargs))){
    kwargs$bias = 0
  }
  if (!("timeStep" %in% names(kwargs))){
    kwargs$timeStep = 10
  }
  if (!("maxIter" %in% names(kwargs))){
    kwargs$maxIter = 400
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
                 ", non-decision time = ", kwargs$nonDecisionTime,
                 ", bias = ", kwargs$bias,
                 ", barrierDecay = ", kwargs$barrierDecay,
                 ", maxIter = ", kwargs$maxIter,
                 ", timeStep = ", kwargs$timeStep))
  }

  #register it to be used by %dopar%
  # doParallel::registerDoParallel(cl = my.sim.cluster)

  # Parallel loop
  out <- foreach(
    ValStim = stimuli$possiblePayoff_dmn,
    ValRef = stimuli$reference,
    .combine = 'rbind'
  ) %dopar% {
    # Simulate RT and choice for a single trial with given DDM parameters and trial stimulus values
    sim_trial(d = kwargs$d, sigma = kwargs$sigma,
              barrier = kwargs$barrier, nonDecisionTime = kwargs$nonDecisionTime, barrierDecay = kwargs$barrierDecay,
              bias = kwargs$bias, timeStep = kwargs$timeStep, maxIter = kwargs$maxIter,
              ValStim = ValStim, ValRef = ValRef)

  }

  # parallel::stopCluster(cl = my.sim.cluster)

  # Add details of the parameters used for the simulation
  out$model = model_name

  return(out)
}