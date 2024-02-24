# Author: Brenden Eum (2024)
# If running this in vscode locally, you need to open up a shell REPL, run 'julia --project=<toolboxdir>', and run 'include("<yourscript.jl>")'. This opens julia with the ADDM environment and runs your code.

#############
# Preamble
#############

using ADDM
using CSV
using DataFrames

#############
# Define model
#############

MyModel = ADDM.define_model(d = 0.007, σ = 0.03, θ = .6, barrier = 1, decay = 0, nonDecisionTime = 100, bias = 0.0)
ADDM.aDDM(
    Dict{Symbol, Any}(:nonDecisionTime => 100, :σ => 0.03, :d => 0.007, :bias => 0.0, :barrier => 1, :decay => 0, :θ => 0.6, :η => 0.0)
)

#############
# Define stimuli
#############

data = ADDM.load_data_from_csv("../../../data/stimdata.csv", "../../../data/fixations.csv"; stimsOnly = true);

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

    println(k)
    cur_subj_data = data_dotloss[k]

    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>0)
  
    subj_best_pars, subj_nll_df, trial_posteriors = ADDM.grid_search(
        cur_subj_data, param_grid, custom_aDDM_likelihood, 
        fixed_params,
        likelihood_args=my_likelihood_args,
        return_model_posteriors = true);
    
    nTrials = length(cur_subj_data)
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

CSV.write("dot_nll_df.csv", dot_nll_df)