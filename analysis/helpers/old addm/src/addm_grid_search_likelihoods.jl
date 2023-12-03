"""
#!/usr/bin/env julia
Copyright (C) 2023, California Institute of Technology

This file is part of addm_toolbox.

addm_toolbox is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

addm_toolbox is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with addm_toolbox. If not, see <http://www.gnu.org/licenses/>.

---

Module: addm_grid_search_likelihoods.jl
Author: Lynn Yang, lynnyang@caltech.edu

Testing functions in aDDM Toolbox.
"""

using Pkg
Pkg.activate("addm")

using LinearAlgebra
using ProgressMeter
using BenchmarkTools
using Plots
using StatsPlots

include("addm.jl")
include("util.jl")


function aDDM_grid_search_likelihoods(addm::aDDM, fixationData::FixationData, dList::LinRange{Float64, Int64}, σList::LinRange{Float64, Int64},
                          θList::LinRange{Float64, Int64}; trials::Int64=1000, cutOff::Int64=30000)
    """
    """
    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ) for d in dList, σ in σList, θ in θList]
        
    addmTrials = aDDM_simulate_trial_data_threads(addm, fixationData, trials, cutOff=cutOff)
    
    # Vectorized calculation of negative log-likelihood for all parameter combinations
    likelihood_array = [aDDM_total_likelihood(addmTrials, d, σ, θ) for (d, σ, θ) in param_combinations]

    post_likelihood_array = likelihood_array ./ sum(likelihood_array)

    println("issue?")

    println(post_likelihood_array)

    likelihood_df = DataFrame(d=dList, σ=σList, θ=θList, probability=vec(post_likelihood_array))

    println("issue 2?")

    corner(likelihood_df, :d, :σ, :θ, kind=:scatter)

    #cornerplot(likelihood_array)

    savefig("corner_plot.png")

    """
    d_post = sum(post_likelihood_array, dims=(2,3))
    σ_post = sum(post_likelihood_array, dims=(1,3))
    θ_post = sum(post_likelihood_array, dims=(1,2))
    """
end

println("Enter dLow:")
dLow = parse(Float64, readline())
println("Enter dHigh:")
dHigh = parse(Float64, readline())
println("Enter σLow:")
σLow = parse(Float64, readline())
println("Enter σHigh:")
σHigh = parse(Float64, readline())
println("Enter uLow:")
θLow = parse(Float64, readline())
println("Enter θHigh:")
θHigh = parse(Float64, readline())
println("Enter grid size:")
gridSize = parse(Int64, readline())

dTrue = 0.005
σTrue = 0.07
θTrue = 0.3

addm = aDDM(dTrue, σTrue, θTrue)
data = load_data_from_csv("expdata.csv", "fixations.csv", convertItemValues=convert_item_values)
fixationData = get_empirical_distributions(data, fixDistType="simple")

dList = LinRange(dLow, dHigh, gridSize)
σList = LinRange(σLow, σHigh, gridSize)
θList = LinRange(θLow, θHigh, gridSize)

aDDM_grid_search_likelihoods(addm, fixationData, dList, σList, θList)

#plot(dList, vec(d_post), label="Marginal Posterior for d", xlabel="d")

#println("d Likelihood: ", d_post)
#println("σ Likelihood: ", σ_post)
#println("θ Likelihood: ", θ_post)