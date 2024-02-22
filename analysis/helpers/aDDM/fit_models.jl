#############
# Preamble
#############

using ADDM
using CSV
using DataFrames
using StatsPlots

#############
# Get data
#############

data_dotgain = ADDM.load_data_from_csv("../../../data/processed_data/dots/e/expdataGain.csv", "../../../data/processed_data/dots/e/fixationsGain.csv")
data_numgain = ADDM.load_data_from_csv("../../../data/processed_data/numeric/e/expdataGain.csv", "../../../data/processed_data/numeric/e/fixationsGain.csv")
data_dotloss = ADDM.load_data_from_csv("../../../data/processed_data/dots/e/expdataloss.csv", "../../../data/processed_data/dots/e/fixationsloss.csv")
data_numloss = ADDM.load_data_from_csv("../../../data/processed_data/numeric/e/expdataloss.csv", "../../../data/processed_data/numeric/e/fixationsloss.csv")

#############
# Get grids
#############

include("./custom_aDDM_likelihood.jl")
fn = "aDDM_grid.csv"
tmp = DataFrame(CSV.File(fn, delim=","))
tmp.likelihood_fn .= "ADDM.custom_aDDM_likelihood";
param_grid1 = Dict(pairs(NamedTuple.(eachrow(tmp))))

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

for k in keys(dotdata)
    
    cur_subj_data = dotdata[k]

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