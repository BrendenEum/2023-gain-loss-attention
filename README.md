# Eum, Gonzalez, and Rangel (in progress)

A series of three studies that look at the influence of visual attention on
choices amongst negatively-valued options. The first study uses perceptual 
lotteries ("dots"), the second study uses numeric lotteries ("numeric"), and
the third study uses aversive food options ("food").

If you have questions, concerns, or just want to chat, feel free to reach out
to Brenden Eum at beum@caltech.edu!

## Order to run code

```
analysis/preprocessing/cleanDotsData.R
analysis/preprocessing/cleanNumericData.R
analysis/preprocessing/cleanFoodData.R
analysis/preprocessing/combineDatasets.R
analysis/preprocessing/droppedTrials.R
```

Now you should have 3 datasets in data/processed_data called ecfr.RData, ccfr.Rdata,
and jcfr.RData. These correspond to the exploratory, confirmatory, and joint datasets.
They combine data from all three studies, differentiated by the "dataset" variable.
There's also some text files with average dropped trials per subject in the
"analysis/output/text"" folder.

