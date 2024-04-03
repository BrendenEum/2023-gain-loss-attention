#######################
# Loss
#######################

# Standard aDDM

include("custom_functions/aDDM_likelihood.jl")
fn = parameter_grid_folder*"aDDM_Loss_"*subject*".csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp[:, :likelihood_fn] .= "aDDM_likelihood";
param_grid1 = Dict(pairs(NamedTuple.(eachrow(tmp))));

# Additive aDDM

include("custom_functions/AddDDM_likelihood.jl")
fn = parameter_grid_folder*"AddDDM_Loss_"*subject*".csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp[:, :likelihood_fn] .= "AddDDM_likelihood";
param_grid2 = Dict(pairs(NamedTuple.(eachrow(tmp))));
param_grid2 = Dict(keys(param_grid2) .+ length(param_grid1) .=> values(param_grid2));

# Reference-Dependent aDDM

include("custom_functions/RaDDM_likelihood.jl")
fn = parameter_grid_folder*"RaDDM_Loss_"*subject*".csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp[:, :likelihood_fn] .= "RaDDM_likelihood";
param_grid3 = Dict(pairs(NamedTuple.(eachrow(tmp))));
param_grid3 = Dict(keys(param_grid3) .+ length(param_grid2) .+ length(param_grid1) .=> values(param_grid3));

# Combine

global param_grid_Loss = Dict(param_grid1..., param_grid2..., param_grid3...)