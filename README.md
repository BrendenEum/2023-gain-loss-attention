# Eum, Gonzalez, and Rangel (in progress)

A series of three studies that look at the influence of visual attention on choices amongst negatively-valued options. The first study uses perceptual lotteries ("dots"), the second study uses numeric lotteries ("numeric"), and the third study uses aversive food options ("food").

If you have questions, concerns, or just want to chat, feel free to reach out to Brenden Eum at beum@caltech.edu!

## Order to run code

```
analysis/preprocessing/get_list_of_subjects_qc_pass.R
analysis/preprocessing/cleanDotsData.R
analysis/preprocessing/cleanNumericData.R
analysis/preprocessing/cleanFoodData.R
analysis/preprocessing/combineDatasets.R
analysis/preprocessing/droppedTrials.R
```

Now you should have 3 datasets in data/processed_data called ecfr.RData, ccfr.Rdata, and jcfr.RData. These correspond to the exploratory, confirmatory, and joint datasets. They combine data from all three studies, differentiated by the "dataset" variable. There's also some text files with average dropped trials per subject in the "analysis/output/text"" folder.

```
analysis/helpers/participants/demographics.R
```

Now there should be text files in analysis/output/text with statistics on participant demographics: age, gender, race.

```
analysis/helpers/model_free_analysis/model_free_analysis_figures.R
```
* BE: Once you've collected confirmatory set, you can uncomment the c and j datasets from the for loop in the model_free_anaysis_figures script (roughly line 21).

These are a huge scripts. They generate ALL of the figures for Basic Psychometrics, Fixation Process, and Choice Biases for the three studies, separately for the exploratory, confirmatory, and joint datasets. Those are saved in analysis/output/figures.