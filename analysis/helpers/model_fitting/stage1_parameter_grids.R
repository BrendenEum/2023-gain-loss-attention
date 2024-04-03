#####################################################################
# COMMON GRIDS
#d_grid_normal = seq(.001, .025, .004)
#sigma_grid = seq(.01, .13, .04)
#bias_grid = seq(-.4, .4, .4)
#theta_grid = seq(-.2, 1, .4)
d_grid_normal = .004
sigma_grid = .07
bias_grid = 0
theta_grid = .5
#####################################################################
#if (length(d_grid_normal)!=length(d_grid_large)) {warning("Make sure d_grids are equal length.")}

####################################
# Standard aDDM
####################################

# Gain and Loss
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = theta_grid,
    bias = bias_grid
)
grid = expand.grid(grid)
write.csv(grid, file="stage1_parameter_grids/aDDM_Gain.csv", row.names=F)
write.csv(grid, file="stage1_parameter_grids/aDDM_Loss.csv", row.names=F)


####################################
# Additive aDDM
####################################

# Gain and Loss
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    eta = seq(0, .02, .004),
    bias = bias_grid
)
grid = expand.grid(grid)
write.csv(grid, file="stage1_parameter_grids/AddDDM_Gain.csv", row.names=F)
write.csv(grid, file="stage1_parameter_grids/AddDDM_Loss.csv", row.names=F)


####################################
# Reference-Dependent aDDM in Study 1
####################################

# Gain
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = theta_grid,
    bias = bias_grid,
    reference = seq(4.5-8, 4.5, 4)
)
grid = expand.grid(grid)
write.csv(grid, file="stage1_parameter_grids/RaDDM_Gain_Study1.csv", row.names=F)

# Loss
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = theta_grid,
    bias = bias_grid,
    reference = seq(-5.5-8, -5.5, 4)
)
grid = expand.grid(grid)
write.csv(grid, file="stage1_parameter_grids/RaDDM_Loss_Study1.csv", row.names=F)

####################################
# Reference-Dependent aDDM in Study 2
####################################

# Gain
grid = list(
  d = d_grid_normal, 
  sigma = sigma_grid,
  theta = theta_grid,
  bias = bias_grid,
  reference = seq(1-8, 1, 4)
)
grid = expand.grid(grid)
write.csv(grid, file="stage1_parameter_grids/RaDDM_Gain_Study2.csv", row.names=F)

# Loss
grid = list(
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = theta_grid,
  bias = bias_grid,
  reference = seq(-6-8, -6, 4)
)
grid = expand.grid(grid)
write.csv(grid, file="stage1_parameter_grids/RaDDM_Loss_Study2.csv", row.names=F)