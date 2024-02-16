# Get the estimates.

read_estimates <- function(fitdir="error", study="error", model="error", dataset="error") {
  
  gainFileName = paste0(study, "_", model, "_GainEst_", dataset, ".csv")
  lossFileName = paste0(study, "_", model, "_LossEst_", dataset, ".csv")
  gainFit = read.csv(file.path(fitdir, gainFileName))
  lossFit = read.csv(file.path(fitdir, lossFileName))
  
  estimates = data.frame(
    d.gain = gainFit$d, #*1000
    d.loss = lossFit$d,
    s.gain = gainFit$s, #*10
    s.loss = lossFit$s,
    b.gain = gainFit$b,
    b.loss = lossFit$b,
    t.gain = gainFit$t,
    t.loss = lossFit$t,
    k.gain = NA,
    k.loss = NA,
    c.gain = NA,
    c.loss = NA
  )
  
  if (model %in% c("AddaDDM", "DNPaDDM", "RNPaDDM", "DRNPaDDM")) {
    estimates$k.gain = gainFit$k
    estimates$k.loss = lossFit$k
  }
  
  if (model %in% c("AddDDM")) {
    estimates$t.gain = NA
    estimates$t.loss = NA
    estimates$k.gain = gainFit$t #I coded the additive attentional bias as theta in the toolbox,
    estimates$k.loss = lossFit$t #but calling it k is more intuitive for the paper.
  }
  
  if (model %in% c("cbAddDDM")) {
    estimates$t.gain = NA
    estimates$t.loss = NA
    estimates$k.gain = gainFit$t
    estimates$k.loss = lossFit$t
    estimates$c.gain = gainFit$c
    estimates$c.loss = lossFit$c
  }
  
  estimates = estimates %>% mutate_if(is.numeric, round, digits=3)
  return(estimates)
}

# Get individual BIC for a study-model-dataset.

getIC = function(datadir="error", fitdir="error", study="error", model="error", dataset="error", parameterCount=4) {
  
  #get loglikelihood
  gainFileName = paste0(study, "_", model, "_GainNLL_", dataset, ".csv")
  lossFileName = paste0(study, "_", model, "_LossNLL_", dataset, ".csv")
  gainFit = read.csv(file.path(fitdir, gainFileName), header=F)
  lossFit = read.csv(file.path(fitdir, lossFileName), header=F)
  loglikelihoods = data.frame(
    gain = -1*gainFit[,1],
    loss = -1*lossFit[,1])
  BICs = matrix(NA, nrow=nrow(loglikelihoods), ncol=ncol(loglikelihoods)) #placeholder
  AICs = matrix(NA, nrow=nrow(loglikelihoods), ncol=ncol(loglikelihoods)) #placeholder
  log_m_hats = matrix(NA, nrow=nrow(loglikelihoods), ncol=ncol(loglikelihoods)) #placeholder
  
  #get observation count and calculate BIC
  load(file.path(datadir, paste0(dataset, "cfr.RData")))
  if (dataset=="e"){raw=ecfr}
  if (dataset=="c"){raw=ccfr}
  if (dataset=="j"){raw=jcfr}
  raw = raw[raw$study==study,]
  raw = raw[raw$trial%%2==1,] # in-sample only
  s=0
  for (subject in unique(raw$subject)[1:nrow(loglikelihoods)]) { # for (subject in unique(raw$subject)) { ! ! ! ! ! ! ! ! 
    s=s+1
    for (condition in unique(raw$condition)) {
      data = raw[raw$subject==subject & raw$condition==condition & raw$firstFix==T,]
      observationCount = nrow(data)
      if (condition=="Gain") {
        BICs[s,1] = (parameterCount*log(observationCount)) - (2*loglikelihoods[s,1]) #Wikipedia
        AICs[s,1] = parameterCount*2 - 2*loglikelihoods[s,1] #Wikipedia
        log_m_hats[s,1] = loglikelihoods[s,1] - ((parameterCount/2)*log(observationCount)) # Eq.25 in Wasserman (2000)
      }
      if (condition=="Loss") {
        BICs[s,2] = (parameterCount*log(observationCount)) - (2*loglikelihoods[s,2])
        AICs[s,2] = parameterCount*2 - 2*loglikelihoods[s,2]
        log_m_hats[s,2] = loglikelihoods[s,2] - ((parameterCount/2)*log(observationCount))
      }
    }
  }
  return(list(BIC=BICs, AIC=AICs, log_m_hats=log_m_hats))
}