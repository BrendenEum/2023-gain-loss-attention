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

<<<<<<<< Updated upstream:analysis/helpers/model_fitting/fit_all_Stage2.jl
========
<<<<<<<< HEAD:analysis/helpers/model_fitting/fit_Stage1.jl
# Prep output folder
time = Dates.format(now(), "yyyy.mm.dd-H.M");
open("time1.txt", "w") do file
    write(file, time)
end
datefolder = "../../outputs/temp/model_fitting/" * time * "/"
========
>>>>>>>> Stashed changes:analysis/helpers/model_fitting/fit_Stage1.jl
# Prep output folder and save the time in a silly file.
WhatTimeIsItRightNowDotCom = Dates.format(now(), "yyyy.mm.dd-H.M");
open("WhatTimeIsItRightNowDotCom.txt", "w") do file
    write(file, WhatTimeIsItRightNowDotCom)
end
datefolder = "../../outputs/temp/model_fitting/" * WhatTimeIsItRightNowDotCom * "/";
<<<<<<<< Updated upstream:analysis/helpers/model_fitting/fit_all_Stage2.jl
========
>>>>>>>> 0ecc60be1749eaa1cf0382ea9a637c882b0711ea:analysis/helpers/model_fitting/fit_all_Stage2.jl
>>>>>>>> Stashed changes:analysis/helpers/model_fitting/fit_Stage1.jl
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
# Stage 1
##################################################################################################################
stage = "Stage1";

# Prep output folder
stagefolder = datefolder * stage * "/";
stage1folder = stagefolder;
mkpath(stagefolder);

# Parameter grids
parameter_grid_folder = stage*"_parameter_grids/";

###########
# Study 1
###########

# Prep output folder
study = "Study1E";     
println("== " * study * " ==")
flush(stdout)
outdir = stagefolder * study * "/"; # change this to datefolder once you're on stage3.
mkpath(outdir);

<<<<<<<< Updated upstream:analysis/helpers/model_fitting/fit_all_Stage2.jl
========
<<<<<<<< HEAD:analysis/helpers/model_fitting/fit_Stage1.jl
# Prep parameter grid (param_grid)
parameter_grid_folder = stage*"_parameter_grids/";
include("merge_parameter_grid_Study1.jl");

========
>>>>>>>> 0ecc60be1749eaa1cf0382ea9a637c882b0711ea:analysis/helpers/model_fitting/fit_all_Stage2.jl
>>>>>>>> Stashed changes:analysis/helpers/model_fitting/fit_Stage1.jl
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

<<<<<<<< Updated upstream:analysis/helpers/model_fitting/fit_all_Stage2.jl
========
<<<<<<<< HEAD:analysis/helpers/model_fitting/fit_Stage1.jl
# Prep parameter grid (param_grid)
parameter_grid_folder = stage*"_parameter_grids/";
include("merge_parameter_grid_Study2.jl");
========
>>>>>>>> Stashed changes:analysis/helpers/model_fitting/fit_Stage1.jl
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
# Make parameter grids
parameter_grid_folder = stage*"_parameter_grids/";
R"""
source("make_Stage2_parameter_grids.R")
"""
sleep(10)

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
<<<<<<<< Updated upstream:analysis/helpers/model_fitting/fit_all_Stage2.jl
========
>>>>>>>> 0ecc60be1749eaa1cf0382ea9a637c882b0711ea:analysis/helpers/model_fitting/fit_all_Stage2.jl
>>>>>>>> Stashed changes:analysis/helpers/model_fitting/fit_Stage1.jl

# Fitting
include("fit_Study2E.jl")
