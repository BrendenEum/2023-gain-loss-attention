# Make a csv containing all the parameter combinations you want to test

###################
# Phase 1
###################

# Parameters

d_     <- seq(.001, .010, .003)
sigma_ <- seq(.01, .05, .02)
theta_ <- seq(-.5, 2, .5)
bias_  <- seq(-.1, .1, .05)

# Make grid

test <- expand.grid(d_, sigma_, theta_, bias_)
colnames(test) <- c("d", "sigma", "theta", "bias")

# Write csv

write.csv(test, file = "grid1_addm.csv", row.names = F)
