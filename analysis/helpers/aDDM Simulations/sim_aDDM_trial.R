simulate.trial <- function(
    study = "dots",
    model = "aDDM",
    b = .002,
    d = .003,
    t = .5,
    s = .02,
    k = 0,
    vL = 2,
    vR = 2,
    vMin = 1,
    vMax = 6,
    fixCrossLoc = "Center",
    prFirstLeft = .8,
    firstFix = c(272),
    middleFix = c(456),
    latency = c(170), 
    transition = c(25),
    maximum_rt = 20000
) {
  
  ###################################################################
  # Prep work
  stopper <- 0 # create a variable to track when to stop (for efficiency purposes)
  RDV <- b # initialize rdv at bias point
  rt  <- 0 # recorded rt starts at 0
  totFixL <- 0 # keep track of total time fix left and right, and first fixation duration
  totFixR <- 0
  firstDuration <- 0
  firstFixLoc <- 0
  earlyFixL <- 0 # keep track of early fixation left and late fixation left in case reviewers ask
  lateFixL <- 0
  resim <- 1 # restart simulation if it takes too long

  ###################################################################
  # Evidence function for various models
  # model=model, d=d, t=t, k=k, vL=vL, vR=vR, vMax=vMax, vMin=vMin
  evidence = function(loc) {
    
    if (model=="aDDM" | model=="UaDDM") {
      if (loc==1){mu = d*(vL-t*vR)}
      if (loc==0){mu = d*(t*vL-vR)}
    }
    
    if (model=="AddDDM") {
      if (loc==1){mu = d*(vL-vR+k)}
      if (loc==0){mu = d*(vL-vR-k)}
    }
    
    if (model=="DNaDDM") {
      L = vL/abs(vL+vR)
      R = vR/abs(vL+vR)
      if (loc==1){mu = d*(L-t*R)}
      if (loc==0){mu = d*(t*L-R)}
    }
    
    if (model=="GDaDDM") {
      L = vL-vMin
      R = vR-vMin
      if (loc==1){mu = d*(L-t*R)}
      if (loc==0){mu = d*(t*L-R)}
    }
    
    if (model=="RNaDDM") {
      L = (vL-vMin)/(vMax-vMin)
      R = (vR-vMin)/(vMax-vMin)
      if (loc==1){mu = d*(L-t*R)}
      if (loc==0){mu = d*(t*L-R)}
    }
    
    if (model=="RNPaDDM" | model=="DRNPaDDM") {
      L = ((vL-vMin)/(vMax-vMin)) + (k/(1-t))
      R = ((vR-vMin)/(vMax-vMin)) + (k/(1-t))
      if (loc==1){mu = d*(L-t*R)}
      if (loc==0){mu = d*(t*L-R)}
    }
    
    return(mu)
  }
  
  ###################################################################
  # LATENCY and FIRST FIXATIONS
  # Dots and numeric studies will differ when it comes to latency to first fixation and first fixation location.
  # Location is not stochastic in numeric, and latency may be 0 if fix cross is not "Center"
  
  ## DOTS ##
  
  if (study == "dots") {
    
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
    
    # first fixation 
    if (stopper==0) {
      firstDur <- sample(firstFix,1)
      firstDuration <- firstDur
      loc <- rbinom(1,1,prFirstLeft)
      firstFixLoc <- loc
      drift = evidence(loc) + rnorm(n=firstDur, mean=0, sd=s)
      if (abs(RDV+sum(drift))>=1) {
        for (t in 1:firstDur) {
          RDV <- RDV + drift[t]
          rt <- rt + 1
          if (loc==1 & rt<=1000) {earlyFixL <- earlyFixL + 1}
          if (loc==1 & rt>1000) {lateFixL <- lateFixL + 1}
          lastLoc <- loc
          if (abs(RDV)>=1) {stopper<-1; break}
        }
      } else {
        RDV <- RDV + sum(drift)
        rt <- rt + firstDur
        if (loc==1 & rt<=1000) {earlyFixL <- earlyFixL + firstDur}
        if (loc==1 & rt>1000) {
          earlyFixL <- earlyFixL + 1000
          lateFixL <- lateFixL + rt - 1000
        }
        prevLoc <- loc
      }
      if (loc==1) {totFixL = totFixL + firstDur}
      if (loc==0) {totFixR = totFixR + firstDur}
    }
  }
  
  ## Numeric ##
  
  if (study == "numeric") {
    
    # latency to first fixation
    if (fixCrossLoc=="Left" | fixCrossLoc=="Right") {latencyDur=0}
    if (fixCrossLoc=="Center") {latencyDur <- sample(latency,1)}
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
    
    # first fixation 
    if (stopper==0) {
      firstDur <- sample(firstFix,1)
      firstDuration <- firstDur
      if (fixCrossLoc=="Left") {loc=1}
      if (fixCrossLoc=="Right") {loc=0}
      if (fixCrossLoc=="Center") {loc <- rbinom(1,1,prFirstLeft)}
      firstFixLoc <- loc
      drift <- evidence(loc) + rnorm(n=firstDur, mean=0, sd=s)
      if (abs(RDV+sum(drift))>=1) {
        for (t in 1:firstDur) {
          RDV <- RDV + drift[t]
          rt <- rt + 1
          if (loc==1 & rt<=1000) {earlyFixL <- earlyFixL + 1}
          if (loc==1 & rt>1000) {lateFixL <- lateFixL + 1}
          lastLoc <- loc
          if (abs(RDV)>=1) {stopper<-1; break}
        }
      } else {
        RDV <- RDV + sum(drift)
        rt <- rt + firstDur
        if (loc==1 & rt<=1000) {earlyFixL <- earlyFixL + firstDur}
        if (loc==1 & rt>1000) {
          earlyFixL <- earlyFixL + 1000
          lateFixL <- lateFixL + rt - 1000
        }
        prevLoc <- loc
      }
      if (loc==1) {totFixL = totFixL + firstDur}
      if (loc==0) {totFixR = totFixR + firstDur}
    }
  }
  
  #######################################################
  # TRANSITIONS and MIDDLE FIXATIONS
  
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
      drift <- evidence(loc) + rnorm(n=middleDur, mean=0, sd=s)
      
      if (abs(RDV+sum(drift))>=1) {
        for (t in 1:middleDur) {
          RDV <- RDV + drift[t]
          rt <- rt + 1
          if (loc==1 & rt<=1000) {earlyFixL <- earlyFixL + 1}
          if (loc==1 & rt>1000) {lateFixL <- lateFixL + 1}
          lastLoc <- loc
          if (abs(RDV)>=1) {break}
        }
      } else {
        RDV <- RDV + sum(drift)
        rt <- rt + middleDur
        if (loc==1 & rt<=1000) {earlyFixL <- earlyFixL + middleDur}
        if (loc==1 & (rt - middleDur > 1000)) {lateFixL <- lateFixL + middleDur}
        if (loc==1 & rt>1000 & (rt - middleDur <= 1000)) {
          earlyFixL <- earlyFixL + 1000 - (rt-middleDur)
          lateFixL <- lateFixL + rt - 1000
        }
        prevLoc <- loc
      }
      
      
      if (loc==1) {totFixL = totFixL + middleDur}
      if (loc==0) {totFixR = totFixR + middleDur}
    }
    
    if (rt > maximum_rt) { #20 second response?! no way
      choice = NA; rt = NA; lastLoc = NA; totFixL = NA; totFixR = NA; firstDuration = NA; firstFixLoc = NA
      break
    }
  }
  
  ##############################
  # SAVE
  
  if (RDV>1) {choice <- 1}
  if (RDV<(-1)) {choice <- 0}
  vDiff <- vL-vR
  results <- data.frame(
    choice=choice, 
    rt=rt, 
    vL=vL, 
    vR=vR, 
    vDiff=vDiff, 
    lastFixLoc=lastLoc,
    netFixLeft=totFixL-totFixR,
    firstFixDur=firstDuration,
    firstFixLoc=firstFixLoc,
    earlyFixL=earlyFixL,
    lateFixL=lateFixL
  )
  return(results)
  
}