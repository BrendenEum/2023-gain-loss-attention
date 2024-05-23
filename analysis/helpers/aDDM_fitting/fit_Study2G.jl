# For the terminal:
# cd "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_fitting"
# julia --project=/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_fitting/ADDM.jl --threads=4 "fit_Study2G.jl"

#######################
# Preamble
#######################

# Libraries and directories
using ADDM, CSV, DataFrames, DataFramesMeta, Distributed, Distributions, LinearAlgebra, StatsPlots, Base.Threads
datadir = "test_data/";
tempdir = "../../outputs/aDDM_fitting/";

# Data
full_data = ADDM.load_data_from_csv(datadir * "expdataGain.csv", datadir * "fixationsGain.csv");
subj_data = full_data["201"]; # 201 has half the original data for 201. 202 is full original.

# Likelihood functions
include("custom_functions/AddDDM_likelihood.jl");
fn_module = [meth.module for meth in methods(AddDDM_likelihood)][1];
include("custom_functions/StatusQuo_likelihood.jl");
fn_module = [meth.module for meth in methods(StatusQuo_likelihood)][1];
include("custom_functions/MaxMin_likelihood.jl");
fn_module = [meth.module for meth in methods(MaxMin_likelihood)][1];
include("custom_functions/MinOutcome_likelihood.jl");
fn_module = [meth.module for meth in methods(MinOutcome_likelihood)][1];


#######################
# Parameter grid for all models
#######################

# AddDDM
tmp = DataFrame(CSV.File("parameter_grids/AddDDM_grid.csv", delim=","));
tmp.likelihood_fn .= "AddDDM_likelihood"
param_grid1 = NamedTuple.(eachrow(tmp));

# RaDDM: Status Quo
tmp = DataFrame(CSV.File("parameter_grids/RaDDM_grid.csv", delim=","));
tmp.likelihood_fn .= "StatusQuo_likelihood"
param_grid2 = NamedTuple.(eachrow(tmp));

# RaDDM: MaxMin
tmp = DataFrame(CSV.File("parameter_grids/RaDDM_grid.csv", delim=","));
tmp.likelihood_fn .= "MaxMin_likelihood"
param_grid3 = NamedTuple.(eachrow(tmp));

# RaDDM: Status Quo
tmp = DataFrame(CSV.File("parameter_grids/RaDDM_grid.csv", delim=","));
tmp.likelihood_fn .= "MinOutcome_likelihood"
param_grid4 = NamedTuple.(eachrow(tmp));

# Combine the grids
param_grid = vcat(param_grid1, param_grid2, param_grid3, param_grid4)


#######################
# Model Fitting
#######################

# Fitting options
my_likelihood_args = (timeStep = 10.0, stateStep = 0.01);
my_fixed_params = Dict(:barrier=>1, :decay=>0)

# Grid search with uniform priors over all models
output = ADDM.grid_search(
    subj_data,
    param_grid,
    nothing,        # likelihood = nothing uses the likelihood function listed in param_grid
    my_fixed_params,
    likelihood_args = my_likelihood_args,
    likelihood_fn_module = fn_module,
    return_grid_nlls = true, return_trial_posteriors = true, return_model_posteriors = true
);

# Results
mle = output[:mle];
nll_df = output[:grid_nlls];
trial_posteriors = output[:trial_posteriors];
model_posteriors = output[:model_posteriors];

# Model posteriors
posteriors_df2 = DataFrame();
for (k, v) in model_posteriors
    cur_row = DataFrame([k])
    cur_row.posterior = [v]
    posteriors_df2 = vcat(posteriors_df2, cur_row, cols=:union)
end;


#######################
# Model Comparison
#######################

gdf = groupby(posteriors_df2, :likelihood_fn);
combdf = combine(gdf, :posterior => sum);
@df combdf bar(:likelihood_fn, :posterior_sum, legend = false, xrotation = 45, ylabel = "p(model|data)",bottom_margin = (5, :mm))


#######################
# Individual Parameter Posteriors
#######################

param_posteriors = ADDM.marginal_posteriors(model_posteriors);
plot_array = Any[];
for plot_df in param_posteriors
    x_lab = names(plot_df)[1]
    cur_plot = @df plot_df bar(plot_df[:, x_lab], :posterior_sum, leg = false, ylabel = "p(" * x_lab * " = x|data)", xlabel = x_lab )
    push!(plot_array, cur_plot)
end;
plot(plot_array...)


#######################
# Joint Parameter Posteriors
#######################

all_marginal_posteriors = ADDM.marginal_posteriors(model_posteriors, two_d_marginals = true)
ADDM.marginal_posterior_plot(all_marginal_posteriors)

#######################
# Save it all!
#######################

CSV.write(tempdir * "model_posteriors/model_posteriors.csv", model_posteriors)
