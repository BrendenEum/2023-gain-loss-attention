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

# Prep param_grid functions
include("merge_parameter_grid.jl");

# Common model settings (! ! !)
fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :decay=>0.0);
my_likelihood_args = (timeStep = 10.0, approxStateStep = 0.01); #ms, RDV units
verbose = true;

# Prep output folder
time = Dates.format(now(), "yyyy.mm.dd-H.M");
open("time2.txt", "w") do file
    write(file, time)
end
datefolder = "../../outputs/temp/model_fitting/" * time * "/"
mkpath(datefolder);

# List of study 1 and 2 participants
expdata = "../../../data/processed_data/dots/e/expdataGain.csv";
fixdata = "../../../data/processed_data/dots/e/fixationsGain.csv";
study1 = ADDM.load_data_from_csv(expdata, fixdata);
CSV.write("Study1_participants.csv", DataFrame(participants = collect(keys(study1))))
expdata = "../../../data/processed_data/numeric/e/expdataGain.csv";
fixdata = "../../../data/processed_data/numeric/e/fixationsGain.csv";
study2 = ADDM.load_data_from_csv(expdata, fixdata);
CSV.write("Study2_participants.csv", DataFrame(participants = collect(keys(study2))))


##################################################################################################################
# Stage 2
##################################################################################################################
stage = "Stage2";
println("=====" * stage * "=====")
flush(stdout)

# Prep output folder
stagefolder = datefolder * stage * "/";
stage1folder = stagefolder;
mkpath(stagefolder);

# Prep all parameter grids
all_parameter_grid_folder = stage*"_parameter_grids/";
all_param_grid_Gain_Study1 = Dict();
all_param_grid_Loss_Study1 = Dict();
for j in collect(keys(study1))
    parameter_grid_folder = all_parameter_grid_folder * "$(j)/";
    param_grid_Gain, param_grid_Loss = merge_parameter_grid(parameter_grid_folder);
    all_param_grid_Gain_Study1[j] = param_grid_Gain;
    all_param_grid_Loss_Study1[j] = param_grid_Loss;
end
all_param_grid_Gain_Study2 = Dict();
all_param_grid_Loss_Study2 = Dict();
for j in collect(keys(study2))
    parameter_grid_folder = all_parameter_grid_folder * "$(j)/";
    param_grid_Gain, param_grid_Loss = merge_parameter_grid(parameter_grid_folder);
    all_param_grid_Gain_Study2[j] = param_grid_Gain;
    all_param_grid_Loss_Study2[j] = param_grid_Loss;
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

# Fitting
all_param_grid_Gain = all_param_grid_Gain_Study1;
all_param_grid_Loss = all_param_grid_Loss_Study1;
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

# Fitting
all_param_grid_Gain = all_param_grid_Gain_Study2;
all_param_grid_Loss = all_param_grid_Loss_Study2;
include("fit_Study2E.jl")