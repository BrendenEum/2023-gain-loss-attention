####################################
# Reference-Dependent aDDM
####################################

# Gain
grid = list(
    d = c(.003, .006, .009, .012),
    sigma = c(.05, .06, .07, .08, .09, .095),
    theta = c(.25, .5, .75),
    bias = 0,
    reference = 0
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Gain.csv", row.names=F)