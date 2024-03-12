# Author: Brenden Eum (2024)
# If running this in vscode locally, you need to open up a shell REPL, run 'julia --project=<toolboxdir>', and run 'include("<yourscript.jl>")'. This opens julia with the ADDM environment and runs your code.

#############
# Preamble
#############

using ADDM
using CSV
using DataFrames
using Random, Distributions, StatsBase
using StatsPlots
using Base.Threads
outdir = "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp/model_fits/";
mkpath(outdir);

#############
# Get data
#############

data = ADDM.load_data_from_csv("testexpdataLoss.csv", "testfixationsLoss.csv")

#############
# Get likelihood function and grid
#############

include("custom_aDDM_likelihood.jl")
tmp = DataFrame(CSV.File("param_grid.csv", delim=","))
param_grid = Dict(pairs(NamedTuple.(eachrow(tmp))))
fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :η=>0)

#############
# Common settings
#############

my_likelihood_args = (timeStep = 10.0, approxStateStep = 0.01);

#############
# Fit numeric study
#############

Nsubjects = length(collect(keys(data)))
Threads.@threads for i in 1:Nsubjects # Threading doesn't work over keys. Needs to be iterable like subject index.

    # Split the data and fit for each subject.
    s = collect(keys(data))[i];
    cur_subj_data = data[s];
    subj_best_pars, subj_nll_df, trial_posteriors = ADDM.grid_search(
        cur_subj_data, param_grid, custom_aDDM_likelihood, 
        fixed_params,
        likelihood_args=my_likelihood_args,
        return_model_posteriors = true;
        verbose = true,
        threadNum = Threads.threadid()
    );

    # Model posteriors.
    nTrials = length(cur_subj_data);
    model_posteriors = Dict(zip(keys(trial_posteriors), [x[nTrials] for x in values(trial_posteriors)]));
    model_posteriors_df = DataFrame();
    for (k, v) in param_grid
        cur_row = DataFrame([v])
        cur_row.posterior = [model_posteriors[k]]
        model_posteriors_df = vcat(model_posteriors_df, cur_row, cols=:union)
    end

    # Parameter posteriors.
    param_posteriors = ADDM.marginal_posteriors(param_grid, model_posteriors)

    # Store.
    subdir = outdir*"/$(s)/";
    mkpath(subdir);
    CSV.write(subdir*"nll.csv", subj_nll_df)
    CSV.write(subdir*"modelposteriors.csv", model_posteriors_df)
    for paramIndex in 1:length(param_posteriors)
        param = names(param_posteriors[paramIndex])[1]
        CSV.write(subdir*"parameterposterior_$(param).csv", param_posteriors[paramIndex])
    end
end