# Eum, Gonzalez, and Rangel (in progress)

A series of three studies that look at the influence of visual attention on choices amongst negatively-valued options. The first study uses perceptual lotteries ("dots"), the second study uses numeric lotteries ("numeric"), and the third study uses aversive food options ("food").

Directories in this readme are assuming the main project folder (containing all the other project subfolders) is the working directory. "{x,y}" indicate that each element of the set should be included separately. "{study}" means dots, numeric, or food study.  "*" indicate wildcards, so it could be anything in that space. If an input or output is a folder (not a file), then it means that whole folder was used in the input process.

If you have questions, concerns, or just want to chat, feel free to reach out to Brenden Eum at beum@caltech.edu!

## Order to run code

Generate example runs of the aDDM, separately for gains and losses.

- Input:

- Output:
  - analysis/outputs/figures/aDDM_example_gain.pdf
  - analysis/outputs/figures/aDDM_example_loss.pdf


```
analysis/aDDM/aDDM_example_gain.R
analysis/aDDM/aDDM_example_loss.R
```

Generate 3 datasets in data/processed_data called ecfr.RData, ccfr.Rdata, and jcfr.RData. These correspond to the exploratory, confirmatory, and joint datasets. They combine data from all three studies, differentiated by the "dataset" variable. Also calculates some info about missing trials.

- Input:
  - data/raw_data/good
  - experiment/{study}/recruitment
  
- Output:
  - data/processed_data
  - analysis/outputs/temp/*_subject_list.csv
  - analysis/outputs/text/{study}_averageDroppedTrials.txt

```
analysis/preprocessing/get_list_of_subjects_qc_pass.R
analysis/preprocessing/cleanDotsData.R
analysis/preprocessing/cleanNumericData.R
analysis/preprocessing/cleanFoodData.R
analysis/preprocessing/combineDatasets.R
analysis/preprocessing/droppedTrials.R
```

Create text files in analysis/output/text with statistics on participant demographics: age, gender, race.

- Input:
  - experiment/{study}/recruitment

- Output:
  - analysis/outputs/text/{study}_{age,gender,race}_*.txt

```
analysis/helpers/participants/demographics.R
```

These are a huge scripts. They generate ALL of the figures for Basic Psychometrics, Fixation Process, and Choice Biases for the three studies, separately for the exploratory, confirmatory, and joint datasets. Those are saved in analysis/outputs/figures. Associated regressions for the figures are also run, with the models stored in temporary .rds files in the analysis/output/temp folder.

* BE: Once you've collected confirmatory set, you can uncomment the c and j datasets from the for loop in the model_free_anaysis_figures and regressions scripts (roughly line 21).

* BE: Figure out a way to save the results of the regressions to publishable tables in the analysis/outputs/tables folder.

- Input:
  - data/processed_data

- Output:
  - analysis/outputs/figures/{study}_{BasicPsychometrics,FixationProcess,ChoiceBiases}_{E,C,J}.pdf
  - analysis/outputs/text
  - analysis/outputs/temp/regressions/{study}_{BasicPsychometrics,FixationProcess,ChoiceBiases}_{E,C,J}.rds

```
analysis/helpers/model_free_analysis/model_free_analysis_figures.R
analysis/helpers/model_free_analysis/model_free_analysis_regressions.R
```

Generate the 3-panel figures to look at the influence of fixation cross location on choice. This gives us a manipulation of attention that allows us to look at the causal effects of attention on choice. We don't label with the study since the fixation cross manipulation was only for the numeric study.

- Input:
  - data/processed_data/numeric/{e,c,j}/cfr_numeric.RData

- Output:
  - analysis/outputs/figures/fixCross_*.pdf

```
analysis/helpers/fix_cross_analysis/fix_cross_analysis_figures.R
```



