# aDDM

d = seq(.001, .005, .001)
sigma = seq(.01, .05, .01)
bias = seq(-.1, .1, .1)
theta = seq(0, 2, .1)
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


grid = do.call("rbind", list(grid_aDDM, grid_AddDDM))
write.csv(grid, file="custom_addm_grid.csv", row.names=F)

# # aDDM
# 
# d = seq(.001, .005, .0025)
# sigma = seq(.01, .05, .025)
# bias = 0
# theta = .5
# eta = 0
# lambda = 0
# nonDecisionTime = 200
# minValue = 0
# range = 1
# grid = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,eta=eta,lambda=lambda,nonDecisionTime=nonDecisionTime,minValue=minValue,range=range)
# 
# write.csv(grid, file="custom_addm_grid.csv", row.names=F)