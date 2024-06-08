##########################################
# Preamble
##########################################

# Libraries, seeds, and directories
using ADDM, CSV, DataFrames, DataFramesMeta, Distributed, Distributions, LinearAlgebra, Base.Threads, Dates
using IterTools: product
seed = 1337;
fitdir = "../aDDM_fitting/"

# ------------------------------------------------------------------------------------
# Things to change!

# What is the data generating process and condition?
predir = "results_RaDDM_Loss/";

# Custom functions
include("custom_simulators/RaDDM_simulate_trial.jl")
simulator_fn = RaDDM_simulate_trial;

# Stimuli for loss simulations
expdata = fitdir * "data/study2L_expdata.csv";
fixdata = fitdir * "data/study2L_fixations.csv";

# Parameter values for parameter recovery exercise 
d_grid = [.003, .007];
σ_grid = [.03, .07];
θ_grid = [.1, .5, .9];
ref_grid = [-12, 0, 12];
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
Stims = ADDM.process_stimuli(data, 81);
Fixations = ADDM.process_fixations(data, fixDistType="simple");

# Param grid to simulate with
sim_grid = collect(product(d_grid, σ_grid, θ_grid, ref_grid));
sim_grid_df = DataFrame(sim_grid, ["d", "sigma", "theta", "ref"]);
CSV.write(outdir * "sim_grid.csv", sim_grid_df);


##########################################
# Simulate Data
##########################################

# Placeholder
SimulatedDataList = [];
SimDataBehList = [];
SimDataFixList = [];

# Loop through parameter combinations
for i in 1:nrow(sim_grid_df)

    # Get the row
    row = sim_grid_df[i,:]

    # Define the model object
    MyModel = ADDM.define_model(d = row.d, σ = row.sigma, θ = row.theta, η = 0.0, bias = 0.0, nonDecisionTime = 100, decay = 0.0);
    MyModel.ref = row.ref;

    # Simulate data using the model object (with default settings: 10ms timeSteps, 100000 timeStep cutoff)
    MyArgs = (timeStep = 10.0, cutOff = 20000, fixationData = Fixations);
    SimulatedData = ADDM.simulate_data(MyModel, Stims, simulator_fn, MyArgs);
    push!(SimulatedDataList, SimulatedData)

    # Save SimData
    SimDataDf = ADDM.process_simulations(SimulatedData); # [1]=Behavioral, [2]=Fixations
    push!(SimDataBehList, SimDataDf[1]);
    CSV.write(outdir * "sim_data_beh_$(i).csv", SimDataDf[1])
    push!(SimDataFixList, SimDataDf[2]);
    CSV.write(outdir * "sim_data_fix_$(i).csv", SimDataDf[2])
    
end
