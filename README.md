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

## Parameter recovery

In previous iterations of code, I ran dozens of parameter recovery (PR) tests on simplified versions of models in this paper. For instance, the original aDDM, the additive aDDM, range-normalized aDDM, and so on. If you want to see that stuff, check out an older version of the main branch on github (3/12/24). That earlier analysis has helped me narrow down the set of models I want to test without the massive computation time that the next set of models will require. 

Now, I will be doing parameter recovery exercises for the 3 model listed below. The idea is to generate data using one model, but go through the fitting pipeline with all three models, and see if the model with the highest posterior probability is the one that generated the data. 
1.  standard aDDM with collapsing bounds (drift, noise, multiplicative attentional bias, starting point bias, collapse rate)
2.  additive aDDM with collapsing bounds (drift, noise, additive attentional bias, starting point bias, collapse rate)
3. reference-dependent aDDM with collapsing bounds (drift, noise, multiplicative attentional bias, starting point bias, collapse rate, reference point)

The range of values that I think are reasonable for each parameter is below:
- drift: $d \in (.001, .009)$
- noise: $s \in (.01, .09)$
- mult. attn. bias: $\theta \in \{(0,1), (1,2)\}$ depending on the model and condition
- add. attn. bias: $\eta \in (0, .04)$ depending on the model
- start. pt. bias: $b \in (-.5, .5)$
- collapse rate: $\lambda \in (0, .004)$
- reference-point: $r \in \{0, 1, -6\}$ depending on the model and condition

GEN: Based on these ranges, I'll randomly select from 5 possible values (approx close to min, 25%, median, 75%, max) per parameter to generate data. Note that when $\theta=1$, $r$ in the reference-dependent aDDM is not identified, e.g. $\mu = d([V_L-r] - \theta [V_R-r])$. Because of this, I will avoid $\theta=1$ in my PR exercises. I also assume non-decision time is fixed at 100 ms. Per model and condition, I will simulate 20 datasets using randomly drawn parameters. I chose 20 because it is a multiple of the 4 performance cores I have on my laptop.
- drift: $d \in \{.003, .005, .007, .009\}$
- noise: $s \in \{.02, .04, .06, .08\}$
- mult. attn. bias: $\theta \in \{0, .25, .5, .75, .9\}$ or $\theta \in \{1.1, 1.25, 1.5, 1.75, 2\}$ 
- add. attn. bias: $\eta \in \{0, .01, .02, .03, .04\}$
- start. pt. bias: $b \in \{-.2, -.1, 0, .1, .2\}$
- collapse rate: $\lambda \in \{0, .001, .002, .003, .004\}$
- reference-point: $r=0$, $r=1$, or $r=-6$

FIT: I'm going to try and fit the simulated data (GEN) using the same grid that was sampled from to generated the data. For every trial, this is calculating the likelihood for $5^5=3125$ possible parameter combinations.
- drift: $d \in \{.003, .005, .007, .009\}$
- noise: $s \in \{.02, .04, .06, .08\}$
- mult. attn. bias: $\theta \in \{0, .25, .5, .75, .9\}$ or $\theta \in \{1.1, 1.25, 1.5, 1.75, 2\}$ 
- add. attn. bias: $\eta \in \{0, .01, .02, .03, .04\}$
- start. pt. bias: $b \in \{-.2, -.1, 0, .1, .2\}$
- collapse rate: $\lambda \in \{0, .001, .002, .003, .004\}$
- reference-point: $r=0$, $r=1$, or $r=-6$

Ok, first things first, we need to generate the grid of possible parameter values that we are going to test.

```
analysis/helpers/parameter_recovery/model_parameter_grids.R
analysis/helpers/parameter_recovery/make_parameter_grids.jl
```

To do this, open a shell and start julia in an ADDM environment. I like to start it with 4 threads. Multi-threading will significantly speed up the speed at which this gets done.

```
julia --project=/Users/brenden/Toolboxes/ADDM.jl --threads=4
```

In Julia, run the following code to do all the parameter recovery exercises.

```
include("parameter_recovery.jl")
```

## DELETE Parameter recovery exercises

Do some parameter recovery exercises with the new models you're proposing before you try fitting them to real data.
To do this, open up your terminal, navigate to your project folder, then type the code below. Note, this only works with Julia 1.10 or later.



You also need to generate a grid of parameters to search through before doing any fitting:

```
analysis/helpers/parameter_recovery/parameter_grids.R
```

After that, you can run your code by using `include()`.

```
include("simglemodel_iterative_parameter_recovery.jl")
```

To check the results of your parameter recovery, run:

- Input:
  - analysis/helpers/parameter_recovery/expdata{Gain,Loss}.csv from the numeric study.
  - analysis/helpers/parameter_recovery/fixations{Gain,Loss}.csv from the numeric study.
  - analysis/helpers/parameter_recovery/parameter_grids/*.csv with grids for each model

- Output:
  - analysis/outputs/temp/parameter_recovery/{model_acronym}/*_fits_*.csv for parameter combos and their NLL.
  - analysis/outputs/temp/parameter_recovery/{model_acronym}/*_model_*.txt for true data generating processes.
  - analysis/outputs/temp/parameter_recovery/{model_acronym}/*_summary_*.txt for details about best fitting estimates.

```
analysis/helpers/parameter_recovery/check_parameter_recovery.R
```

You'll need to change the "data_generating_process" variable to the acronym that satisfies the data generating model. For instance, "dst" is aDDM with drift, sigma, theta. "dstb" is with the additional parameter "starting point bias". The full length acronym is "dstbelmr" for drift, sigma, theta, bias, eta, lambda, nonDecisionTime, minValue, and range. A summary .txt file is stored with the full fitted outputs and details about the data generating processes.

The results so far are for checking if models can recover original parameters when they are also the original data generating process. What about comparing pairs of models on data generated from only one of those models?

```
include("pairmodel_iterative_parameter_recovery.jl")
```


## DELETE Practice model comparison

Let's figure out how to get model posteriors and parameter posteriors for two subjects before proceeding.

Start Julia with 4 threads and the aDDM environment.

```
julia --project=/Users/brenden/Toolboxes/ADDM.jl --threads=4
```

Then run the practice script.

- Input:
  - testexpdataLoss.csv
  - testfixationsLoss.csv

Output:
  - model_posteriors
  - parameter_posteriors

```
include("practice_model_comparison.jl")
```




## Fit real data

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