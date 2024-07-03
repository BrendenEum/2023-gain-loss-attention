# Attention in Aversive Choice: Code Package
### Author: Brenden Eum (2024)

This is the README file for the entire project. Following this should allow you to run all the analyses in the paper and supplementary. 

Each section starts with the subfolder in the analysis folder that contains all the scripts. This is followed by a description of any input files (e.g. data files) and output files (e.g. figures). Finally, the scripts that should be run for analyses are included in the code blocks IN the ORDER that they should be run.

I've included some additional code that I think you might find interesting or useful, but that isn't necessary to run the code package. I'll mark these with a [NOT NECESSARY] stamp.

Some file names contain text in curly brackets. These are meant to be placeholders. 
- {study} refers to Study 1 (dots) or Study 2 (numeric). 
- {dataset} refers to exploratory, confirmatory, or joint datasets (E,C,J).
- {model} refers to aDDM, RaDDM, AddDDM, and others. See paper for more deets.
- {condition} refers to Gain or Loss.

## Convert raw data to dataset. [NOT NECESSARY]

Analysis Folder: preprocessing

Input: (Not including this in the code package. You can request this by emailing beum@caltech.edu or rangel@hss.caltech.edu. By the time you read this, I'll probably have moved universities, so beum might not work. As far as I'm aware, there's only one Brenden Eum in the world, so it shouldn't be hard to look me up!)
- /data/raw_data/good/*

Output:
- /data/processed_data/datasets/{dataset}cfr.RData

```
cleanDotsData.R
cleanNumericData.R
combineDatasets.R
```

## Subject demographics. [NOT NECESSARY] 

Analysis Folder: participants

Code and details available upon request. Easier this than to risk dealing with the IRB. 

## Model free analyses.

Analysis Folder: model_free_analysis

This folder contains scripts that generate all the figures and regressions for Basic Psychometrics, Fixation Process, Choice Biases, and Additional Fixation Properties. They do these separately for the two studies and separately for the exploratory, confirmatory, and joint datasets. Associated regressions for the figures are stored as temporary .rds files in the analysis/output/temp folder.

Input:
- /data/processed_data/datasets/{dataset}cfr.RData

Output:
- /analysis/outputs/figures/{BasicPsychometrics,FixationProcess,ChoiceBiases}_{dataset}.pdf
- /analysis/outputs/temp/regressions/{study}_{BasicPsychometrics,FixationProcess,ChoiceBiases,AdditionalFixProp}_{dataset}.rds

```
model_free_analysis_figures.R
model_free_analysis_regressions.R
```

## Fixation cross analysis.

Analysis Folder: fix_cross_analysis

Generate 3-panel figures to look at the influence of fixation cross location (Left, Middle, Right) on choice in Study 2 Joint Dataset. This gives us a manipulation of attention that allows us to look at the causal effects of attention on choice. The code allows for subsetting by dataset (E,C,J), but the final analyses displayed the paper are just for joint.

Input:
- /data/processed_data/numeric/j/cfr_numeric.RData

Output:
- /analysis/outputs/figures/fixCross_{BasicPsychometrics,FixationProcess,ChoiceBiases,AdditionalFixProp}_J.pdf

```
fix_cross_analysis_figures.R
```

## What versions of the aDDM can predict the attentional choice biases that we observe?

Analysis Folder: aDDM_predictions

Input:

Output:
- analysis/outputs/figures/sim_{model}_ChoiceBiases_{Net,First,Last}.pdf

```
make_SimIndividualEstimates.R
simulate_predictions.jl
plot_predictions_{model}.R
```

## Are we able to distinguish the RaDDM from the AddDDM from data generating using one of these models?

Analysis Folder: parameter_recovery

In model_recovery_analysis.R, you'll need to change the datetime in pr_trials to match your most recent run.

Input:

Output:
- analysis/helpers/parameter_recovery/results_{model}_{condition}/{datetime}/*
- analysis/outputs/figures/ParameterRecovery_ModelRecovery.pdf

```
analysis/helpers/parameter_recovery/make_parameter_grid.R
analysis/helpers/parameter_recovery/{model}_simulate_{condition}.R
analysis/helpers/parameter_recovery/{model}_fit_{condition}.R
analysis/helpers/parameter_recovery/model_recovery_analysis.R
```

## Convert data [NOT NECESSARY]

Converting cfr to aDDM data takes a little bit of time since I couldn't think of a clever way to do it, so I use a roundabout way with a bunch of for loops. It's just making the fixation data that takes a while. Start the code, go grab a cup of coffee, enjoy a movie, and come back.

The code only runs for the exploratory and confirmatory datasets. Once those finish running, just copy and paste the respective exdata{condition}_{test,train}.csv and fixations{condition}_{test,train}.csv together and put those new files in 'data/processed_data/{study}/j/'.

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