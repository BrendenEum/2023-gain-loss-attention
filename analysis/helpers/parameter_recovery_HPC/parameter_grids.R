# aDDM

d = seq(.001, .005, .001)
sigma = seq(.01, .05, .01)
bias = seq(-.1, .1, .1)
theta = seq(0, 1, .1)
eta = 0
lambda = seq(0,.0003, .00015)
nonDecisionTime = seq(100,400,100)
minValue = 0
range = 1
grid_aDDM = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,eta=eta,lambda=lambda,nonDecisionTime=nonDecisionTime,minValue=minValue,range=range)

# AddDDM

d = seq(.001, .005, .001)
sigma = seq(.01, .05, .01)
bias = seq(-.1, .1, .1)
theta = 1
eta = seq(.1, 2, .1)
lambda = seq(0,.0003, .00015)
nonDecisionTime = seq(100,400,100)
minValue = 0
range = 1
grid_AddDDM = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,eta=eta,lambda=lambda,nonDecisionTime=nonDecisionTime,minValue=minValue,range=range)

# GRaDDM

d = seq(.001, .005, .001)
sigma = seq(.01, .05, .01)
bias = seq(-.1, .1, .1)
theta = seq(0, 1, .1)
eta = 0
lambda = seq(0,.0003, .00015)
nonDecisionTime = seq(100,400,100)
minValue = 1
range = 1
grid_GRaDDM = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,eta=eta,lambda=lambda,nonDecisionTime=nonDecisionTime,minValue=minValue,range=range)

# RNaDDM

d = seq(.001, .005, .001)
sigma = seq(.01, .05, .01)
bias = seq(-.1, .1, .1)
theta = seq(0, 1, .1)
eta = 0
lambda = seq(0,.0003, .00015)
nonDecisionTime = seq(100,400,100)
minValue = 1
range = 5
grid_RNaDDM = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,eta=eta,lambda=lambda,nonDecisionTime=nonDecisionTime,minValue=minValue,range=range)


grid_gain = do.call("rbind", list(grid_aDDM, grid_AddDDM, grid_GRaDDM, grid_RNaDDM))
write.csv(grid_gain, file="custom_addm_grid_gain.csv", row.names=F)

grid_benchmark = do.call("rbind", list(grid_aDDM, grid_AddDDM))
write.csv(grid_benchmark, file="custom_addm_grid_gain_benchmark.csv", row.names=F)


####################################################################################################################


# aDDM

d = seq(.001, .005, .001)
sigma = seq(.01, .05, .01)
bias = seq(-.1, .1, .1)
theta = seq(1, 2, .1)
eta = 0
lambda = seq(0,.0003, .00015)
nonDecisionTime = seq(100,400,100)
minValue = 0
range = 1
grid_aDDM = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,eta=eta,lambda=lambda,nonDecisionTime=nonDecisionTime,minValue=minValue,range=range)

# AddDDM

d = seq(.001, .005, .001)
sigma = seq(.01, .05, .01)
bias = seq(-.1, .1, .1)
theta = 1
eta = seq(.1, 2, .1)
lambda = seq(0,.0003, .00015)
nonDecisionTime = seq(100,400,100)
minValue = 0
range = 1
grid_AddDDM = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,eta=eta,lambda=lambda,nonDecisionTime=nonDecisionTime,minValue=minValue,range=range)

# GRaDDM

d = seq(.001, .005, .001)
sigma = seq(.01, .05, .01)
bias = seq(-.1, .1, .1)
theta = seq(0, 1, .1)
eta = 0
lambda = seq(0,.0003, .00015)
nonDecisionTime = seq(100,400,100)
minValue = -6
range = 1
grid_GRaDDM = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,eta=eta,lambda=lambda,nonDecisionTime=nonDecisionTime,minValue=minValue,range=range)

# RNaDDM

d = seq(.001, .005, .001)
sigma = seq(.01, .05, .01)
bias = seq(-.1, .1, .1)
theta = seq(0, 1, .1)
eta = 0
lambda = seq(0,.0003, .00015)
nonDecisionTime = seq(100,400,100)
minValue = -6
range = 5
grid_RNaDDM = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,eta=eta,lambda=lambda,nonDecisionTime=nonDecisionTime,minValue=minValue,range=range)


grid_loss = do.call("rbind", list(grid_aDDM, grid_AddDDM, grid_GRaDDM, grid_RNaDDM))
write.csv(grid_loss, file="custom_addm_grid_loss.csv", row.names=F)


####################################################################################################################


# Simple

d = seq(.001, .009, .001)
sigma = seq(.01, .09, .01)
theta = seq(0, 2, .1)
grid_aDDM = expand.grid(d=d,sigma=sigma,theta=theta)


grid_simple = do.call("rbind", list(grid_aDDM))
write.csv(grid_simple, file="addm_grid.csv", row.names=F)