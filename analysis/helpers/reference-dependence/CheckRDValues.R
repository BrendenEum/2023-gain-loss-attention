####################################
# Preamble
####################################

library(tidyverse)
library(latex2exp)
source("../plot_options/GainLossColorPalette.R")
source("../plot_options/MyPlotOptions.R")
source("../plot_options/SE.R")
.figdir = file.path("../../outputs/figures")
.tempdir = file.path("../../outputs/temp/ref_dept")

load(file.path(.tempdir, "ref_dept_values.RData"))


####################################
# Get plot data
####################################

bounds = 25
pdataA = RDValuesDF[,c("L_RDVal", "Model", "condition")] %>% rename(RDVal = L_RDVal)
pdataB = RDValuesDF[,c("R_RDVal", "Model", "condition")] %>% rename(RDVal = R_RDVal)
pdata = rbind(pdataA, pdataB)
pdata = pdata %>% mutate(RDVal = pmin(pmax(RDVal, -bounds), bounds))
pdata$Model = factor(pdata$Model, levels=c("StatusQuo", "MaxMin", "minOutcome"))


####################################
# Plot
####################################

histcolor = "darkblue"
plt = ggplot(pdata, aes(x = RDVal)) +
  myPlot +
  
  geom_histogram(binwidth=1, color = histcolor, fill = histcolor) +
  geom_vline(xintercept = 0, color = "darkgrey", alpha = .9, linewidth = 1) +
  
  labs(x = TeX("Ref. Dept. Value (Trunc. $\\pm 25$)"), y = "Count") +
  coord_cartesian(expand = F) +
  facet_grid(rows = vars(Model), cols = vars(condition))

ggsave(file.path(.figdir, "RefDept-ValuesByModel.pdf"), plt, height = 8, width = 8)
