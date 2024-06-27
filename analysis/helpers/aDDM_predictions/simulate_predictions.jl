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
seed = 4;
simCount = 10; # how many simulations to run per data generating process?


#############
# Prep likelihood and simulator functions
#############
include("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/parameter_recovery/custom_simulators/aDDM_simulate_trial.jl")
include("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/parameter_recovery/custom_simulators/RaDDM_simulate_trial.jl")
include("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/parameter_recovery/custom_simulators/AddDDM_simulate_trial.jl")
include("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/parameter_recovery/custom_simulators/OPPaDDM_simulate_trial.jl")
include("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/parameter_recovery/custom_simulators/TrOPPaDDM_simulate_trial.jl")


#############
# Prep output folder
#############
datetime = Dates.format(now(), "yyyy.mm.dd.H.M");
outdir = "../../outputs/temp/model_predictions/" * datetime * "/";
mkpath(outdir);
file = open("most_recent_simulation.txt", "w")
write(file, datetime*"\n")
close(file)

#############
# Predict using Study 2 stimuli
#############

expdataGain_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/numeric/e/expdataGain_train.csv", DataFrame);
fixdataGain_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/numeric/e/fixationsGain_train.csv", DataFrame);
expdataLoss_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/numeric/e/expdataLoss_train.csv", DataFrame);
fixdataLoss_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/numeric/e/fixationsLoss_train.csv", DataFrame);

# Just keep the first subject's data
expdataGain_raw = filter(row ->(row.parcode == 201), expdataGain_raw)
fixdataGain_raw = filter(row ->(row.parcode == 201), fixdataGain_raw)
expdataLoss_raw = filter(row ->(row.parcode == 201), expdataLoss_raw)
fixdataLoss_raw = filter(row ->(row.parcode == 201), fixdataLoss_raw)
nTrials = nrow(expdataGain_raw);

simdir = "../../outputs/temp/model_predictions/sim_exp_fix_temp/";
mkpath(simdir);
CSV.write(simdir*"expdataGain.csv", expdataGain_raw);
CSV.write(simdir*"fixdataGain.csv", fixdataGain_raw);
CSV.write(simdir*"expdataLoss.csv", expdataLoss_raw);
CSV.write(simdir*"fixdataLoss.csv", fixdataLoss_raw);

expdataGain = simdir*"expdataGain.csv";
fixdataGain = simdir*"fixdataGain.csv";
expdataLoss = simdir*"expdataLoss.csv";
fixdataLoss = simdir*"fixdataLoss.csv";


#############
# Function: Loop through estimates csv and simulate
#############

function simulate_data(estimates, condition, expdata, fixdata, nTrials, simCount, simulator_fn, modelname)

    # Make a list of parameter combinations
    subset_estimates = filter(row ->(row.condition == condition), estimates)
    model_list = [];
    subject_list = [];
    for row in eachrow(subset_estimates)
        model = ADDM.define_model(
            d = row.d,
            σ = row.sigma,
            θ = row.theta,
            bias = 0,
            nonDecisionTime = 100,
            decay = 0
        )
        model.η = row.eta
        push!(model_list, model);
        push!(subject_list, row.subject);
    end

    # Loop through subjects
    for subject in 1:length(subject_list)

        println(subject_list[subject])
        MyModel = model_list[subject];
    
        # Get stimuli and fixations
        data = ADDM.load_data_from_csv(expdata, fixdata);
    
        Stims = (
            valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], 
            valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials],
            LProb = reduce(vcat, [[i.LProb for i in data[j]] for j in keys(data)])[1:nTrials],
            LAmt = reduce(vcat, [[i.LAmt for i in data[j]] for j in keys(data)])[1:nTrials],
            RProb = reduce(vcat, [[i.RProb for i in data[j]] for j in keys(data)])[1:nTrials],
            RAmt = reduce(vcat, [[i.RAmt for i in data[j]] for j in keys(data)])[1:nTrials],
            minOutcome = reduce(vcat, [[i.minOutcome for i in data[j]] for j in keys(data)])[1:nTrials],
            maxOutcome = reduce(vcat, [[i.maxOutcome for i in data[j]] for j in keys(data)])[1:nTrials]
        );
        Fixations = ADDM.process_fixations(data, fixDistType="simple", numFixDists = 2);
    
        # Simulate
        for sim in 1:simCount
            
            MyArgs = (timeStep = 10, cutOff = 100000, fixationData = Fixations, numFixDists = 2); # numFixDists=2: use first and middle fixations.
            SimData = ADDM.simulate_data(MyModel, Stims, simulator_fn, MyArgs);
    
            # Make SimData
            SimDataBehDf = DataFrame()
            SimDataFixDf = DataFrame()
            for (i, cur_trial) in enumerate(SimData)
                cur_fix_df = DataFrame(:fix_item => cur_trial.fixItem, :fix_time => cur_trial.fixTime)
                cur_fix_df[!, :parcode] .= subject_list[subject]
                cur_fix_df[!, :trial] .= i  
                cur_fix_df[!, :condition] .= condition
                cur_fix_df[!, :sim] .= sim
                SimDataFixDf = vcat(SimDataFixDf, cur_fix_df, cols=:union)
                cur_beh_df = DataFrame(:parcode => subject_list[subject], :trial => i, :condition => condition, :sim => sim, :choice => cur_trial.choice, :rt => cur_trial.RT, :item_left => cur_trial.valueLeft, :item_right => cur_trial.valueRight, :LProb => cur_trial.LProb, :LAmt => cur_trial.LAmt, :RProb => cur_trial.RProb, :RAmt => cur_trial.RAmt)
                SimDataBehDf = vcat(SimDataBehDf, cur_beh_df, cols=:union)
            end
            
            # Save data
            mdir = outdir * string(modelname) * "/";
            mkpath(mdir);
            fn = "sim_data_beh_" * string(subject_list[subject]) * "_" * string(sim) * "_" * string(condition) * ".csv"
            CSV.write(mdir * fn, SimDataBehDf)
            fn = "sim_data_fix_" * string(subject_list[subject]) * "_" * string(sim) * "_" * string(condition) * ".csv"
            CSV.write(mdir * fn, SimDataFixDf)
        end
    end
end


##################################################################################################################
# Predictions based on Study 2 Gains and Losses
##################################################################################################################


#############
# Standard aDDM
#############
modelname = "aDDM";
println(modelname)

estimates = CSV.read("SimIndividualEstimates_aDDM.csv" ,DataFrame);
simulator_fn = aDDM_simulate_trial

# Gain
condition = "Gain";
simulate_data(estimates, condition, expdataGain, fixdataGain, nTrials, simCount, simulator_fn, modelname)

# Loss
condition = "Loss";
simulate_data(estimates, condition, expdataLoss, fixdataLoss, nTrials, simCount, simulator_fn, modelname)


#############
# Unbounded aDDM
#############
modelname = "UaDDM";
println(modelname)

estimates = CSV.read("SimIndividualEstimates_UaDDM.csv" ,DataFrame);
simulator_fn = aDDM_simulate_trial

# Gain
condition = "Gain";
simulate_data(estimates, condition, expdataGain, fixdataGain, nTrials, simCount, simulator_fn, modelname)

# Loss
condition = "Loss";
simulate_data(estimates, condition, expdataLoss, fixdataLoss, nTrials, simCount, simulator_fn, modelname)


#############
# OPPaDDM
#############
modelname = "OPPaDDM";
println(modelname)

estimates = CSV.read("SimIndividualEstimates_OPPaDDM.csv" ,DataFrame);
simulator_fn = OPPaDDM_simulate_trial

# Gain
condition = "Gain";
simulate_data(estimates, condition, expdataGain, fixdataGain, nTrials, simCount, simulator_fn, modelname)

# Loss
condition = "Loss";
simulate_data(estimates, condition, expdataLoss, fixdataLoss, nTrials, simCount, simulator_fn, modelname)


#############
# TrOPPaDDM
#############
modelname = "TrOPPaDDM";
println(modelname)

estimates = CSV.read("SimIndividualEstimates_TrOPPaDDM.csv" ,DataFrame);
simulator_fn = TrOPPaDDM_simulate_trial

# Gain
condition = "Gain";
simulate_data(estimates, condition, expdataGain, fixdataGain, nTrials, simCount, simulator_fn, modelname)

# Loss
condition = "Loss";
simulate_data(estimates, condition, expdataLoss, fixdataLoss, nTrials, simCount, simulator_fn, modelname)


#############
# AddDDM
#############
modelname = "AddDDM";
println(modelname)

estimates = CSV.read("SimIndividualEstimates_AddDDM.csv" ,DataFrame);
simulator_fn = AddDDM_simulate_trial

# Gain
condition = "Gain";
simulate_data(estimates, condition, expdataGain, fixdataGain, nTrials, simCount, simulator_fn, modelname)

# Loss
condition = "Loss";
simulate_data(estimates, condition, expdataLoss, fixdataLoss, nTrials, simCount, simulator_fn, modelname)


#############
# RaDDM
#############
modelname = "RaDDM";
println(modelname)

estimates = CSV.read("SimIndividualEstimates_RaDDM.csv" ,DataFrame);
simulator_fn = RaDDM_simulate_trial

# Gain
condition = "Gain";
simulate_data(estimates, condition, expdataGain, fixdataGain, nTrials, simCount, simulator_fn, modelname)

# Loss
condition = "Loss";
simulate_data(estimates, condition, expdataLoss, fixdataLoss, nTrials, simCount, simulator_fn, modelname)