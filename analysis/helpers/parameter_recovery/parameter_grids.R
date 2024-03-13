####################################
# Standard aDDM
####################################

# Gain
grid = list(
    d = c(.002, .0035, .005, .0065, .008),
    sigma = c(.02, .035, .05, .065, .08),
    theta = c(0, .25, .5, .75, .9),
    bias = c(-.2, -.1, 0, .1, .2),
    lambda = c(0, .001, .002, .003, .004)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/aDDM_Gain.csv", row.names=F)

# Loss
grid = list(
    d = c(.002, .0035, .005, .0065, .008),
    sigma = c(.02, .035, .05, .065, .08),
    theta = c(1.1, 1.25, 1.5, 1.75, 2),
    bias = c(-.2, -.1, 0, .1, .2),
    lambda = c(0, .001, .002, .003, .004)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/aDDM_Loss.csv", row.names=F)


####################################
# Additive aDDM
####################################

# Gain and Loss
grid = list(
    d = c(.002, .0035, .005, .0065, .008),
    sigma = c(.02, .035, .05, .065, .08),
    eta = c(0, .01, .02, .03, .04),
    bias = c(-.2, -.1, 0, .1, .2),
    lambda = c(0, .001, .002, .003, .004)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/Add-aDDM_Gain.csv", row.names=F)
write.csv(grid, file="parameter_grids/Add-aDDM_Loss.csv", row.names=F)


####################################
# Reference-Dependent aDDM
####################################

# Gain
grid = list(
    d = c(.002, .0035, .005, .0065, .008),
    sigma = c(.02, .035, .05, .065, .08),
    theta = c(0, .25, .5, .75, .9),
    bias = c(-.2, -.1, 0, .1, .2),
    lambda = c(0, .001, .002, .003, .004),
    reference = 1
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Gain.csv", row.names=F)

# Loss
grid = list(
    d = c(.002, .0035, .005, .0065, .008),
    sigma = c(.02, .035, .05, .065, .08),
    theta = c(0, .25, .5, .75, .9),
    bias = c(-.2, -.1, 0, .1, .2),
    lambda = c(0, .001, .002, .003, .004),
    reference = -6
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Loss.csv", row.names=F)