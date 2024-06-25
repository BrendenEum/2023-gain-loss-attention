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

timeStep = 10.0; # ms
approxStateStep = 0.01; # the approximate resolution of the relative-decision-variable space
simCutoff = 100000; # maximum decision time for one simulated choice
numFixDists = 2; # How many fixation distributions? (2 = firstFix, MiddleFix)


#############
# Prep likelihood and simulator functions
#############
include("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/parameter_recovery/custom_simulators/RaDDM_simulate_trial.jl")

#############
# Prep output folder
#############
prdir = "../../outputs/temp/out_of_sample_simulations/" * Dates.format(now(), "yyyy.mm.dd.H.M") * "/";
mkpath(prdir);


##################################################################################################################
# Study 1
##################################################################################################################
study = "Study1";      # ! ! !
studyN = 1;      # ! ! !
studyName = "dots"      # ! ! !
println(study)
m = "RaDDM";      # ! ! !
println("== GEN: " * m * " ==")
flush(stdout)
outdir = prdir * "/" * m * "/";
mkpath(outdir);
simulator_fn = RaDDM_simulate_trial      # ! ! !


############# 
# Gain
#############
condition = "Gain"
println("= "*condition*" =")
flush(stdout)
Random.seed!(seed)

# SIM: Parameters     
estimates = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_analysis/RaDDM_IndividualEstimates_E.csv", DataFrame)
subset_estimates = filter(row ->(row.study == studyN && row.condition == condition), estimates)
model_list = [];
for row in eachrow(subset_estimates)
    model = ADDM.define_model(
        d = row.d,
        σ = row.sigma,
        θ = row.theta,
        bias = 0,
        nonDecisionTime = 100,
        decay = 0
    )
    model.ref = row.ref;
    model.subject = row.subject;
    push!(model_list, model);
end
 # SIM: Data
expdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/"*studyName*"/e/expdata"*condition*"_test.csv", DataFrame);
fixdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/"*studyName*"/e/fixations"*condition*"_test.csv", DataFrame);

# DO SIM
for subject in subset_estimates.subject

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
            cur_fix_df[!, :studyN] .= studyN
            cur_fix_df[!, :parcode] .= subject
            cur_fix_df[!, :trial] .= i  
            cur_fix_df[!, :sim] .= sim
            cur_fix_df[!, :condition] .= condition
            SimDataFixDf = vcat(SimDataFixDf, cur_fix_df, cols=:union)
            # "parcode","trial","rt","choice","item_left","item_right"
            cur_beh_df = DataFrame(:studyN => studyN, :parcode => subject, :trial => i, :condition => condition, :sim => sim, :choice => cur_trial.choice, :rt => cur_trial.RT, :item_left => cur_trial.valueLeft, :item_right => cur_trial.valueRight, :LProb => cur_trial.LProb, :LAmt => cur_trial.LAmt, :RProb => cur_trial.RProb, :RAmt => cur_trial.RAmt)
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

# SIM: Parameters      
subset_estimates = filter(row ->(row.study == studyN && row.condition == condition), estimates)
model_list = [];
for row in eachrow(subset_estimates)
    model = ADDM.define_model(
        d = row.d,
        σ = row.sigma,
        θ = row.theta,
        bias = 0,
        nonDecisionTime = 100,
        decay = 0
    )
    model.ref = row.ref;
    model.subject = row.subject;
    push!(model_list, model);
end
 # SIM: Data
 expdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/"*studyName*"/e/expdata"*condition*"_test.csv", DataFrame);
 fixdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/"*studyName*"/e/fixations"*condition*"_test.csv", DataFrame);

# DO SIM
for subject in subset_estimates.subject

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
            cur_fix_df[!, :studyN] .= studyN
            cur_fix_df[!, :parcode] .= subject
            cur_fix_df[!, :trial] .= i  
            cur_fix_df[!, :condition] .= condition
            cur_fix_df[!, :sim] .= sim
            SimDataFixDf = vcat(SimDataFixDf, cur_fix_df, cols=:union)
            # "parcode","trial","rt","choice","item_left","item_right"
            cur_beh_df = DataFrame(:studyN => studyN, :parcode => subject, :trial => i, :condition => condition, :sim => sim, :choice => cur_trial.choice, :rt => cur_trial.RT, :item_left => cur_trial.valueLeft, :item_right => cur_trial.valueRight, :LProb => cur_trial.LProb, :LAmt => cur_trial.LAmt, :RProb => cur_trial.RProb, :RAmt => cur_trial.RAmt)
            SimDataBehDf = vcat(SimDataBehDf, cur_beh_df, cols=:union)
        end
        #CSV.write(outdir * "sim_data_beh.csv", SimDataBehDf)
        fn = "sim_data_beh_" * string(subject) * "_" * string(sim) * "_" * string(study) * "_" * string(condition) * ".csv"
        CSV.write(outdir * fn, SimDataBehDf)
        fn = "sim_data_fix_" * string(subject) * "_" * string(sim) * "_" * string(study) * "_" * string(condition) * ".csv"
        CSV.write(outdir * fn, SimDataFixDf)

    end
end


##################################################################################################################
# Study 2
##################################################################################################################
study = "Study2";      # ! ! !
studyN = 2;      # ! ! !
studyName = "numeric"      # ! ! !
println(study)
m = "RaDDM";      # ! ! !
println("== GEN: " * m * " ==")
flush(stdout)
outdir = prdir * "/" * m * "/";
mkpath(outdir);
simulator_fn = RaDDM_simulate_trial      # ! ! !


############# 
# Gain
#############
condition = "Gain"
println("= "*condition*" =")
flush(stdout)
Random.seed!(seed)

# SIM: Parameters      # ! ! !
estimates = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM_analysis/RaDDM_IndividualEstimates_E.csv", DataFrame)
subset_estimates = filter(row ->(row.study == studyN && row.condition == condition), estimates)
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
    model.ref = row.ref;
    push!(model_list, model);
    push!(subject_list, row.subject);
end
 # SIM: Data
expdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/"*studyName*"/j/expdata"*condition*"_test.csv", DataFrame);
fixdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/"*studyName*"/j/fixations"*condition*"_test.csv", DataFrame);

# DO SIM
for subject in 1:length(subject_list)

    println(subject_list[subject])
    MyModel = model_list[subject];

    ############################### Prep experiment data
    simdir = "../../outputs/temp/out_of_sample_simulations/sim_exp_fix_temp/";
    mkpath(simdir);
    subset_expdata = filter(row ->(row.parcode == subject_list[subject]), expdata_raw);
    subset_fixdata = filter(row ->(row.parcode == subject_list[subject]), fixdata_raw);
    CSV.write(simdir*"expdata.csv", subset_expdata);
    CSV.write(simdir*"fixdata.csv", subset_fixdata);
    expdata = simdir * "expdata.csv";
    fixdata = simdir * "fixdata.csv";
    data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);

    nTrials = nrow(subset_expdata);
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
            cur_fix_df[!, :studyN] .= studyN
            cur_fix_df[!, :parcode] .= subject_list[subject]
            cur_fix_df[!, :trial] .= i  
            cur_fix_df[!, :condition] .= condition
            cur_fix_df[!, :sim] .= sim
            SimDataFixDf = vcat(SimDataFixDf, cur_fix_df, cols=:union)
            # "parcode","trial","rt","choice","item_left","item_right"
            cur_beh_df = DataFrame(:studyN => studyN, :parcode => subject_list[subject], :trial => i, :condition => condition, :sim => sim, :choice => cur_trial.choice, :rt => cur_trial.RT, :item_left => cur_trial.valueLeft, :item_right => cur_trial.valueRight, :LProb => cur_trial.LProb, :LAmt => cur_trial.LAmt, :RProb => cur_trial.RProb, :RAmt => cur_trial.RAmt)
            SimDataBehDf = vcat(SimDataBehDf, cur_beh_df, cols=:union)
        end
        #CSV.write(outdir * "sim_data_beh.csv", SimDataBehDf)
        fn = "sim_data_beh_" * string(subject_list[subject]) * "_" * string(sim) * "_" * string(study) * "_" * string(condition) * ".csv"
        CSV.write(outdir * fn, SimDataBehDf)
        fn = "sim_data_fix_" * string(subject_list[subject]) * "_" * string(sim) * "_" * string(study) * "_" * string(condition) * ".csv"
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
subset_estimates = filter(row ->(row.study == studyN && row.condition == condition), estimates)
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
    model.ref = row.ref;
    push!(model_list, model);
    push!(subject_list, row.subject);
end
 # SIM: Data
 expdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/"*studyName*"/e/expdata"*condition*"_test.csv", DataFrame);
 fixdata_raw = CSV.read("/Users/brenden/Desktop/2023-gain-loss-attention/data/processed_data/"*studyName*"/e/fixations"*condition*"_test.csv", DataFrame);

# DO SIM
for subject in 1:length(subject_list)

    println(subject_list[subject])
    MyModel = model_list[subject];

    ############################### Prep experiment data
    simdir = "../../outputs/temp/out_of_sample_simulations/sim_exp_fix_temp/";
    mkpath(simdir);
    subset_expdata = filter(row ->(row.parcode == subject_list[subject]), expdata_raw);
    subset_fixdata = filter(row ->(row.parcode == subject_list[subject]), fixdata_raw);
    CSV.write(simdir*"expdata.csv", subset_expdata);
    CSV.write(simdir*"fixdata.csv", subset_fixdata);
    expdata = simdir * "expdata.csv";
    fixdata = simdir * "fixdata.csv";
    data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);

    nTrials = nrow(subset_expdata);
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
            cur_fix_df[!, :studyN] .= studyN
            cur_fix_df[!, :parcode] .= subject_list[subject]
            cur_fix_df[!, :trial] .= i  
            cur_fix_df[!, :condition] .= condition
            cur_fix_df[!, :sim] .= sim
            SimDataFixDf = vcat(SimDataFixDf, cur_fix_df, cols=:union)
            # "parcode","trial","rt","choice","item_left","item_right"
            cur_beh_df = DataFrame(:studyN => studyN, :parcode => subject_list[subject], :trial => i, :condition => condition, :sim => sim, :choice => cur_trial.choice, :rt => cur_trial.RT, :item_left => cur_trial.valueLeft, :item_right => cur_trial.valueRight, :LProb => cur_trial.LProb, :LAmt => cur_trial.LAmt, :RProb => cur_trial.RProb, :RAmt => cur_trial.RAmt)
            SimDataBehDf = vcat(SimDataBehDf, cur_beh_df, cols=:union)
        end
        #CSV.write(outdir * "sim_data_beh.csv", SimDataBehDf)
        fn = "sim_data_beh_" * string(subject_list[subject]) * "_" * string(sim) * "_" * string(study) * "_" * string(condition) * ".csv"
        CSV.write(outdir * fn, SimDataBehDf)
        fn = "sim_data_fix_" * string(subject_list[subject]) * "_" * string(sim) * "_" * string(study) * "_" * string(condition) * ".csv"
        CSV.write(outdir * fn, SimDataFixDf)

    end
end