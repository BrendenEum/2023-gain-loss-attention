################################################################################
# Things you can change
################################################################################

# Preamble

rm(list = ls())
library(dplyr)
library(truncnorm)

# Pick your favorite number

set.seed(4)

# Bounds on expected value

ev.lower = 1
ev.upper = 6

# Value differences in expected value

vDiff_list <- seq(-4,4,1)

# Bounds on amount

amt.lower <- 6
amt.upper <- 12

# Trial counts (85 total)

nTrials.center = 27
nTrials.left = 27
nTrials.right = 27
nSanity = 4


################################################################################
# In preparation for creating the spreadsheet
################################################################################

# Placeholder

spread_raw <- data.frame(
  TrialType = NA,
  TrialN = NA,
  Condition = NA,
  Sanity = NA,
  LProb = NA,
  LAmt = NA,
  RProb = NA,
  RAmt = NA,
  TextColor = NA,
  FixCrossLoc = NA
)

# Function for exactly d decimal places

formatround <- function(x, d) {
  return( format(round(x, d), nsmall=d) %>% as.numeric() )
}

# Function to test if choice is obvious

is_it_obvious <- function(LAmt, LProb, RAmt, RProb) {
  return(
    (abs(LAmt) > abs(RAmt) & LProb > RProb) |
      (abs(LAmt) < abs(RAmt) & LProb < RProb) |
      (LAmt == RAmt & LProb != RProb) |
      (LAmt != RAmt & LProb == RProb)
  )
}

# Function to draw a prob and amt such that vDiff is equal to some amt

probamt <- function(vDiff, condition) {
  LAmt = 1; LProb = 1; RAmt = 0; RProb = 0;
  resample <- is_it_obvious(LAmt, LProb, RAmt, RProb)
  while(resample) {
    if (vDiff < 0) {
      Lev <- runif(1, min=ev.lower, max=(ev.upper+vDiff)) %>% formatround(3)
    } else {
      Lev <- runif(1, min=(ev.lower+vDiff), max=ev.upper) %>% formatround(3)
    }
    Rev <- Lev - vDiff
    LAmt <- runif(1, min=amt.lower, max=amt.upper) %>%
      formatround(1)
    LProb <- (Lev/LAmt) %>% formatround(2)
    RAmt <- runif(1, min=amt.lower, max=amt.upper) %>%
      formatround(1)
    RProb <- (Rev/RAmt) %>% formatround(2)
    resample <- is_it_obvious(LAmt, LProb, RAmt, RProb)
  }
  if (condition == "loss") {
    LAmt = -LAmt
    RAmt = -RAmt
  }
  return(list(LAmt=LAmt, LProb=LProb, RAmt=RAmt, RProb=RProb))
}

# Function to add details of a trial

trial.details <- function(TrialType, TrialNumber, sanity, vDiff, cross_loc, condition, spread, row) {

  if (condition == "gain") {sanity.amt <- 10} else {sanity.amt <- -10}

  if (sanity == 0) {
    lotteries <- probamt(vDiff, condition)
    LAmt = lotteries$LAmt
    RAmt = lotteries$RAmt
    LProb = lotteries$LProb
    RProb = lotteries$RProb
  } else {
    AmtOne = sanity.amt %>% formatround(1)
    AmtTwo = 0
    ProbOne = .99 %>% formatround(2)
    ProbTwo = .99 %>% formatround(2)
    lRProb <- runif(1,0,1)
    if (lRProb>=.5) {
      LAmt = AmtOne; RAmt = AmtTwo; LProb = ProbOne; RProb = ProbTwo;
    } else {
      LAmt = AmtTwo; RAmt = AmtOne; LProb = ProbTwo; RProb = ProbOne;
    }
  }


  if (cross_loc == "center") {
    crossXY <- "[0,0]"
  } else if (cross_loc == "left") {
    crossXY <- "[-.5,0]"
  } else if (cross_loc == "right") {
    crossXY <- "[.5,0]"
  }

  if (condition == "gain") {
    TextColor = "green"
  } else if (condition == "loss") {
    TextColor = "red"
  }

  spread <- as.data.frame(spread)

  spread[row,"TrialType"] <- TrialType
  spread[row,"TrialN"] <- TrialNumber
  spread[row,"Condition"] <- condition
  spread[row,"Sanity"] <- sanity
  spread[row,"LProb"] <- LProb
  spread[row,"LAmt"] <- LAmt
  spread[row,"RProb"] <- RProb
  spread[row,"RAmt"] <- RAmt
  spread[row,"TextColor"] <- TextColor
  spread[row,"FixCrossLoc"] <- crossXY

  row <- row + 1

  return(list(
    "spread"=spread,
    "row"=row
  ))

}


################################################################################
# Make the spreadsheet
################################################################################

row <- 1

################### 12 PRACTICE TRIALS

TrialType <- "Practice"

spread <- spread_raw

for (practice in 1:2) {
  trial.list <- trial.details(
    TrialType = "Practice",
    TrialNumber = 0,
    sanity = 0,
    vDiff = sample(vDiff_list, 1),
    cross_loc = "center",
    condition = "gain",
    spread = spread,
    row = row
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

for (practice in 1:2) {
  trial.list <- trial.details(
    TrialType = "Practice",
    TrialNumber = 0,
    sanity = 0,
    vDiff = sample(vDiff_list, 1),
    cross_loc = "left",
    condition = "gain",
    spread = spread,
    row = row
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

for (practice in 1:2) {
  trial.list <- trial.details(
    TrialType = "Practice",
    TrialNumber = 0,
    sanity = 0,
    vDiff = sample(vDiff_list, 1),
    cross_loc = "right",
    condition = "gain",
    spread = spread,
    row = row
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

for (practice in 1:2) {

  trial.list <- trial.details(
    TrialType = "Practice",
    TrialNumber = 0,
    sanity = 0,
    vDiff = sample(vDiff_list, 1),
    cross_loc = "left",
    condition = "loss",
    spread = spread,
    row = row
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

for (practice in 1:2) {

  trial.list <- trial.details(
    TrialType = "Practice",
    TrialNumber = 0,
    sanity = 0,
    vDiff = sample(vDiff_list, 1),
    cross_loc = "right",
    condition = "loss",
    spread = spread,
    row = row
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

for (practice in 1:2) {

  trial.list <- trial.details(
    TrialType = "Practice",
    TrialNumber = 0,
    sanity = 0,
    vDiff = sample(vDiff_list, 1),
    cross_loc = "center",
    condition = "loss",
    spread = spread,
    row = row
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

write.csv(
  spread,
  file = "spreadsheet_practice.csv",
  na="",
  row.names = F
)


################### BLOCK: GAIN 1

TrialNumber <- 1

spread <- spread_raw
row <- 1

for (vDiff in vDiff_list) {
  for (trial in 1:(nTrials.center/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "center",
      condition = "gain",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
  for (trial in 1:(nTrials.left/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "left",
      condition = "gain",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
  for (trial in 1:(nTrials.right/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "right",
      condition = "gain",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
}

for (trial in 1:nSanity) {
  trial.list <- trial.details(
    TrialType = "Trial",
    TrialNumber = TrialNumber,
    sanity = 1,
    vDiff = NA,
    cross_loc = "center",
    condition = "gain",
    spread = spread,
    row = row
  )
  spread <- trial.list$spread
  row <- trial.list$row
  TrialNumber = TrialNumber + 1
}

write.csv(
  spread,
  file = "spreadsheet_gain1.csv",
  na="",
  row.names = F
)

################### BLOCK: GAIN 2

spread <- spread_raw
row <- 1

for (vDiff in vDiff_list) {
  for (trial in 1:(nTrials.center/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "center",
      condition = "gain",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
  for (trial in 1:(nTrials.left/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "left",
      condition = "gain",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
  for (trial in 1:(nTrials.right/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "right",
      condition = "gain",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
}

for (trial in 1:nSanity) {
  trial.list <- trial.details(
    TrialType = "Trial",
    TrialNumber = TrialNumber,
    sanity = 1,
    vDiff = NA,
    cross_loc = "center",
    condition = "gain",
    spread = spread,
    row = row
  )
  spread <- trial.list$spread
  row <- trial.list$row
  TrialNumber = TrialNumber + 1
}

write.csv(
  spread,
  file = "spreadsheet_gain2.csv",
  na="",
  row.names = F
)

################### Block: LOSS 1

TrialNumber = 1

spread <- spread_raw
row <- 1

for (vDiff in vDiff_list) {
  for (trial in 1:(nTrials.center/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "center",
      condition = "loss",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
  for (trial in 1:(nTrials.left/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "left",
      condition = "loss",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
  for (trial in 1:(nTrials.right/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "right",
      condition = "loss",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
}

for (trial in 1:nSanity) {
  trial.list <- trial.details(
    TrialType = "Trial",
    TrialNumber = TrialNumber,
    sanity = 1,
    vDiff = NA,
    cross_loc = "center",
    condition = "loss",
    spread = spread,
    row = row
  )
  spread <- trial.list$spread
  row <- trial.list$row
  TrialNumber = TrialNumber + 1
}

write.csv(
  spread,
  file = "spreadsheet_loss1.csv",
  na="",
  row.names = F
)

################### Block: LOSS 2

spread <- spread_raw
row <- 1

for (vDiff in vDiff_list) {
  for (trial in 1:(nTrials.center/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "center",
      condition = "loss",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
  for (trial in 1:(nTrials.left/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "left",
      condition = "loss",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
  for (trial in 1:(nTrials.right/length(vDiff_list))) {
    trial.list <- trial.details(
      TrialType = "Trial",
      TrialNumber = TrialNumber,
      sanity = 0,
      vDiff = vDiff,
      cross_loc = "right",
      condition = "loss",
      spread = spread,
      row = row
    )
    spread <- trial.list$spread
    row <- trial.list$row
    TrialNumber = TrialNumber + 1
  }
}

for (trial in 1:nSanity) {
  trial.list <- trial.details(
    TrialType = "Trial",
    TrialNumber = TrialNumber,
    sanity = 1,
    vDiff = NA,
    cross_loc = "center",
    condition = "loss",
    spread = spread,
    row = row
  )
  spread <- trial.list$spread
  row <- trial.list$row
  TrialNumber = TrialNumber + 1
}

write.csv(
  spread,
  file = "spreadsheet_loss2.csv",
  na="",
  row.names = F
)