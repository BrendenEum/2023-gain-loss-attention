#######################
# Gain
#######################

# Standard aDDM

include("custom_functions/aDDM_likelihood.jl")
fn_module = [meth.module for meth in methods(aDDM_likelihood)][1];
fn = "parameter_grids/aDDM_Gain_test.csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp.likelihood_fn .= "aDDM_likelihood";
param_grid = Dict(pairs(NamedTuple.(eachrow(tmp))));