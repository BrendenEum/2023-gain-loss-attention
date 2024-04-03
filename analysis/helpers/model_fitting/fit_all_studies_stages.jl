# Author: Brenden Eum (2024)
# If running this in vscode locally, you need to open up a shell REPL, run 'julia --project=<toolboxdir>', and run 'include("<yourscript.jl>")'. This opens julia with the ADDM environment and runs your code.

##################################################################################################################
# Preamble
##################################################################################################################

# Libraries and settings
using ADDM
using CSV
using DataFrames
using Random, Distributions, StatsBase
using Base.Threads
using Dates
using RCall
seed = 1337;

# Prep likelihood functions
include("custom_functions/aDDM_likelihood.jl")
include("custom_functions/AddDDM_likelihood.jl")
include("custom_functions/RaDDM_likelihood.jl")

# Common model settings (! ! !)
fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :decay=>0.0);
my_likelihood_args = (timeStep = 10.0, approxStateStep = 0.01); #ms, RDV units
verbose = true;

# Prep output folder
datefolder = "../../outputs/temp/model_fitting/" * Dates.format(now(), "yyyy.mm.dd-H.M") * "/"
mkpath(datefolder);


##################################################################################################################
# Stage 1
##################################################################################################################
stage = "Stage1";

# Prep output folder
stagefolder = datefolder * stage * "/";
stage1folder = stagefolder;
mkpath(stagefolder);

###########
# Study 1
###########

# Prep output folder
study = "Study1E";     
println("== " * study * " ==")
flush(stdout)
outdir = stagefolder * study * "/"; # change this to datefolder once you're on stage3.
mkpath(outdir);

# Prep parameter grid (param_grid)
parameter_grid_folder = stage*"_parameter_grids/";
include("make_parameter_grid_Study1.jl");

# Fitting
include("fit_Study1E.jl")

###########
# Study 2
###########

# Prep output folder
study = "Study2E";     
println("== " * study * " ==")
flush(stdout)
outdir = stagefolder * study * "/"; # change this to datefolder once you're on stage3.
mkpath(outdir);

# Prep parameter grid (param_grid)
parameter_grid_folder = stage*"_parameter_grids/";
include("make_parameter_grid_Study2.jl");

# Fitting
include("fit_Study2E.jl")


##################################################################################################################
# Stage 2
##################################################################################################################
stage = "Stage2";

# Prep output folder
stagefolder = datefolder * stage * "/";
stage2folder = stagefolder;
mkpath(stagefolder);

# Make new parameter grids
R"""
source("Stage2_parameter_grids.R")
"""

###########
# Study 1
###########

# Prep output folder
study = "Study1E";     
println("== " * study * " ==")
flush(stdout)
outdir = stagefolder * study * "/"; # change this to datefolder once you're on stage3.
mkpath(outdir);

# Prep parameter grid (param_grid)
parameter_grid_folder = stage*"_parameter_grids/";
include("make_parameter_grid_Study1.jl");

# Fitting
include("fit_Study1E.jl")

###########
# Study 2
###########

# Prep output folder
study = "Study2E";     
println("== " * study * " ==")
flush(stdout)
outdir = stagefolder * study * "/"; # change this to datefolder once you're on stage3.
mkpath(outdir);

# Prep parameter grid (param_grid)
parameter_grid_folder = stage*"_parameter_grids/";
include("make_parameter_grid_Study2.jl");

# Fitting
include("fit_Study2E.jl")
