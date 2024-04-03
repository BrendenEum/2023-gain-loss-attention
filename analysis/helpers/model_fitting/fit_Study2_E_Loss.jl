# Author: Brenden Eum (2024)
# If running this in vscode locally, you need to open up a shell REPL, run 'julia --project=<toolboxdir>', and run 'include("<yourscript.jl>")'. This opens julia with the ADDM environment and runs your code.

##################################################################################################################
# Preamble
##################################################################################################################

#############
# Libraries and settings
#############
using ADDM
using CSV
using DataFrames
using Random, Distributions, StatsBase
using Base.Threads
using Dates
seed = 1337;

#############
# Prep likelihood functions
#############
include("custom_functions/aDDM_likelihood.jl")
include("custom_functions/AddDDM_likelihood.jl")
include("custom_functions/RaDDM_likelihood.jl")

#############
# Prep parameter grid (param_grid)
#############
include("make_parameter_grid_Study2.jl")

#############
# Common model settings (! ! !)
# Fitting parameters: d, σ, θ, η, bias, NDT, decay, barrier
#############
fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :decay=>0.0);
my_likelihood_args = (timeStep = 10.0, approxStateStep = 0.01); #ms, RDV units
verbose = true;


##################################################################################################################
# Study 2 Exploratory
##################################################################################################################


#############
# Prep output folder
#############
study = "Study2E"      # ! ! !
println("== " * study * " ==")
flush(stdout)
outdir = "../../outputs/temp/model_fitting/" * study * "-" * Dates.format(now(), "yyyy.mm.dd.H.M") * "/";
mkpath(outdir);

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
    
    # Subset the data by subject.
    cur_subj_data = study2[k]

    # Fit the model via grid search.
    subj_best_pars, subj_nll_df, subj_trial_posteriors = ADDM.grid_search(
        cur_subj_data, param_grid, nothing, fixed_params, likelihood_args=my_likelihood_args, return_model_posteriors=true; verbose=verbose, threadNum=Threads.threadid()
    );
    sort!(subj_nll_df, [:nll])
    CSV.write(outdir * condition * "_nll_$(k).csv", subj_nll_df)
    CSV.write(outdir * condition * "_trialPosteriors_$(k).csv", subj_trial_posteriors)
    
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