#######################
# Gain
#######################

# Reference-Dependent aDDM

include("custom_functions/RaDDM_likelihood.jl")
fn_module = [meth.module for meth in methods(RaDDM_likelihood)][1];
fn = "parameter_grids/RaDDM_Gain.csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp.likelihood_fn .= "RaDDM_likelihood";
param_grid_Gain = Dict(pairs(NamedTuple.(eachrow(tmp))));

#######################
# Loss
#######################

# Reference-Dependent aDDM

include("custom_functions/RaDDM_likelihood.jl")
fn_module = [meth.module for meth in methods(RaDDM_likelihood)][1];
fn = "parameter_grids/RaDDM_Loss.csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp.likelihood_fn .= "RaDDM_likelihood";
param_grid_Loss = Dict(pairs(NamedTuple.(eachrow(tmp))));