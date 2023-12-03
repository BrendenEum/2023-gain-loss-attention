# This script takes the typical cfr data that I collect (choice, fixations, cleaned) and turns
# it into a dataframe where every observation is one millisecond.

cfr_to_addmdata <- function(data) {

  # Variables of interest.
  voi = c(
    "subject",
    "trial",
    "Condition",
    "choice",
    "rt",
    "vL",
    "vR",
    "Location",
    "fix_start",
    "fix_end"
  )
  data = data[,voi]

  # Convert fixation data to milliseconds if in seconds.
  # Floor to nearest 10.
  if (max(data$rt) < 100) {data$rt = floor(data$rt*100)*10}
  if (max(data$fix_start) < 100) {data$fix_start = data$fix_start*1000}
  if (max(data$fix_end) < 100) {data$fix_end = data$fix_end*1000}

  #######################
  ## Trial data
  #######################

  data.trial <- data %>%
    group_by(subject, trial) %>%
    summarize(
      Condition = first(Condition),
      choice = first(choice),
      rt = first(rt),
      vL = first(vL),
      vR = first(vR)
    )

  #######################
  ## Fixation data
  #######################

  data.fixation = data.frame()
  for (j in unique(data$subject)) {
    subdata = data[data$subject==j,]
    for (i in unique(subdata$trial)){
      subtrialdata = data[data$trial==i,]
      rt = first(subtrialdata$rt)
      t = seq(0, rt, 10)
      fixLoc = rep(4, length(t))
      for (k in nrow(subtrialdata)) {
        ind = (subtrialdata$fix_start[k] <= t & t < subtrialdata$fix_end[k])
        fixLoc[ind] = subtrialdata$Location[k]
      }
      add.data.fixation = data.frame(subject = j, trial = i, t = t, fixLoc = fixLoc)
      data.fixation = rbind(data.fixation, add.data.fixation)
    }
  }




  ## Return list
  returnme <- list(trial = data.trial, fixation = data.fixation)
  return(returnme)

}

test = cfr_to_addmdata(cfr2)