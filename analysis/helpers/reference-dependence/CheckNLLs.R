####################################
# Preamble
####################################

library(tidyverse)
library(patchwork)
source("../plot_options/GainLossColorPalette.R")
source("../plot_options/MyPlotOptions.R")
source("../plot_options/SE.R")
.figdir = file.path("../../outputs/figures")
.tempdir = file.path("../../outputs/temp/ref_dept")

load(file.path(.tempdir, "ref_dept_results.RData"))


####################################
# Histograms of NLLs
####################################

NLL_df = data.frame(studyN = NA, subject = NA, condition = NA, model = NA, totalNLL = NA)
for (m in names(results)){
  .mini_results = results[[m]]
  .mini_results = .mini_results %>%
    group_by(studyN, subject, condition) %>%
    summarize(
      model = m,
      totalNLL = sum(NLL)
    )
  NLL_df = bind_rows(NLL_df, .mini_results)
}
NLL_df = na.omit(NLL_df)
NLL_df$studyN = factor(NLL_df$studyN, levels = c(1,2), labels = c("Study 1", "Study 2"))

.plt_loss = ggplot(data = NLL_df[NLL_df$condition=="Loss",], aes(x = totalNLL)) +
  myPlot +
  geom_histogram(position = "identity", binwidth = 4, alpha = .7, fill = "red", color = "white") +
  labs(y = "Count in Losses", x = "Neg. LogLike") +
  facet_grid(cols = vars(studyN), rows = vars(model)) +
  coord_cartesian(expand=T)

.plt_gain = ggplot(data = NLL_df[NLL_df$condition=="Gain",], aes(x = totalNLL)) +
  myPlot +
  geom_histogram(position = "identity", binwidth = 4, alpha = .7, fill = "darkgreen", color = "white") +
  labs(y = "Count in Gains", x = "Neg. LogLike") +
  facet_grid(cols = vars(studyN), rows = vars(model)) +
  coord_cartesian(expand=T)

.plt = .plt_gain + .plt_loss
ggsave(file.path(.figdir, "RefDept-NLLs.pdf"), .plt, height = 8, width = 9)


####################################
# How best-fitting are our best-fitting models?
####################################

bestFit = NLL_df %>%
  group_by(studyN, subject, condition) %>%
  summarize(
    minNLL = min(totalNLL),
    maxNLL = max(totalNLL),
    rawDiff = maxNLL - minNLL,
    percentDiffFromMax = (maxNLL-minNLL)/maxNLL
  )
bestFit = bestFit[order(bestFit$subject, bestFit$condition),]
.plt = ggplot(data = bestFit, aes(x = minNLL, y = rawDiff)) +
  myPlot +
  geom_point() +
  labs(y = "Max - Min NLL", x = "Min NLL") +
  facet_grid(cols = vars(studyN), rows = vars(condition)) +
  coord_cartesian(expand=T)
ggsave(file.path(.figdir, "RefDept-NLLdiffs.pdf"), .plt, height = 4, width = 6)
