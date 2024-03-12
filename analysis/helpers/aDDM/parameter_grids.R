# RDaDDM

d = seq(.001, .009, .001)
sigma = seq(.01, .09, .01)
bias = seq(-.5, .5, .1)
theta = seq(0, 1, .1)
lambda = seq(0,.004, .001)
minValue = -6
grid = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,lambda=lambda,minValue=minValue)
write.csv(grid, file="param_grid.csv", row.names=F)


# RDaDDM

d = seq(.001, .009, .004)
sigma = seq(.01, .09, .04)
bias = seq(-.5, .5, .5)
theta = seq(0, 1, .25)
lambda = seq(0,.004, .002)
minValue = -6
grid = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,lambda=lambda,minValue=minValue)
write.csv(grid, file="param_grid.csv", row.names=F)