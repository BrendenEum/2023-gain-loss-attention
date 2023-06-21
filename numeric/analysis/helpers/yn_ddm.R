sim_trial = function(d, sigma, nonDecisionTime, bias, barrierDecay, barrier=1, timeStep=10, maxIter=400, debug=FALSE,...){

  # d : drift rate
  # sigma: sd of the normal distribution
  # timeStep: in ms
  # nonDecisionTime: in ms
  # maxIter: num max samples. if a barrier isn't hit by this sampling of evidence no decision is made.
  # If time step is 10ms and maxIter is 1000 this would be a 10sec timeout maximum

  if (debug){
    debug_df = data.frame(time = 0, mu = NA, RDV = 0, barrier = barrier)
  }

  RDV = bias # this is operationalized differently than the HDDM, where it ranges 0 to 1 and no bias is .5
  # Here no bias is 0 and the range is -1 to 1
  time = 1
  elapsedNDT = 0
  choice = 0
  RT = NA

  tooSlow = 0

  kwargs = list(...)

  ValStim=kwargs$ValStim
  ValRef=kwargs$ValRef

  nonDecIters = nonDecisionTime / timeStep

  initialBarrier = barrier
  barrier = rep(initialBarrier, maxIter)

  # The values of the barriers can change over time
  for(t in seq(2, maxIter, 1)){
    barrier[t] = initialBarrier / (1 + (barrierDecay * t))
  }

  mu_mean = d * (ValStim - ValRef)

  while (time<maxIter){

    # If the RDV hit one of the barriers, the trial is over.
    if (RDV >= barrier[time] | RDV <= -barrier[time]){

      # Convert ms back to secs
      RT = (time * timeStep)/1000

      if (RDV >= barrier[time]){
        choice = "yes"
      } else if (RDV <= -barrier[time]){
        choice = "no"
      }
      break
    }


    if (elapsedNDT < nonDecIters){
      mu = 0
      elapsedNDT = elapsedNDT + 1
    } else{
      mu = mu_mean
    }

    # Sample the change in RDV from the distribution.
    RDV = RDV + rnorm(1, mu, sigma)

    if (debug){
      debug_row = data.frame(time = time, mu = round(mu, 3), RDV = round(RDV, 3), barrier = round(barrier[time], 3))
      debug_df = rbind(debug_df, debug_row)
    }

    # Increment sampling iteration
    time = time + 1
  }

  # If a choice hasn't been made by the time limit
  if(is.na(RT)){
    # Choose whatever you have most evidence for
    if (RDV >= 0){
      choice = "yes"
    } else if (RDV <= 0){
      choice = "no"
    }
    if(debug){
      print("Max iterations reached.")
    }
    tooSlow = 1
    RT=rlnorm(1, mean = 1.25, sd = 0.1)
  }

  # Make sure the RT is always at least as large as the nonDecisionTime
  # (Even if a boundary is hit only by noise before nDt)
  tooFast = as.numeric( (RT*1000) < nonDecisionTime )
  RT = ifelse( (RT*1000) < nonDecisionTime, nonDecisionTime/1000, RT)

  #Organize output
  out = data.frame(ValStim = ValStim, ValRef = ValRef, choice=choice, reactionTime = RT, tooSlow = tooSlow, tooFast = tooFast, d = d, sigma = sigma, barrierDecay = barrierDecay, barrier=barrier[time], nonDecisionTime=nonDecisionTime, bias=bias, timeStep=timeStep, maxIter=maxIter)

  if(debug){
    return(list(out=out, debug_df = debug_df))
  } else {
    return(out)
  }
}


fit_trial = function(d, sigma, nonDecisionTime, bias, barrierDecay, barrier=1, timeStep=10, approxStateStep = 0.1, debug=FALSE, ...){

  # RDV = bias

  kwargs = list(...)

  choice=kwargs$choice #must be 1 for left and -1 for left
  if(choice == "yes" | choice == 1){
    choice = 1
  } else if (choice == "no" | choice == 0){
    choice = -1
  }
  reactionTime=kwargs$reactionTime #in ms
  if(reactionTime < 100){
    reactionTime = reactionTime *1000
  }

  ValStim=kwargs$ValStim
  ValRef=kwargs$ValRef

  nonDecIters = nonDecisionTime / timeStep

  numTimeSteps = floor(reactionTime / timeStep)

  initialBarrier = barrier
  barrier = rep(initialBarrier, numTimeSteps)

  # The values of the barriers can change over time
  for(t in seq(2, numTimeSteps, 1)){
    barrier[t] = initialBarrier / (1 + (barrierDecay * (t-1)) )
  }

  # Obtain correct state step.

  # Make state space finer if the average drift rate is too small
  mu_mean = d * (ValStim - ValRef)

  i = 1
  while(i < 4){
    if(approxStateStep > abs(mu_mean)){
      print("Reducing approxStateStep...")
      approxStateStep = approxStateStep/10
      print(paste0("New approxStateStep = ", approxStateStep))
    }
    i = i+1
  }

  # If attempt to reduce the state step has failed notify
  if(approxStateStep > abs(mu_mean)){
    print("State space reduction failed.")
  }

  halfNumStateBins = round(initialBarrier / approxStateStep)
  stateStep = initialBarrier / (halfNumStateBins + 0.5)

  # The vertical axis is divided into states.
  states = seq(-1*(initialBarrier) + (stateStep / 2), initialBarrier - (stateStep / 2), stateStep)

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

  changeMatrix = matrix(data = states, ncol=length(states), nrow=length(states), byrow=FALSE) - matrix(data = states, ncol=length(states), nrow=length(states), byrow=TRUE)

  # How much change is required from each state to cross the up or down barrier at each time point

  changeUp = matrix(data = barrier, ncol=numTimeSteps, nrow=length(states), byrow=TRUE) - matrix(data = states, ncol=numTimeSteps, nrow=length(states), byrow=FALSE)
  changeDown = matrix(data = -barrier, ncol=numTimeSteps, nrow=length(states), byrow=TRUE) - matrix(data = states, ncol=numTimeSteps, nrow=length(states), byrow=FALSE)

  elapsedNDT = 0

  # LOOP of state probability updating up to reaction time

  # Start at 2 to match python indexing that starts at 0
  for(nextTime in 2:numTimeSteps){

    curTime = nextTime - 1

    if (elapsedNDT < nonDecIters){
      mu = 0
      elapsedNDT = elapsedNDT + 1
    } else{
      mu = mu_mean
    }

    # Update the probability of the states that remain inside the
    # barriers. The probability of being in state B is the sum, over
    # all states A, of the probability of being in A at the previous
    # time step times the probability of changing from A to B. We
    # multiply the probability by the stateStep to ensure that the area
    # under the curves for the probability distributions probUpCrossing
    # and probDownCrossing add up to 1.
    # If there is barrier decay and there are next states that are cross
    # the decayed barrier set their probabilities to 0.

    prStatesNew = (stateStep * (dnorm(changeMatrix, mu, sigma) %*% prStates[,curTime]) )
    prStatesNew[states >= barrier[nextTime] | states <= -barrier[nextTime]] = 0

    # Calculate the probabilities of crossing the up barrier and the
    # down barrier. This is given by the sum, over all states A, of the
    # probability of being in A at the previous timestep times the
    # probability of crossing the barrier if A is the previous state.

    tempUpCross = (prStates[,curTime] %*% (1 - pnorm(changeUp[,nextTime], mu, sigma)))[1]
    tempDownCross = (prStates[,curTime] %*% (pnorm(changeDown[,nextTime], mu, sigma)))[1]

    # Renormalize to cope with numerical approximations.

    sumIn = sum(prStates[,curTime])
    sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
    prStatesNew = prStatesNew * sumIn / sumCurrent
    tempUpCross = tempUpCross * sumIn / sumCurrent
    tempDownCross = tempDownCross * sumIn / sumCurrent

    # Update the probabilities of each state and the probabilities of
    # crossing each barrier at this timestep.

    prStates[, nextTime] = prStatesNew
    probUpCrossing[nextTime] = tempUpCross
    probDownCrossing[nextTime] = tempDownCross

    checksFailed = 0
    checks = c(sumIn == 0,
               is.nan(tempDownCross),
               is.na(tempDownCross),
               is.nan(tempUpCross),
               is.na(tempUpCross),
               (!is.nan(probUpCrossing[nextTime]) & probUpCrossing[nextTime] < probUpCrossing[curTime]),
               (!is.nan(probDownCrossing[nextTime]) & probDownCrossing[nextTime] < probDownCrossing[curTime]))

    if(sum(checks)>0){
      print("Numerical approximations will break. Drift rate might be too high. Or RT too fast.")
      break
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

  out = data.frame(likelihood = likelihood, ValStim = ValStim, ValRef = ValRef, choice=choice, reactionTime = reactionTime, d = d, sigma = sigma, nonDecisionTime=nonDecisionTime, bias=bias, barrierDecay = barrierDecay, barrier=barrier[numTimeSteps], timeStep=timeStep)


  return(out)

}