##########################
# Gain
##########################
condition = "Gain"               # ! ! !
println("= " * condition * " =")
flush(stdout)
Random.seed!(seed)
param_grid = param_grid_Gain;               # ! ! !
expdata = "../../../data/processed_data/numeric/e/expdata"*condition*".csv";
fixdata = "../../../data/processed_data/numeric/e/fixations"*condition*".csv";
study2 = ADDM.load_data_from_csv(expdata, fixdata);

Threads.@threads for k in collect(keys(study2))

    # Progress.
    println("Participant " * k)
    flush(stdout)
    
    # Subset the data by subject.
    cur_subj_data = study2[k]

    # Fit the model via grid search.
    subj_best_pars, subj_nll_df, subj_trial_posteriors, subj_trial_likelihoods = ADDM.grid_search(
        cur_subj_data, param_grid, nothing, fixed_params, likelihood_args=my_likelihood_args; 
        return_model_posteriors=true, 
        return_trial_likelihoods=true,
        verbose=verbose, threadNum=Threads.threadid()
    );
    sort!(subj_nll_df, [:nll])
    CSV.write(outdir * condition * "_nll_$(k).csv", subj_nll_df)
    CSV.write(outdir * condition * "_trialPosteriors_$(k).csv", subj_trial_posteriors)
    CSV.write(outdir * condition * "_trialLikelihoods_$(k).csv", subj_trial_likelihoods)
    
    # Get model posteriors.
    nTrials = length(study2[k]);
    subj_model_posteriors = Dict(zip(keys(subj_trial_posteriors), [x[nTrials] for x in values(subj_trial_posteriors)]));
    subj_model_posteriors_df = DataFrame();
    for (k, v) in param_grid
        cur_row = DataFrame([v])
        cur_row.posterior = [subj_model_posteriors[k]]
        subj_model_posteriors_df = vcat(subj_model_posteriors_df, cur_row, cols=:union)
    end
    CSV.write(outdir * condition * "_modelPosteriors_$(k).csv", subj_model_posteriors_df)

    # Do generating process comparison.
    gdf = groupby(subj_model_posteriors_df, :likelihood_fn);
    subj_model_comparison = combine(gdf, :posterior => sum)
    CSV.write(outdir * condition * "_modelComparison_$(k).csv", subj_model_comparison)
  
end;

##########################
# Loss
##########################
condition = "Loss"               # ! ! !
println("= " * condition * " =")
flush(stdout)
Random.seed!(seed)
param_grid = param_grid_Loss;               # ! ! !
expdata = "../../../data/processed_data/numeric/e/expdata"*condition*".csv";
fixdata = "../../../data/processed_data/numeric/e/fixations"*condition*".csv";
study2 = ADDM.load_data_from_csv(expdata, fixdata);

Threads.@threads for k in collect(keys(study2))

    println("Participant " * k)
    flush(stdout)
    
    # Subset the data by subject.
    cur_subj_data = study2[k]

    # Fit the model via grid search.
    subj_best_pars, subj_nll_df, subj_trial_posteriors, subj_trial_likelihoods = ADDM.grid_search(
        cur_subj_data, param_grid, nothing, fixed_params, likelihood_args=my_likelihood_args; 
        return_model_posteriors=true, 
        return_trial_likelihoods=true,
        verbose=verbose, threadNum=Threads.threadid()
    );
    sort!(subj_nll_df, [:nll])
    CSV.write(outdir * condition * "_nll_$(k).csv", subj_nll_df)
    CSV.write(outdir * condition * "_trialPosteriors_$(k).csv", subj_trial_posteriors)
    CSV.write(outdir * condition * "_trialLikelihoods_$(k).csv", subj_trial_likelihoods)
    
    # Get model posteriors.
    nTrials = length(study2[k]);
    subj_model_posteriors = Dict(zip(keys(subj_trial_posteriors), [x[nTrials] for x in values(subj_trial_posteriors)]));
    subj_model_posteriors_df = DataFrame();
    for (k, v) in param_grid
        cur_row = DataFrame([v])
        cur_row.posterior = [subj_model_posteriors[k]]
        subj_model_posteriors_df = vcat(subj_model_posteriors_df, cur_row, cols=:union)
    end
    CSV.write(outdir * condition * "_modelPosteriors_$(k).csv", subj_model_posteriors_df)

    # Do generating process comparison.
    gdf = groupby(subj_model_posteriors_df, :likelihood_fn);
    subj_model_comparison = combine(gdf, :posterior => sum)
    CSV.write(outdir * condition * "_modelComparison_$(k).csv", subj_model_comparison)
  
end;