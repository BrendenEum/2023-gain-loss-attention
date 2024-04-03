#####################################################################
# COMMON GRIDS
d_grid_normal = seq(.001, .021, .004)
d_grid_large = seq(.008, .028, .004)
sigma_grid = seq(.05, .09, .02)
bias_grid = c(-1:1)/10
#####################################################################
if (length(d_grid_normal)!=length(d_grid_large)) {warning("Make sure d_grids are equal length.")}

####################################
# Standard aDDM in Study 1
####################################

# Gain
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = seq(0, 1, .25),
    bias = bias_grid
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/aDDM_Gain.csv", row.names=F)

# Loss
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = seq(0, 1, .25),
    bias = bias_grid
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/aDDM_Loss.csv", row.names=F)


####################################
# Additive aDDM
####################################

# Gain and Loss
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    eta = seq(0, .02, .005),
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
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = seq(0, 1, .25),
    bias = bias_grid,
    reference = seq(4.5-9, 4.5, 1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Gain_Study1.csv", row.names=F)

# Loss
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = seq(0, 1, .25),
    bias = bias_grid,
    reference = seq(-5.5-9, -5.5, 1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Loss_Study1.csv", row.names=F)

####################################
# Reference-Dependent aDDM in Study 2
####################################

# Gain
grid = list(
  d = d_grid_normal, 
  sigma = sigma_grid,
  theta = seq(0, 1, .25),
  bias = bias_grid,
  reference = seq(1-9, 1, 1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Gain_Study2.csv", row.names=F)

# Loss
grid = list(
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = seq(0, 1, .25),
  bias = bias_grid,
  reference = seq(-6-9, -6, 1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/RaDDM_Loss_Study2.csv", row.names=F)