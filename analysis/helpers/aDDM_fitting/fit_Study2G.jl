# For the terminal:
# cd "/Users/brendeneum/Desktop/aDDM_fitting"
# julia --project=/Users/brendeneum/Desktop/aDDM_fitting/ADDM.jl --threads=4 "fit_Study2L.jl"

##############################################
# Preamble
##############################################

# Libraries
using ADDM, CSV, DataFrames, DataFramesMeta, Distributed, Distributions, LinearAlgebra, Base.Threads

#---------------------------------------------------------------------------------------
# THINGS TO CHANGE

# Participants
study_participants = DataFrame(CSV.File("Study2_participants.csv", delim=","))[:,1];

# Directories
tempdir = "results/study2G/";

# Data
full_data = ADDM.load_data_from_csv(
    "/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/numeric/e/expdataGain_train.csv", 
    "/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/numeric/e/fixationsGain_train.csv"
);
#---------------------------------------------------------------------------------------

# Likelihood functions
include("custom_functions/AddDDM_likelihood.jl");
include("custom_functions/StatusQuo_likelihood.jl");
include("custom_functions/MaxMin_likelihood.jl");
include("custom_functions/RaDDM_likelihood.jl");

# Fitting options
my_likelihood_args = (timeStep = 10.0, stateStep = 0.01);
my_fixed_params = Dict(:barrier=>1, :decay=>0, :bias=>0, :nonDecisionTime=>100);


##############################################
# Parameter grid for all models
##############################################

# AddDDM
tmp = DataFrame(CSV.File("parameter_grids/AddDDM_grid.csv", delim=","));
tmp.likelihood_fn .= "AddDDM_likelihood";
param_grid1 = NamedTuple.(eachrow(tmp));

# RaDDM: Status Quo
tmp = DataFrame(CSV.File("parameter_grids/aDDM_grid.csv", delim=","));
tmp.likelihood_fn .= "StatusQuo_likelihood";
param_grid2 = NamedTuple.(eachrow(tmp));

# RaDDM: MaxMin
tmp = DataFrame(CSV.File("parameter_grids/aDDM_grid.csv", delim=","));
tmp.likelihood_fn .= "MaxMin_likelihood";
param_grid3 = NamedTuple.(eachrow(tmp));

# RaDDM: FreeRef
tmp = DataFrame(CSV.File("parameter_grids/RaDDM_grid.csv", delim=","));
tmp.likelihood_fn .= "RaDDM_likelihood";
param_grid4 = NamedTuple.(eachrow(tmp));

# Combine the grids
param_grid = vcat(param_grid1, param_grid2, param_grid3, param_grid4);

##############################################
# Loop through all participants and save
##############################################

Threads.@threads for k in study_participants

    # Subset data
    println("Starting Participant $(k).")
    subj_data = full_data["$(k)"];

    # Grid search with uniform priors over all models. Measure computation time.
    elapsed_sec = @elapsed begin
        output = ADDM.grid_search(
            subj_data,
            param_grid,
            nothing,    # nothing: uses likelihood_fn in param_grid
            my_fixed_params,
            likelihood_args = my_likelihood_args,
            return_grid_nlls = true, 
            return_trial_posteriors = true, 
            return_model_posteriors = true
        );
    end
    elapsed_min = round(elapsed_sec/60, digits=1);
    println("Participant $(k) took $(elapsed_min) minutes.")

    # Results
    mle = output[:mle];
    nll_df = output[:grid_nlls];
    trial_posteriors = output[:trial_posteriors];
    model_posteriors = output[:model_posteriors];

    # Model posteriors
    posteriors_df = DataFrame();
    for (k, v) in model_posteriors
        cur_row = DataFrame([k]);
        cur_row.posterior = [v];
        posteriors_df = vcat(posteriors_df, cur_row, cols=:union);
    end;
    sort!(posteriors_df, :posterior, order = Base.Order.Reverse);

    # Model comparison
    gdf = groupby(posteriors_df, :likelihood_fn);
    combdf = combine(gdf, :posterior => sum);

    # Save it all in temp folder
    CSV.write(tempdir * "mle/mle_$(k).csv", mle);
    CSV.write(tempdir * "nll_df/nll_df_$(k).csv", nll_df);
    CSV.write(tempdir * "model_posteriors/model_posteriors_$(k).csv", model_posteriors);
    CSV.write(tempdir * "model_posteriors/posteriors_df_$(k).csv", posteriors_df);
    CSV.write(tempdir * "model_comparison/combdf_$(k).csv", combdf);

end