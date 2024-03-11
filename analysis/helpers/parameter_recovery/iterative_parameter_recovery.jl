# Author: Brenden Eum (2024)
# If running this in vscode locally, you need to open up a shell REPL, run 'julia --project=<toolboxdir>', and run 'include("<yourscript.jl>")'. This opens julia with the ADDM environment and runs your code.

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
include("custom_aDDM_simulator.jl")
include("custom_aDDM_likelihood.jl")
include("sim_and_fit.jl")
seed = 4;
"""
These options are the defaults for the arguments in sim_and_fit().
timeStep = 10.0; # ms
approxStateStep = 0.01; # the approximate resolution of the relative-decision-variable space
simCutoff = 20000; # maximum decision time for one simulated choice
verbose = true; # show progress
"""
simCount = 8; # how many simulations to run per data generating process?

"""
##################################################################################################################
# (d, σ, θ)
##################################################################################################################
m = "dst"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :bias=>0.0, :nonDecisionTime=>100, :η=>0.0, :λ=>0, :minValue=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params) #models, condition, grid.csv, free_params (string; first letter), fixed_params (dictionary; greek)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(1,2),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :bias=>0.0, :nonDecisionTime=>100, :η=>0.0, :λ=>0, :minValue=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# (d, σ, θ, b)
##################################################################################################################
m = "dstb"
println("== " * m * " ==")
println(paste0("== ", m, " =="))
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = sample([-0.1,0.0,0.1], Weights([.2,.6,.2]), 1)[1],
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :η=>0.0, :λ=>0, :minValue=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = sample([-0.1,0.0,0.1], Weights([.2,.6,.2]), 1)[1],
            θ = round( rand(Uniform(1,2),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :η=>0.0, :λ=>0, :minValue=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# (d, σ, η)
##################################################################################################################
m = "dse"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = 1.0,
            nonDecisionTime = 100
        )
        model.η = round( rand(Uniform(0,.020),1)[1] ; digits=3);
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :theta=>1.0, :λ=>0, :bias=>0.0, :minValue=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = 1.0,
            nonDecisionTime = 100
        )
        model.η = round( rand(Uniform(0,.020),1)[1] ; digits=3);
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :theta=>1.0, :λ=>0, :bias=>0.0, :minValue=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# (d, σ, b, η)
##################################################################################################################
m = "dsbe"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = sample([-0.1,0.0,0.1], Weights([.2,.6,.2]), 1)[1],
            θ = 1.0,
            nonDecisionTime = 100
        )
        model.η = round( rand(Uniform(0,.020),1)[1] ; digits=3);
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :theta=>1.0, :λ=>0, :minValue=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = sample([-0.1,0.0,0.1], Weights([.2,.6,.2]), 1)[1],
            θ = 1.0,
            nonDecisionTime = 100
        )
        model.η = round( rand(Uniform(0,.020),1)[1] ; digits=3);
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :theta=>1.0, :λ=>0, :minValue=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# (d, σ, t, b, η)
##################################################################################################################
m = "dstbe"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = sample([-0.1,0.0,0.1], Weights([.2,.6,.2]), 1)[1],
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = round( rand(Uniform(0,.020),1)[1] ; digits=3);
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :λ=>0, :minValue=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = sample([-0.1,0.0,0.1], Weights([.2,.6,.2]), 1)[1],
            θ = round( rand(Uniform(1,2),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = round( rand(Uniform(0,.020),1)[1] ; digits=3);
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :λ=>0, :minValue=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end

"""
##################################################################################################################
# (d, σ, t, m) [m = 1 and -6]
##################################################################################################################
m = "dstm16"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 1.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :η=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = -6.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :η=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# (d, σ, t, m) [m = 0 and -7]
##################################################################################################################
m = "dstm07"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :η=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = -7.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :η=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end

"""
##################################################################################################################
# (d, σ, t, m, r)
##################################################################################################################
m = "dstmr"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = sample([.001*5:.001*5:.005*5;]),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 1.0;
        model.range = 5.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :η=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = sample([.001*5:.001*5:.005*5;]),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = -6.0;
        model.range = 5.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :η=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# GEN: (d,σ,θ,m)
# FIT: (d,σ,θ,m) + (d,σ,η)
##################################################################################################################
m = "dstm-dse"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 1.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = -6.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# GEN: (d,σ,η)
# FIT: (d,σ,θ,m) + (d,σ,η)
##################################################################################################################
m = "dse-dstm"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = 1.0,
            nonDecisionTime = 100
        )
        model.η = round( rand(Uniform(0,.020),1)[1] ; digits=3);
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = 1.0,
            nonDecisionTime = 100
        )
        model.η = round( rand(Uniform(0,.020),1)[1] ; digits=3);
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# GEN: (d,σ,θ,m,r)
# FIT: (d,σ,θ,m,r) + (d,σ,η)
##################################################################################################################
m = "dstmr-dse"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = sample([.001*5:.001*5:.005*5;]),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 1.0;
        model.range = 5.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = sample([.001*5:.001*5:.005*5;]),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = -6.0;
        model.range = 5.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# GEN: (d,σ,η)
# FIT: (d,σ,θ,m,r) + (d,σ,η)
##################################################################################################################
m = "dse-dstmr"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = 1.0,
            nonDecisionTime = 100
        )
        model.η = round( rand(Uniform(0,.020),1)[1] ; digits=3);
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = 1.0,
            nonDecisionTime = 100
        )
        model.η = round( rand(Uniform(0,.020),1)[1] ; digits=3);
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# GEN: (d,σ,θ,m,r)
# FIT: (d,σ,θ,m,r) + (d,σ,θ)
##################################################################################################################
m = "dstmr-dst"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = sample([.001*5:.001*5:.005*5;]),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 1.0;
        model.range = 5.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = sample([.001*5:.001*5:.005*5;]),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = -6.0;
        model.range = 5.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# GEN: (d,σ,θ)
# FIT: (d,σ,θ,m,r) + (d,σ,θ)
##################################################################################################################
m = "dst-dstmr"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(1,2),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# GEN: (d,σ,θ,m)
# FIT: (d,σ,θ,m) + (d,σ,θ)
##################################################################################################################
m = "dstm-dst"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = sample([.001:.001:.005;]),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 1.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = sample([.001:.001:.005;]),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = -6.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# GEN: (d,σ,θ)
# FIT: (d,σ,θ,m) + (d,σ,θ)
##################################################################################################################
m = "dst-dstm"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(1,2),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 0.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0, :range=>1.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end


##################################################################################################################
# GEN: (d,σ,θ,m,r)
# FIT: (d,σ,θ,m,r) + (d,σ,θ,m)
##################################################################################################################
m = "dstmr-dstm"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = sample([.001*5:.001*5:.005*5;]),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 1.0;
        model.range = 5.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = sample([.001*5:.001*5:.005*5;]),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = -6.0;
        model.range = 5.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end

##################################################################################################################
# GEN: (d,σ,θ,m)
# FIT: (d,σ,θ,m,r) + (d,σ,θ,m)
##################################################################################################################
m = "dstm-dstmr"
println("== " * m * " ==")
flush(stdout)
Random.seed!(seed)
@elapsed begin

    # Gain
    println("= Gain =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = 1.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Gain", "parameter_grids/"*m*"_Gain.csv", m, fixed_params)

    # Loss
    println("= Loss =")
    flush(stdout)
    model_list = Any[];
    for i in 1:simCount
        model = ADDM.define_model(
            d = round( rand(Uniform(.001,.005),1)[1] ; digits=3),
            σ = round( rand(Uniform(.01,.05),1)[1] ; digits=2),
            bias = 0.0,
            θ = round( rand(Uniform(0,1),1)[1] ; digits=1),
            nonDecisionTime = 100
        )
        model.η = 0.0;
        model.λ = 0.0;
        model.minValue = -6.0;
        model.range = 1.0;
        push!(model_list, model);
    end
    fixed_params = Dict(:barrier=>1, :nonDecisionTime=>100, :bias=>0.0, :λ=>0.0)
    sim_and_fit(model_list, "Loss", "parameter_grids/"*m*"_Loss.csv", m, fixed_params)

end
"""