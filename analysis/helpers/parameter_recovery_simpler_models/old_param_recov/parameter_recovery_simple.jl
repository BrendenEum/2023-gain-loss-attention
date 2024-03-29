# Author: Brenden Eum (2024)
# If running this in vscode locally, you need to open up a shell REPL, run 'julia --project=<toolboxdir>', and run 'include("<yourscript.jl>")'. This opens julia with the ADDM environment and runs your code.

######################################################################################
# Preamble
######################################################################################

#############
# Libraries and settings
#############

using ADDM
using CSV
using DataFrames
using Random, Distributions, StatsBase
using Base.Threads
Random.seed!(4)
include("custom_aDDM_simulator.jl")
include("custom_aDDM_likelihood.jl")
timeStep = 10.0; # ms
approxStateStep = 0.01; # the approximate resolution of the relative-decision-variable space
simCutoff = 20000; # maximum decision time for one simulated choice
simCount = 10; # how many simulations to run per data generating process?

######################################################################################
# GAINS
######################################################################################

#############
# Every model-parameter combination that you want to simulate and test.
#############

sim_list_gain = Any[];

# aDDM
for i in 1:1
    model = ADDM.define_model(
        d = .003,
        σ = .02,
        bias = 0,
        θ = 1.5,
        nonDecisionTime = 100
    )
    model.η = 0.0;
    model.λ = 0.0;
    model.minValue = 0.0;
    model.range = 1.0;
    push!(sim_list_gain, model);
end

#############
# Things that don't vary within loop: stimuli and fixations for simulations
#############

# Stimuli
data = ADDM.load_data_from_csv("expdataLoss.csv", "fixationsLoss.csv"; stimsOnly=true);
nTrials = 100;
MyStims = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);

#Fixations
MyFixationData = ADDM.process_fixations(data, fixDistType="simple");

#############
# Iterate through each model-parameter combination using stimuli and fixaitons
#############

@elapsed begin
Threads.@threads for m in 1:length(sim_list_gain)

    # Simulate data
    MyModel = sim_list_gain[m]
    MyArgs = (timeStep = timeStep, cutOff = simCutoff, fixationData = MyFixationData);
    SimData = ADDM.simulate_data(MyModel, MyStims, custom_aDDM_simulator, MyArgs);

    # Fit the simulated data with the modified aDDM that nests all models
    fn = "addm_grid.csv";
    tmp = DataFrame(CSV.File(fn, delim=","));
    param_grid = Dict(pairs(NamedTuple.(eachrow(tmp))));

    fixed_params = Dict(:barrier=>1, :bias=>0.0, :nonDecisionTime=>100, :η=>0.0, :λ=>0, :minValue=>0.0, :range=>1.0);
    my_likelihood_args = (timeStep = timeStep, approxStateStep = approxStateStep);

    best_pars, all_nll_df = ADDM.grid_search(SimData, param_grid, custom_aDDM_likelihood, fixed_params, likelihood_args=my_likelihood_args; verbose=true, threadNum=Threads.threadid());

    sort!(all_nll_df, [:nll])

    # Record data generating model and output
    output_path = "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp/parameter_recovery/loss/model_$(m).txt";
    write(output_path, string(MyModel)); 
    output_path = "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp/parameter_recovery/loss/fit_$(m).csv";
    CSV.write(output_path, all_nll_df);

end
end