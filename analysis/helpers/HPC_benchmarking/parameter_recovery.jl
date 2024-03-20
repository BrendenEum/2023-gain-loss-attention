# Author: Brenden Eum (2024)
# If running this in vscode locally, you need to open up a shell REPL, run 'julia --project=<toolboxdir>', and run 'include("<yourscript.jl>")'. This opens julia with the ADDM environment and runs your code.
@elapsed begin
        
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
    seed = 4;
    simCount = 1; # how many simulations to run per data generating process?
    include("sim_and_fit.jl")
    """
    These options are the defaults for the arguments in sim_and_fit().
    timeStep = 10.0; # ms
    approxStateStep = 0.01; # the approximate resolution of the relative-decision-variable space
    simCutoff = 20000; # maximum decision time for one simulated choice
    verbose = true; # show progress
    """


    #############
    # Prep experiment data
    #############
    expdata = "expdataGain.csv";
    fixdata = "fixationsGain.csv";
    data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);
    nTrials = 81;
    Stims_Gain = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);
    Fixations_Gain = ADDM.process_fixations(data, fixDistType="simple");
    expdata = "expdataLoss.csv";
    fixdata = "fixationsLoss.csv";
    data = ADDM.load_data_from_csv(expdata, fixdata; stimsOnly=true);
    nTrials = 81;
    Stims_Loss = (valueLeft = reduce(vcat, [[i.valueLeft for i in data[j]] for j in keys(data)])[1:nTrials], valueRight = reduce(vcat, [[i.valueRight for i in data[j]] for j in keys(data)])[1:nTrials]);
    Fixations_Loss = ADDM.process_fixations(data, fixDistType="simple");


    #############
    # Prep likelihood and simulator functions
    #############
    include("custom_functions/aDDM_likelihood.jl")
    include("custom_functions/aDDM_simulator.jl")


    #############
    # Prep parameter grid (param_grid)
    #############
    include("make_parameter_grid.jl")


    ##################################################################################################################
    # GEN: Standard aDDM
    ##################################################################################################################
    m = "aDDM"      # ! ! !
    println("== GEN: " * m * " ==")
    flush(stdout)
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
            d = sample([.002, .005, .008]),
            σ = sample([.02, .05, .08]),
            θ = sample([0, .5, .9]),
            bias = 0.0
        ) 
        model.λ = 0.0
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)

    # DO SIM AND FIT
    sim_and_fit(model_list, condition, simulator_fn, param_grid, fixed_params)

end