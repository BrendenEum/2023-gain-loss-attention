# Author: Brenden Eum (2024)
# If running this in vscode locally, you need to open up a shell REPL, run 'julia --project=<toolboxdir>', and run 'include("<yourscript.jl>")'. This opens julia with the ADDM environment and runs your code.

#############
# Preamble
#############

using ADDM
using CSV
using DataFrames
using StatsPlots

cluster = true

#############
# Get data
#############

if cluster == false
    data_dotgain = ADDM.load_data_from_csv("../../../data/processed_data/dots/e/expdataGain.csv", "../../../data/processed_data/dots/e/fixationsGain.csv")
    data_numgain = ADDM.load_data_from_csv("../../../data/processed_data/numeric/e/expdataGain.csv", "../../../data/processed_data/numeric/e/fixationsGain.csv")
    data_dotloss = ADDM.load_data_from_csv("../../../data/processed_data/dots/e/expdataLoss.csv", "../../../data/processed_data/dots/e/fixationsLoss.csv")
    data_numloss = ADDM.load_data_from_csv("../../../data/processed_data/numeric/e/expdataLoss.csv", "../../../data/processed_data/numeric/e/fixationsLoss.csv")
else
    data_dotloss = ADDM.load_data_from_csv("testexpdataLoss.csv", "testfixationsLoss.csv")
end

#############
# Get grids
#############

include("custom_aDDM_likelihood.jl")
fn = "aDDM_grid.csv"
tmp = DataFrame(CSV.File(fn, delim=","))
tmp.likelihood_fn .= "ADDM.custom_aDDM_likelihood";
param_grid = Dict(pairs(NamedTuple.(eachrow(tmp))))

#############
# Common settings
#############

my_likelihood_args = (timeStep = 10.0, approxStateStep = 0.1);

#############
# Fit dots study
#############

dot_nll_df = DataFrame()
dot_best_pars = Dict()
dot_model_posteriors = Dict()
dot_param_posteriors = Dict()

for k in keys(data_dotloss)
    
    cur_subj_data = data_dotloss[k]

    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>0, :minValue=>0, :range=>1)
  
    subj_best_pars, subj_nll_df, trial_posteriors = ADDM.grid_search(
        cur_subj_data, param_grid, nothing, 
        fixed_params,
        likelihood_args=my_likelihood_args,
        return_model_posteriors = true);
  
    nTrials = length(subj_data)
    model_posteriors = Dict(zip(keys(trial_posteriors), [x[nTrials] for x in values(trial_posteriors)]))
    param_posteriors = ADDM.marginal_posteriors(param_grid, model_posteriors)
    model_posteriors_df = DataFrame();
    for (k, v) in param_grid
        cur_row = DataFrame([v])
        cur_row.posterior = [model_posteriors[k]]
        model_posteriors_df = vcat(model_posteriors_df, cur_row, cols=:union)
    end;
   
  dot_best_pars[k] = subj_best_pars
  dot_model_posteriors[k] = model_posteriors_df
  dot_param_posteriors[k] = param_posteriors

  subj_nll_df[!, "parcode"] .= k
  append!(dot_nll_df, subj_nll_df)
  
end