function sim_and_fit(model_list, condition, param_grid_csv, free_params, fixed_params; timeStep=10.0, simCutoff=20000, approxStateStep=0.01, verbose=true)

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

        # Simulate data
        MyModel = model_list[m];
        MyArgs = (timeStep = timeStep, cutOff = simCutoff, fixationData = MyFixationData);
        SimData = ADDM.simulate_data(MyModel, MyStims, custom_aDDM_simulator, MyArgs);

        # Fit the simulated data with the modified aDDM that nests all models
        fn = param_grid_csv;
        tmp = DataFrame(CSV.File(fn, delim=","));
        param_grid = Dict(pairs(NamedTuple.(eachrow(tmp))));

        my_likelihood_args = (timeStep = timeStep, approxStateStep = approxStateStep);

        best_pars, all_nll_df = ADDM.grid_search(SimData, param_grid, custom_aDDM_likelihood, fixed_params, likelihood_args=my_likelihood_args; verbose=verbose, threadNum=Threads.threadid());

        sort!(all_nll_df, [:nll])

        # Record data generating model and output
        write(outdir*condition*"_"*"model_$(m).txt", string(MyModel)); 
        CSV.write(outdir*condition*"_"*"fit_$(m).csv", all_nll_df);
    end
end