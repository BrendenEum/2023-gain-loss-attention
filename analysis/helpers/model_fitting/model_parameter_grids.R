#####################################################################
# COMMON GRIDS
d_grid = seq(.001, .009, .001)
sigma_grid = seq(.01, .09, .01)
bias_grid = c(-3:3)/10
#####################################################################


####################################
# Standard aDDM
####################################

# Gain
grid = list(
    d = d_grid,
    sigma = sigma_grid,
    theta = seq(0, 1, .1),
    bias = bias_grid
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/aDDM_Gain.csv", row.names=F)

# Loss
grid = list(
    d = d_grid,
    sigma = sigma_grid,
    theta = seq(1, 2, .1),
    bias = bias_grid
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/aDDM_Loss.csv", row.names=F)


####################################
# Additive aDDM
####################################

# Gain and Loss
grid = list(
    d = d_grid,
    sigma = sigma_grid,
    eta = seq(0, .05, .005),
    bias = bias_grid
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/AddDDM_Gain.csv", row.names=F)
write.csv(grid, file="parameter_grids/AddDDM_Loss.csv", row.names=F)


####################################
# Reference-Dependent aDDM in Study 1
####################################

# Gain
grid = list(
    d = d_grid,
    sigma = sigma_grid,
    theta = seq(0, 1, .1),
    bias = bias_grid,
    reference = 4.5
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Gain_Study1.csv", row.names=F)

# Loss
grid = list(
    d = d_grid,
    sigma = sigma_grid,
    theta = seq(0, 1, .1),
    bias = bias_grid,
    reference = -5.5
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Loss_Study1.csv", row.names=F)

####################################
# Reference-Dependent aDDM in Study 2
####################################

# Gain
grid = list(
  d = d_grid,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  bias = bias_grid,
  reference = 1
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Gain_Study2.csv", row.names=F)

# Loss
grid = list(
  d = d_grid,
  sigma = sigma_grid,
  theta = seq(0, 1, .1),
  bias = bias_grid,
  reference = -6
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Loss_Study2.csv", row.names=F)