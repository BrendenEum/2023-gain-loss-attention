
####################################
# Reference-Dependent aDDM
####################################

# Gain
grid = list(
    d = c(.003, .009),
    sigma = c(.03, .07),
    theta = c(.5, .8),
    bias = 0,
    reference = -1,
    decay = c(0, .0002)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Gain.csv", row.names=F)

# Loss
grid = list(
    d = c(.003, .009),
    sigma = c(.03, .07),
    theta = c(.5, .8),
    bias = 0,
    reference = -8,
    decay = c(0, .0002)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Loss.csv", row.names=F)