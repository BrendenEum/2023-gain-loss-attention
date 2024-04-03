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

#############
# Prep likelihood functions
#############
include("custom_functions/aDDM_likelihood.jl")
include("custom_functions/AddDDM_likelihood.jl")
include("custom_functions/RaDDM_likelihood.jl")

#############
# Common model settings (! ! !)
# Fitting parameters: d, σ, θ, η, bias, NDT, decay, barrier
#############
fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :decay=>0.0);
my_likelihood_args = (timeStep = 10.0, approxStateStep = 0.01); #ms, RDV units
verbose = true;

#############
# Prep output folder
#############
datefolder = "../../outputs/temp/model_fitting/" * Dates.format(now(), "yyyy.mm.dd.H.M") * "/"
mkpath(datefolder);




include("fit_Study2E.jl")

##################################################################################################################
# Stage 1
##################################################################################################################

####################################################
# Study 1
####################################################

#############
# Prep output folder
#############
study = "Study1E"     
println("== " * study * " ==")
flush(stdout)
outdir = datefolder * study * "/"

#############
# Prep parameter grid (param_grid)
#############
parameter_grid_folder = "stage1_parameter_grids/"
include("make_parameter_grid_Study1.jl")

#############
# Fitting
#############
include("fit_Study1E.jl")

