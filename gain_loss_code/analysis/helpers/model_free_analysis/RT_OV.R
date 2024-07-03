#####################
# Preamble
#####################

library(tidyverse)
library(ggsci)
figdir = file.path("../../outputs/figures")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))

#####################
# Data
#####################

load("../../../data/processed_data/ecfr.RData")

data = ecfr
data = data[data$sanity==0,]
data = data[data$firstFix==T,]
data$ov = data$vL + data$vR
data = data %>%
  group_by(studyN, subject) %>%
  mutate(
    nov = ov/max(ov),
  )
data$nov = round(data$nov, digits = 1)
data$ov[data$studyN==2] = round(data$ov[data$studyN==2], digits = 0)
data$ov = round(data$ov, 0)

dots.gain = data[data$condition=="Gain" & data$studyN==1,]
dots.loss = data[data$condition=="Loss" & data$studyN==1,]
numeric.gain = data[data$condition=="Gain" & data$studyN==2,]
numeric.loss = data[data$condition=="Loss" & data$studyN==2,]

fit.dots.gain = lm(rt ~ vDiff, dots.gain)
fit.dots.loss = lm(rt ~ vDiff, dots.loss)
fit.numeric.gain = lm(rt ~ vDiff, numeric.gain)
fit.numeric.loss = lm(rt ~ vDiff, numeric.loss)

dots.gain$rt.residuals = fit.dots.gain$residuals
dots.loss$rt.residuals = fit.dots.loss$residuals
numeric.gain$rt.residuals = fit.numeric.gain$residuals
numeric.loss$rt.residuals = fit.numeric.loss$residuals

data = do.call("rbind", list(dots.gain, dots.loss, numeric.gain, numeric.loss))

#####################
# Plot
#####################

pdata = data %>%
  group_by(studyN, subject, condition, ov) %>%
  summarize(
    rt.mean = mean(rt.residuals)
  ) %>%
  ungroup() %>%
  group_by(studyN, condition, ov) %>%
  summarize(
    y = mean(rt.mean), 
    se = std.error(rt.mean)
  )

plt.rt_ov = ggplot(data = pdata, aes(x=ov, y=y, color=condition)) +
  myPlot +
  geom_vline(xintercept = 0, color = "grey") +
  geom_hline(yintercept = 0, color = "grey") +
  geom_errorbar(
    aes(ymin=y-se, ymax=y+se),
    size=errsize, 
    show.legend=F
  ) +
  geom_line(size=linesize) +
  labs(
    x = "Overall Value",
    y = "Residuals from RT ~ (L-R)",
    color = "Condition"
  ) +
  ylim(c(-1.2,1.2)) +
  theme(
    legend.position=c(.07,.85),
    panel.spacing=unit(2,"lines")
  ) +
  facet_grid(cols = vars(studyN))

ggsave(
  file.path(figdir, paste0("rt_ov.pdf")), 
  plot=plt.rt_ov, width=figw*1.2, height=figh, units="in")

#####################
# What is that weird parabolic shape in study 2?
#####################

num = data[data$studyN==2,]
voi = c("vDiff","LAmt","LProb","RAmt","RProb")
case1 = distinct(num[abs(num$ov)>10,voi]) # extremes: slow RT
case2 = distinct(num[abs(num$ov)==6 | abs(num$ov)==7,voi]) # \pm 6 and 7: fast RT
case3 = distinct(num[abs(num$ov)<5,voi]) # close to 0: slow RT

summary(case1)
summary(case2)
summary(case3)
