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

ev.gain.lower.bound <- 1
ev.gain.upper.bound <- 6
ev.loss.lower.bound <- -6
ev.loss.upper.bound <- -1

# Bounds on amount

amt.gain.lower.bound <- 6
amt.gain.upper.bound <- 12
amt.loss.lower.bound <- -12
amt.loss.upper.bound <- -6

# Font size in px

font_size = 100

# Trial counts

nTrials.center = 64
nTrials.left = 64
nTrials.right = 64
nSanity = 8


################################################################################
# In preparation for creating the spreadsheet
################################################################################

# Placeholder

spread_raw <- data.frame(
  TrialType = NA,
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

# Function to draw a prob and amt such that EV is between A and B

probamt <- function(A,B) {
  ev <- runif(1, min=A, max=B) %>% formatround(3)
  if (A > 0) {
    amt <- runif(1, min=amt.gain.lower.bound, max=amt.gain.upper.bound) %>%
      formatround(1)
    prob <- (ev/amt) %>% formatround(2)
    ev <- amt*prob #recalculate to account for rounding
  } else if (A < 0) {
    amt <- runif(1, min=amt.loss.lower.bound, max=amt.loss.upper.bound) %>%
      formatround(1)
    prob <- (ev/amt) %>% formatround(2)
    ev <- amt*prob
  }
  return(c(amt, prob, ev))
}

# Function for as.numeric(.) and round(.,1)

as.percent <- function(x) {
  return( paste0(formatround(as.numeric(x)*100, 1), "%") )
}

# Function to add details of a trial

trial.details <- function(TrialType, sanity, cross_loc, condition, spread, row, n) {

  n <- n + 1

  if (condition == "gain") {
    ev.lower.bound <- ev.gain.lower.bound
    ev.upper.bound <- ev.gain.upper.bound
    sanity.amt <- 10
  } else {
    ev.lower.bound <- ev.loss.lower.bound
    ev.upper.bound <- ev.loss.upper.bound
    sanity.amt <- -10
  }

  if (sanity == 0) {
    Lstats <- c(1,1,1)
    Rstats <- c(0,0,0)
    it_is_obvious <- (abs(Lstats[1])>abs(Rstats[1]) & Lstats[2]>Rstats[2]) |
      (abs(Lstats[1])<abs(Rstats[1]) & Lstats[2]<Rstats[2]) |
      (Lstats[1]==Rstats[1] & Lstats[2]!=Rstats[2]) |
      (Lstats[1]!=Rstats[1] & Lstats[2]==Rstats[2])
    while (it_is_obvious) {
      Lstats <- probamt(ev.lower.bound, ev.upper.bound)
      Rstats <- probamt(ev.lower.bound, ev.upper.bound)
      it_is_obvious <- (abs(Lstats[1])>abs(Rstats[1]) & Lstats[2]>Rstats[2]) |
        (abs(Lstats[1])<abs(Rstats[1]) & Lstats[2]<Rstats[2]) |
        (Lstats[1]==Rstats[1] & Lstats[2]!=Rstats[2]) |
        (Lstats[1]!=Rstats[1] & Lstats[2]==Rstats[2])
    }
  } else {
    #amt,prob,ev
    statsUno <- c(sanity.amt %>% formatround(1), .99 %>% formatround(2), sanity.amt)
    statsDos <- c(0 %>% formatround(1), .99 %>% formatround(2), 0)
    lrprob <- runif(1,0,1)
    if (lrprob>=.5) {Lstats <- statsUno; Rstats <- statsDos}
    if (lrprob<.5) {Lstats <- statsDos; Rstats <- statsUno}
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
  spread[row,"Condition"] <- condition
  spread[row,"Sanity"] <- sanity
  spread[row,"LProb"] <- Lstats[2]
  spread[row,"LAmt"] <- Lstats[1]
  spread[row,"RProb"] <- Rstats[2]
  spread[row,"RAmt"] <- Rstats[1]
  spread[row,"TextColor"] <- TextColor
  spread[row,"FixCrossLoc"] <- crossXY

  row <- row + 1

  return(list(
    "spread"=spread,
    "row"=row,
    "n"=n
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
    sanity = 0,
    cross_loc = "center",
    condition = "gain",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

for (practice in 1:2) {
  trial.list <- trial.details(
    TrialType = "Practice",
    sanity = 0,
    cross_loc = "left",
    condition = "gain",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

for (practice in 1:2) {
  trial.list <- trial.details(
    TrialType = "Practice",
    sanity = 0,
    cross_loc = "right",
    condition = "gain",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

for (practice in 1:2) {

  trial.list <- trial.details(
    TrialType = "Practice",
    sanity = 0,
    cross_loc = "left",
    condition = "loss",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

for (practice in 1:2) {

  trial.list <- trial.details(
    TrialType = "Practice",
    sanity = 0,
    cross_loc = "right",
    condition = "loss",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row

}

for (practice in 1:2) {

  trial.list <- trial.details(
    TrialType = "Practice",
    sanity = 0,
    cross_loc = "center",
    condition = "loss",
    spread = spread,
    row = row,
    n = NA
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


################### BLOCK: GAIN

spread <- spread_raw
row <- 1

for (trial in 1:nTrials.center) {

  trial.list <- trial.details(
    TrialType = "Trial",
    sanity = 0,
    cross_loc = "center",
    condition = "gain",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row
  n <- trial.list$n

}

for (trial in 1:nTrials.left) {

  trial.list <- trial.details(
    TrialType = "Trial",
    sanity = 0,
    cross_loc = "left",
    condition = "gain",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row
  n <- trial.list$n

}

for (trial in 1:nTrials.right) {

  trial.list <- trial.details(
    TrialType = "Trial",
    sanity = 0,
    cross_loc = "right",
    condition = "gain",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row
  n <- trial.list$n

}

for (trial in 1:nSanity) {

  trial.list <- trial.details(
    TrialType = "Trial",
    sanity = 1,
    cross_loc = "center",
    condition = "gain",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row
  n <- trial.list$n

}

write.csv(
  spread,
  file = "spreadsheet_gain.csv",
  na="",
  row.names = F
)

################### Block: LOSS

spread <- spread_raw
row <- 1

for (trial in 1:nTrials.center) {

  trial.list <- trial.details(
    TrialType = "Trial",
    sanity = 0,
    cross_loc = "center",
    condition = "loss",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row
  n <- trial.list$n

}

for (trial in 1:nTrials.left) {

  trial.list <- trial.details(
    TrialType = "Trial",
    sanity = 0,
    cross_loc = "left",
    condition = "loss",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row
  n <- trial.list$n

}

for (trial in 1:nTrials.right) {

  trial.list <- trial.details(
    TrialType = "Trial",
    sanity = 0,
    cross_loc = "right",
    condition = "loss",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row
  n <- trial.list$n

}

for (trial in 1:nSanity) {

  trial.list <- trial.details(
    TrialType = "Trial",
    sanity = 1,
    cross_loc = "center",
    condition = "loss",
    spread = spread,
    row = row,
    n = NA
  )
  spread <- trial.list$spread
  row <- trial.list$row
  n <- trial.list$n

}

write.csv(
  spread,
  file = "spreadsheet_loss.csv",
  na="",
  row.names = F
)