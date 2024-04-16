####################################
# Reference-Dependent aDDM
####################################

# Gain
grid = list(
    d = c(.003, .006, .009, .012),
    sigma = c(.05, .1, .14, .2),
    theta = c(.25, .5, .75),
    bias = 0,
    reference = c(1,0,-1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Gain.csv", row.names=F)

# Loss
grid = list(
    d = c(.003, .006, .009, .012),
    sigma = c(.05, .1, .14, .2),
    theta = c(.25, .5, .75),
    bias = 0,
    reference = c(-6,0,-8)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Loss.csv", row.names=F)