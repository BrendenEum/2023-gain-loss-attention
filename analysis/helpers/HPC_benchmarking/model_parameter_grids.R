####################################
# Standard aDDM
####################################

# Gain
grid = list(
    d = c(.002, .005, .008),
    sigma = c(.02, .05, .08),
    theta = c(0, .5, .9)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/aDDM_Gain.csv", row.names=F)