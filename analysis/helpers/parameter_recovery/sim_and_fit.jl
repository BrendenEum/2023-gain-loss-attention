function sim_and_fit(model_list, condition, param_grid, free_params, fixed_params; timeStep=10.0, simCutoff=20000, approxStateStep=0.01, verbose=true)

    # Filenames
    if (condition=="Gain")
        expdata = "expdataGain.csv";
        fixdata = "fixationsGain.csv";
    elseif (condition=="Loss")
        expdata = "expdataLoss.csv";
        fixdata = "fixationsLoss.csv";
    end
    outdir = "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp/parameter_recovery/"*free_params*"/";
    mkpath(outdir);

    # Get stimuli
    data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);
    nTrials = 81;
    MyStims = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);

    # Get fixation properties
    MyFixationData = ADDM.process_fixations(data, fixDistType="simple");

    # Simulate using model container and fit simulated data
    Threads.@threads for m in 1:length(model_list)

        # progress
        println("Thread ", Threads.threadid(), ": Model $(m)")
        flush(stdout)

        ############################### Simulate data
        MyModel = model_list[m];
        MyArgs = (timeStep = timeStep, cutOff = simCutoff, fixationData = MyFixationData);
        SimData = ADDM.simulate_data(MyModel, MyStims, custom_aDDM_simulator, MyArgs);

        ############################### Fit simulated data

        my_likelihood_args = (timeStep = timeStep, approxStateStep = approxStateStep);

        best_pars, all_nll_df, trial_posteriors = ADDM.grid_search(SimData, param_grid, custom_aDDM_likelihood, fixed_params, likelihood_args=my_likelihood_args, return_model_posteriors=true; verbose=verbose, threadNum=Threads.threadid());

        sort!(all_nll_df, [:nll])

        # Record data generating model and output
        write(outdir*condition*"_model_$(m).txt", string(MyModel)); 
        CSV.write(outdir*condition*"_fit_$(m).csv", all_nll_df);
        CSV.write(outdir*condition*"_trialposteriors_$(m).csv", trial_posteriors);

        ############################### Model and Parameter Posteriors

        # Model posteriors.
        nTrials = length(SimData);
        model_posteriors = Dict(zip(keys(trial_posteriors), [x[nTrials] for x in values(trial_posteriors)]));
        model_posteriors_df = DataFrame();
        for (k, v) in param_grid
            cur_row = DataFrame([v])
            cur_row.posterior = [model_posteriors[k]]
            model_posteriors_df = vcat(model_posteriors_df, cur_row, cols=:union)
        end
        CSV.write(outdir*condition*"_modelposteriors_$(m).csv", model_posteriors_df)

        # Parameter posteriors.
        param_posteriors = ADDM.marginal_posteriors(param_grid, model_posteriors)

        # Store.
        for paramIndex in 1:length(param_posteriors)
            param = names(param_posteriors[paramIndex])[1]
            CSV.write(outdir*condition*"_$(param)_posterior.csv", param_posteriors[paramIndex])
        end

    end
end