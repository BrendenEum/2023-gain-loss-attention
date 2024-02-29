####################################
# d,s,t
####################################
grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dst_Gain.csv", row.names=F)

grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(1, 2, .1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dst_Loss.csv", row.names=F)

####################################
# d,s,t,b
####################################
grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    bias = seq(-.1, .1, .1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstb_Gain.csv", row.names=F)

grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(1, 2, .1),
    bias = seq(-.1, .1, .1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstb_Loss.csv", row.names=F)

####################################
# d,s,b,e
####################################
grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    bias = seq(-.1, .1, .1),
    eta = seq(0, .02, .001)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dsbe_Gain.csv", row.names=F)

grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    bias = seq(-.1, .1, .1),
    eta = seq(0, .02, .001)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dsbe_Loss.csv", row.names=F)

####################################
# d,s,t,b,e
####################################
grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0,1,.1),
    bias = seq(-.1, .1, .1),
    eta = seq(0, .02, .001)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstbe_Gain.csv", row.names=F)

grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(1,2,.1),
    bias = seq(-.1, .1, .1),
    eta = seq(0, .02, .001)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstbe_Loss.csv", row.names=F)

####################################
# d,s,t,m
####################################
grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstm_Gain.csv", row.names=F)

grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,-6)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstm_Loss.csv", row.names=F)