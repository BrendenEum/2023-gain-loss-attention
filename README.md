# Attention in Aversive Choice
## Code Author: Brenden Eum (2024)

This is the README file for the entire project. As long as you have the raw data and all the scripts in the /analysis/helpers/ subfolders, this will generate all the analyses for the paper.

Some file names contain text in curly brackets. These are meant to be placeholders. {study} refers to Study 1 (dots) or Study 2 (numeric). {dataset} refers to exploratory, confirmatory, or joint datasets (E,C,J).

### Convert raw data to dataset.

Input:
- /data/raw_data/good/*

Output:
- /data/processed_data/{dataset}cfr.RData

```
analysis/preprocessing/get_list_of_subjects_qc_pass.R
analysis/preprocessing/cleanDotsData.R
analysis/preprocessing/cleanNumericData.R
analysis/preprocessing/combineDatasets.R
analysis/preprocessing/droppedTrials.R
```

### Subject demographics

Input:
- '/experiment/{study}/recruitment/participant demographics - final dataset.xlsx'

Output:
- analysis/outputs/text/{study}_{age,gender,race}_*.txt

```
analysis/helpers/participants/demographics.R
```

### Model free analysis

These are a huge scripts. They generate ALL of the figures for Basic Psychometrics, Fixation Process, and Choice Biases for the three studies, separately for the exploratory, confirmatory, and joint datasets. Those are saved in analysis/outputs/figures. Associated regressions for the figures are also run, with the models stored in temporary .rds files in the analysis/output/temp folder.

* BE: Once you've collected confirmatory set, you can uncomment the c and j datasets from the for loop in the model_free_anaysis_figures and regressions scripts (roughly line 21).

* BE: Figure out a way to save the results of the regressions to publishable tables in the analysis/outputs/tables folder.

Input:
- /data/processed_data/

Output:
- /analysis/outputs/figures/{study}_{BasicPsychometrics,FixationProcess,ChoiceBiases}_{dataset}.pdf
- /analysis/outputs/text/
- /analysis/outputs/temp/regressions/{study}_{BasicPsychometrics,FixationProcess,ChoiceBiases}_{dataset}.rds

```
analysis/helpers/model_free_analysis/model_free_analysis_figures.R
analysis/helpers/model_free_analysis/model_free_analysis_regressions.R
```

### Fixation cross analysis

Generate the 3-panel figures to look at the influence of fixation cross location on choice. This gives us a manipulation of attention that allows us to look at the causal effects of attention on choice. We don't label with the study since the fixation cross manipulation was only for the numeric study.

Input:
- /data/processed_data/numeric/{dataset}/cfr_numeric.RData

Output:
- /analysis/outputs/figures/fixCross_*.pdf

```
analysis/helpers/fix_cross_analysis/fix_cross_analysis_figures.R
```

# aDDM

## What versions of the aDDM can predict the choice biases that we observe?

Input:
- analysis/helpers/aDDM_predictions/aDDM_simulate_trial.R

Output:
- analysis/outputs/figures/sim_{model}_ChoiceBiases_{Net,First,Last}.pdf

```
analysis/helpers/aDDM_predictions/plot_{model}_attnBias+&+rt(ov)_predictions.R
```

## Parameter recovery

```
analysis/helpers/parameter_recovery/make_parameter_grid.R
```

When that's done, we open a shell and start julia in an ADDM environment. I like to start it with 4 threads. Multi-threading will significantly speed up the speed at which this gets done.

```
julia --project=/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_fitting/ADDM.jl --threads=4
```

In Julia, run the following code to do all the parameter recovery exercises.

```
include("{model}_simulate_{condition}.jl")
include("{model}_fit_{condition}.jl")
```

Output:
- analysis/helpers/parameter_recovery/results_*/
- analysis/helpers/parameter_recovery/parameter_recovery_{nTrials}/*.pdf

```
analysis/helpers/parameter_recovery/model_recovery_analysis.R
analysis/helpers/parameter_recovery/parameter_recovery_analysis.R
```

## Check reference-dependence models

Which reference point rules best fit each subject? Fit prospect theory first, then prospect theory estimates with subject-specific reference point rule to generate E[V] signals to feed into aDDM.

Input:
- /data/processed_data/{dataset}cfr.RData

Output:
- /analysis/outputs/figures/ProspectTheory_*.pdf
- /analysis/outputs/temp/ref_dept/*.RData

```
analysis/reference-dependence/FitAndPlotRefDeptModels.R
analysis/reference-dependence/CheckNLLs.R
analysis/reference-dependence/CheckRDValues.R
```

## Convert data

Fit the various versions of aDDM to the data. Converting cfr to aDDM data takes a little bit of time since I couldn't think of a clever way to do it, so I use a roundabout way with a bunch of for loops. Sue me.

Input:
- /data/processed_data/{dataset}cfr.RData

Output:
- data/processed_data/{study}/{dataset}/expdata*.csv
- data/processed_data/{study}/{dataset}/fixations*.csv

```
analysis/helpers/aDDM/cfr_to_addmdata.R
```

## Fit real data

Note that in each script, you'll need to change the data directory. It "cd"s into a folder specific to my computer.

- Input:
  - analysis/helpers/aDDM_fitting/data/study*_expdata.csv
  - analysis/helpers/aDDM_fitting/data/study*_fixations.csv

- Output:
  - A bunch of files related to model fitting. Each file ends with a number, representing participant number. 
  - modelComparison: posterior model probabilites for each model (summing over all posterior likelihoods for each parameter combination within a model)
  - modelPosteriors: the posterior probability of each parameter combination after going thru all trials
  - nll: negative log likelihoods after going thru all trials
  - trialPosteriors: posterior probability after each trial

```
analysis/helpers/model_fitting/fit_Study{study}{condition}.jl
```

### Model comparison

Look at model estimates and likelihoods.

Input:
- analysis/outputs/temp/model_fitting/{dataset}/{study}/{condition}_modelComparison_{subjectNumber}.csv
- analysis/outputs/temp/model_fitting/{dataset}/{study}/{condition}_modelPosteriors_{subjectNumber}.csv

Output:
- analysis/outputs/figures/aDDM_modelComparison.csv
- analysis/outputs/temp/model_free_model_comparison/{regression_test}.rds

```
analysis/helpers/aDDM_analysis/posterior_model_probabilities.R
analysis/helpers/aDDM_analysis/model_comparison_regression_tests.R
```

### RaDDM analysis

Look at individual-level parameters and predictive accuracy of the RaDDM.

Input:
- analysis/outputs/temp/model_fitting/{dataset}/{study}/{condition}_modelPosteriors_{subjectNumber}.csv

Output:
- analysis/outputs/figures/RaDDM_IndividualEstimates.pdf

```
analysis/helpers/aDDM_analysis/RaDDM_IndividualEstimates.R
analysis/helpers/aDDM_analysis/RaDDM_GroupEstimates.R
analysis/helpers/aDDM_analysis/RaDDM_ParameterCorrelations.R
analysis/helpers/aDDM_analysis/subjects_using_same_model.R
```

### RaDDM out-of-sample simulations

Simulate data with the estimates from the RaDDM.

Input:
- 

Output:
- 
  
```
analysis/helpers/aDDM_analysis/simulate_out_of_sample.jl
analysis/helpers/aDDM_analysis/plot_out_of_sample.Rmd
```