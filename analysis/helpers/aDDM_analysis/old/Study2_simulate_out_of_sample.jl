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
simCount = 10; # how many simulations to run per data generating process?

timeStep = 10.0; # ms
approxStateStep = 0.01; # the approximate resolution of the relative-decision-variable space
simCutoff = 100000; # maximum decision time for one simulated choice
numFixDists = 2; # How many fixation distributions? (2 = firstFix, MiddleFix)


#############
# Prep likelihood and simulator functions
#############
include("custom_functions/aDDM_simulator.jl")
include("custom_functions/AddDDM_simulator.jl")
include("custom_functions/RaDDM_simulator.jl")

#############
# Prep output folder
#############
prdir = "../../outputs/temp/out_of_sample_simulations/" * Dates.format(now(), "yyyy.mm.dd.H.M") * "/";
mkpath(prdir);


##################################################################################################################
# Study 1
##################################################################################################################
study = "Study2"
m = "RaDDM"      # ! ! !
println("== GEN: " * m * " ==")
flush(stdout)
outdir = prdir * "/" * m * "/";
mkpath(outdir);
simulator_fn = RaDDM_simulator      # ! ! !


############# 
# Gain
#############
condition = "Gain"
println("= "*condition*" =")
flush(stdout)
Random.seed!(seed)

# SIM: Parameters      # ! ! !
estimates = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp/out_of_sample_simulations/study2estimates.csv", DataFrame)
subset_estimates = filter(row ->(row.study == 2 && row.condition == condition), estimates)
model_list = [];
for row in eachrow(subset_estimates)
    model = ADDM.define_model(
        d = row.d,
        σ = row.sigma,
        θ = row.theta,
        bias = row.bias,
        nonDecisionTime = 100,
        decay = 0
    )
    model.reference = row.reference;
    model.subject = row.subject;
    push!(model_list, model);
end
 # SIM: Data
expdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/dots/e/expdata"*condition*".csv", DataFrame);
fixdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/dots/e/fixations"*condition*".csv", DataFrame);

# DO SIM
for subject in 1:length(model_list)

    println(subject)
    MyModel = model_list[subject];

    ############################### Prep experiment data
    simdir = "../../outputs/temp/out_of_sample_simulations/sim_exp_fix_temp/";
    mkpath(simdir);
    subset_expdata = filter(row ->(row.parcode == MyModel.subject), expdata_raw);
    subset_fixdata = filter(row ->(row.parcode == MyModel.subject), fixdata_raw);
    CSV.write(simdir*"expdata.csv", subset_expdata);
    CSV.write(simdir*"fixdata.csv", subset_fixdata);
    expdata = simdir * "expdata.csv";
    fixdata = simdir * "fixdata.csv";
    data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);

    nTrials = nrow(subset_expdata);
    Stims = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);
    Fixations = ADDM.process_fixations(data, fixDistType="simple", numFixDists = 2);

    ############################### Simulate data
    for sim in 1:simCount
        
        MyArgs = (timeStep = timeStep, cutOff = simCutoff, fixationData = Fixations, numFixDists = numFixDists);
        SimData = ADDM.simulate_data(MyModel, Stims, simulator_fn, MyArgs);

        # Save SimData
        SimDataBehDf = DataFrame()
        SimDataFixDf = DataFrame()
        for (i, cur_trial) in enumerate(SimData)
            # "parcode","trial","fix_time","fix_item"
            cur_fix_df = DataFrame(:fix_item => cur_trial.fixItem, :fix_time => cur_trial.fixTime)
            cur_fix_df[!, :parcode] .= subject
            cur_fix_df[!, :trial] .= i  
            cur_fix_df[!, :sim] .= sim
            SimDataFixDf = vcat(SimDataFixDf, cur_fix_df, cols=:union)
            # "parcode","trial","rt","choice","item_left","item_right"
            cur_beh_df = DataFrame(:parcode => subject, :trial => i, :sim => sim, :choice => cur_trial.choice, :rt => cur_trial.RT, :item_left => cur_trial.valueLeft, :item_right => cur_trial.valueRight)
            SimDataBehDf = vcat(SimDataBehDf, cur_beh_df, cols=:union)
        end
        #CSV.write(outdir * "sim_data_beh.csv", SimDataBehDf)
        fn = "sim_data_beh_" * string(subject) * "_" * string(sim) * "_" * string(study) * "_" * string(condition) * ".csv"
        CSV.write(outdir * fn, SimDataBehDf)
        fn = "sim_data_fix_" * string(subject) * "_" * string(sim) * "_" * string(study) * "_" * string(condition) * ".csv"
        CSV.write(outdir * fn, SimDataFixDf)

    end
end



############# 
# Loss
#############
condition = "Loss"
println("= "*condition*" =")
flush(stdout)
Random.seed!(seed)

# SIM: Parameters      # ! ! !
subset_estimates = filter(row ->(row.study == 1 && row.condition == condition), estimates)
model_list = [];
for row in eachrow(subset_estimates)
    model = ADDM.define_model(
        d = row.d,
        σ = row.sigma,
        θ = row.theta,
        bias = row.bias,
        nonDecisionTime = 100,
        decay = 0
    )
    model.reference = row.reference;
    model.subject = row.subject;
    push!(model_list, model);
end
 # SIM: Data
expdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/dots/e/expdata"*condition*".csv", DataFrame);
fixdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/dots/e/fixations"*condition*".csv", DataFrame);

# DO SIM
for subject in 1:length(model_list)

    println(subject)
    MyModel = model_list[subject];

    ############################### Prep experiment data
    simdir = "../../outputs/temp/out_of_sample_simulations/sim_exp_fix_temp/";
    mkpath(simdir);
    subset_expdata = filter(row ->(row.parcode == MyModel.subject), expdata_raw);
    subset_fixdata = filter(row ->(row.parcode == MyModel.subject), fixdata_raw);
    CSV.write(simdir*"expdata.csv", subset_expdata);
    CSV.write(simdir*"fixdata.csv", subset_fixdata);
    expdata = simdir * "expdata.csv";
    fixdata = simdir * "fixdata.csv";
    data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);

    nTrials = nrow(subset_expdata);
    Stims = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);
    Fixations = ADDM.process_fixations(data, fixDistType="simple", numFixDists = 2);

    ############################### Simulate data
    for sim in 1:simCount
        
        MyArgs = (timeStep = timeStep, cutOff = simCutoff, fixationData = Fixations, numFixDists = numFixDists);
        SimData = ADDM.simulate_data(MyModel, Stims, simulator_fn, MyArgs);

        # Save SimData
        SimDataBehDf = DataFrame()
        SimDataFixDf = DataFrame()
        for (i, cur_trial) in enumerate(SimData)
            # "parcode","trial","fix_time","fix_item"
            cur_fix_df = DataFrame(:fix_item => cur_trial.fixItem, :fix_time => cur_trial.fixTime)
            cur_fix_df[!, :parcode] .= subject
            cur_fix_df[!, :trial] .= i  
            cur_fix_df[!, :sim] .= sim
            SimDataFixDf = vcat(SimDataFixDf, cur_fix_df, cols=:union)
            # "parcode","trial","rt","choice","item_left","item_right"
            cur_beh_df = DataFrame(:parcode => subject, :trial => i, :sim => sim, :choice => cur_trial.choice, :rt => cur_trial.RT, :item_left => cur_trial.valueLeft, :item_right => cur_trial.valueRight)
            SimDataBehDf = vcat(SimDataBehDf, cur_beh_df, cols=:union)
        end
        #CSV.write(outdir * "sim_data_beh.csv", SimDataBehDf)
        fn = "sim_data_beh_" * string(subject) * "_" * string(sim) * "_" * string(study) * "_" * string(condition) * ".csv"
        CSV.write(outdir * fn, SimDataBehDf)
        fn = "sim_data_fix_" * string(subject) * "_" * string(sim) * "_" * string(study) * "_" * string(condition) * ".csv"
        CSV.write(outdir * fn, SimDataFixDf)

    end
end