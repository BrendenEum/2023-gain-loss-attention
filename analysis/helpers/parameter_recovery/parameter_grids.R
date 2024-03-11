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
# d,s,t,m16
####################################
grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstm16_Gain.csv", row.names=F)

grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,-6)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstm16_Loss.csv", row.names=F)

####################################
# d,s,t,m07
####################################
grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,1)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstm07_Gain.csv", row.names=F)

grid = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,-6,-7)
)
grid = expand.grid(grid)
write.csv(grid, file="parameter_grids/dstm07_Loss.csv", row.names=F)

####################################
# d,s,t,m,r
####################################
gridR1 = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,1),
    range = 1
)
gridR1 = expand.grid(gridR1)
gridR5 = list(
    d = seq(.001*5, .005*5, .001*5),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,1),
    range = 5
)
gridR5 = expand.grid(gridR5)
grid = rbind(gridR1, gridR5)
write.csv(grid, file="parameter_grids/dstmr_Gain.csv", row.names=F)

gridR1 = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,-6),
    range = 1
)
gridR1 = expand.grid(gridR1)
gridR5 = list(
    d = seq(.001*5, .005*5, .001*5),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    minValue = c(0,-6),
    range = 5
)
gridR5 = expand.grid(gridR5)
grid = rbind(gridR1, gridR5)
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

####################################
# d,s,t,m,r + d,s,e
####################################
gridR1 = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,1),
    range = 1
)
gridR1 = expand.grid(gridR1)
gridR5 = list(
    d = seq(.001*5, .005*5, .001*5),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,1),
    range = 5
)
gridR5 = expand.grid(gridR5)
gridDSE = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = 1,
    eta = seq(0, .02, .001),
    minValue = 0,
    range = 1
)
gridDSE = expand.grid(gridDSE)
grid = do.call("rbind", list(gridR1, gridR5, gridDSE))
write.csv(grid, file="parameter_grids/dstmr-dse_Gain.csv", row.names=F)
write.csv(grid, file="parameter_grids/dse-dstmr_Gain.csv", row.names=F)

gridR1 = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,-6),
    range = 1
)
gridR1 = expand.grid(gridR1)
gridR5 = list(
    d = seq(.001*5, .005*5, .001*5),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,-6),
    range = 5
)
gridR5 = expand.grid(gridR5)
gridDSE = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = 1,
    eta = seq(0, .02, .001),
    minValue = 0,
    range = 1
)
gridDSE = expand.grid(gridDSE)
grid = do.call("rbind", list(gridR1, gridR5, gridDSE))
write.csv(grid, file="parameter_grids/dstmr-dse_Loss.csv", row.names=F)
write.csv(grid, file="parameter_grids/dse-dstmr_Loss.csv", row.names=F)

####################################
# d,s,t,m,r + d,s,t
####################################
gridR1 = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,1),
    range = 1
)
gridR1 = expand.grid(gridR1)
gridR5 = list(
    d = seq(.001*5, .005*5, .001*5),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,1),
    range = 5
)
gridR5 = expand.grid(gridR5)
gridDST = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = 0,
    range = 1
)
gridDST = expand.grid(gridDST)
grid = do.call("rbind", list(gridR1,gridR5,gridDST))
write.csv(grid, file="parameter_grids/dstmr-dst_Gain.csv", row.names=F)
write.csv(grid, file="parameter_grids/dst-dstmr_Gain.csv", row.names=F)

gridR1 = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,-6),
    range = 1
)
gridR1 = expand.grid(gridR1)
gridR5 = list(
    d = seq(.001*5, .005*5, .001*5),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,-6),
    range = 5
)
gridR5 = expand.grid(gridR5)
gridDST = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(1, 2, .1),
    eta = 0,
    minValue = 0,
    range = 1
)
gridDST = expand.grid(gridDST)
grid = do.call("rbind", list(gridR1,gridR5,gridDST))
write.csv(grid, file="parameter_grids/dstmr-dst_Loss.csv", row.names=F)
write.csv(grid, file="parameter_grids/dst-dstmr_Loss.csv", row.names=F)

####################################
# d,s,t,m + d,s,t
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
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = 0
)
gridB = expand.grid(gridB)
grid = rbind(gridA, gridB)
write.csv(grid, file="parameter_grids/dstm-dst_Gain.csv", row.names=F)
write.csv(grid, file="parameter_grids/dst-dstm_Gain.csv", row.names=F)

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
    theta = seq(1, 2, .1),
    eta = 0,
    minValue = 0
)
gridB = expand.grid(gridB)
grid = rbind(gridA, gridB)
write.csv(grid, file="parameter_grids/dstm-dst_Loss.csv", row.names=F)
write.csv(grid, file="parameter_grids/dst-dstm_Loss.csv", row.names=F)

####################################
# d,s,t,m,r + d,s,t,m
####################################
gridR1 = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,1),
    range = 1
)
gridR1 = expand.grid(gridR1)
gridR5 = list(
    d = seq(.001*5, .005*5, .001*5),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,1),
    range = 5
)
gridR5 = expand.grid(gridR5)
gridDSTM = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,1),
    range = 1
)
gridDSTM = expand.grid(gridDSTM)
grid = do.call("rbind", list(gridR1,gridR5,gridDSTM))
write.csv(grid, file="parameter_grids/dstmr-dstm_Gain.csv", row.names=F)
write.csv(grid, file="parameter_grids/dstm-dstmr_Gain.csv", row.names=F)

gridR1 = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,-6),
    range = 1
)
gridR1 = expand.grid(gridR1)
gridR5 = list(
    d = seq(.001*5, .005*5, .001*5),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,-6),
    range = 5
)
gridR5 = expand.grid(gridR5)
gridDSTM = list(
    d = seq(.001, .005, .001),
    sigma = seq(.01, .05, .01),
    theta = seq(0, 1, .1),
    eta = 0,
    minValue = c(0,-6),
    range = 1
)
gridDSTM = expand.grid(gridDSTM)
grid = do.call("rbind", list(gridR1,gridR5,gridDSTM))
write.csv(grid, file="parameter_grids/dstmr-dstm_Loss.csv", row.names=F)
write.csv(grid, file="parameter_grids/dstm-dstmr_Loss.csv", row.names=F)