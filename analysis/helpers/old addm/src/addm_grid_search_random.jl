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

Module: addm_grid_search_random.jl
Author: Lynn Yang, lynnyang@caltech.edu

Testing functions in aDDM Toolbox.
"""
using Pkg
Pkg.activate("addm")

using LinearAlgebra
using ProgressMeter
using BenchmarkTools

include("addm.jl")
include("util.jl")


function aDDM_grid_search_random(fixationData::FixationData, dList::LinRange{Float64, Int64}, σList::LinRange{Float64, Int64},
                          θList::LinRange{Float64, Int64}, n::Int64; trials::Int64=1000, cutOff::Int64=30000)
    """
    """

    dTrueList = Vector{Float64}(undef, n)
    σTrueList = Vector{Float64}(undef, n)
    θTrueList = Vector{Float64}(undef, n)

    dMLEList = Vector{Float64}(undef, n)
    σMLEList = Vector{Float64}(undef, n)
    θMLEList = Vector{Float64}(undef, n)

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ) for d in dList, σ in σList, θ in θList]
    
    @showprogress for i in 1:n
        dTrue = rand(dList)
        σTrue = rand(σList)
        θTrue = rand(θList)
        
        addm = aDDM(dTrue, σTrue, θTrue)
        
        addmTrials = aDDM_simulate_trial_data_threads(addm, fixationData, trials, cutOff=cutOff)
        
        # Vectorized calculation of negative log-likelihood for all parameter combinations
        neg_log_like_array = [aDDM_negative_log_likelihood_threads(addm, addmTrials, d, σ, θ) for (d, σ, θ) in param_combinations]
        
        # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
        minIdx = argmin(neg_log_like_array)
        dMin, σMin, θMin = param_combinations[minIdx]
        
        # Store results in the preallocated arrays
        dTrueList[i] = dTrue
        σTrueList[i] = σTrue
        θTrueList[i] = θTrue

        dMLEList[i] = dMin
        σMLEList[i] = σMin
        θMLEList[i] = θMin
    end

    return dTrueList, σTrueList, θTrueList, dMLEList, σMLEList, θMLEList
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
println("Enter number of datasets:")
n = parse(Int64, readline())

data = load_data_from_csv("expdata.csv", "fixations.csv", convertItemValues=convert_item_values)
fixationData = get_empirical_distributions(data, fixDistType="simple")

dList = LinRange(dLow, dHigh, gridSize)
σList = LinRange(σLow, σHigh, gridSize)
θList = LinRange(θLow, θHigh, gridSize)

dTrueList, σTrueList, θTrueList, dMLEList, σMLEList, θMLEList = aDDM_grid_search_random(fixationData, dList, σList, θList, n)

println("d_True: ", dTrueList)
println("σ_True: ", σTrueList)
println("θ_True: ", θTrueList)

println("d_MLE: ", dMLEList)
println("σ_MLE: ", σMLEList)
println("θ_MLE: ", θMLEList)