## This generates the example aDDM figure for positive-valued options.

# Preamble  ############################################################################

set.seed(19)
library(tidyverse)
library(truncnorm)
library(plotrix)
library(ggsci)
library(latex2exp)
figdir = file.path("../../outputs/figures")
optdir = file.path("../plot_options/")

# Plot Aesthetics ############################################################################

source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))
left_color = "red"
right_color = "yellow"

# Trial data ############################################################################

vL <- -1
vR <- -1

# Fixation properties ###################################################################

prFirstLeft <- .831
latency     <- ceiling(runif(1, min=50, max=250))
firstFix_mean <- 346
firstFix_sd <- 181
middleFix_mean <- 707
middleFix_sd <- 423
transition_min <- 6
transition_max <- 50

# aDDM parameters ##########################################################################

d <- .003
sig    <- .02
theta  <- .52
bias   <- .02
bounds <- 1

# Simulate evidence process for a single trial ################################################

evid_list <- c()
loc_list  <- c()
fix_num_list <- c()

evid      <- bias
time      <- 1
fix_num   <- 0
saccade   <- 0
bound_hit <- 0
loc_list[time]  <- 4 #4=nowhere
evid_list[time] <- evid

while (bound_hit==0) {
  
  #latency to first fixation
  if (time<=latency) {
    time <- time + 1
    loc <- 4
    evid <- evid + rnorm(1, mean=0, sd=sig)
    loc_list[time] <- loc
    evid_list[time] <- evid
    if (abs(evid)>=bounds) {bound_hit=1}
  }
  
  #first fixation
  if (time>latency & fix_num==0 & bound_hit==0) {
    fix_num <- fix_num + 1
    saccade <- 1
    loc <- rbinom(1,1,prFirstLeft)
    fix_dur <- ceiling(rtruncnorm(1, a=1, b=Inf, mean=firstFix_mean, sd=firstFix_sd))
    for (fix_time in c(1:fix_dur)) {
      time <- time + 1
      if (loc==1) { evid <- evid + d*(vL-theta*vR) + rnorm(1, mean=0, sd=sig) }
      if (loc==0) { evid <- evid + d*(theta*vL-vR) + rnorm(1, mean=0, sd=sig) }
      loc_list[time] <- loc
      fix_num_list[time] <- fix_num
      evid_list[time] <- evid
      if (abs(evid)>=bounds) {break}
    }
    if (abs(evid)>=bounds) {bound_hit=1}
  }
  
  #saccades
  if (time>latency & saccade==1 & bound_hit==0) {
    saccade <- 0
    prevLoc <- loc
    loc <- 4
    fix_dur <- ceiling(runif(1, min=transition_min, max=transition_max))
    for (fix_time in c(1:fix_dur)) {
      time <- time + 1
      evid <- evid + rnorm(1, mean=0, sd=sig)
      loc_list[time] <- loc
      evid_list[time] <- evid
      if (abs(evid)>=bounds) {break}
    }
    if (abs(evid)>=bounds) {bound_hit=1}
  }
  
  #middle fixations
  if (time>latency & fix_num>0 & saccade==0 & bound_hit==0) {
    fix_num <- fix_num + 1
    saccade <- 1
    loc <- abs(prevLoc-1) #0->1 and 1->0
    fix_dur <- ceiling(rtruncnorm(1, a=1, b=Inf, mean=middleFix_mean, sd=middleFix_sd))
    for (fix_time in c(1:fix_dur)) {
      time <- time + 1
      if (loc==1) { evid <- evid + d*(vL-theta*vR) + rnorm(1, mean=0, sd=sig) }
      if (loc==0) { evid <- evid + d*(theta*vL-vR) + rnorm(1, mean=0, sd=sig) }
      loc_list[time] <- loc
      fix_num_list[time] <- fix_num
      evid_list[time] <- evid
      if (abs(evid)>=bounds) {break}
    }
    if (abs(evid)>=bounds) {bound_hit=1}
  }
  
}

# Transform into plot data ########################################################################

pdata.exampleaDDM <- data.frame(time = c(1:length(evid_list)), loc = loc_list, fix_num = fix_num_list, evid = evid_list)
pdata.fixations <- pdata.exampleaDDM %>%
  na.omit() %>%
  group_by(fix_num) %>%
  summarise(
    fix_start = first(time),
    fix_end = last(time),
    loc = first(loc)
  )


# Plot the results ########################################################################

x_init = 650
y_init = .72
gap = .13

p.exampleaDDM <- ggplot(data = pdata.exampleaDDM, aes(x=time, y=evid)) +
  
  myPlot +
  
  annotate("rect", xmin = pdata.fixations$fix_start[1], xmax = pdata.fixations$fix_end[1], ymin = -.99, ymax = .99, alpha = .25, fill=left_color) +
  annotate(geom='text', x=mean(c(pdata.fixations$fix_start[1],pdata.fixations$fix_end[1])), y=.88, label='Left', size=9/.pt) +
  annotate("rect", xmin = pdata.fixations$fix_start[2], xmax = pdata.fixations$fix_end[2], ymin = -.99, ymax = .99, alpha = .25, fill=right_color) +
  annotate(geom='text', x=mean(c(pdata.fixations$fix_start[2],pdata.fixations$fix_end[2])), y=.88, label='Right', size=9/.pt) +
  annotate("rect", xmin = pdata.fixations$fix_start[3], xmax = pdata.fixations$fix_end[3], ymin = -.99, ymax = .99, alpha = .25, fill=left_color) +
  annotate(geom='text', x=mean(c(pdata.fixations$fix_start[3],pdata.fixations$fix_end[3])), y=.88, label='Left', size=9/.pt) +
  
  geom_line(size=linesize) +
  
  coord_cartesian(ylim=c(-1.1,1.1)) +
  xlim(c(-.01,1350)) +
  geom_hline(yintercept=0, color='darkgrey', alpha=.6) +
  geom_hline(yintercept=1, color='black', linetype='dashed') +
  annotate(geom='text', x=65, y=1.09, label='Choice = Left', size=9/.pt) +
  geom_hline(yintercept=-1, color='black', linetype='dashed') +
  annotate(geom='text', x=80, y=-1.09, label='Choice = Right', size=9/.pt) +
  ylab("Evidence") +
  xlab("Time (ms)") +
    
  annotate(geom='text', x=x_init, y=y_init-gap*0, label=TeX('$v_{left} = -1$'),  size=9/.pt) +
  annotate(geom='text', x=x_init+10, y=y_init-gap*1, label=TeX('$v_{right} = -1$'), size=9/.pt) +
  annotate(geom='text', x=x_init+4, y=y_init-gap*2, label=TeX('$d = .003$'),      size=9/.pt) +
  annotate(geom='text', x=x_init-8, y=y_init-gap*3, label=TeX('$\\sigma = .02$'), size=9/.pt) +
  annotate(geom='text', x=x_init-8, y=y_init-gap*4, label=TeX('$\\theta = .52$'), size=9/.pt) +
  annotate(geom='text', x=x_init-8, y=y_init-gap*5, label=TeX('$\\b = .02$'),     size=9/.pt)

plot(p.exampleaDDM)
ggsave(
  file.path(figdir, "aDDM_example_loss.pdf"),
  plot=p.exampleaDDM, width=figw, height=figh, units="in")