#####################################################################
# COMMON GRIDS
d_grid_normal = seq(.001, .009, .001)
sigma_grid = seq(.01, .09, .01)
theta_grid = seq(0, 1, .1)
eta_grid = seq(.000, .010, .001)
#####################################################################

####################################
# aDDM
####################################

aDDM_grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = theta_grid
)
aDDM_grid = expand.grid(aDDM_grid)
fn = paste0("parameter_grids/aDDM_grid.csv")
write.csv(aDDM_grid, file=fn, row.names=F)


####################################
# Additive aDDM
####################################

AddDDM_grid = list(
  d = d_grid_normal,
  sigma = sigma_grid,
  eta = eta_grid
)
AddDDM_grid = expand.grid(AddDDM_grid)
fn = paste0("parameter_grids/AddDDM_grid.csv")
write.csv(AddDDM_grid, file=fn, row.names=F)


####################################
# RaDDM
####################################

# Study1G
RaDDM_grid = list(
    d = d_grid_normal,
    sigma = sigma_grid,
    theta = theta_grid
)
RaDDM_grid = expand.grid(RaDDM_grid)
fn = paste0("parameter_grids/RaDDM_grid.csv")
write.csv(RaDDM_grid, file=fn, row.names=F)
