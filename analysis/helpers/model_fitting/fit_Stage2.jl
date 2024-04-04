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
seed = 1337;

# Prep likelihood functions
include("custom_functions/aDDM_likelihood.jl")
include("custom_functions/AddDDM_likelihood.jl")
include("custom_functions/RaDDM_likelihood.jl")

# Common model settings (! ! !)
fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :decay=>0.0);
my_likelihood_args = (timeStep = 10.0, approxStateStep = 0.01); #ms, RDV units
verbose = false;

# Prep output folder
time = Dates.format(now(), "yyyy.mm.dd-H.M");
open("time2.txt", "w") do file
    write(file, time)
end
datefolder = "../../outputs/temp/model_fitting/" * time * "/"
mkpath(datefolder);


##################################################################################################################
# Stage 2
##################################################################################################################
stage = "Stage2";

# Prep output folder
stagefolder = datefolder * stage * "/";
stage2folder = stagefolder;
mkpath(stagefolder);

# Prep parameter grids (param_grid)
study1participants = CSV.read("Study1_participants.csv", DataFrame).participants
Stage2_parameter_grid_folder = stage*"_parameter_grids/";
all_param_grid_Gain = Dict();
all_param_grid_Loss = Dict();
for j in study1participants
    parameter_grid_folder = Stage2_parameter_grid_folder * "$(j)/";
    include("merge_parameter_grid_Study1.jl");
    all_param_grid_Gain[j] = param_grid_Gain;
    all_param_grid_Loss[j] = param_grid_Loss;
end


###########
# Study 1
###########

# Prep output folder
study = "Study1E";     
println("== " * study * " ==")
flush(stdout)
outdir = stagefolder * study * "/"; # change this to datefolder once you're on stage3.
mkpath(outdir);

# Prep parameter grid for specific subject
parameter_grid_folder = 
include("merge_parameter_grid_Study1.jl");

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
include("merge_parameter_grid_Study2.jl");

# Fitting
include("fit_Study2E.jl")
