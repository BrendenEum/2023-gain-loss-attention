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

### aDDM

Fit the various versions of aDDM to the data. Converting cfr to aDDM data takes a little bit of time since I couldn't think of a clever way to do it, so I use a roundabout way with a bunch of for loops. Sue me.

Input:
- /data/processed_data/{dataset}cfr.RData

Output:
- data/processed_data/{study}/{dataset}/expdata*.csv
- data/processed_data/{study}/{dataset}/fixations*.csv

```
analysis/helpers/aDDM/cfr_to_addmdata.R
```

Do some parameter recovery exercises with the new models you're proposing before you try fitting them to real data.
To do this, open up your terminal, navigate to your project folder, then type the code below. Note, this only works with Julia 1.10 or later.

```
julia --project=/Users/brenden/Toolboxes/ADDM.jl --threads=4
```

You also need to generate a grid of parameters to search through before doing any fitting:

```
analysis/helpers/aDDM/parameter_grids.R
```

After that, you can run your code by using `include()`.

```
include("parameter_recovery.jl")
```

Note that in fit_all_models.jl, you'll need to change the directory on line 15. It "cd"s into a folder specific to my computer.

- Input:
  - data/processed_data/{study}/{dataset}/expdata*.csv
  - data/processed_data/{study}/{dataset}/fixations*.csv

- Output:
  - analysis/outputs/temp/{study}_GainFit_{dataset}.csv
  - analysis/outputs/temp/{study}_LossFit_{dataset}.csv

```
analysis/helpers/aDDM/fit_all_models.jl
```

### Model comparison

Look at model estimates and likelihoods.

Input:
- analysis/helpers/aDDM/get_estimates_likelihoods.R
- analysis/outputs/temp/{study}_GainFit_{dataset}.csv
- analysis/outputs/temp/{study}_LossFit_{dataset}.csv
- analysis/outputs/temp/{study}_GainNLL_{dataset}.csv
- analysis/outputs/temp/{study}_LossNLL_{dataset}.csv

Output:
- analysis/outputs/tables/group_estimates.csv
- analysis/outputs/tables/{study}_group_estimates.csv
- analysis/outputs/tables/posterior_model_probabilities.pdf
- analysis/outputs/tables/individual_estimates_{model}.pdf

```
analysis/helpers/aDDM/group_estimates_table.R
analysis/helpers/aDDM/posterior_model_probabilities.R
analysis/helpers/aDDM/best_fitting_model_counts.R
analysis/helpers/aDDM/plot_individual_estimates_{model}.R
analysis/helpers/aDDM/ttest_individual_estimates.R
```

### Model simulations

Simulate data with the estimates from the various aDDM.

Input:
- For parameter estimates
  - analysis/outputs/temp/{study}_{model}_GainEst_{dataset}.csv
  - analysis/outputs/temp/{study}_{model}_LossEst_{dataset}.csv
- For out-of-sample fixation data
  - data/processed_data/{dataset}cfr.RData

Output:
- analysis/outputs/temp/{study}_SimGainData_{dataset}.Rdata
- analysis/outputs/temp/{study}_SimLossData_{dataset}.Rdata
- analysis/outputs/figures/{model}_SimChoice_{dataset}.pdf
- analysis/outputs/figures/{model}_SimRT_{dataset}.pdf
- analysis/outputs/figures/{model}_SimNetFixBias_{dataset}.pdf
- analysis/outputs/figures/{model}_SimLastFixBias_{dataset}.pdf
  
```
analysis/helpers/aDDM/AddDDM_sims.R
analysis/helpers/aDDM/plot_AddDDM_sims.R
analysis/helpers/aDDM/GDaDDM_sims.R
analysis/helpers/aDDM/plot_GDaDDM_sims.R
```