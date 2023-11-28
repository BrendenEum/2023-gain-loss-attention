######################
## Exploratory
######################

## plot

# # graph options # # # #
gradient_resolution = 100
exact = 'grey40'
close = 'grey70'
far = 'white'
# # # # # # # # # # # # #

# coord.lim <- 7
# d_gradient <- expand.grid(x=seq(0,coord.lim,coord.lim/gradient_resolution), y=seq(0,coord.lim,coord.lim/gradient_resolution))
# plt.compare.d.e <- ggplot(data=MAP.indiv) +
#   geom_tile(data=d_gradient, aes(x=x, y=y, fill=abs(y-x))) + #add gradient background
#   scale_fill_gradient(low=close, high=far) +
#   geom_abline(intercept=0, slope=1, color=exact) +
#   geom_point(aes(x=drift.gain, y=drift.loss), size=linesize) +
#   xlim(c(0,coord.lim)) +
#   ylim(c(0,coord.lim)) +
#   labs(x = TeX(r"(Gain $d$)"), y = TeX(r"(Loss $d$)")) +
#   scale_y_continuous(labels = function(x) format(x, nsmall = 2)) +
#   scale_x_continuous(labels = function(x) format(x, nsmall = 2))
#
# coord.lim <- 1.2
# sig_gradient <- expand.grid(x=seq(0,coord.lim,coord.lim/gradient_resolution), y=seq(0,coord.lim,coord.lim/gradient_resolution))
# plt.compare.sig.e <- ggplot(data=MAP.indiv) +
#   geom_tile(data=sig_gradient, aes(x=x, y=y, fill=abs(y-x))) +
#   scale_fill_gradient(low=close, high=far) +
#   geom_abline(intercept=0, slope=1, color=exact) +
#   geom_point(aes(x=sig.gain, y=sig.loss), size=linesize) +
#   xlim(c(0,coord.lim)) +
#   ylim(c(0,coord.lim)) +
#   labs(x = TeX(r"(Gain $\sigma$)"), y = TeX(r"(Loss $\sigma$)")) +
#   scale_y_continuous(labels = function(x) format(x, nsmall = 2)) +
#   scale_x_continuous(labels = function(x) format(x, nsmall = 2))
#
# coord.lim <- .4
# bias_gradient <- expand.grid(x=seq(-coord.lim,coord.lim,coord.lim/gradient_resolution), y=seq(-coord.lim,coord.lim,coord.lim/gradient_resolution))
# plt.compare.bias.e <- ggplot(data=MAP.indiv) +
#   geom_tile(data=bias_gradient, aes(x=x, y=y, fill=abs(y-x))) +
#   scale_fill_gradient(low=close, high=far) +
#   geom_abline(intercept=0, slope=1, color=exact) +
#   geom_point(aes(x=bias.gain, y=bias.loss), size=linesize) +
#   xlim(c(-coord.lim,coord.lim)) +
#   ylim(c(-coord.lim,coord.lim)) +
#   labs(x = TeX(r"(Gain bias)"), y = TeX(r"(Loss bias)")) +
#   scale_y_continuous(labels = function(x) format(x, nsmall = 2)) +
#   scale_x_continuous(labels = function(x) format(x, nsmall = 2))

coord.lim <- 2.25
theta_gradient <- expand.grid(x=seq(0,coord.lim,coord.lim/gradient_resolution), y=seq(0,coord.lim,coord.lim/gradient_resolution))
plt.compareTheta.e <- ggplot(data=MAP.indiv) +
  myPlot +
  geom_tile(data=theta_gradient, aes(x=x, y=y, fill=abs(y-x))) +
  scale_fill_gradient(low='orange', high=far) +
  geom_vline(xintercept = 1, color='grey30', alpha=.5) +
  geom_hline(yintercept = 1, color='grey30', alpha=.5) +
  #geom_abline(intercept=0, slope=1, color='grey30') +
  geom_point(aes(x=theta.gain, y=theta.loss), size=linesize) +
  xlim(c(0,coord.lim)) +
  ylim(c(0,coord.lim)) +
  labs(x = expression("Gain"~theta), y = expression("Loss"~theta)) +
  scale_y_continuous(labels = function(x) format(x, nsmall = 2)) +
  scale_x_continuous(labels = function(x) format(x, nsmall = 2))

# plt.compare.param.e <- grid.arrange(plt.compare.d.e, plt.compare.sig.e, plt.compare.bias.e, plt.compare.theta.e,
#                                     nrow=2)