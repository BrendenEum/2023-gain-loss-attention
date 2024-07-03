library(tidyverse)
.colors = list(Gain="Green4", Loss="Red3")
.figdir = file.path("../../outputs/figures")
.optdir = file.path("../plot_options/")
source(file.path(.optdir, "GainLossColorPalette.R"))
source(file.path(.optdir, "MyPlotOptions.R"))

# Data
edGain = read.csv("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/numeric/e/expdataGain_train.csv")
edLoss = read.csv("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/numeric/e/expdataLoss_train.csv")

# Adjust distribution of loss values to match distribution of gain values. This is because gain condition simulations (without adjustment) look more like observed behavior.
adjustment = -5

# Gain RD values
edGain$rdvL = edGain$LProb * (edGain$LAmt-edGain$minOutcome) + (1-edGain$LProb) * (0 - edGain$minOutcome)
edGain$rdvR = edGain$RProb* (edGain$RAmt-edGain$minOutcome) + (1-edGain$RProb) * (0 - edGain$minOutcome)

# Loss RD Values
edLoss$rdvL = edLoss$LProb * (edLoss$LAmt-edLoss$minOutcome + adjustment) + (1-edLoss$LProb) * (0 - edLoss$minOutcome + adjustment)
edLoss$rdvR = edLoss$RProb * (edLoss$RAmt-edLoss$minOutcome + adjustment) + (1-edLoss$RProb) * (0 - edLoss$minOutcome + adjustment)

# Add condition and combine
edGain$condition = "Gain"
edLoss$condition = "Loss"
ed = bind_rows(edGain, edLoss)

# Plot left and right RD values and make sure they align. Otherwise, simulations will come out with mismatched behavior in gains and losses.
ggplot(data=ed) +
  myPlot +
  
  geom_histogram(aes(rdvR, fill = condition), alpha = .5) +
  geom_freqpoly(aes(rdvL, color = condition), linewidth = 2) +
  
  theme_classic()

