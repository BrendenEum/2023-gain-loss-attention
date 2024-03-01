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
# d,s,e
####################################
grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    eta = seq(0, .02, .001)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dse_Gain.csv", row.names=F)

grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    eta = seq(0, .02, .001)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dse_Loss.csv", row.names=F)

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

####################################
# d,s,t,m,r
####################################
grid = list(
    d = seq(.001*5, .005*5, .001*5),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,1),
    range = c(1,5)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstmr_Gain.csv", row.names=F)

grid = list(
    d = seq(.001*5, .005*5, .001*5),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,-6),
    range = c(1,5)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstmr_Loss.csv", row.names=F)

####################################
# d,s,t,m + d,s,e
####################################
gridA = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,1)
)
gridA = expand.grid(gridA)
gridB = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = 1,
    eta = seq(0, .02, .001),
    minValue = 0
)
gridB = expand.grid(gridB)
grid = rbind(gridA, gridB)
write.csv(grid, file="parameter_grids/dstm-dse_Gain.csv", row.names=F)
write.csv(grid, file="parameter_grids/dse-dstm_Gain.csv", row.names=F)

gridA = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,-6)
)
gridA = expand.grid(gridA)
gridB = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = 1,
    eta = seq(0, .02, .001),
    minValue = 0
)
gridB = expand.grid(gridB)
grid = rbind(gridA, gridB)
write.csv(grid, file="parameter_grids/dstm-dse_Loss.csv", row.names=F)
write.csv(grid, file="parameter_grids/dse-dstm_Loss.csv", row.names=F)