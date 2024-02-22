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

Module: addm_grid_search.jl
Author: Lynn Yang, lynnyang@caltech.edu

Testing functions in aDDM Toolbox.
"""

using Pkg
Pkg.activate("addm_toolbox")

using LinearAlgebra
using ProgressMeter
using BenchmarkTools

include("addm.jl")
include("util.jl")

# aDDM

function aDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}}, dList::Vector{Float64}, σList::Vector{Float64},
                          θList::Vector{Float64}, bList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b) for d in dList, σ in σList, θ in θList, b in bList]
    
    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [aDDM_negative_log_likelihood_threads(addm, addmTrials[subject], d, σ, θ, b) for (d, σ, θ, b) in param_combinations]
    
    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, NNL
end

# Additive model of attention (Michael Frank, David Reddish, ...)

function addDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}}, dList::Vector{Float64}, σList::Vector{Float64},
    θList::Vector{Float64}, bList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b) for d in dList, σ in σList, θ in θList, b in bList]

    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [addDDM_negative_log_likelihood_threads(addm, addmTrials[subject], d, σ, θ, b) for (d, σ, θ, b) in param_combinations]

    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, NNL
end

# Additive model of attention with collapsing boundaries

function cbAddDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}}, dList::Vector{Float64}, σList::Vector{Float64},
    θList::Vector{Float64}, bList::Vector{Float64}, cList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b, c) for d in dList, σ in σList, θ in θList, b in bList, c in cList]

    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [cbAddDDM_negative_log_likelihood_threads(addm, addmTrials[subject], d, σ, θ, b, c) for (d, σ, θ, b, c) in param_combinations]

    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin, cMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, cMin, NNL
end

# Additive and multiplicative model of attention

function AddaDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}}, minValue::Number, maxValue::Number,
    dList::Vector{Float64}, σList::Vector{Float64}, θList::Vector{Float64}, bList::Vector{Float64}, kList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b, k) for d in dList, σ in σList, θ in θList, b in bList, k in kList]

    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [AddaDDM_negative_log_likelihood_threads(addm, addmTrials[subject], minValue, maxValue, d, σ, θ, b, k) for (d, σ, θ, b, k) in param_combinations]

    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin, kMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, kMin, NNL
end

# Divisive Normalization (simplified)

function DNaDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}},
    dList::Vector{Float64}, σList::Vector{Float64}, θList::Vector{Float64}, bList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b) for d in dList, σ in σList, θ in θList, b in bList]

    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [DNaDDM_negative_log_likelihood_threads(addm, addmTrials[subject], d, σ, θ, b) for (d, σ, θ, b) in param_combinations]

    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, NNL
end

# Divisive Normalization Plus (k, k+1)

function DNPaDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}},
    dList::Vector{Float64}, σList::Vector{Float64}, θList::Vector{Float64}, bList::Vector{Float64}, kList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b, k) for d in dList, σ in σList, θ in θList, b in bList, k in kList]

    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [DNPaDDM_negative_log_likelihood_threads(addm, addmTrials[subject], d, σ, θ, b, k) for (d, σ, θ, b, k) in param_combinations]

    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin, kMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, kMin, NNL
end

# Goal-Dependent

function GDaDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}}, minValue::Number, maxValue::Number, dList::Vector{Float64}, σList::Vector{Float64}, θList::Vector{Float64}, bList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b) for d in dList, σ in σList, θ in θList, b in bList]

    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [GDaDDM_negative_log_likelihood_threads(addm, addmTrials[subject], minValue, maxValue, d, σ, θ, b) for (d, σ, θ, b) in param_combinations]

    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, NNL
end

# Goal dependent collapsing boundaries

function cbGDaDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}}, minValue::Number, maxValue::Number, dList::Vector{Float64}, σList::Vector{Float64}, θList::Vector{Float64}, bList::Vector{Float64}, cList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b, c) for d in dList, σ in σList, θ in θList, b in bList, c in cList]

    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [cbGDaDDM_negative_log_likelihood_threads(addm, addmTrials[subject], minValue, maxValue, d, σ, θ, b, c) for (d, σ, θ, b, c) in param_combinations]

    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin, cMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, cMin, NNL
end

# Range Normalization (0 to 1)

function RNaDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}}, minValue::Number, maxValue::Number,
    dList::Vector{Float64}, σList::Vector{Float64}, θList::Vector{Float64}, bList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b) for d in dList, σ in σList, θ in θList, b in bList]

    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [RNaDDM_negative_log_likelihood_threads(addm, addmTrials[subject], minValue, maxValue, d, σ, θ, b) for (d, σ, θ, b) in param_combinations]

    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, NNL
end

# Range Normalized Plus (range between 0+K to 1+K)

function RNPaDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}}, minValue::Number, maxValue::Number,
    dList::Vector{Float64}, σList::Vector{Float64}, θList::Vector{Float64}, bList::Vector{Float64}, kList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b, k) for d in dList, σ in σList, θ in θList, b in bList, k in kList]

    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [RNPaDDM_negative_log_likelihood_threads(addm, addmTrials[subject], minValue, maxValue, d, σ, θ, b, k) for (d, σ, θ, b, k) in param_combinations]

    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin, kMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, kMin, NNL
end

# Dynamic Range Normalized Plus (range between 0+K to 1+K) (min and max adjust trial-by-trial)

function DRNPaDDM_grid_search(addm::aDDM, addmTrials::Dict{String, Vector{aDDMTrial}},
    dList::Vector{Float64}, σList::Vector{Float64}, θList::Vector{Float64}, bList::Vector{Float64}, kList::Vector{Float64}, subject::String)
    """
    """

    # Create an array of tuples for all parameter combinations.
    param_combinations = [(d, σ, θ, b, k) for d in dList, σ in σList, θ in θList, b in bList, k in kList]

    # Vectorized calculation of negative log-likelihood for all parameter combinations
    neg_log_like_array = [DRNPaDDM_negative_log_likelihood_threads(addm, addmTrials[subject], d, σ, θ, b, k) for (d, σ, θ, b, k) in param_combinations]

    # Find the index of the minimum negative log-likelihood and obtain the MLE parameters
    minIdx = argmin(neg_log_like_array)
    dMin, σMin, θMin, bMin, kMin = param_combinations[minIdx]
    NNL = minimum(neg_log_like_array)

    return dMin, σMin, θMin, bMin, kMin, NNL
end
