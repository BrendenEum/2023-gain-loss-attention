###################################################################################################
## Simulate a trial
###################################################################################################

sim_trial = function(d, sigma, theta, bias, barrier=1, timeStep=10, maxIter=600, debug=FALSE, ...){

  # d : drift rate
  # sigma: sd of the normal distribution
  # theta: attentional discounting
  # timeStep: in ms
  # maxIter: num max samples. if a barrier isn't hit by this sampling of evidence no decision is made.
  # If time step is 10ms and maxIter is 1000 this would be a 10sec timeout maximum

  if (debug){
    debug_df = data.frame(iteration = 0, location = NA, mu = NA, RDV = 0, barrier = barrier)
  }

  kwargs = list(...)

  vL = kwargs$vL
  vR = kwargs$vR
  prFirstLeft  = kwargs$prFirstLeft
  firstIter_   = floor(kwargs$firstFix / timeStep)
  middleIter_  = floor(kwargs$middleFix / timeStep)
  latencyIter_ = floor(kwargs$latency / timeStep)
  saccadeIter_ = floor(kwargs$saccade / timeStep)

  initialBarrier = barrier
  barrier = rep(initialBarrier, maxIter)

  # create a variable to track when to stop (for efficiency purposes)
  stopper <- 0

  # initialize rdv at bias point
  RDV <- bias
  iter  <- 0

  ##############################
  # latency to first fixation
  latencyIter <- sample(latencyIter_,1)
  latencyNoise <- rnorm(n=latencyIter, mean=0, sd=sigma)
  loc <- 4

  if (abs(RDV+sum(latencyNoise))>=1) {
    for (t in 1:latencyIter) {
      RDV <- RDV + latencyNoise[t]
      iter <- iter + 1
      if (abs(RDV)>=1) {stopper<-1; break}
    }
  } else {
    RDV <- RDV + sum(latencyNoise)
    iter <- iter + latencyIter
  }

  # Debugging
  if (debug){
    debug_row = data.frame(iteration = iter, location = loc, mu = 0, RDV = round(RDV, 3), barrier = round(barrier[iter], 3))
    debug_df = rbind(debug_df, debug_row)
  }

  ##############################
  # first fixation
  if (stopper==0) {
    firstIter <- sample(firstIter_,1)
    loc <- rbinom(1,1,prFirstLeft)
    if (loc==1) {drift_mean <- d*(vL-theta*vR)}
    if (loc==0) {drift_mean <- d*(theta*vL-vR)}
    drift <- drift_mean + rnorm(n=firstIter, mean=0, sd=sigma)

    if (abs(RDV+sum(drift))>=1) {
      for (t in 1:firstIter) {
        RDV <- RDV + drift[t]
        iter <- iter + 1
        lastLoc <- loc
        if (abs(RDV)>=1) {stopper<-1; break}
      }
    } else {
      RDV <- RDV + sum(drift)
      iter <- iter + firstIter
      prevLoc <- loc
    }

    # Debugging
    if (debug){
      debug_row = data.frame(iteration = iter, location = loc, mu = round(drift_mean, 3), RDV = round(RDV, 3), barrier = round(barrier[iter], 3))
      debug_df = rbind(debug_df, debug_row)
    }
  }

  #######################################################
  # transitions and middle fixations until choice is made
  while (abs(RDV)<1 & iter<=maxIter) {
    saccadeIter <- sample(saccadeIter_,1)
    saccadeNoise <- rnorm(n=saccadeIter, mean=0, sd=sigma)
    loc <- 4

    if (abs(RDV+sum(saccadeNoise))>=1) {
      for (t in 1:saccadeIter) {
        RDV <- RDV + saccadeNoise[t]
        iter <- iter + 1
        if (abs(RDV)>=1) {stopper<-1; break}
      }
    } else {
      RDV <- RDV + sum(saccadeNoise)
      iter <- iter + saccadeIter
    }

    # Debugging
    if (debug){
      debug_row = data.frame(iteration = iter, location = loc, mu = round(drift_mean, 3), RDV = round(RDV, 3), barrier = round(barrier[iter], 3))
      debug_df = rbind(debug_df, debug_row)
    }

    if (stopper==0) {
      middleIter <- sample(middleIter_,1)
      if (prevLoc==1) {loc<-0}
      if (prevLoc==0) {loc<-1}
      if (loc==1) {drift_mean <- d*(vL-theta*vR)}
      if (loc==0) {drift_mean <- d*(theta*vL-vR)}
      drift <- drift_mean + rnorm(n=middleIter, mean=0, sd=sigma)

      if (abs(RDV+sum(drift))>=1) {
        for (t in 1:middleIter) {
          RDV <- RDV + drift[t]
          iter <- iter + 1
          if (abs(RDV)>=1) {break}
        }
      } else {
        RDV <- RDV + sum(drift)
        iter <- iter + middleIter
        prevLoc <- loc
      }
    }

    # Debugging
    if (debug){
      debug_row = data.frame(iteration = iter, location = loc, mu = round(drift_mean, 3), RDV = round(RDV, 3), barrier = round(barrier[iter], 3))
      debug_df = rbind(debug_df, debug_row)
    }

  }

  # response time
  rt = (iter * timeStep) / 1000 # convert timesteps to ms, then to s

  # Choice
  choice <- NA
  if (RDV>=1) {choice <- 1}
  if (RDV<=-1) {choice <- 0}

  # If a choice hasn't been made by the time limit
  tooSlow = 0
  if (is.na(choice)) {
    # Choose whatever you have most evidence for
    if (RDV >= 0) {
      choice = 1
    } else if (RDV < 0) {
      choice = 0
    }
    if(debug){
      print("Max iterations reached.")
    }
    tooSlow = 1
  }

  #Organize output
  out = data.frame(
    vL = vL,
    vR = vR,
    choice=choice,
    responseTime = rt,
    tooSlow = tooSlow,
    d = d,
    sigma = sigma,
    theta = theta,
    bias = bias,
    barrier=barrier[iter],
    timeStep=timeStep,
    maxIter=maxIter
  )

  if(debug){
    return(list(out=out, debug_df = debug_df))
  } else {
    return(out)
  }
}



###################################################################################################
## Calculate the likelihood of a single trial
###################################################################################################

fit_trial = function(d, sigma, theta, bias, barrier=1, timeStep=10, approxStateStep = 0.05, debug=FALSE, ...){

  # RDV = bias

  kwargs = list(...)

  choice=kwargs$choice #must be 1 for left and -1 for left
  if(choice == "yes" | choice == 1){
    choice = 1
  } else if (choice == "no" | choice == 0){
    choice = -1
  }
  responseTime=kwargs$responseTime #in ms
  if(responseTime < 100){
    responseTime = responseTime * 1000
  }

  vL=kwargs$vL
  vR=kwargs$vR
  fixLoc = kwargs$fixLoc

  numTimeSteps = floor(responseTime / timeStep)

  initialBarrier = barrier
  barrier = rep(initialBarrier, numTimeSteps)

  # # Obtain correct state step.
  #
  # # Make state space finer if the minimum possible drift rate is too small
  # mu_L = d * (vL - theta*vR)
  # mu_R = d * (theta*vL - vR)
  # mu_min = min(mu_L, mu_R)
  #
  # for (i in 1:4){
  #   if(approxStateStep > abs(mu_min)){
  #     print("Reducing approxStateStep...")
  #     approxStateStep = approxStateStep/10
  #     print(paste0("New approxStateStep = ", approxStateStep))
  #   }
  # }
  #
  # # If attempt to reduce the state step has failed notify
  # if(approxStateStep > abs(mu_min)){
  #   print("State space reduction failed.")
  # }

  halfNumStateBins = round(initialBarrier / approxStateStep)
  stateStep = initialBarrier / (halfNumStateBins + 0.5)

  # The vertical axis is divided into states.
  states = seq(-1*(initialBarrier) + (stateStep / 2), initialBarrier - (stateStep / 2), stateStep)
  #states = seq(-1*(initialBarrier), initialBarrier, stateStep)

  # Find the state corresponding to the bias parameter.
  biasState = which.min(abs(states - bias))

  # Initial probability for all states is zero, except the bias state,
  # for which the initial probability is one.
  # p(bottom boundary) is the first value! Don't get confused by seeing it at the top

  prStates = matrix(data = 0, nrow = length(states), ncol = numTimeSteps)
  prStates[biasState,1] = 1

  # The probability of crossing each barrier over the time of the trial.

  probUpCrossing = rep(0, numTimeSteps)
  probDownCrossing = rep(0, numTimeSteps)

  # Rows of these matrices correspond to array elements in python

  # How much change is required from each state to move onto every other state. From the smallest state (bottom boundary) to the largest state (top boundary)

  changeMatrix = matrix(data = states, ncol=length(states), nrow=length(states), byrow=FALSE) -
    matrix(data = states, ncol=length(states), nrow=length(states), byrow=TRUE)

  # How much change is required from each state to cross the up or down barrier at each time point

  changeUp = matrix(data = barrier, ncol=numTimeSteps, nrow=length(states), byrow=TRUE) -
    matrix(data = states, ncol=numTimeSteps, nrow=length(states), byrow=FALSE)
  changeDown = matrix(data = -barrier, ncol=numTimeSteps, nrow=length(states), byrow=TRUE) -
    matrix(data = states, ncol=numTimeSteps, nrow=length(states), byrow=FALSE)

  # LOOP of state probability updating up to reaction time

  # Start at 2 to match python indexing that starts at 0
  debug_out = data.frame(
    sumIn = NA,
    sumPrStatesNew = NA,
    sumProbUpCrossing = NA,
    tempUpCross = NA,
    sumProbDownCrossing = NA,
    tempDownCross = NA,
    sumCurrent = NA,
    checkNextProb = NA
  )
  debug_row = debug_out

  for(nextTime in 2:numTimeSteps){

    curTime = nextTime - 1

    if (fixLoc[curTime]==4) {mu = 0}
    if (fixLoc[curTime]==1) {mu = d*(vL - theta*vR)}
    if (fixLoc[curTime]==0) {mu = d*(theta*vL - vR)}

    # Update the probability of the states that remain inside the
    # barriers. The probability of being in state B is the sum, over
    # all states A, of the probability of being in A at the previous
    # time step times the probability of changing from A to B. We
    # multiply the probability by the stateStep to ensure that the area
    # under the curves for the probability distributions probUpCrossing
    # and probDownCrossing add up to 1.

    prStatesNew = (stateStep * (dnorm(changeMatrix, mu, sigma) %*% prStates[,curTime]) )
    debug_row$sumPrStatesNew = sum(prStatesNew)

    # Calculate the probabilities of crossing the up barrier and the
    # down barrier. This is given by the sum, over all states A, of the
    # probability of being in A at the previous timestep times the
    # probability of crossing the barrier if A is the previous state.

    tempUpCross = (prStates[,curTime] %*% (1 - pnorm(changeUp[,nextTime], mu, sigma)))[1]
    tempDownCross = (prStates[,curTime] %*% (pnorm(changeDown[,nextTime], mu, sigma)))[1]
    debug_row$tempUpCross = tempUpCross
    debug_row$tempDownCross = tempDownCross

    # Renormalize to cope with numerical approximations.

    sumIn = sum(prStates[,curTime])
    sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross

    debug_row$sumIn = sumIn
    debug_row$sumCurrent = sumCurrent
    debug_row$sumProbUpCrossing = sum(probUpCrossing[1:curTime])
    debug_row$sumProbDownCrossing = sum(probDownCrossing[1:curTime])

    prStatesNew = prStatesNew * sumIn / sumCurrent
    tempUpCross = tempUpCross * sumIn / sumCurrent
    tempDownCross = tempDownCross * sumIn / sumCurrent

    debug_row$checkNextProb = sum(prStatesNew) + tempUpCross + tempDownCross + sum(probUpCrossing[1:curTime]) + sum(probDownCrossing[1:curTime])

    # Update the probabilities of each state and the probabilities of
    # crossing each barrier at this timestep.

    prStates[, nextTime] = prStatesNew
    probUpCrossing[nextTime] = tempUpCross
    probDownCrossing[nextTime] = tempDownCross

    checks = c(sumIn == 0,
               is.nan(tempDownCross),
               is.na(tempDownCross),
               is.nan(tempUpCross),
               is.na(tempUpCross))
               #(!is.nan(probUpCrossing[nextTime]) & probUpCrossing[nextTime] < probUpCrossing[curTime]),
               #(!is.nan(probDownCrossing[nextTime]) & probDownCrossing[nextTime] < probDownCrossing[curTime]))

    if(sum(checks)>0){
      print("Numerical approximations will break. Drift rate might be too high. Or RT too fast.")
      print(checks)
      break
    }

    if (debug){
      debug_out = rbind(debug_out, debug_row)
    }
  }

  likelihood = 0
  if (choice == 1){ # Choice was yes/top boundary
    if (!is.nan(probUpCrossing[numTimeSteps]) & !is.na(probUpCrossing[numTimeSteps]) & probUpCrossing[numTimeSteps] > 0){
      likelihood = probUpCrossing[numTimeSteps]
    }
  } else if (choice == -1){
    if(!is.nan(probDownCrossing[numTimeSteps]) & !is.na(probDownCrossing[numTimeSteps]) & probDownCrossing[numTimeSteps] > 0){
      likelihood = probDownCrossing[numTimeSteps]
    }
  }

  out = data.frame(
    likelihood = likelihood,
    vL = vL,
    vR = vR,
    choice = choice,
    responseTime = responseTime/1000,
    d = d,
    sigma = sigma,
    theta = theta,
    bias = bias,
    barrier = barrier[numTimeSteps],
    stateStep = stateStep,
    timeStep = timeStep
  )

  if (debug){

    prStates <<- prStates
    View(debug_out)
    return(list(out = out, debug_out = debug_out))

  }

  return(out)

}

source('TEST.R')
colSums(prStates)