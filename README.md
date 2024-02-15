# About

This is an effort to create a general template for most projects

# To resolve

- The minimal amount of library/package info

- Narrative overview of code and the order it is ought to be run in
    - Would a README be a good place to put that info? But one README per directory is unlikely to be enough

- What should the `run_all_analyses.R` script and its outputs look like?

- Different type of projects: e.g. theoretical/simulation based, meta-analyses

- Data version control
    - Do we want to use tools designed for ML https://neptune.ai/blog/best-data-version-control-tools
    - Or something that is more focused on research https://www.datalad.org/

- Linking files in raw_data to code/collection procedure that collected it in experiment
    - How about adding column to raw_data that contains at least the script name and preferably some sort of hash associated with the version experiment code script
    - What would this look like for the different methods we use e.g. Gorilla vs. Psychopy vs. Psychtoolbox etc.

# Resources

[Chapter on project management from open textbook on Experimental Methods](https://experimentology.io/13-management)  

[A practical guide for transparency in psychological science](https://psych-transparency-guide.uni-koeln.de/)

<<<<<<< Updated upstream
[The Practice of Reproducible Research: Case Studies and Lessons from the Data-Intensive Sciences](http://www.practicereproducibleresearch.org/)  
=======
```
analysis/preprocessing/get_list_of_subjects_qc_pass.R
analysis/preprocessing/cleanDotsData.R
analysis/preprocessing/cleanNumericData.R
analysis/preprocessing/combineDatasets.R
analysis/preprocessing/droppedTrials.R
```
>>>>>>> Stashed changes

[Stanford CORES: Open By Design](https://dsi-cores.github.io/OpenByDesign/README.html)  
    - Brief descriptions with links to many resources  

[NASA: Transform to Open Science](https://nasa.github.io/Transform-to-Open-Science-Book/About/About-Announcements.html)  

<<<<<<< Updated upstream
[Easing Into Open Science: A Gudie for Graduate Students and their Advisors](https://psyarxiv.com/vzjdp/)
    - Short paper with step by step guide  
=======
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

Fit the various versions of aDDM to the data. Converting cfr to aDDM data takes a little bit of time since I couldn't think of a clever way to do it, so I use a roundabout way with a bunch of for loops. Sue me.

Note that in fit_all_models.jl, you'll need to change the directory on line 15. It "cd"s into a folder specific to my computer.

- Input:
  - data/processed_data/{study}/{e,c,j}/expdata*.csv
  - data/processed_data/{study}/{e,c,j}/fixations*.csv

- Output:
  - analysis/outputs/temp/{study}_GainFit_{E,C,J}.csv
  - analysis/outputs/temp/{study}_LossFit_{E,C,J}.csv

```
analysis/helpers/aDDM/cfr_to_addmdata.R
analysis/helpers/aDDM/fit_all_models.jl
```

Look at model estimates and likelihoods.

- Input:
  - analysis/helpers/aDDM/get_estimates_likelihoods.R
  - analysis/outputs/temp/{study}_GainFit_{E,C,J}.csv
  - analysis/outputs/temp/{study}_LossFit_{E,C,J}.csv
  - analysis/outputs/temp/{study}_GainNLL_{E,C,J}.csv
  - analysis/outputs/temp/{study}_LossNLL_{E,C,J}.csv

- Output:
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

Simulate data with the estimates from the various aDDM.

- Input:
  - For parameter estimates
    - analysis/outputs/temp/{study}_{model}_GainEst_{e,c,j}.csv
    - analysis/outputs/temp/{study}_{model}_LossEst_{e,c,j}.csv
  - For out-of-sample fixation data
    - data/processed_data/{e,c,j}cfr.RData

- Output:
  - analysis/outputs/temp/{study}_SimGainData_{E,C,J}.Rdata
  - analysis/outputs/temp/{study}_SimLossData_{E,C,J}.Rdata
  - analysis/outputs/figures/{model}_SimChoice_{E,C,J}.pdf
  - analysis/outputs/figures/{model}_SimRT_{E,C,J}.pdf
  - analysis/outputs/figures/{model}_SimNetFixBias_{E,C,J}.pdf
  - analysis/outputs/figures/{model}_SimLastFixBias_{E,C,J}.pdf
  
```
analysis/helpers/aDDM/AddDDM_sims.R
analysis/helpers/aDDM/plot_AddDDM_sims.R
analysis/helpers/aDDM/GDaDDM_sims.R
analysis/helpers/aDDM/plot_GDaDDM_sims.R
```
>>>>>>> Stashed changes

[TIER: Teaching Integrity in Empirical Reasearch](https://www.projecttier.org/)
    - Specifically the [protocol](https://www.projecttier.org/tier-protocol/protocol-4-0/)  
    - Lots of teaching materials as well  
