# aDDM 

d = seq(.001, .009, .004)
sigma = seq(.01, .09, .04)
bias = seq(-.9, .9, .9)
theta = seq(0, 3, 1.5)
eta = seq(0,3,1.5)
lambda = seq(0,.004, .002)
df = data.frame(d,sigma,bias,theta,eta,lambda)
grid = expand.grid(df)
write.table(grid, file="aDDM_grid.csv", sep=",", row.names=F, col.names=F)