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
simCount = 20; # how many simulations to run per data generating process?
include("sim_and_fit.jl")
"""
These options are the defaults for the arguments in sim_and_fit().
timeStep = 10.0; # ms
approxStateStep = 0.01; # the approximate resolution of the relative-decision-variable space
simCutoff = 20000; # maximum decision time for one simulated choice
verbose = true; # show progress
"""


#############
# Prep experiment data
#############
expdata = "expdataGain.csv";
fixdata = "fixationsGain.csv";
data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);
nTrials = 81;
Stims_Gain = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);
Fixations_Gain = ADDM.process_fixations(data, fixDistType="simple");


#############
# Prep likelihood and simulator functions
#############
include("custom_functions/RaDDM_likelihood.jl")
include("custom_functions/RaDDM_simulator.jl")


#############
# Prep parameter grid (param_grid)
#############
include("custom_functions/RaDDM_likelihood.jl")
fn_module = [meth.module for meth in methods(RaDDM_likelihood)][1];
fn = "parameter_grids/RaDDM_Gain.csv";
tmp = DataFrame(CSV.File(fn, delim=","));
tmp.likelihood_fn .= "RaDDM_likelihood";
param_grid_Gain = Dict(pairs(NamedTuple.(eachrow(tmp))));

#############
# Prep output folder
#############
prdir = "../../outputs/temp/parameter_recovery/" * Dates.format(now(), "yyyy.mm.dd-H.M") * "/";
mkpath(prdir);


##################################################################################################################
# GEN: Reference-Dependent aDDM
##################################################################################################################
m = "RaDDM"      # ! ! !
println("== GEN: " * m * " ==")
flush(stdout)
outdir = prdir * "/" * m * "/";
mkpath(outdir);
simulator_fn = RaDDM_simulator      # ! ! !


############# 
# Gain
#############
condition = "Gain"
println("= "*condition*" =")
flush(stdout)
Random.seed!(seed)

# SIM: Parameters      # ! ! !
model_list = Any[];
for i in 1:simCount
    model = ADDM.define_model(
        d = sample([.003, .006, .009, .012]),
        σ = sample([.05, .07, .09]),
        θ = sample([.25, .5, .75]),
        bias = 0,
        nonDecisionTime = 100,
        decay = 0
    ) 
    model.reference = 0;
    push!(model_list, model);
end

#FIT
fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :decay=>0.0)

# DO SIM AND FIT
sim_and_fit(model_list, condition, simulator_fn, param_grid_Gain, fixed_params)