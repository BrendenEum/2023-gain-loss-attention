function sim_and_fit(model_list, condition, simulator_fn, param_grid, fixed_params; timeStep=10.0, simCutoff=20000, approxStateStep=0.01, verbose=true)

    Threads.@threads for m in 1:length(model_list)

        # progress
        println("Thread ", Threads.threadid(), ": Model $(m)")
        flush(stdout)
        
        ############################### Simulate data
        
        if (condition=="Gain")
            MyStims = Stims_Gain;
            MyFixationData = Fixations_Gain;
        elseif (condition=="Loss")
            MyStims = Stims_Loss;
            MyFixationData = Fixations_Loss;
        end
        MyModel = model_list[m];
        MyArgs = (timeStep = timeStep, cutOff = simCutoff, fixationData = MyFixationData);
        global  SimData = ADDM.simulate_data(MyModel, MyStims, simulator_fn, MyArgs);

        ############################### Fit simulated data
        
        my_likelihood_args = (timeStep = timeStep, approxStateStep = approxStateStep);
    
        best_pars, all_nll_df, trial_posteriors = ADDM.grid_search(SimData, param_grid, nothing, fixed_params, likelihood_args=my_likelihood_args, return_model_posteriors=true; verbose=verbose, threadNum=Threads.threadid());
    
        sort!(all_nll_df, [:nll])
    
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
        
        # Model comparison
        gdf = groupby(model_posteriors_df, :likelihood_fn);
        combdf = combine(gdf, :posterior => sum)
        
    
    end

end