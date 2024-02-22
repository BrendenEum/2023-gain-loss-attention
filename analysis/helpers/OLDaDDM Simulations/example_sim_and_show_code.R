## *Out-of-Samp. Prediction

In order to test the fits for our model, we run out-of-sample predictions. We compare group-level and subject-level predictions.

### - Simulation Functions

Write a function that will simulate a single trial of the aDDM.

```{r addmSimFunctions}

simulate.trial <- function(
    b = .002,
    d = .003,
    t = .5,
    s = .02,
    vL = 2,
    vR = 2,
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
    if (loc==1) {drift_mean <- d*(vL-t*vR)}
    if (loc==0) {drift_mean <- d*(t*vL-vR)}
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
      if (loc==1) {drift_mean <- d*(vL-t*vR)}
      if (loc==0) {drift_mean <- d*(t*vL-vR)}
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
  vDiff <- vL*5-vR*5
  results <- data.frame(
    choice=choice, 
    rt=rt, 
    vL=vL*5, 
    vR=vR*5, 
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

```

### - Run out-of-samp. sims.

Requires vtrace_j and htrace_j, which are generated in aDDM Model Fitting section above.

This will run simulations for every subject, for every trial. It will do this "simCount" times. You can use this simulated data to calculate the group-level and subject-level model predictions.

```{r runSims}

# Only working with the joint data / estimates here. Pull the out-of-sample (even) trials.
source(file.path(codedir,"set_j_dir.R"))
source(file.path(codedir,"load_data.R"))
cfr_even <- cfr[(cfr$trial%%2==0),]
cf_even <- cf[(cf$trial%%2==0),]



################################################################################################################################################
# Things you can adjust
set.seed(seed)
simCount <- 10
subjects <- unique(cfr$parcode)
simulation_subjects <- subjects # select the subjects you want to run simulations for
figsubs <- c( sort(sample(subjects[subjects<300], 2)) , sort(sample(subjects[subjects>=300], 2))  ) # example subjects in supplementary
################################################################################################################################################



## Get subject-level aDDM parameters and fixation patterns #####################################################################################

# Placeholders
vL <- list(); vR <- list(); d_v <- list(); d_h <- list(); s_v <- list(); s_h <- list(); t_v <- list(); t_h <- list(); b_v <- list(); b_h <- list(); e_v <- list(); e_h <- list(); prFirstLeftV <- list(); prFirstLeftH <- list(); latencyV <- list(); latencyH <- list(); firstFixV <- list(); firstFixH <- list(); transitionV <- list(); transitionH <- list(); middleFixV <- list(); middleFixH <- list()

# Loop through subjects to get everyone's aDDM parameters and fixations
for (subj in simulation_subjects) {
  
  # Transform subject number
  sub <- match(subj, simulation_subjects)
  
  # Limit relevant datasets
  choices_data <- choices_even[(choices_even$parcode==subj),]
  cf_data <- cf_even[(cf_even$parcode==subj),]
  data <- cfr_even[(cfr_even$parcode==subj),]
  
  #####
  # Get vector of values. Normalize to [0,1] space.
  vL[[sub]] <- choices_data$avgWTP_left/5
  vR[[sub]] <- choices_data$avgWTP_right/5
  
  #####
  # Sample estimates for this subject. Already in ms units.
  #drift
  d_ind <- paste('b.p.', toString(sub), '.', sep='')
  d_v[[sub]] <- sample(vtrace_j[[d_ind]], simCount) / 1000
  d_h[[sub]] <- sample(htrace_j[[d_ind]], simCount) / 1000
  #sigma
  sig_ind <- paste('alpha.p.', toString(sub), '.', sep='')
  s_v[[sub]] <- sample(vtrace_j[[sig_ind]], simCount) / sqrt(1000)
  s_h[[sub]] <- sample(htrace_j[[sig_ind]], simCount) / sqrt(1000)
  #theta
  t_ind <- paste('thetaGaze.', toString(sub), '.', sep='')
  t_v[[sub]] <- sample(vtrace_j[[t_ind]], simCount)
  t_h[[sub]] <- sample(htrace_j[[t_ind]], simCount)
  #bias
  bias_ind <- paste('bias.', toString(sub), '.', sep='')
  b_v[[sub]] <- (sample(vtrace_j[[bias_ind]], simCount) - 0.5)*2
  b_h[[sub]] <- (sample(htrace_j[[bias_ind]], simCount) - 0.5)*2
  
  #####
  # Get fixations in vector form. We will sample from these vectors later.
  prFirstLeftV[[sub]] <- mean( data$location[data$firstFix==T & data$hidden==0] )
  prFirstLeftH[[sub]] <- mean( data$location[data$firstFix==T & data$hidden==1] )
  
  latencydata <- cf_data %>% group_by(trial) %>% filter(row_number()==1) %>% ungroup()
  latencyV[[sub]] <- latencydata$latency[latencydata$hidden==0]
  latencyH[[sub]] <- latencydata$latency[latencydata$hidden==1]
  
  firstFixV[[sub]] <- data[(data$hidden==0 & data$firstFix==1),]$fix_dur
  firstFixH[[sub]] <- data[(data$hidden==1 & data$firstFix==1),]$fix_dur
  
  transdata <- cf_data %>% group_by(trial) %>% filter(row_number()!=1 & location==4) %>% ungroup()
  transitionV[[sub]] <- transdata$duration[transdata$hidden==0]
  transitionH[[sub]] <- transdata$duration[transdata$hidden==1]
  
  middleFixV[[sub]] <- data[(data$hidden==0 & data$middleFix==1),]$fix_dur
  middleFixH[[sub]] <- data[(data$hidden==1 & data$middleFix==1),]$fix_dur
  
}

############ check if runoutsamp is true 
if (runoutsamp ==T) {
  
  ## VISIBLE CONDITION SIMULATIONS #####################################################################################################
  
  print('simulations: visible')
  
  # Placeholders
  simVData <- data.frame(
    subj=NA, 
    trial=NA, 
    choice=NA, 
    rt=NA, 
    vL=NA, 
    vR=NA, 
    vDiff=NA, 
    hidden=NA, 
    lastFix=NA, 
    lr_fixDiff=NA, 
    firstDur=NA, 
    firstFixLoc=NA,
    simulation=NA
  )
  
  # Loop through subjects to get everyone's choices and RT
  for (subj in simulation_subjects) {
    
    # Progress tracker
    print(subj)
    
    # Transform subject number
    sub <- match(subj, simulation_subjects)
    
    # Simulate dataset
    for (j in 1:simCount) {
      
      for (i in 1:length(vL[[sub]])) {
        
        simTrial <- simulate.trial(
          b = b_v[[sub]][j],
          d = d_v[[sub]][j],
          t = t_v[[sub]][j],
          s = s_v[[sub]][j],
          vL = vL[[sub]][i],
          vR = vR[[sub]][i],
          prFirstLeft = prFirstLeftV[[sub]],
          latency = latencyV[[sub]],
          transition = transitionV[[sub]],
          firstFix = firstFixV[[sub]],
          middleFix = middleFixV[[sub]]
        )
        
        simTrial$subj <- subj
        simTrial$trial <- i
        simTrial$hidden <- 0
        simTrial$simulation <- j
        simVData <- rbind(simVData, simTrial)
        
      }
    }
  }
  
  simVData <- na.omit(simVData)
  save(simVData, file = file.path(tempdir, "simVData.RData"))
  
  ## HIDDEN CONDITION SIMULATIONS #####################################################################################################
  
  print('simulations: hidden')
  
  # Placeholders
  simHData <- data.frame(
    subj=NA, 
    trial=NA, 
    choice=NA, 
    rt=NA, 
    vL=NA, 
    vR=NA, 
    vDiff=NA, 
    hidden=NA, 
    lastFix=NA, 
    lr_fixDiff=NA, 
    firstDur=NA, 
    firstFixLoc=NA,
    simulation=NA
  )
  
  # Loop through subjects to get everyone's choices and RT
  for (subj in simulation_subjects) {
    
    # Progress tracker
    print(subj)
    
    # Transform subject number
    sub <- match(subj, simulation_subjects)
    
    # Simulate dataset
    for (j in 1:simCount) {
      
      for (i in 1:length(vL[[sub]])) {
        
        simTrial <- simulate.trial(
          b = b_h[[sub]][j],
          d = d_h[[sub]][j],
          t = t_h[[sub]][j],
          s = s_h[[sub]][j],
          vL = vL[[sub]][i],
          vR = vR[[sub]][i],
          prFirstLeft = prFirstLeftH[[sub]],
          latency = latencyH[[sub]],
          transition = transitionH[[sub]],
          firstFix = firstFixH[[sub]],
          middleFix = middleFixH[[sub]]
        )
        
        simTrial$subj <- subj
        simTrial$trial <- i
        simTrial$hidden <- 1
        simTrial$simulation <- j
        simHData <- rbind(simHData, simTrial)
        
      }
    }
  }
  
  simHData <- na.omit(simHData)
  save(simHData, file = file.path(tempdir, "simHData.RData"))
  
} else if (runoutsamp ==F) {
  
  load(file = file.path(tempdir, "simVData.RData"))
  load(file = file.path(tempdir, "simHData.RData"))
  
}

```

### - Fig S5 Group

Check the out-of-sample predictions at the group-level.

```{r addmGroupSims}

###############################################################################################################
## Construct psychometric and RT pdata

#grab visible sims
pdataV <- simVData

# drop all trials that ended before the first item was looked at
pdataV <- pdataV[(pdataV$lastFix==0 | pdataV$lastFix==1),]

# bin the x variable
breaks <- c(-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5)
tags   <- c(-4,-3,-2,-1,0,1,2,3,4)
pdataV$bin <- as.numeric(as.character(cut(pdataV$vDiff, breaks, labels=tags)))

#get y values
pdataV <- pdataV %>%
  group_by(subj, bin, hidden) %>%
  summarize(
    pre_y = mean(choice), 
    pre_rt = mean(rt),
    pre_y_sd = sd(choice), 
    pre_rt_sd = sd(rt)
  ) %>%
  ungroup()

indiv.V.psycho.rt <- pdataV
indiv.V.psycho.rt$sim <- 1

#make x
pdataV$x <- as.numeric(pdataV$bin)

#get mean of means
pdataV <- pdataV %>%
  group_by(x, hidden) %>%
  summarize(
    y = mean(pre_y), 
    se = std.error(pre_y), 
    sd = sd(pre_y), 
    q5 = quantile(pre_y,.025), 
    q95 = quantile(pre_y,.975),
    rt = mean(pre_rt), 
    se_rt = std.error(pre_rt), 
    sd_rt = sd(pre_rt), 
    q5_rt = quantile(pre_rt,.025), 
    q95_rt = quantile(pre_rt,.975)
  )

#this is a simulation
pdataV$sim <- 1

#make factors
pdataV$hidden <- factor(pdataV$hidden)

#grab hidden sims
pdataH <- simHData

# drop all trials that ended before the first item was looked at
pdataH <- pdataH[(pdataH$lastFix==0 | pdataH$lastFix==1),]

# bin the x variable
breaks <- c(-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5)
tags   <- c(-4,-3,-2,-1,0,1,2,3,4)
pdataH$bin <- as.numeric(as.character(cut(pdataH$vDiff, breaks, labels=tags)))

#get y values
pdataH <- pdataH %>%
  group_by(subj, bin, hidden) %>%
  summarize(
    pre_y = mean(choice), 
    pre_rt = mean(rt),
    pre_y_sd = sd(choice), 
    pre_rt_sd = sd(rt)
  ) %>%
  ungroup()

indiv.H.psycho.rt <- pdataH
indiv.H.psycho.rt$sim <- 1

#make x
pdataH$x <- as.numeric(pdataH$bin)

#get mean of means
pdataH <- pdataH %>%
  group_by(x, hidden) %>%
  summarize(
    y = mean(pre_y), 
    se = std.error(pre_y), 
    sd = sd(pre_y), 
    q5 = quantile(pre_y,.025), 
    q95 = quantile(pre_y,.975),
    rt = mean(pre_rt), 
    se_rt = std.error(pre_rt), 
    sd_rt = sd(pre_rt), 
    q5_rt = quantile(pre_rt,.025), 
    q95_rt = quantile(pre_rt,.975)
  )

#this is a simulation
pdataH$sim <- 1

#make factors
pdataH$hidden <- factor(pdataH$hidden)

#load in real data
pdata.emp <- choices_even

# bin the x variable
breaks <- c(-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5)
tags   <- c(-4,-3,-2,-1,0,1,2,3,4)
pdata.emp$bin <- as.numeric(as.character(cut(pdata.emp$lr_diff, breaks, labels=tags)))

#get y values
pdata.emp <- pdata.emp %>%
  group_by(parcode, bin, hidden) %>%
  summarize(
    pre_y = mean(choice), 
    pre_rt = mean(rt),
    pre_y_sd = sd(choice), 
    pre_rt_sd = sd(rt)
  ) %>%
  ungroup()

indiv.emp.psycho.rt <- pdata.emp
indiv.emp.psycho.rt$sim <- 0

#make x
pdata.emp$x <- as.numeric(pdata.emp$bin)

#get mean of means
pdata.emp <- pdata.emp %>%
  group_by(x, hidden) %>%
  summarize(
    y = mean(pre_y), 
    se = std.error(pre_y), 
    sd = sd(pre_y), 
    q5 = quantile(pre_y,.025), 
    q95 = quantile(pre_y,.975),
    rt = mean(pre_rt), 
    se_rt = std.error(pre_rt), 
    sd_rt = sd(pre_rt), 
    q5_rt = quantile(pre_rt,.025), 
    q95_rt = quantile(pre_rt,.975)
  )

#this is NOT a simulation
pdata.emp$sim <- 0

#make factors
pdata.emp$hidden <- factor(pdata.emp$hidden)

# combine everything into one dataset
pdata <- rbind(pdataV, pdataH)
pd    <- rbind(pdata, pdata.emp)

##################################################################################################################
## Plots

# Colors
pd$colors <- 0 #'#00BFC4'
pd$colors[pd$hidden==1] <- 1  #'#F8766D'
pd$colors[pd$sim==1] <- 2  #'black'
pd$colors <- factor(pd$colors)

# linesize, textsize, legend text size, legend location
ls = 1.5
ts = 15
lts = 5

# Plot choices and RTs

## choices hidden

p.choicesH <- 
  
  ggplot(data=pd) +
  geom_hline(yintercept=.5, alpha=.25) +
  geom_vline(xintercept=0, alpha=.25) +
  
  geom_line(
    data=pd[pd$hidden==1 & pd$sim==0,],
    aes(x=x, y=y), 
    color='#F8766D', 
    linetype='solid', 
    size=ls
  ) +
  geom_errorbar(
    data=pd[pd$hidden==1 & pd$sim==0,],
    aes(x=x, ymin=y-sd, ymax=y+sd),
    color='#F8766D', 
    size=ls,  
    width=.2
  ) +
  
  geom_line(
    data=pd[pd$hidden==1 & pd$sim==1,],
    aes(x=x, y=y), 
    color='black', 
    linetype='dashed', 
    size=ls
  ) +
  geom_ribbon(
    data=pd[pd$hidden==1 & pd$sim==1,],
    aes(x=x, ymin=y-sd, ymax=y+sd),
    color=NA, 
    fill="grey30", 
    alpha=.25
  ) +
  
  scale_x_continuous(breaks=seq(-4,4,1)) +
  coord_cartesian(ylim=c(0, 1)) +
  theme_classic() +
  theme(
    panel.border = element_rect(colour = "black", fill=NA, size=1), 
    plot.title=element_text(hjust=0.5, size=ts+2, face='bold'),
    axis.text=element_text(size=ts-2), 
    axis.title=element_text(size=ts),
    legend.position='none'
  ) +
  labs(
    title = "Subject Pool",
    x = "Value Difference (L–R)",
    y = "P(Choose Left)"
  )

## choices visible

p.choicesV <- 
  
  ggplot(data=pd) +
  geom_hline(yintercept=.5, alpha=.25) +
  geom_vline(xintercept=0, alpha=.25) +
  
  geom_line(
    data=pd[pd$hidden==0 & pd$sim==0,],
    aes(x=x, y=y), 
    color='#00BFC4', 
    linetype='solid', 
    size=ls
  ) +
  geom_errorbar(
    data=pd[pd$hidden==0 & pd$sim==0,],
    aes(x=x, ymin=y-sd, ymax=y+sd),
    color='#00BFC4', 
    size=ls,
    width=.2
  ) +
  
  geom_line(
    data=pd[pd$hidden==0 & pd$sim==1,],
    aes(x=x, y=y), 
    color="black", 
    linetype='dashed', 
    size=ls
  ) +
  geom_ribbon(
    data=pd[pd$hidden==0 & pd$sim==1,],
    aes(x=x, ymin=y-sd, ymax=y+sd),
    color=NA, 
    fill="grey30", 
    alpha=.25
  ) +
  
  scale_x_continuous(breaks=seq(-4,4,1)) +
  coord_cartesian(ylim=c(0, 1)) +
  theme_classic() +
  theme(
    panel.border = element_rect(colour = "black", fill=NA, size=1), 
    plot.title=element_text(hjust=0.5, size=ts+2, face='bold'),
    axis.text=element_text(size=ts-2), 
    axis.title=element_text(size=ts),
    legend.position='none'
  ) +
  labs(
    title = '',
    x = "Value Difference (L–R)",
    y = "P(Choose Left)"
  )

## RT hidden

p.rtH <- 
  
  ggplot(data=pd) +
  geom_vline(xintercept=0, alpha=.25) +
  
  geom_line(
    data=pd[pd$hidden==1 & pd$sim==0,],
    aes(x=x, y=rt), 
    color='#F8766D', 
    linetype='solid', 
    size=ls
  ) +
  geom_errorbar(
    data=pd[pd$hidden==1 & pd$sim==0,],
    aes(x=x, ymin=rt-sd_rt, ymax=rt+sd_rt),
    color="#F8766D", 
    size=ls,  
    width=.2
  ) +
  
  geom_line(
    data=pd[pd$hidden==1 & pd$sim==1,],
    aes(x=x, y=rt), 
    color="black", 
    linetype='dashed', 
    size=ls
  ) +
  geom_ribbon(
    data=pd[pd$hidden==1 & pd$sim==1,],
    aes(x=x, ymin=rt-sd_rt, ymax=rt+sd_rt),
    color=NA, 
    fill="grey30", 
    alpha=.25
  ) +
  
  scale_x_continuous(breaks=seq(-4,4,1)) +
  coord_cartesian(ylim=c(0, round_any(max(pd$q95_rt,na.rm=T),1000,f=ceiling))) +
  theme_classic() +
  theme(
    panel.border = element_rect(colour = "black", fill=NA, size=1),
    plot.title=element_text(hjust=0.5, size=ts+2, face='bold'),
    axis.text=element_text(size=ts-2), 
    axis.title=element_text(size=ts),
    legend.position='none'
  ) +
  labs(
    title = '',
    x = "Value Difference (L–R)",
    y = "Response Time (ms)"
  )

## RT visible

p.rtV <- 
  ggplot(data=pd) +
  geom_vline(xintercept=0, alpha=.25) +
  geom_line(
    data=pd[pd$hidden==1 & pd$sim==0,],
    aes(x=x, y=rt, color=colors), 
    linetype='solid', 
    alpha=0
  ) +
  
  geom_line(
    data=pd[pd$hidden==0 & pd$sim==0,],
    aes(x=x, y=rt, color=colors), 
    linetype='solid', 
    size=ls
  ) +
  geom_errorbar(
    data=pd[pd$hidden==0 & pd$sim==0,],
    aes(x=x, ymin=rt-sd_rt,  ymax=rt+sd_rt),
    color='#00BFC4', 
    size=ls, 
    width=.2
  ) +
  
  geom_line(
    data=pd[pd$hidden==0 & pd$sim==1,],
    aes(x=x, y=rt, color=colors), 
    linetype='dashed', 
    size=ls
  ) +
  geom_ribbon(
    data=pd[pd$hidden==0 & pd$sim==1,],
    aes(x=x, ymin=rt-sd_rt, ymax=rt+sd_rt),
    color=NA, 
    fill="grey30", 
    alpha=.25
  ) +
  
  scale_color_manual(labels=c('Visible','Hidden','Simulated'), values=c('#00BFC4','#F8766D','black')) + 
  scale_x_continuous(breaks=seq(-4,4,1)) +
  coord_cartesian(ylim=c(0, round_any(max(pd$q95_rt,na.rm=T),1000,f=ceiling))) +
  theme_classic() +
  theme(
    panel.border = element_rect(colour = "black", fill=NA, size=1),
    plot.title=element_text(hjust=0.5, size=ts+2, face='bold'),
    axis.text=element_text(size=ts-2), 
    axis.title=element_text(size=ts)
  ) +
  theme(
    legend.position=c(0,1), 
    legend.justification=c(0,1), 
    legend.title=element_blank(),
    legend.background=element_rect(fill="transparent")
  ) +
  labs(
    title = '',
    x = "Value Difference (L–R)",
    y = "Response Time (ms)"
  )

###############################################################################################################
## Construct last fix pdata

#grab visible sims
pdataV <- simVData

#get last seen item - other item rating
pdataV$fixDiff <- pdataV$vL - pdataV$vR
pdataV$fixDiff[pdataV$lastFix==0] <- pdataV$vR[pdataV$lastFix==0] - pdataV$vL[pdataV$lastFix==0]

#last fix chosen
pdataV$lastFixChosen <- (pdataV$choice==pdataV$lastFix)

# drop all trials that ended before the first item was looked at
pdataV <- pdataV[(pdataV$lastFix==0 | pdataV$lastFix==1),]

# bin the x variable
breaks <- c(-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5)
tags   <- c(-4,-3,-2,-1,0,1,2,3,4)
pdataV$bin <- as.numeric(as.character(cut(pdataV$fixDiff, breaks, labels=tags)))

#get y values
pdataV <- pdataV %>%
  group_by(subj, bin, hidden) %>%
  summarize(
    pre_y = mean(lastFixChosen), 
    pre_y_sd = sd(lastFixChosen)
  ) %>%
  ungroup()

indiv.V.lastFix <- pdataV
indiv.V.lastFix$sim <- 1

#make x
pdataV$x <- as.numeric(pdataV$bin)

#get mean of means
pdataV <- pdataV %>%
  group_by(x, hidden) %>%
  summarize(
    y = mean(pre_y), 
    se = std.error(pre_y), 
    sd = sd(pre_y), 
    q5 = quantile(pre_y,.025), 
    q95 = quantile(pre_y,.975)
  )

#this is a simulation
pdataV$sim <- 1

#make factors
pdataV$hidden <- factor(pdataV$hidden)

#grab hidden sims
pdataH <- simHData

#get last seen item - other item rating
pdataH$fixDiff <- pdataH$vL - pdataH$vR
pdataH$fixDiff[pdataH$lastFix==0] <- pdataH$vR[pdataH$lastFix==0] - pdataH$vL[pdataH$lastFix==0]

#last fix chosen
pdataH$lastFixChosen <- (pdataH$choice==pdataH$lastFix)

# drop all trials that ended before the first item was looked at
pdataH <- pdataH[(pdataH$lastFix==0 | pdataH$lastFix==1),]

# bin the x variable
breaks <- c(-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5)
tags   <- c(-4,-3,-2,-1,0,1,2,3,4)
pdataH$bin <- as.numeric(as.character(cut(pdataH$fixDiff, breaks, labels=tags)))

#get y values
pdataH <- pdataH %>%
  group_by(subj, bin, hidden) %>%
  summarize(
    pre_y = mean(lastFixChosen),
    pre_y_sd = sd(lastFixChosen)
  ) %>%
  ungroup()

indiv.H.lastFix <- pdataH
indiv.H.lastFix$sim <- 1

#make x
pdataH$x <- as.numeric(pdataH$bin)

#get mean of means
pdataH <- pdataH %>%
  group_by(x, hidden) %>%
  summarize(
    y = mean(pre_y), 
    se = std.error(pre_y), 
    sd = sd(pre_y), 
    q5 = quantile(pre_y,.025), 
    q95 = quantile(pre_y,.975)
  )

#this is a simulation
pdataH$sim <- 1

#make factors
pdataH$hidden <- factor(pdataH$hidden)

#grab real data
pdata.emp <- cfr_even[cfr_even$lastFix==T,]

# bin the x variable
breaks <- c(-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5)
tags   <- c(-4,-3,-2,-1,0,1,2,3,4)
pdata.emp$bin <- as.numeric(as.character(cut(pdata.emp$fix_diff, breaks, labels=tags)))

#get y values
pdata.emp <- pdata.emp %>%
  group_by(parcode, bin, hidden) %>%
  summarize(
    pre_y = mean(lastFixChosen), 
    pre_y_sd = sd(lastFixChosen)
  ) %>%
  ungroup()

indiv.emp.lastFix <- pdata.emp
indiv.emp.lastFix$sim <- 0

#make x
pdata.emp$x <- as.numeric(pdata.emp$bin)

#get mean of means
pdata.emp <- pdata.emp %>%
  group_by(x, hidden) %>%
  summarize(
    y = mean(pre_y), 
    se = std.error(pre_y), 
    sd = sd(pre_y), 
    q5 = quantile(pre_y,.025), 
    q95 = quantile(pre_y,.975)
  )

#this is a simulation
pdata.emp$sim <- 0

#make factors
pdata.emp$hidden <- factor(pdata.emp$hidden)

# combine everything into one dataset
pdata <- rbind(pdataV, pdataH)
pd2   <- rbind(pdata, pdata.emp)

###############################################################################################################
## Plot last fix pdata

## last fixation hidden

p.lastFixH <-
  
  ggplot(data=pd2) +
  geom_hline(yintercept=.5, alpha=.25) +
  geom_vline(xintercept=0, alpha=.25) +
  
  geom_line(
    data=pd2[pd2$hidden==1 & pd2$sim==0,],
    aes(x=x, y=y), 
    color='#F8766D', 
    linetype='solid', 
    size=ls
  ) +
  geom_errorbar(
    data=pd2[pd2$hidden==1 & pd2$sim==0,],
    aes(x=x, ymin=y-sd, ymax=y+sd),
    color='#F8766D', 
    size=ls, 
    width=.2
  ) +
  
  geom_line(
    data = pd2[pd2$hidden == 1 & pd2$sim == 1, ],
    aes(x = x, y = y),
    color = 'black',
    linetype = 'dashed',
    size = ls
  ) +
  geom_ribbon(
    data = pd2[pd2$hidden == 1 & pd2$sim == 1, ],
    aes(x = x, ymin = y - sd, ymax = y + sd),
    color = NA,
    fill = "grey30",
    alpha = .25
  ) +
  
  scale_x_continuous(breaks=seq(-4,4,1)) +
  coord_cartesian(ylim=c(0, 1)) +
  theme_classic() +
  theme(
    panel.border = element_rect(colour = "black", fill=NA, size=1), 
    plot.title=element_text(hjust=0.5, size=ts+2, face='bold'),
    axis.text=element_text(size=ts-2), 
    axis.title=element_text(size=ts),
    legend.position='none'
  ) +
  labs(
    title = "",
    x = "Last Seen – Other Item Rating",
    y = "P(Last Fixation to Chosen)"
  )

## last fixation visible

p.lastFixV <- 
  
  ggplot(data=pd2) +
  geom_hline(yintercept=.5, alpha=.25) +
  geom_vline(xintercept=0, alpha=.25) +
  
  geom_line(
    data = pd2[pd2$hidden == 0 & pd2$sim == 0, ],
    aes(x = x, y = y),
    color = '#00BFC4',
    linetype = 'solid',
    size = ls
  ) +
  geom_errorbar(
    data = pd2[pd2$hidden == 0 & pd2$sim == 0, ],
    aes(x = x, ymin = y - sd, ymax = y + sd),
    color = '#00BFC4',
    size = ls,
    width = .2
  ) +
  
  geom_line(
    data = pd2[pd2$hidden == 0 & pd2$sim == 1, ],
    aes(x = x, y = y),
    color = 'black',
    linetype = 'dashed',
    size = ls
  ) +
  geom_ribbon(
    data = pd2[pd2$hidden == 0 & pd2$sim == 1, ],
    aes(x = x, ymin = y - sd, ymax = y + sd),
    color = NA,
    fill = "grey30",
    alpha = .25
  ) +
  
  scale_x_continuous(breaks=seq(-4,4,1)) +
  coord_cartesian(ylim=c(0, 1)) +
  theme_classic() +
  theme(
    panel.border = element_rect(colour = "black", fill=NA, size=1), 
    plot.title=element_text(hjust=0.5, size=ts+2, face='bold'),
    axis.text=element_text(size=ts-2), 
    axis.title=element_text(size=ts),
    legend.position='none'
  ) +
  labs(
    title = "",
    x = "Last Seen – Other Item Rating",
    y = "P(Last Fixation to Chosen)"
  )

###############################################################################################################
## Combine everything and save

final <- grid.arrange(
  arrangeGrob(
    p.choicesH,
    p.rtH,
    p.lastFixH,
    p.choicesV,
    p.rtV,
    p.lastFixV,
    nrow = 2,
    vp = viewport(width = 0.9, height = 0.9)
  )
)

source(file.path(codedir,"set_j_dir.R"))
#pdf(file=file.path(figdir,"Fig_PoolSims.pdf"), width=10, height=7.5)
pAll <- grid.arrange(arrangeGrob(final, nrow=1))
dev.off()
ggsave(file=file.path(figdir,"Fig_PoolSims.pdf"), pAll, width=10, height=7.5, device=cairo_pdf)
#ggsave(file=file.path(figdir,"Fig_PoolSims.png"), pAll, width=10, height=7.5)

```

### - Fig S6

Check the subject-level out-of-sample predictions. Use 4 randomly selected subjects for an example figure.

```{r subjLevelSims}

# make the data using the generated datasets from the last cell
indiv.psycho.rt <- rbind(indiv.H.psycho.rt, indiv.V.psycho.rt)
indiv.emp.psycho.rt <- rename(indiv.emp.psycho.rt, subj=parcode)
indiv.psycho.rt <- rbind(indiv.psycho.rt, indiv.emp.psycho.rt)

indiv.lastFix <- rbind(indiv.H.lastFix, indiv.V.lastFix)
indiv.emp.lastFix <- rename(indiv.emp.lastFix, subj=parcode)
indiv.lastFix <- rbind(indiv.lastFix, indiv.emp.lastFix)

# NA only appears when SD=0, so replace NA with 0.
indiv.psycho.rt[is.na(indiv.psycho.rt)] <- 0
indiv.lastFix[is.na(indiv.lastFix)] <- 0

indiv.figures <- list()

ind <- 1
for (indiv in figsubs) {
  
  pd  <- indiv.psycho.rt[indiv.psycho.rt$subj==indiv,]
  pd2 <- indiv.lastFix[indiv.lastFix$subj==indiv,]
  if (indiv==figsubs[1]) {addLegend<-1} else {addLegend<-0}
  indiv.title <- as.character(indiv)
  source(file.path(codedir, 'subject_level_simulations.R'))
  ind = ind+1
  
}

# Return a ggarrange object for the individual simulations
final <- grid.arrange(
  arrangeGrob(
    indiv.figures[[1]],
    indiv.figures[[2]],
    indiv.figures[[3]],
    indiv.figures[[4]],
    nrow = 2
  )
)

# save
pAll <- grid.arrange(arrangeGrob(final, nrow=1))
dev.off()
ggsave(file=file.path(figdir,"Fig_IndivSims.pdf"), pAll, width=20, height=15)
#ggsave(file=file.path(figdir,"Fig_IndivSims.png"), pAll, width=20, height=15)

```