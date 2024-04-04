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

dir.create("Stage1_parameter_grids")
study1participants = read.csv("Study1_participants.csv")$participants
study2participants = read.csv("Study2_participants.csv")$participants
dir.create("Stage1_parameter_grids/")
for (j in study1participants){dir.create(paste0("Stage1_parameter_grids/",j,"/"))}
for (j in study2participants){dir.create(paste0("Stage1_parameter_grids/",j,"/"))}

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
for (j in study1participants){
  fn = paste0("stage1_parameter_grids/", j, "/aDDM_Gain.csv")
  write.csv(grid, file=fn, row.names=F)
  fn = paste0("stage1_parameter_grids/", j, "/aDDM_Loss.csv")
  write.csv(grid, file=fn, row.names=F)
}
for (j in study2participants){
  fn = paste0("stage1_parameter_grids/", j, "/aDDM_Gain.csv")
  write.csv(grid, file=fn, row.names=F)
  fn = paste0("stage1_parameter_grids/", j, "/aDDM_Loss.csv")
  write.csv(grid, file=fn, row.names=F)
}


####################################
# Additive aDDM
####################################

# Gain and Loss
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    eta = .004, #seq(0, .02, .004),
    bias = bias_grid
)
grid = expand.grid(grid)
for (j in study1participants){
  fn = paste0("stage1_parameter_grids/", j, "/AddDDM_Gain.csv")
  write.csv(grid, file=fn, row.names=F)
  fn = paste0("stage1_parameter_grids/", j, "/AddDDM_Loss.csv")
  write.csv(grid, file=fn, row.names=F)
}
for (j in study2participants){
  fn = paste0("stage1_parameter_grids/", j, "/AddDDM_Gain.csv")
  write.csv(grid, file=fn, row.names=F)
  fn = paste0("stage1_parameter_grids/", j, "/AddDDM_Loss.csv")
  write.csv(grid, file=fn, row.names=F)
}


####################################
# Reference-Dependent aDDM in Study 1
####################################

# Gain
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = theta_grid,
    bias = bias_grid,
    reference = 3.5#seq(4.5-8, 4.5, 4)
)
grid = expand.grid(grid)
for (j in study1participants){
  fn = paste0("stage1_parameter_grids/", j, "/RaDDM_Gain.csv")
  write.csv(grid, file=fn, row.names=F)
}

# Loss
grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = theta_grid,
    bias = bias_grid,
    reference = -6.5#seq(-5.5-8, -5.5, 4)
)
grid = expand.grid(grid)
for (j in study1participants){
  fn = paste0("stage1_parameter_grids/", j, "/RaDDM_Loss.csv")
  write.csv(grid, file=fn, row.names=F)
}

####################################
# Reference-Dependent aDDM in Study 2
####################################

# Gain
grid = list(
  d = d_grid_normal, 
  sigma = sigma_grid,
  theta = theta_grid,
  bias = bias_grid,
  reference = 0#seq(1-8, 1, 4)
)
grid = expand.grid(grid)
for (j in study2participants){
  fn = paste0("stage1_parameter_grids/", j, "/RaDDM_Gain.csv")
  write.csv(grid, file=fn, row.names=F)
}

# Loss
grid = list(
  d = d_grid_normal,
  sigma = sigma_grid,
  theta = theta_grid,
  bias = bias_grid,
  reference = -7#seq(-6-8, -6, 4)
)
grid = expand.grid(grid)
for (j in study2participants){
  fn = paste0("stage1_parameter_grids/", j, "/RaDDM_Loss.csv")
  write.csv(grid, file=fn, row.names=F)
}