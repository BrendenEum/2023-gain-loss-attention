addm_simulate_trial <- function(b=.002, d=.003, t=.5, s=.02, e=.0003, ref=0, valueL=2, valueR=2, prFirstLeft=.8, firstFix=c(272), middleFix=c(456), latency=c(170), transition=c(25)) {
  
  ###################################################################
  # create a variable to track when to stop (for efficiency purposes)
  stopper <- 0
  
  ##############################
  # initialize rdv at bias point
  RDV <- b
  rt  <- 0
  
  ##############################
  # reference-dependence
  vL = valueL - ref
  vR = valueR - ref
  
  ###########################################################################
  # keep track of total time fix left and right, and first fixation duration
  totFixL <- 0
  totFixR <- 0
  firstDuration <- 0
  firstFixLoc <- 0
  
  ##############################
  # latency to first fixation
  latencyDur <- sample(latency,1)
  latency_err <- rnorm(n=latencyDur, mean=0, sd=s)
  
  if (abs(RDV+sum(latency_err))>=1) {
    for (t in 1:latencyDur) {
      RDV <- RDV + latency_err[t]
      rt <- rt + 1
      lastLoc <- 4
      if (abs(RDV)>=1) {stopper<-1; break}
    }
  } else {
    RDV <- RDV + sum(latency_err)
    rt <- rt + latencyDur
  }
  
  ##############################
  # first fixation
  if (stopper==0) {
    firstDur <- sample(firstFix,1)
    firstDuration <- firstDur
    loc <- rbinom(1,1,prFirstLeft)
    firstFixLoc <- loc
    if (loc==1) {drift <- rep(d*(vL-t*vR) + e, firstDur)}
    if (loc==0) {drift <- rep(d*(t*vL-vR) - e, firstDur)}
    
    if (abs(RDV+sum(drift))>=1) {
      for (t in 1:firstDur) {
        RDV <- RDV + drift[t]
        rt <- rt + 1
        lastLoc <- loc
        if (abs(RDV)>=1) {stopper<-1; break}
      }
    } else {
      RDV <- RDV + sum(drift)
      rt <- rt + firstDur
      prevLoc <- loc
    }
    
    if (loc==1) {totFixL = totFixL + firstDur}
    if (loc==0) {totFixR = totFixR + firstDur}
  }
  
  #######################################################
  # transitions and middle fixations until choice is made
  while (abs(RDV)<1) {
    transDur <- sample(transition,1)
    trans_err <- rnorm(n=transDur, mean=0, sd=s)
    
    if (abs(RDV+sum(trans_err))>=1) {
      for (t in 1:transDur) {
        RDV <- RDV + trans_err[t]
        rt <- rt + 1
        lastLoc <- prevLoc
        if (abs(RDV)>=1) {stopper<-1; break}
      }
    } else {
      RDV <- RDV + sum(trans_err)
      rt <- rt + transDur
    }
    
    if (stopper==0) {
      middleDur <- sample(middleFix,1)
      if (prevLoc==1) {loc<-0}
      if (prevLoc==0) {loc<-1}
      if (loc==1) {drift <- rep(d*(vL-t*vR) + e, middleDur)}
      if (loc==0) {drift <- rep(d*(t*vL-vR) - e, middleDur)}
    
      if (abs(RDV+sum(drift))>=1) {
        for (t in 1:middleDur) {
          RDV <- RDV + drift[t]
          rt <- rt + 1
          lastLoc <- loc
          if (abs(RDV)>=1) {break}
        }
      } else {
        RDV <- RDV + sum(drift)
        rt <- rt + middleDur
        prevLoc <- loc
      }
      
      
      if (loc==1) {totFixL = totFixL + middleDur}
      if (loc==0) {totFixR = totFixR + middleDur}
    }
  }

  ##############################
  # return your results
  if (RDV>0) {choice <- 1}
  if (RDV<0) {choice <- 0}
  if (lastLoc==4) {lastLoc = firstFixLoc}
  if (lastLoc==1) {nlastOtherVDiff=(valueL-valueR)/5}
  if (lastLoc==0) {nlastOtherVDiff=(valueR-valueL)/5}
  if (firstFixLoc==1) {nfirstOtherVDiff=(valueL-valueR)/5}
  if (firstFixLoc==0) {nfirstOtherVDiff=(valueR-valueL)/5}
  results <- data.frame(
    choice=choice, 
    rt=rt/1000, 
    vL=valueL, 
    vR=valueR, 
    lastFixLoc=lastLoc,
    net_fix=(totFixL-totFixR)/1000,
    nlastOtherVDiff = nlastOtherVDiff,
    firstDur=firstDuration/1000,
    firstFixLoc=firstFixLoc,
    nfirstOtherVDiff=nfirstOtherVDiff
  )
  return(results)
  
}