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
simCount = 20; # how many simulations to run per data generating process?

#############
# Things you might want to change           ! ! !
#############
timeStep = 10.0; # ms
simCutoff = 100000; # maximum decision time for one simulated choice

#############
# Prep likelihood and simulator functions
#############
include("../parameter_recovery/custom_functions/aDDM_simulator.jl")
include("../parameter_recovery/custom_functions/AddDDM_simulator.jl")
include("../parameter_recovery/custom_functions/RaDDM_simulator.jl")

#############
# Prep experiment data
#############
expdata = "../parameter_recovery/expdataGain.csv";
fixdata = "../parameter_recovery/fixationsGain.csv";
data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);
nTrials = 81;
Stims_Gain = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);
Fixations_Gain = ADDM.process_fixations(data, fixDistType="simple");
expdata = "../parameter_recovery/expdataLoss.csv";
fixdata = "../parameter_recovery/fixationsLoss.csv";
data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);
nTrials = 81;
Stims_Loss = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);
Fixations_Loss = ADDM.process_fixations(data, fixDistType="simple");

#############
# Prep output folder
#############
prdir = "../../outputs/temp/model_predictions/" * Dates.format(now(), "yyyy.mm.dd.H.M") * "/";
mkpath(prdir);

##################################################################################################################
# Simulate
##################################################################################################################
m = "aDDM"      # ! ! !
println("== GEN: " * m * " ==")
flush(stdout)
outdir = prdir * "/" * m * "/";
mkpath(outdir);
simulator_fn = aDDM_simulator      # ! ! !


############# 
# Gain
#############
condition = "Gain"
println("= "*condition*" =")
flush(stdout)
Random.seed!(seed)

# SIM: Parameters      # ! ! !
model_list = Any[];
for i in 1:simCount
    model = ADDM.define_model(
        d = sample([.005, .006, .007]),
        σ = sample([.03, .04, .05, .06]),
        θ = sample([.25, .5, .75]),
        bias = sample([-.2, -.1, 0, .1, .2]),
        nonDecisionTime = 100,
        decay = 0
    ) 
    push!(model_list, model);
end

sim_list = Any[];
for m in 1:length(model_list)
    if (condition=="Gain")
        MyStims = Stims_Gain;
        MyFixationData = Fixations_Gain;
    elseif (condition=="Loss")
        MyStims = Stims_Loss;
        MyFixationData = Fixations_Loss;
    end
    MyModel = model_list[m];
    MyArgs = (timeStep = timeStep, cutOff = simCutoff, fixationData = MyFixationData);
    SimData = ADDM.simulate_data(MyModel, MyStims, simulator_fn, MyArgs);
    push!(sim_list, SimData);
end