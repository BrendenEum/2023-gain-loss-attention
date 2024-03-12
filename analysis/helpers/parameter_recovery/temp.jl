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
include("custom_functions/custom_aDDM_simulator.jl")
include("custom_functions/custom_aDDM_likelihood.jl")
include("sim_and_fit.jl")
seed = 4;
"""
These options are the defaults for the arguments in sim_and_fit().
"""
timeStep = 10.0; # ms
approxStateStep = 0.01; # the approximate resolution of the relative-decision-variable space
simCutoff = 20000; # maximum decision time for one simulated choice
verbose = true; # show progress

simCount = 8; # how many simulations to run per data generating process?


##################################################################################################################
# GEN: (d,σ,θ,m)
# FIT: (d,σ,θ,m) + (d,σ,η)
##################################################################################################################
dgp = "dstm-dse"
println("== " * dgp * " ==")
flush(stdout)
Random.seed!(seed)

# Gain
condition = "Gain"
println("= Gain =")
flush(stdout)
model_list = Any[];
for i in 1:simCount
    model = ADDM.define_model(
        d = sample([.001, .003, .005, .007]),
        σ = sample([.01, .03, .05, .07]),
        bias = 0.0,
        θ = sample([0, .25, .5, .75, 1]),
        nonDecisionTime = 100
    )
    model.η = 0.0;
    model.λ = 0.0;
    model.minValue = 1.0;
    model.range = 1.0;
    push!(model_list, model);
end
fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)

include("custom_functions/dstm_likelihood.jl")
fn_module = [meth.module for meth in methods(dstm_likelihood)][1];
fn = "parameter_grids/dstm_Gain.csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp.likelihood_fn .= "dstm_likelihood";
param_grid1 = Dict(pairs(NamedTuple.(eachrow(tmp))));

include("custom_functions/dse_likelihood.jl")
fn_module = [meth.module for meth in methods(dse_likelihood)][1];
fn = "parameter_grids/dse_Gain.csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp.likelihood_fn .= "dse_likelihood";
param_grid2 = Dict(pairs(NamedTuple.(eachrow(tmp))));
param_grid2 = Dict(keys(param_grid2) .+ length(param_grid1) .=> values(param_grid2));

param_grid = Dict(param_grid1..., param_grid2...)

expdata = "expdataGain.csv";
fixdata = "fixationsGain.csv";

outdir = "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp/parameter_recovery/"*dgp*"/";
mkpath(outdir);

# Get stimuli
data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);
nTrials = 81;
MyStims = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);

# Get fixation properties
MyFixationData = ADDM.process_fixations(data, fixDistType="simple");

# Simulate using model container and fit simulated data
#Threads.@threads for m in 1:length(model_list)
m=1

# progress
println("Thread ", Threads.threadid(), ": Model $(m)")
flush(stdout)

############################### Simulate data
MyModel = model_list[m];
MyArgs = (timeStep = timeStep, cutOff = simCutoff, fixationData = MyFixationData);
SimData = ADDM.simulate_data(MyModel, MyStims, custom_aDDM_simulator, MyArgs);

############################### Fit simulated data

my_likelihood_args = (timeStep = timeStep, approxStateStep = approxStateStep);

best_pars, all_nll_df, trial_posteriors = ADDM.grid_search(SimData, param_grid, nothing, fixed_params, likelihood_args=my_likelihood_args, return_model_posteriors=true; verbose=verbose, threadNum=Threads.threadid());

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

gdf = groupby(model_posteriors_df, :likelihood_fn);
combdf = combine(gdf, :posterior => sum)

# Parameter posteriors.
param_posteriors = ADDM.marginal_posteriors(param_grid, model_posteriors)

# Store.
for paramIndex in 1:length(param_posteriors)
    param = names(param_posteriors[paramIndex])[1]
    CSV.write(outdir*condition*"_$(param)_posterior.csv", param_posteriors[paramIndex])
end

#end