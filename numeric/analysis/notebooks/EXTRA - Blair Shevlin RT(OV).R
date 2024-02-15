library(tidyverse)
load("../data/processed_data/ecfr.RData")

cfr$ov = cfr$vL + cfr$vR
data = cfr[cfr$Sanity==0,]
data$ov = round(data$ov, digits = 0)

data = data %>%
  group_by(subject, Condition, trial) %>%
  summarize(
    rt = first(rt),
    ov = first(ov),
    vDiff = first(vDiff)
  )
data.gain = data[data$Condition=="Gain",]
data.loss = data[data$Condition=="Loss",]

fit.gain = lm(rt ~ vDiff, data.gain)
fit.loss = lm(rt ~ vDiff, data.loss)

df.gain = data.frame(
  subject = data.gain$subject,
  Condition = "Gain",
  ov = data.gain$ov,
  rt.residuals = fit.gain$residuals
)
df.loss = data.frame(
  subject = data.loss$subject,
  Condition = "Loss",
  ov = data.loss$ov,
  rt.residuals = fit.loss$residuals
)
data = rbind(df.gain, df.loss)

pdata = data %>%
  group_by(subject, Condition, ov) %>%
  summarize(
    rt.mean = mean(rt.residuals)
  ) %>%
  ungroup() %>%
  group_by(Condition, ov) %>%
  summarize(
    y = mean(rt.mean), 
    se = std.error(rt.mean)
  )

ggplot(data = pdata, aes(x=ov, y=y, group=Condition, color=Condition, fill=Condition)) +
  geom_vline(xintercept = c(-3,2), color = "grey") +
  geom_ribbon(aes(ymin=y-se, ymax=y+se), alpha = .25) +
  geom_line() +
  labs(
    x = "Overall Value",
    y = "Residuals from RT ~ (L-R)"
  ) 
  
