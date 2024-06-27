##########################################
# Preamble
##########################################

# Libraries, seeds, and directories
using ADDM, CSV, DataFrames, DataFramesMeta, Distributed, Distributions, LinearAlgebra, Base.Threads, Dates
using IterTools:product
seed = 1337;

# ------------------------------------------------------------------------------------
# Things to change!

# What is the data generating process and condition?
predir = "results_RaDDM_Loss/";

# Custom functions
include("custom_simulators/RaDDM_simulate_trial.jl")
simulator_fn = RaDDM_simulate_trial;

# Stimuli for loss simulations
expdata = "../../../data/processed_data/numeric/e/expdataLoss_train.csv";
fixdata = "../../../data/processed_data/numeric/e/fixationsLoss_train.csv";

# Parameter values for parameter recovery exercise 
d_grid = [.002, .005, .008];
σ_grid = [.02, .05, .08];
θ_grid = [.1, .5, .9];
# ------------------------------------------------------------------------------------

# Prep output foler
mkpath(predir);
most_recent_run = Dates.format(now(), "yyyy.mm.dd.H.M");
open(predir * "most_recent_run.txt", "w") do file
    write(file, most_recent_run)
end
outdir = predir * most_recent_run * "/";
mkpath(outdir);

# Process experiment and fixation data
data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);
Stims = ADDM.process_stimuli(data, 146);
Fixations = ADDM.process_fixations(data, fixDistType="simple");

# Param grid to simulate with
sim_grid = collect(product(d_grid, σ_grid, θ_grid));
sim_grid_df = DataFrame(sim_grid, ["d", "sigma", "theta"]);
CSV.write(outdir * "sim_grid.csv", sim_grid_df);


##########################################
# Simulate Data
##########################################

# Loop through parameter combinations
for subject in 1:nrow(sim_grid_df)

    # Get the row
    row = sim_grid_df[subject,:]

    # Define the model object
    MyModel = ADDM.define_model(d = row.d, σ = row.sigma, θ = row.theta, η = 0.0, bias = 0.0, nonDecisionTime = 100, decay = 0.0);

    # Simulate data using the model object (with default settings: 10ms timeSteps, 100000 timeStep cutoff)
    MyArgs = (timeStep = 10.0, cutOff = 20000, fixationData = Fixations);
    SimData = ADDM.simulate_data(MyModel, Stims, simulator_fn, MyArgs);

    # Make SimData
    SimDataBehDf = DataFrame()
    SimDataFixDf = DataFrame()
    for (i, cur_trial) in enumerate(SimData)
        cur_fix_df = DataFrame(:fix_item => cur_trial.fixItem, :fix_time => cur_trial.fixTime)
        cur_fix_df[!, :parcode] .= subject
        cur_fix_df[!, :trial] .= i  
        cur_fix_df[!, :condition] .= "Loss"
        SimDataFixDf = vcat(SimDataFixDf, cur_fix_df, cols=:union)
        cur_beh_df = DataFrame(:parcode => subject, :trial => i, :condition => "Loss", :choice => cur_trial.choice, :rt => cur_trial.RT, :item_left => cur_trial.valueLeft, :item_right => cur_trial.valueRight, :LProb => cur_trial.LProb, :LAmt => cur_trial.LAmt, :RProb => cur_trial.RProb, :RAmt => cur_trial.RAmt)
        SimDataBehDf = vcat(SimDataBehDf, cur_beh_df, cols=:union)
    end
    
    # Save data
    fn = "sim_data_beh_" * string(subject) * "_" * ".csv"
    CSV.write(outdir * fn, SimDataBehDf)
    fn = "sim_data_fix_" * string(subject) * "_" * ".csv"
    CSV.write(outdir * fn, SimDataFixDf)
    
end
