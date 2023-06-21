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

nTrials.center = 32
nTrials.left = 32
nTrials.right = 32
nSanity = 4


################################################################################
# In preparation for creating the spreadsheet
################################################################################

# Placeholder

spread <- data.frame(
  randomise_blocks = NA,
  randomise_trials = NA,
  trial_number = NA,
  condition = NA,
  sanity = NA,
  cross_loc = NA,
  Ccross = NA,
  Lcross = NA,
  Rcross = NA,
  display = NA,
  Lprob = NA,
  Lamt = NA,
  Rprob = NA,
  Ramt = NA,
  Lprob_disp = NA,
  Lamt_disp = NA,
  Rprob_disp = NA,
  Ramt_disp = NA,
  Lev = NA,
  Rev = NA,
  WrongEV = NA,
  correctAnswer = NA
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

# Function to write javascript object for prob and amt

jstext <- function(font, info, condition) {
  if (condition == "gain") {
    out <- paste0(
      '<h3 style="font-size: ',
      toString(font),
      'px; color: green;">',
      toString(info),
      '<h3/>'
    )
  } else {
    out <- paste0(
      '<h3 style="font-size: ',
      toString(font),
      'px; color: red;">',
      toString(info),
      '<h3/>'
    )
  }
  return(out)
}

# Function for as.numeric(.) and round(.,1)

as.percent <- function(x) {
  return( paste0(formatround(as.numeric(x)*100, 1), "%") )
}

# Function to add details of a trial

trial.details <- function(display, sanity, cross_loc, condition, spread, row, n) {

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
    cross.center <- '<h3 style="font-size: 100px; color: white">+<h3/>'
    cross.left <- ''
    cross.right <- ''
  } else if (cross_loc == "left") {
    cross.center <- ''
    cross.left <- '<h3 style="font-size: 100px; color: white">+<h3/>'
    cross.right <- ''
  } else if (cross_loc == "right") {
    cross.center <- ''
    cross.left <- ''
    cross.right <- '<h3 style="font-size: 100px; color: white">+<h3/>'
  }

  spread <- as.data.frame(spread)

  spread[row,"randomise_blocks"] <- block_count
  spread[row,"randomise_trials"] <- block_count
  spread[row,"trial_number"] <- n
  spread[row,"condition"] <- condition
  spread[row,"sanity"] <- sanity
  spread[row,"cross_loc"] <- cross_loc
  spread[row,"Ccross"] <- cross.center
  spread[row,"Lcross"] <- cross.left
  spread[row,"Rcross"] <- cross.right
  spread[row,"display"] <- display
  spread[row,"Lamt"] <- Lstats[1]
  spread[row,"Lprob"] <- Lstats[2]
  #spread[row,"Lev"] <- Lstats[3]
  spread[row,"Ramt"] <- Rstats[1]
  spread[row,"Rprob"] <- Rstats[2]
  #spread[row,"Rev"] <- Rstats[3]

  spread[row,"correctAnswer"] <- ifelse(
    as.numeric(Lstats[3])>as.numeric(Rstats[3]),
    "left",
    "right"
  )

  #spread[row,"incorrectAnswer"] <- ifelse(
  #  as.numeric(Lstats[3])>as.numeric(Rstats[3]),
  #  "right",
  #  "left"
  #)

  spread[row,"Lprob_disp"] <- jstext(
    font_size,
    as.percent(Lstats[2]),
    condition
  )
  spread[row,"Lamt_disp"] <- jstext(
    font_size,
    Lstats[1],
    condition
  )
  spread[row,"Rprob_disp"] <- jstext(
    font_size,
    as.percent(Rstats[2]),
    condition
  )
  spread[row,"Ramt_disp"] <- jstext(
    font_size,
    Rstats[1],
    condition
  )

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

# ################### DELETE LATER #############################
# spread[row,"Lprob_disp"] <- '<h3 style="font-size: 100px; color: green;">26.3%<p/>'
# spread[row,"Lamt_disp"] <- '<h3 style="font-size: 100px; color: green;">39.3<h3/>'
# spread[row,"Rprob_disp"] <- '<h3 style="font-size: 100px; color: red;">58.9%<h3/>'
# spread[row,"Ramt_disp"] <- '<h3 style="font-size: 100px; color: red;">-15.5<h3/>'
# spread[row,"display"] <- "format" ; row<-row+1
# ##############################################################

spread[row,"display"] <- "Instructions" ; row<-row+1
spread[row,"display"] <- "Calibrate" ; row<-row+1

################### 12 PRACTICE TRIALS

block_count <- NA

spread[row,"display"] <- "PracticeStart" ; row<-row+1

for (practice in 1:2) {
  trial.list <- trial.details(
    display = "PracticeTrial",
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
    display = "PracticeTrial",
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
    display = "PracticeTrial",
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
    display = "PracticeTrial",
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
    display = "PracticeTrial",
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
    display = "PracticeTrial",
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

spread[row,"display"] <- "PracticeEnd" ; row<-row+1

################### BLOCK 1: GAIN

n <- 0
block_count <- 1


spread[row,"display"] <- "Calibrate" ; row<-row+1
spread[row,"randomise_blocks"] <- block_count
spread[row,"display"] <- "BlockWin" ; row<-row+1

for (trial in 1:nTrials.center) {

  trial.list <- trial.details(
    display = "Trial",
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
    display = "Trial",
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
    display = "Trial",
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
    display = "Trial",
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

spread[row,"display"] <- "Block1End" ; row<-row+1

################### Block 2: LOSS

block_count <- 2

spread[row,"display"] <- "Calibrate" ; row<-row+1
spread[row,"randomise_blocks"] <- block_count
spread[row,"display"] <- "BlockLoss" ; row<-row+1

for (trial in 1:nTrials.center) {

  trial.list <- trial.details(
    display = "Trial",
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
    display = "Trial",
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
    display = "Trial",
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
    display = "Trial",
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

spread[row,"display"] <- "Block2End" ; row<-row+1

################### Block 3: GAIN

block_count <- 3

spread[row,"display"] <- "Calibrate" ; row<-row+1
spread[row,"randomise_blocks"] <- block_count
spread[row,"display"] <- "BlockGain" ; row<-row+1

for (trial in 1:nTrials.center) {

  trial.list <- trial.details(
    display = "Trial",
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
    display = "Trial",
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
    display = "Trial",
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
    display = "Trial",
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

spread[row,"display"] <- "Block3End" ; row<-row+1

################### Block 4: LOSS

block_count <- 4

spread[row,"display"] <- "Calibrate" ; row<-row+1
spread[row,"randomise_blocks"] <- block_count
spread[row,"display"] <- "BlockLoss" ; row<-row+1

for (trial in 1:nTrials.center) {

  trial.list <- trial.details(
    display = "Trial",
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
    display = "Trial",
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
    display = "Trial",
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
    display = "Trial",
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

################### END

spread[row,"display"] <- "End"

summary(spread$Lprob %>% as.numeric())
summary(spread$Rprob %>% as.numeric())
summary(spread$Lamt[spread$condition=="gain"] %>% as.numeric())
summary(spread$Ramt[spread$condition=="gain"] %>% as.numeric())
summary(spread$Lamt[spread$condition=="loss"] %>% as.numeric())
summary(spread$Ramt[spread$condition=="loss"] %>% as.numeric())

write.csv(
  spread,
  file = "spreadsheet.csv",
  na="",
  row.names = F
)
