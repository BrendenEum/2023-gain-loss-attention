# aDDM 

d = seq(.001, .009, .004)
sigma = seq(.01, .09, .04)
bias = seq(-.9, .9, .9)
theta = seq(0, 3, 1.5)
eta = seq(0,3,1.5)
lambda = seq(0,.004, .002)
minValue = c(0, -6)
range = c(1, 5)
grid = expand.grid(d=d,sigma=sigma,bias=bias,theta=theta,eta=eta,lambda=lambda,minValue=minValue,range=range)
write.csv(grid, file="param_grid.csv", row.names=F)