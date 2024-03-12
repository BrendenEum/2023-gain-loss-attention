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
timeStep = 10.0; # ms
approxStateStep = 0.01; # the approximate resolution of the relative-decision-variable space
simCutoff = 20000; # maximum decision time for one simulated choice
verbose = true; # show progress
"""
simCount = 8; # how many simulations to run per data generating process?


##################################################################################################################
# GEN: (d,σ,θ,m)
# FIT: (d,σ,θ,m) + (d,σ,η)
##################################################################################################################
m = "dstm-dse"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)

############ Gain
condition = "Gain"
println("= "*condition*" =")
flush(stdout)

# Parameters
model_list = Any[];
for i in 1:simCount
    model = ADDM.define_model(
        d = sample([.002, .004, .006, .008]),
        σ = sample([.01, .03, .05, .07]),
        bias = 0.0,
        θ = sample([0, .25, .5, .75, 1], Weights([.125, .25, .25, .25, .125])),
        nonDecisionTime = 100
    )
    model.η = 0.0;
    model.λ = 0.0;
    model.minValue = 1.0;
    model.range = 1.0;
    push!(model_list, model);
end
fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)

# Grid
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

# Sim and fit
sim_and_fit(model_list, condition, param_grid, m, fixed_params);

############ Loss
condition = "Loss"
println("= "*condition*" =")

# Parameters
model_list = Any[];
for i in 1:simCount
    model = ADDM.define_model(
        d = sample([.002, .004, .006, .008]),
        σ = sample([.01, .03, .05, .07]),
        bias = 0.0,
        θ = sample([0, .25, .5, .75, 1], Weights([.125, .25, .25, .25, .125])),
        nonDecisionTime = 100
    )
    model.η = 0.0;
    model.λ = 0.0;
    model.minValue = -6.0;
    model.range = 1.0;
    push!(model_list, model);
end
fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)

# Grid
include("custom_functions/dstm_likelihood.jl")
fn_module = [meth.module for meth in methods(dstm_likelihood)][1]
fn = "parameter_grids/dstm_Loss.csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp.likelihood_fn .= "dstm_likelihood";
param_grid1 = Dict(pairs(NamedTuple.(eachrow(tmp))));

include("custom_functions/dse_likelihood.jl")
fn_module = [meth.module for meth in methods(dse_likelihood)][1]
fn = "parameter_grids/dse_Loss.csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp.likelihood_fn .= "dse_likelihood";
param_grid2 = Dict(pairs(NamedTuple.(eachrow(tmp))));
param_grid2 = Dict(keys(param_grid2) .+ length(param_grid1) .=> values(param_grid2));

param_grid = Dict(param_grid1..., param_grid2...)

# Sim and Fit
sim_and_fit(model_list, condition, param_grid, m, fixed_params)
