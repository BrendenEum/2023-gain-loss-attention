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
ADDM.aDDM(
    Dict{Symbol, Any}(:nonDecisionTime => 100, :σ => 0.03, :d => 0.007, :bias => 0.0, :barrier => 1, :decay => 0, :θ => 0.6, :η => 0.0)
)

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

MyArgs = (timeStep = 10.0, cutOff = 20000, fixationData = MyFixationData);
SimData = ADDM.simulate_data(MyModel, MyStims, ADDM.aDDM_simulate_trial, MyArgs);

#############
# Recover parameters
#############

fn = "addm_grid.csv";
tmp = DataFrame(CSV.File(fn, delim=","));
param_grid = Dict(pairs(NamedTuple.(eachrow(tmp))));

my_likelihood_args = (timeStep = 10.0, approxStateStep = 0.01);

best_pars, all_nll_df = ADDM.grid_search(
    SimData, param_grid, ADDM.aDDM_get_trial_likelihood, 
    Dict(:η=>0.0, :barrier=>1, :decay=>0, :nonDecisionTime=>100, :bias=>0.0),
    likelihood_args=my_likelihood_args; 
    verbose=true);

#############
# Record output
#############

output_path = '/Users/brenden/Desktop/2023-gain-loss-attention/analysis/outputs/temp'
CSV.write(output_path, all_nll_df)