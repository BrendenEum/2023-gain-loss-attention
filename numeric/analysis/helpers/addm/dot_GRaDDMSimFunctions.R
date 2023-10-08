simulate.trial <- function(
    b = .002,
    d = .003,
    t = .5,
    s = .02,
    vL = 2,
    vR = 2,
    vMin = -6,
    prFirstLeft = .8,
    firstFix = c(272),
    middleFix = c(456),
    latency = c(170),
    transition = c(25)
) {

  ###################################################################
  # create a variable to track when to stop (for efficiency purposes)
  stopper <- 0

  ##############################
  # initialize rdv at bias point
  RDV <- b
  rt  <- 0

  ###########################################################################
  # keep track of total time fix left and right, and first fixation duration
  totFixL <- 0
  totFixR <- 0
  firstDuration <- 0
  firstFixLoc <- 0

  ###########################################################################
  # keep track of early fixation left and late fixation left (which allow you to calculate net)
  earlyFixL <- 0
  lateFixL <- 0

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
    gL = vL-vMin
    gR = vR-vMin
    if (loc==1) {drift_mean <- d*(gL-t*gR)}
    if (loc==0) {drift_mean <- d*(t*gL-gR)}
    drift <- drift_mean + rnorm(n=firstDur, mean=0, sd=s)

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
      gL = vL-vMin
      gR = vR-vMin
      if (loc==1) {drift_mean <- d*(gL-t*gR)}
      if (loc==0) {drift_mean <- d*(t*gL-gR)}
      drift <- drift_mean + rnorm(n=middleDur, mean=0, sd=s)

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

    if (rt > 60000) { #60 second response?! no way
      choice = NA; rt = NA; lastLoc = NA; totFixL = NA; totFixR = NA; firstDuration = NA; firstFixLoc = NA
      break
    }

  }

  ##############################
  # return your results
  if (RDV>0) {choice <- 1}
  if (RDV<0) {choice <- 0}
  vDiff <- vL-vR
  results <- data.frame(
    choice=choice,
    rt=rt,
    vL=vL,
    vR=vR,
    vDiff=vDiff,
    lastFix=lastLoc,
    lr_fixDiff=totFixL-totFixR,
    firstDur=firstDuration,
    firstFixLoc=firstFixLoc,
    earlyFixL=earlyFixL,
    lateFixL=lateFixL
  )
  return(results)

}