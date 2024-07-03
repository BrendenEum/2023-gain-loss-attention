# For the terminal:
# cd "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_fitting"
# julia --project=/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_fitting/ADDM.jl --threads=4 "RaDDM_fit_Loss.jl"

##############################################
# Preamble
##############################################

# Libraries and directories
#using ADDM, CSV, DataFrames, DataFramesMeta, Distributed, Distributions, LinearAlgebra, Base.Threads

#---------------------------------------------------------------------------------------
# THINGS TO CHANGE

# Output directory
predir = "results_AddDDM_Loss/"
most_recent_run = open(predir * "most_recent_run.txt", "r") do file
    read(file, String)
end
outdir = predir * most_recent_run * "/";

# Participants
study_participants = collect(1:27);
#---------------------------------------------------------------------------------------

# Data should be carried over from running RaDDM_simulate_*.jl
full_data = SimulatedDataList;

# Likelihood functions
include("../aDDM_fitting/custom_functions/AddDDM_likelihood.jl");
include("../aDDM_fitting/custom_functions/RaDDM_likelihood.jl");

# Fitting options
my_likelihood_args = (timeStep = 10.0, stateStep = 0.01);
my_fixed_params = Dict(:barrier=>1, :decay=>0, :bias=>0, :nonDecisionTime=>100);


##############################################
# Parameter grid for all models is less resolution than final fitting
##############################################

# AddDDM
tmp = DataFrame(CSV.File("parameter_grids/AddDDM_grid.csv", delim=","));
tmp.likelihood_fn .= "AddDDM_likelihood";
param_grid1 = NamedTuple.(eachrow(tmp));

# RaDDM: FreeRef
tmp = DataFrame(CSV.File("parameter_grids/RaDDM_grid.csv", delim=","));
tmp.likelihood_fn .= "RaDDM_likelihood";
param_grid2 = NamedTuple.(eachrow(tmp));

# Combine the grids
param_grid = vcat(param_grid1, param_grid2);

##############################################
# Loop through all participants and save
##############################################

Threads.@threads for k in study_participants

    # Subset data
    println("Starting Participant $(k).")
    subj_data = full_data[k];

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
    CSV.write(outdir * "mle_$(k).csv", mle);
    CSV.write(outdir * "posteriors_df_$(k).csv", posteriors_df);
    CSV.write(outdir * "combdf_$(k).csv", combdf);

end