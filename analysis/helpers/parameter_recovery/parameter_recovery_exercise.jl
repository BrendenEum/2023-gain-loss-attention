# Author: Brenden Eum (2024)
# If running this in vscode locally, you need to open up a shell REPL, run 'julia --project=<toolboxdir>', and run 'include("<yourscript.jl>")'. This opens julia with the ADDM environment and runs your code.

#############
# Preamble
#############

using ADDM
using CSV
using DataFrames

#############
# Define model
#############

MyModel = ADDM.define_model(d = 0.007, σ = 0.03, θ = .6, barrier = 1, decay = 0, nonDecisionTime = 100, bias = 0.0)
MyModel.barrier = 1;
MyModel.λ = 1;
MyModel.η = 1;

#############
# Define stimuli
#############

data = ADDM.load_data_from_csv("testexpdataLoss.csv", "testfixationsLoss.csv"; stimsOnly=true);
nTrials = 100;
MyStims = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);

#############
# Define fixation data
#############

MyFixationData = ADDM.process_fixations(data, fixDistType="simple");

#############
# Simulate data
#############

include("custom_aDDM_simulator.jl")
MyArgs = (timeStep = 10.0, cutOff = 20000, fixationData = MyFixationData);
SimData = ADDM.simulate_data(MyModel, MyStims, custom_aDDM_simulator, MyArgs);

#############
# Recover parameters
#############

include("custom_aDDM_likelihood.jl")

fn = "addm_grid.csv";
tmp = DataFrame(CSV.File(fn, delim=","));
param_grid = Dict(pairs(NamedTuple.(eachrow(tmp))));

my_likelihood_args = (timeStep = 10.0, approxStateStep = 0.01);
fixed_params = Dict(:η=>0.0, :barrier=>1, :decay=>0, :nonDecisionTime=>100, :bias=>0.0);

best_pars, all_nll_df = ADDM.grid_search(SimData, param_grid, custom_aDDM_likelihood, fixed_params,             likelihood_args=my_likelihood_args; verbose=true);

sort!(all_nll_df, [:nll])

#############
# Record output
#############

output_path = "/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp/all_nll_df.csv";
CSV.write(output_path, all_nll_df);