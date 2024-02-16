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

Module: addm.jl
Author: Lynn Yang, lynnyang@caltech.edu

Implementation of the classic drift-diffusion model (DDM), as described by
Ratcliff et al. (1998).

Based on Python addm_toolbox from Gabriela Tavares, gtavares@caltech.edu.
"""

using Pkg
Pkg.activate("addm_toolbox")

using Random
using Distributions
using Base.Threads

include("ddm.jl")


struct FixationData
    """
    Args:
      probFixLeftFirst: Float64 between 0 and 1, empirical probability that
          the left item will be fixated first.
      latencies: Vector corresponding to the empirical distribution of
          trial latencies (delay before first fixation) in milliseconds.
      transitions: Vector corresponding to the empirical distribution
          of transitions (delays between item fixations) in milliseconds.
      fixations: Dict whose indexing is defined according to parameter
          fixDistType. Each entry is an array corresponding to the
          empirical distribution of item fixation durations in
          milliseconds.
      fixDistType: String, one of {'simple', 'difficulty', 'fixation'},
          determines how the fixation distributions are indexed. If
          'simple', fixation distributions are indexed only by type (1st,
          2nd, etc). If 'difficulty', they are indexed by type and by trial
          difficulty, i.e., the absolute value for the trial's value
          difference. If 'fixation', they are indexed by type and by the
          value difference between the fixated and unfixated items.
    """
    probFixLeftFirst::Float64
    latencies::Vector{Number}
    transitions::Vector{Number}
    fixations::Dict 
    fixDistType::String 

    function FixationData(probFixLeftFirst, latencies, transitions, fixations; fixDistType="fixation")
        availableDistTypes = ["simple", "difficulty", "fixation"]
        if !(fixDistType in availableDistTypes)
            throw(RuntimeError("Argument fixDistType must be one of {simple, difficulty, fixation}"))
        end
        new(probFixLeftFirst, latencies, transitions, fixations, fixDistType)
    end
end


mutable struct aDDMTrial
    """
    Args:
      RT: response time in milliseconds.
      choice: either -1 (for left item) or +1 (for right item).
      valueLeft: value of the left item.
      valueRight: value of the right item.
      fixItem: list of items fixated during the trial in chronological
          order; 1 correponds to left, 2 corresponds to right, and any
          other value is considered a transition/blank fixation.
      fixTime: list of fixation durations (in milliseconds) in
          chronological order.
      fixRDV: list of Float64 corresponding to the RDV values at the end of
          each fixation in the trial.
      uninterruptedLastFixTime: Int64 corresponding to the duration, in
          milliseconds, that the last fixation in the trial would have if it
          had not been interrupted when a decision was made.
    """
    ddmTrial::DDMTrial
    fixItem::Vector{Number}
    fixTime::Vector{Number}
    fixRDV::Vector{Number}
    uninterruptedLastFixTime::Number
    minValue::Number
    maxValue::Number

    function aDDMTrial(RDV, RT, choice, valueLeft, valueRight; fixItem=Number[], 
                       fixTime=Number[], fixRDV=Number[], uninterruptedLastFixTime=0.0, minValue = 0, maxValue = 1)
        ddmTrial = DDMTrial(RDV, RT, choice, valueLeft, valueRight)
        new(ddmTrial, fixItem, fixTime, fixRDV, uninterruptedLastFixTime, minValue, maxValue)
    end
end


Base.@kwdef mutable struct aDDM
    """
    Implementation of the traditional drift-diffusion model (DDM), as described
    by Ratcliff et al. (1998).

    Args:
      d: Number, parameter of the model which controls the speed of
          integration of the signal.
      σ: Number, parameter of the model, standard deviation for the
          normal distribution.
      θ: Float64 between 0 and 1, parameter of the model which controls
          the attentional bias.
      barrier: positive Number, magnitude of the signal thresholds.
      nonDecisionTime: non-negative Number, the amount of time in
          milliseconds during which only noise is added to the nonDecisionTime
          variable.
      bias: Number, corresponds to the initial value of the nonDecisionTime
          variable. Must be smaller than barrier.
      params: Tuple, parameters of the model.
    """
    d::Number
    σ::Number
    θ::Float64
    barrier::Number
    nonDecisionTime::Number
    bias::Number
    params::Tuple{Number, Number, Number}

    function aDDM(d, σ, θ; barrier=1, nonDecisionTime=0, bias=0.0)
        #if θ < 0 || θ > 1  
        #    throw(DomainError("Error: θ parameter must be between 0 and 1.")) # Not for gainloss project!
        #end
        DDM(d, σ, barrier=barrier, nonDecisionTime=nonDecisionTime, bias=bias)
        params = (d, σ, θ)
        new(d, σ, θ, barrier, nonDecisionTime, bias, params)
    end
end


function aDDM_get_trial_likelihood(addm::aDDM, trial::aDDMTrial; timeStep::Number = 10.0, 
                                   approxStateStep::Number = 0.1, plotTrial::Bool = false, 
                                   decay::Number = 0.0)
    """
    Computes the likelihood of the data from a single aDDM trial for these
    particular aDDM parameters.
    Args:
      addm: aDDM object.
      trial: aDDMTrial object.
      timeStep: Number, value in milliseconds to be used for binning the
          time axis.
      approxStateStep: Number, to be used for binning the RDV axis.
      plotTrial: Bool, flag that determines whether the algorithm
          evolution for the trial should be plotted.
      decay: Number, corresponds to how barriers change over time
    Returns:
      The likelihood obtained for the given trial and model.
    """
    # Iterate over the fixations and discount the non-decision time.
    if addm.nonDecisionTime > 0
        correctedFixItem = Number[]
        correctedFixTime = Number[]
        remainingNDT = addm.nonDecisionTime
        for (fItem, fTime) in zip(trial.fixItem, trial.fixTime)
            if remainingNDT > 0
                push!(correctedFixItem, 0)
                push!(correctedFixTime, min(remainingNDT, fTime))
                push!(correctedFixItem, fItem)
                push!(correctedFixTime, max(fTime - remainingNDT, 0))
                remainingNDT = remainingNDT - fTime
            else
                push!(correctedFixItem, fItem)
                push!(correctedFixTime, fTime)
            end
        end
    else
        correctedFixItem = trial.fixItem
        correctedFixTime = trial.fixTime
    end
    
    # Iterate over the fixations and get the number of time steps for this trial.
    numTimeSteps = 0
    
    for fTime in correctedFixTime
        numTimeSteps += Int64(fTime ÷ timeStep)
    end
    
    if numTimeSteps < 1
        throw(RuntimeError("Trial response time is smaller than time step."))
    end
    numTimeSteps += 1
    
    # The values of the barriers can change over time.
    barrierUp = addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    barrierDown = -addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    
    # Obtain correct state step.
    halfNumStateBins = ceil(addm.barrier / approxStateStep)
    stateStep = addm.barrier / (halfNumStateBins + 0.5)
    
    # The vertical axis is divided into states.
    states = range(-1 + stateStep / 2, 1 - stateStep/2, step=stateStep)
    
    # Find the state corresponding to the bias parameter.
    biasState = argmin(abs.(states .- addm.bias))
    
    # Initial probability for all states is zero, except the bias state,
    # for which the initial probability is one.
    prStates = zeros(length(states), numTimeSteps)
    prStates[biasState,1] = 1
    
    # The probability of crossing each barrier over the time of the trial.
    probUpCrossing = zeros(numTimeSteps)
    probDownCrossing = zeros(numTimeSteps)
    
    time = 1
    
    # Dictionary of μ values from fItem.
    μDict = Dict{Number, Number}()
    for fItem in 0:2
        if fItem == 1
            μ = addm.d * (trial.ddmTrial.valueLeft - (addm.θ * trial.ddmTrial.valueRight))
        elseif fItem == 2
            μ = addm.d * ((addm.θ * trial.ddmTrial.valueLeft) - trial.ddmTrial.valueRight)
        else
            μ = 0
        end
        
        μDict[fItem] = μ
    end 
    
    changeMatrix = states .- reshape(states, 1, :)
    changeUp = (barrierUp .- reshape(states, 1, :))'
    changeDown = (barrierDown .- reshape(states, 1, :) )'
    
    pdfDict = Dict{Number, Any}()
    cdfUpDict = Dict{Number, Any}()
    cdfDownDict = Dict{Number, Any}() 
    
    for fItem in 0:2
        normpdf = similar(changeMatrix)
        cdfUp = similar(changeUp[:, time])
        cdfDown = similar(changeDown[:, time])
        
        @. normpdf = pdf(Normal(μDict[fItem], addm.σ), changeMatrix)
        @. cdfUp = cdf(Normal(μDict[fItem], addm.σ), changeUp[:, time])
        @. cdfDown = cdf(Normal(μDict[fItem], addm.σ), changeDown[:, time])
        pdfDict[fItem] = normpdf
        cdfUpDict[fItem] = cdfUp
        cdfDownDict[fItem] = cdfDown
    end
    
    # Iterate over all fixations in this trial.
    for (fItem, fTime) in zip(correctedFixItem, correctedFixTime)
        # We use a normal distribution to model changes in RDV
        # stochastically. The mean of the distribution (the change most
        # likely to occur) is calculated from the model parameters and from
        # the item values.
        μ = μDict[fItem]
        normpdf = pdfDict[fItem]
        cdfUp = cdfUpDict[fItem]
        cdfDown = cdfDownDict[fItem]
        
        # Iterate over the time interval of this fixation.
        for t in 1:Int64(fTime ÷ timeStep)
            # Update the probability of the states that remain inside the 
            # barriers. The probability of being in state B is the sum, 
            # over all states A, of the probability of being in A at the 
            # previous timestep times the probability of changing from A to
            # B. We multiply the probability by the stateStep to ensure
            # that the area under the curves for the probability 
            # distributions probUpCrossing and probDownCrossing add up to 1.
            prStatesNew = stateStep * (normpdf * prStates[:,time])
            prStatesNew[(states .>= barrierUp[t]) .| (states .<= barrierDown[t])] .= 0
            
            # Calculate the probabilities of crossing the up barrier and
            # the down barrier. This is given by the sum, over all states
            # A, of the proability of being in A at the previous timestep
            # times the probability of crossing the barrier if A is the
            # previous state.
            tempUpCross = dot(prStates[:,time], 1 .- cdfUp)
            tempDownCross = dot(prStates[:,time], cdfDown)
            
            # Renormalize to cope with numerical approximations.
            sumIn = sum(prStates[:,time])
            sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
            prStatesNew = prStatesNew * sumIn / sumCurrent
            tempUpCross = tempUpCross * sumIn / sumCurrent
            tempDownCross = tempDownCross * sumIn / sumCurrent

            # Update the probabilities of each state and the probabilities of
            # crossing each barrier at this timestep
            prStates[:,time+1] = prStatesNew
            probUpCrossing[time+1] = tempUpCross
            probDownCrossing[time+1] = tempDownCross
            
            time += 1
        end
    end
    
    # Compute the likelihood contribution of this trial based on the final
    # choice.
    likelihood = 0
    if trial.ddmTrial.choice == -1 # Choice was left.
        if probUpCrossing[end] > 0
            likelihood = probUpCrossing[end]
        end
    elseif trial.ddmTrial.choice == 1 # Choice was right.
        if probDownCrossing[end] > 0 
            likelihood = probDownCrossing[end]
        end
    end
    
    if plotTrial
        # TODO
    end
    
    return likelihood
end

function addDDM_get_trial_likelihood(addm::aDDM, trial::aDDMTrial; timeStep::Number = 10.0, 
                                   approxStateStep::Number = 0.1, plotTrial::Bool = false, 
                                   decay::Number = 0.0)
    """
    Computes the likelihood of the data from a single aDDM trial for these
    particular aDDM parameters.
    Args:
      addm: aDDM object.
      trial: aDDMTrial object.
      timeStep: Number, value in milliseconds to be used for binning the
          time axis.
      approxStateStep: Number, to be used for binning the RDV axis.
      plotTrial: Bool, flag that determines whether the algorithm
          evolution for the trial should be plotted.
      decay: Number, corresponds to how barriers change over time
    Returns:
      The likelihood obtained for the given trial and model.
    """
    # Iterate over the fixations and discount the non-decision time.
    if addm.nonDecisionTime > 0
        correctedFixItem = Number[]
        correctedFixTime = Number[]
        remainingNDT = addm.nonDecisionTime
        for (fItem, fTime) in zip(trial.fixItem, trial.fixTime)
            if remainingNDT > 0
                push!(correctedFixItem, 0)
                push!(correctedFixTime, min(remainingNDT, fTime))
                push!(correctedFixItem, fTime)
                push!(correctedFixTime, max(fTime - remainingNDT, 0))
                remainingNDT = remainingNDT - fTime
            else
                push!(correctedFixTime, fItem)
                push!(correctedFixTime, fTime)
            end
        end
    else
        correctedFixItem = trial.fixItem
        correctedFixTime = trial.fixTime
    end
    
    # Iterate over the fixations and get the number of time steps for this trial.
    numTimeSteps = 0
    
    for fTime in correctedFixTime
        numTimeSteps += Int64(fTime ÷ timeStep)
    end
    
    if numTimeSteps < 1
        throw(RuntimeError("Trial response time is smaller than time step."))
    end
    numTimeSteps += 1
    
    # The values of the barriers can change over time.
    barrierUp = addm.barrier ./ (1 .+ (decay .* (0:numTimeSteps-1)))
    barrierDown = -addm.barrier ./ (1 .+ (decay .* (0:numTimeSteps-1)))
    
    # Obtain correct state step.
    halfNumStateBins = ceil(addm.barrier / approxStateStep)
    stateStep = addm.barrier / (halfNumStateBins + 0.5)
    
    # The vertical axis is divided into states.
    states = range(-1 + stateStep / 2, 1 - stateStep/2, step=stateStep)
    
    # Find the state corresponding to the bias parameter.
    biasState = argmin(abs.(states .- addm.bias))
    
    # Initial probability for all states is zero, except the bias state,
    # for which the initial probability is one.
    prStates = zeros(length(states), numTimeSteps)
    prStates[biasState,1] = 1
    
    # The probability of crossing each barrier over the time of the trial.
    probUpCrossing = zeros(numTimeSteps)
    probDownCrossing = zeros(numTimeSteps)
    
    time = 1
    
    # Dictionary of μ values from fItem.
    μDict = Dict{Number, Number}()
    for fItem in 0:2
        if fItem == 1
            μ = addm.d * (trial.ddmTrial.valueLeft - trial.ddmTrial.valueRight + addm.θ)
        elseif fItem == 2
            μ = addm.d * (trial.ddmTrial.valueLeft - trial.ddmTrial.valueRight - addm.θ)
        else
            μ = 0
        end
        
        μDict[fItem] = μ
    end 
    
    changeMatrix = states .- reshape(states, 1, :)
    changeUp = (barrierUp .- reshape(states, 1, :))'
    changeDown = (barrierDown .- reshape(states, 1, :) )'
    
    pdfDict = Dict{Number, Any}()
    cdfUpDict = Dict{Number, Any}()
    cdfDownDict = Dict{Number, Any}() 
    
    for fItem in 0:2
        normpdf = similar(changeMatrix)
        cdfUp = similar(changeUp[:, time])
        cdfDown = similar(changeDown[:, time])
        
        @. normpdf = pdf(Normal(μDict[fItem], addm.σ), changeMatrix)
        @. cdfUp = cdf(Normal(μDict[fItem], addm.σ), changeUp[:, time])
        @. cdfDown = cdf(Normal(μDict[fItem], addm.σ), changeDown[:, time])
        pdfDict[fItem] = normpdf
        cdfUpDict[fItem] = cdfUp
        cdfDownDict[fItem] = cdfDown
    end
    
    # Iterate over all fixations in this trial.
    for (fItem, fTime) in zip(correctedFixItem, correctedFixTime)
        # We use a normal distribution to model changes in RDV
        # stochastically. The mean of the distribution (the change most
        # likely to occur) is calculated from the model parameters and from
        # the item values.
        μ = μDict[fItem]
        normpdf = pdfDict[fItem]
        cdfUp = cdfUpDict[fItem]
        cdfDown = cdfDownDict[fItem]
        
        # Iterate over the time interval of this fixation.
        for t in 1:Int64(fTime ÷ timeStep)
            # Update the probability of the states that remain inside the 
            # barriers. The probability of being in state B is the sum, 
            # over all states A, of the probability of being in A at the 
            # previous timestep times the probability of changing from A to
            # B. We multiply the probability by the stateStep to ensure
            # that the area under the curves for the probability 
            # distributions probUpCrossing and probDownCrossing add up to 1.
            prStatesNew = stateStep * (normpdf * prStates[:,time])
            prStatesNew[(states .>= barrierUp[t]) .| (states .<= barrierDown[t])] .= 0
            
            # Calculate the probabilities of crossing the up barrier and
            # the down barrier. This is given by the sum, over all states
            # A, of the proability of being in A at the previous timestep
            # times the probability of crossing the barrier if A is the
            # previous state.
            tempUpCross = dot(prStates[:,time], 1 .- cdfUp)
            tempDownCross = dot(prStates[:,time], cdfDown)
            
            # Renormalize to cope with numerical approximations.
            sumIn = sum(prStates[:,time])
            sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
            prStatesNew = prStatesNew * sumIn / sumCurrent
            tempUpCross = tempUpCross * sumIn / sumCurrent
            tempDownCross = tempDownCross * sumIn / sumCurrent

            # Update the probabilities of each state and the probabilities of
            # crossing each barrier at this timestep
            prStates[:,time+1] = prStatesNew
            probUpCrossing[time+1] = tempUpCross
            probDownCrossing[time+1] = tempDownCross
            
            time += 1
        end
    end
    
    # Compute the likelihood contribution of this trial based on the final
    # choice.
    likelihood = 0
    if trial.ddmTrial.choice == -1 # Choice was left.
        if probUpCrossing[end] > 0
            likelihood = probUpCrossing[end]
        end
    elseif trial.ddmTrial.choice == 1 # Choice was right.
        if probDownCrossing[end] > 0 
            likelihood = probDownCrossing[end]
        end
    end
    
    if plotTrial
        # TODO
    end
    
    return likelihood
end

function AddaDDM_get_trial_likelihood(addm::aDDM, trial::aDDMTrial, minValue::Number, maxValue::Number, k::Number; timeStep::Number = 10.0, 
                                   approxStateStep::Number = 0.1, plotTrial::Bool = false, 
                                   decay::Number = 0.0)
    """
    Computes the likelihood of the data from a single aDDM trial for these
    particular aDDM parameters.
    Args:
      addm: aDDM object.
      trial: aDDMTrial object.
      timeStep: Number, value in milliseconds to be used for binning the
          time axis.
      approxStateStep: Number, to be used for binning the RDV axis.
      plotTrial: Bool, flag that determines whether the algorithm
          evolution for the trial should be plotted.
      decay: Number, corresponds to how barriers change over time
    Returns:
      The likelihood obtained for the given trial and model.
    """
    # Iterate over the fixations and discount the non-decision time.
    if addm.nonDecisionTime > 0
        correctedFixItem = Number[]
        correctedFixTime = Number[]
        remainingNDT = addm.nonDecisionTime
        for (fItem, fTime) in zip(trial.fixItem, trial.fixTime)
            if remainingNDT > 0
                push!(correctedFixItem, 0)
                push!(correctedFixTime, min(remainingNDT, fTime))
                push!(correctedFixItem, fTime)
                push!(correctedFixTime, max(fTime - remainingNDT, 0))
                remainingNDT = remainingNDT - fTime
            else
                push!(correctedFixTime, fItem)
                push!(correctedFixTime, fTime)
            end
        end
    else
        correctedFixItem = trial.fixItem
        correctedFixTime = trial.fixTime
    end
    
    # Iterate over the fixations and get the number of time steps for this trial.
    numTimeSteps = 0
    
    for fTime in correctedFixTime
        numTimeSteps += Int64(fTime ÷ timeStep)
    end
    
    if numTimeSteps < 1
        throw(RuntimeError("Trial response time is smaller than time step."))
    end
    numTimeSteps += 1
    
    # The values of the barriers can change over time.
    barrierUp = addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    barrierDown = -addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    
    # Obtain correct state step.
    halfNumStateBins = ceil(addm.barrier / approxStateStep)
    stateStep = addm.barrier / (halfNumStateBins + 0.5)
    
    # The vertical axis is divided into states.
    states = range(-1 + stateStep / 2, 1 - stateStep/2, step=stateStep)
    
    # Find the state corresponding to the bias parameter.
    biasState = argmin(abs.(states .- addm.bias))
    
    # Initial probability for all states is zero, except the bias state,
    # for which the initial probability is one.
    prStates = zeros(length(states), numTimeSteps)
    prStates[biasState,1] = 1
    
    # The probability of crossing each barrier over the time of the trial.
    probUpCrossing = zeros(numTimeSteps)
    probDownCrossing = zeros(numTimeSteps)
    
    time = 1
    
    # Dictionary of μ values from fItem.
    μDict = Dict{Number, Number}()
    NL = trial.ddmTrial.valueLeft + (k/(1-addm.θ))
    NR = trial.ddmTrial.valueRight + (k/(1-addm.θ))
    for fItem in 0:2
        if fItem == 1
            μ = addm.d * (NL - addm.θ*NR)
        elseif fItem == 2
            μ = addm.d * (addm.θ*NL - NR)
        else
            μ = 0
        end
        
        μDict[fItem] = μ
    end 
    
    changeMatrix = states .- reshape(states, 1, :)
    changeUp = (barrierUp .- reshape(states, 1, :))'
    changeDown = (barrierDown .- reshape(states, 1, :) )'
    
    pdfDict = Dict{Number, Any}()
    cdfUpDict = Dict{Number, Any}()
    cdfDownDict = Dict{Number, Any}() 
    
    for fItem in 0:2
        normpdf = similar(changeMatrix)
        cdfUp = similar(changeUp[:, time])
        cdfDown = similar(changeDown[:, time])
        
        @. normpdf = pdf(Normal(μDict[fItem], addm.σ), changeMatrix)
        @. cdfUp = cdf(Normal(μDict[fItem], addm.σ), changeUp[:, time])
        @. cdfDown = cdf(Normal(μDict[fItem], addm.σ), changeDown[:, time])
        pdfDict[fItem] = normpdf
        cdfUpDict[fItem] = cdfUp
        cdfDownDict[fItem] = cdfDown
    end
    
    # Iterate over all fixations in this trial.
    for (fItem, fTime) in zip(correctedFixItem, correctedFixTime)
        # We use a normal distribution to model changes in RDV
        # stochastically. The mean of the distribution (the change most
        # likely to occur) is calculated from the model parameters and from
        # the item values.
        μ = μDict[fItem]
        normpdf = pdfDict[fItem]
        cdfUp = cdfUpDict[fItem]
        cdfDown = cdfDownDict[fItem]
        
        # Iterate over the time interval of this fixation.
        for t in 1:Int64(fTime ÷ timeStep)
            # Update the probability of the states that remain inside the 
            # barriers. The probability of being in state B is the sum, 
            # over all states A, of the probability of being in A at the 
            # previous timestep times the probability of changing from A to
            # B. We multiply the probability by the stateStep to ensure
            # that the area under the curves for the probability 
            # distributions probUpCrossing and probDownCrossing add up to 1.
            prStatesNew = stateStep * (normpdf * prStates[:,time])
            prStatesNew[(states .>= barrierUp[t]) .| (states .<= barrierDown[t])] .= 0
            
            # Calculate the probabilities of crossing the up barrier and
            # the down barrier. This is given by the sum, over all states
            # A, of the proability of being in A at the previous timestep
            # times the probability of crossing the barrier if A is the
            # previous state.
            tempUpCross = dot(prStates[:,time], 1 .- cdfUp)
            tempDownCross = dot(prStates[:,time], cdfDown)
            
            # Renormalize to cope with numerical approximations.
            sumIn = sum(prStates[:,time])
            sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
            prStatesNew = prStatesNew * sumIn / sumCurrent
            tempUpCross = tempUpCross * sumIn / sumCurrent
            tempDownCross = tempDownCross * sumIn / sumCurrent

            # Update the probabilities of each state and the probabilities of
            # crossing each barrier at this timestep
            prStates[:,time+1] = prStatesNew
            probUpCrossing[time+1] = tempUpCross
            probDownCrossing[time+1] = tempDownCross
            
            time += 1
        end
    end
    
    # Compute the likelihood contribution of this trial based on the final
    # choice.
    likelihood = 0
    if trial.ddmTrial.choice == -1 # Choice was left.
        if probUpCrossing[end] > 0
            likelihood = probUpCrossing[end]
        end
    elseif trial.ddmTrial.choice == 1 # Choice was right.
        if probDownCrossing[end] > 0 
            likelihood = probDownCrossing[end]
        end
    end
    
    if plotTrial
        # TODO
    end
    
    return likelihood
end

function DNaDDM_get_trial_likelihood(addm::aDDM, trial::aDDMTrial; timeStep::Number = 10.0, 
                                   approxStateStep::Number = 0.1, plotTrial::Bool = false, 
                                   decay::Number = 0.0)
    """
    Computes the likelihood of the data from a single aDDM trial for these
    particular aDDM parameters.
    Args:
      addm: aDDM object.
      trial: aDDMTrial object.
      timeStep: Number, value in milliseconds to be used for binning the
          time axis.
      approxStateStep: Number, to be used for binning the RDV axis.
      plotTrial: Bool, flag that determines whether the algorithm
          evolution for the trial should be plotted.
      decay: Number, corresponds to how barriers change over time
    Returns:
      The likelihood obtained for the given trial and model.
    """
    # Iterate over the fixations and discount the non-decision time.
    if addm.nonDecisionTime > 0
        correctedFixItem = Number[]
        correctedFixTime = Number[]
        remainingNDT = addm.nonDecisionTime
        for (fItem, fTime) in zip(trial.fixItem, trial.fixTime)
            if remainingNDT > 0
                push!(correctedFixItem, 0)
                push!(correctedFixTime, min(remainingNDT, fTime))
                push!(correctedFixItem, fTime)
                push!(correctedFixTime, max(fTime - remainingNDT, 0))
                remainingNDT = remainingNDT - fTime
            else
                push!(correctedFixTime, fItem)
                push!(correctedFixTime, fTime)
            end
        end
    else
        correctedFixItem = trial.fixItem
        correctedFixTime = trial.fixTime
    end
    
    # Iterate over the fixations and get the number of time steps for this trial.
    numTimeSteps = 0
    
    for fTime in correctedFixTime
        numTimeSteps += Int64(fTime ÷ timeStep)
    end
    
    if numTimeSteps < 1
        throw(RuntimeError("Trial response time is smaller than time step."))
    end
    numTimeSteps += 1
    
    # The values of the barriers can change over time.
    barrierUp = addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    barrierDown = -addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    
    # Obtain correct state step.
    halfNumStateBins = ceil(addm.barrier / approxStateStep)
    stateStep = addm.barrier / (halfNumStateBins + 0.5)
    
    # The vertical axis is divided into states.
    states = range(-1 + stateStep / 2, 1 - stateStep/2, step=stateStep)
    
    # Find the state corresponding to the bias parameter.
    biasState = argmin(abs.(states .- addm.bias))
    
    # Initial probability for all states is zero, except the bias state,
    # for which the initial probability is one.
    prStates = zeros(length(states), numTimeSteps)
    prStates[biasState,1] = 1
    
    # The probability of crossing each barrier over the time of the trial.
    probUpCrossing = zeros(numTimeSteps)
    probDownCrossing = zeros(numTimeSteps)
    
    time = 1
    
    # Dictionary of μ values from fItem.
    μDict = Dict{Number, Number}()
    if trial.ddmTrial.valueLeft < 0
        NL = -(abs(trial.ddmTrial.valueLeft) / (abs(trial.ddmTrial.valueLeft) + abs(trial.ddmTrial.valueRight)))
        NR = -(abs(trial.ddmTrial.valueRight) / (abs(trial.ddmTrial.valueLeft) + abs(trial.ddmTrial.valueRight)))
    else
        NL = trial.ddmTrial.valueLeft / (trial.ddmTrial.valueLeft + trial.ddmTrial.valueRight)
        NR = trial.ddmTrial.valueRight / (trial.ddmTrial.valueLeft + trial.ddmTrial.valueRight)
    end
    for fItem in 0:2
        if fItem == 1
            μ = addm.d * (NL - addm.θ*NR)
        elseif fItem == 2
            μ = addm.d * (addm.θ*NL - NR)
        else
            μ = 0
        end
        
        μDict[fItem] = μ
    end 
    
    changeMatrix = states .- reshape(states, 1, :)
    changeUp = (barrierUp .- reshape(states, 1, :))'
    changeDown = (barrierDown .- reshape(states, 1, :) )'
    
    pdfDict = Dict{Number, Any}()
    cdfUpDict = Dict{Number, Any}()
    cdfDownDict = Dict{Number, Any}() 
    
    for fItem in 0:2
        normpdf = similar(changeMatrix)
        cdfUp = similar(changeUp[:, time])
        cdfDown = similar(changeDown[:, time])
        
        @. normpdf = pdf(Normal(μDict[fItem], addm.σ), changeMatrix)
        @. cdfUp = cdf(Normal(μDict[fItem], addm.σ), changeUp[:, time])
        @. cdfDown = cdf(Normal(μDict[fItem], addm.σ), changeDown[:, time])
        pdfDict[fItem] = normpdf
        cdfUpDict[fItem] = cdfUp
        cdfDownDict[fItem] = cdfDown
    end
    
    # Iterate over all fixations in this trial.
    for (fItem, fTime) in zip(correctedFixItem, correctedFixTime)
        # We use a normal distribution to model changes in RDV
        # stochastically. The mean of the distribution (the change most
        # likely to occur) is calculated from the model parameters and from
        # the item values.
        μ = μDict[fItem]
        normpdf = pdfDict[fItem]
        cdfUp = cdfUpDict[fItem]
        cdfDown = cdfDownDict[fItem]
        
        # Iterate over the time interval of this fixation.
        for t in 1:Int64(fTime ÷ timeStep)
            # Update the probability of the states that remain inside the 
            # barriers. The probability of being in state B is the sum, 
            # over all states A, of the probability of being in A at the 
            # previous timestep times the probability of changing from A to
            # B. We multiply the probability by the stateStep to ensure
            # that the area under the curves for the probability 
            # distributions probUpCrossing and probDownCrossing add up to 1.
            prStatesNew = stateStep * (normpdf * prStates[:,time])
            prStatesNew[(states .>= barrierUp[t]) .| (states .<= barrierDown[t])] .= 0
            
            # Calculate the probabilities of crossing the up barrier and
            # the down barrier. This is given by the sum, over all states
            # A, of the proability of being in A at the previous timestep
            # times the probability of crossing the barrier if A is the
            # previous state.
            tempUpCross = dot(prStates[:,time], 1 .- cdfUp)
            tempDownCross = dot(prStates[:,time], cdfDown)
            
            # Renormalize to cope with numerical approximations.
            sumIn = sum(prStates[:,time])
            sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
            prStatesNew = prStatesNew * sumIn / sumCurrent
            tempUpCross = tempUpCross * sumIn / sumCurrent
            tempDownCross = tempDownCross * sumIn / sumCurrent

            # Update the probabilities of each state and the probabilities of
            # crossing each barrier at this timestep
            prStates[:,time+1] = prStatesNew
            probUpCrossing[time+1] = tempUpCross
            probDownCrossing[time+1] = tempDownCross
            
            time += 1
        end
    end
    
    # Compute the likelihood contribution of this trial based on the final
    # choice.
    likelihood = 0
    if trial.ddmTrial.choice == -1 # Choice was left.
        if probUpCrossing[end] > 0
            likelihood = probUpCrossing[end]
        end
    elseif trial.ddmTrial.choice == 1 # Choice was right.
        if probDownCrossing[end] > 0 
            likelihood = probDownCrossing[end]
        end
    end
    
    if plotTrial
        # TODO
    end
    
    return likelihood
end

function DNPaDDM_get_trial_likelihood(addm::aDDM, trial::aDDMTrial, k::Number; timeStep::Number = 10.0, approxStateStep::Number = 0.1, plotTrial::Bool = false, decay::Number = 0.0)
    """
    Computes the likelihood of the data from a single aDDM trial for these
    particular aDDM parameters.
    Args:
      addm: aDDM object.
      trial: aDDMTrial object.
      timeStep: Number, value in milliseconds to be used for binning the
          time axis.
      approxStateStep: Number, to be used for binning the RDV axis.
      plotTrial: Bool, flag that determines whether the algorithm
          evolution for the trial should be plotted.
      decay: Number, corresponds to how barriers change over time
    Returns:
      The likelihood obtained for the given trial and model.
    """
    # Iterate over the fixations and discount the non-decision time.
    if addm.nonDecisionTime > 0
        correctedFixItem = Number[]
        correctedFixTime = Number[]
        remainingNDT = addm.nonDecisionTime
        for (fItem, fTime) in zip(trial.fixItem, trial.fixTime)
            if remainingNDT > 0
                push!(correctedFixItem, 0)
                push!(correctedFixTime, min(remainingNDT, fTime))
                push!(correctedFixItem, fTime)
                push!(correctedFixTime, max(fTime - remainingNDT, 0))
                remainingNDT = remainingNDT - fTime
            else
                push!(correctedFixTime, fItem)
                push!(correctedFixTime, fTime)
            end
        end
    else
        correctedFixItem = trial.fixItem
        correctedFixTime = trial.fixTime
    end
    
    # Iterate over the fixations and get the number of time steps for this trial.
    numTimeSteps = 0
    
    for fTime in correctedFixTime
        numTimeSteps += Int64(fTime ÷ timeStep)
    end
    
    if numTimeSteps < 1
        throw(RuntimeError("Trial response time is smaller than time step."))
    end
    numTimeSteps += 1
    
    # The values of the barriers can change over time.
    barrierUp = addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    barrierDown = -addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    
    # Obtain correct state step.
    halfNumStateBins = ceil(addm.barrier / approxStateStep)
    stateStep = addm.barrier / (halfNumStateBins + 0.5)
    
    # The vertical axis is divided into states.
    states = range(-1 + stateStep / 2, 1 - stateStep/2, step=stateStep)
    
    # Find the state corresponding to the bias parameter.
    biasState = argmin(abs.(states .- addm.bias))
    
    # Initial probability for all states is zero, except the bias state,
    # for which the initial probability is one.
    prStates = zeros(length(states), numTimeSteps)
    prStates[biasState,1] = 1
    
    # The probability of crossing each barrier over the time of the trial.
    probUpCrossing = zeros(numTimeSteps)
    probDownCrossing = zeros(numTimeSteps)
    
    time = 1
    
    # Dictionary of μ values from fItem.
    μDict = Dict{Number, Number}()
    if trial.ddmTrial.valueLeft < 0
        NL = -(abs(trial.ddmTrial.valueLeft) / (abs(trial.ddmTrial.valueLeft) + abs(trial.ddmTrial.valueRight)))
        NR = -(abs(trial.ddmTrial.valueRight) / (abs(trial.ddmTrial.valueLeft) + abs(trial.ddmTrial.valueRight)))
    else
        NL = trial.ddmTrial.valueLeft / (trial.ddmTrial.valueLeft + trial.ddmTrial.valueRight)
        NR = trial.ddmTrial.valueRight / (trial.ddmTrial.valueLeft + trial.ddmTrial.valueRight)
    end
    NL = NL + k
    NR = NR + k
    for fItem in 0:2
        if fItem == 1
            μ = addm.d * (NL - addm.θ*NR)
        elseif fItem == 2
            μ = addm.d * (addm.θ*NL - NR)
        else
            μ = 0
        end
        
        μDict[fItem] = μ
    end 
    
    changeMatrix = states .- reshape(states, 1, :)
    changeUp = (barrierUp .- reshape(states, 1, :))'
    changeDown = (barrierDown .- reshape(states, 1, :) )'
    
    pdfDict = Dict{Number, Any}()
    cdfUpDict = Dict{Number, Any}()
    cdfDownDict = Dict{Number, Any}() 
    
    for fItem in 0:2
        normpdf = similar(changeMatrix)
        cdfUp = similar(changeUp[:, time])
        cdfDown = similar(changeDown[:, time])
        
        @. normpdf = pdf(Normal(μDict[fItem], addm.σ), changeMatrix)
        @. cdfUp = cdf(Normal(μDict[fItem], addm.σ), changeUp[:, time])
        @. cdfDown = cdf(Normal(μDict[fItem], addm.σ), changeDown[:, time])
        pdfDict[fItem] = normpdf
        cdfUpDict[fItem] = cdfUp
        cdfDownDict[fItem] = cdfDown
    end
    
    # Iterate over all fixations in this trial.
    for (fItem, fTime) in zip(correctedFixItem, correctedFixTime)
        # We use a normal distribution to model changes in RDV
        # stochastically. The mean of the distribution (the change most
        # likely to occur) is calculated from the model parameters and from
        # the item values.
        μ = μDict[fItem]
        normpdf = pdfDict[fItem]
        cdfUp = cdfUpDict[fItem]
        cdfDown = cdfDownDict[fItem]
        
        # Iterate over the time interval of this fixation.
        for t in 1:Int64(fTime ÷ timeStep)
            # Update the probability of the states that remain inside the 
            # barriers. The probability of being in state B is the sum, 
            # over all states A, of the probability of being in A at the 
            # previous timestep times the probability of changing from A to
            # B. We multiply the probability by the stateStep to ensure
            # that the area under the curves for the probability 
            # distributions probUpCrossing and probDownCrossing add up to 1.
            prStatesNew = stateStep * (normpdf * prStates[:,time])
            prStatesNew[(states .>= barrierUp[t]) .| (states .<= barrierDown[t])] .= 0
            
            # Calculate the probabilities of crossing the up barrier and
            # the down barrier. This is given by the sum, over all states
            # A, of the proability of being in A at the previous timestep
            # times the probability of crossing the barrier if A is the
            # previous state.
            tempUpCross = dot(prStates[:,time], 1 .- cdfUp)
            tempDownCross = dot(prStates[:,time], cdfDown)
            
            # Renormalize to cope with numerical approximations.
            sumIn = sum(prStates[:,time])
            sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
            prStatesNew = prStatesNew * sumIn / sumCurrent
            tempUpCross = tempUpCross * sumIn / sumCurrent
            tempDownCross = tempDownCross * sumIn / sumCurrent

            # Update the probabilities of each state and the probabilities of
            # crossing each barrier at this timestep
            prStates[:,time+1] = prStatesNew
            probUpCrossing[time+1] = tempUpCross
            probDownCrossing[time+1] = tempDownCross
            
            time += 1
        end
    end
    
    # Compute the likelihood contribution of this trial based on the final
    # choice.
    likelihood = 0
    if trial.ddmTrial.choice == -1 # Choice was left.
        if probUpCrossing[end] > 0
            likelihood = probUpCrossing[end]
        end
    elseif trial.ddmTrial.choice == 1 # Choice was right.
        if probDownCrossing[end] > 0 
            likelihood = probDownCrossing[end]
        end
    end
    
    if plotTrial
        # TODO
    end
    
    return likelihood
end

function GDaDDM_get_trial_likelihood(addm::aDDM, trial::aDDMTrial, minValue::Number, maxValue::Number; timeStep::Number = 10.0, 
                                   approxStateStep::Number = 0.1, plotTrial::Bool = false, 
                                   decay::Number = 0.0)
    """
    Computes the likelihood of the data from a single aDDM trial for these
    particular aDDM parameters.
    Args:
      addm: aDDM object.
      trial: aDDMTrial object.
      timeStep: Number, value in milliseconds to be used for binning the
          time axis.
      approxStateStep: Number, to be used for binning the RDV axis.
      plotTrial: Bool, flag that determines whether the algorithm
          evolution for the trial should be plotted.
      decay: Number, corresponds to how barriers change over time
    Returns:
      The likelihood obtained for the given trial and model.
    """
    # Iterate over the fixations and discount the non-decision time.
    if addm.nonDecisionTime > 0
        correctedFixItem = Number[]
        correctedFixTime = Number[]
        remainingNDT = addm.nonDecisionTime
        for (fItem, fTime) in zip(trial.fixItem, trial.fixTime)
            if remainingNDT > 0
                push!(correctedFixItem, 0)
                push!(correctedFixTime, min(remainingNDT, fTime))
                push!(correctedFixItem, fTime)
                push!(correctedFixTime, max(fTime - remainingNDT, 0))
                remainingNDT = remainingNDT - fTime
            else
                push!(correctedFixTime, fItem)
                push!(correctedFixTime, fTime)
            end
        end
    else
        correctedFixItem = trial.fixItem
        correctedFixTime = trial.fixTime
    end
    
    # Iterate over the fixations and get the number of time steps for this trial.
    numTimeSteps = 0
    
    for fTime in correctedFixTime
        numTimeSteps += Int64(fTime ÷ timeStep)
    end
    
    if numTimeSteps < 1
        throw(RuntimeError("Trial response time is smaller than time step."))
    end
    numTimeSteps += 1
    
    # The values of the barriers can change over time.
    barrierUp = addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    barrierDown = -addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    
    # Obtain correct state step.
    halfNumStateBins = ceil(addm.barrier / approxStateStep)
    stateStep = addm.barrier / (halfNumStateBins + 0.5)
    
    # The vertical axis is divided into states.
    states = range(-1 + stateStep / 2, 1 - stateStep/2, step=stateStep)
    
    # Find the state corresponding to the bias parameter.
    biasState = argmin(abs.(states .- addm.bias))
    
    # Initial probability for all states is zero, except the bias state,
    # for which the initial probability is one.
    prStates = zeros(length(states), numTimeSteps)
    prStates[biasState,1] = 1
    
    # The probability of crossing each barrier over the time of the trial.
    probUpCrossing = zeros(numTimeSteps)
    probDownCrossing = zeros(numTimeSteps)
    
    time = 1
    
    # Dictionary of μ values from fItem.
    μDict = Dict{Number, Number}()
    NL = trial.ddmTrial.valueLeft - minValue
    NR = trial.ddmTrial.valueRight - minValue
    for fItem in 0:2
        if fItem == 1
            μ = addm.d * (NL - addm.θ*NR)
        elseif fItem == 2
            μ = addm.d * (addm.θ*NL - NR)
        else
            μ = 0
        end
        
        μDict[fItem] = μ
    end 
    
    changeMatrix = states .- reshape(states, 1, :)
    changeUp = (barrierUp .- reshape(states, 1, :))'
    changeDown = (barrierDown .- reshape(states, 1, :) )'
    
    pdfDict = Dict{Number, Any}()
    cdfUpDict = Dict{Number, Any}()
    cdfDownDict = Dict{Number, Any}() 
    
    for fItem in 0:2
        normpdf = similar(changeMatrix)
        cdfUp = similar(changeUp[:, time])
        cdfDown = similar(changeDown[:, time])
        
        @. normpdf = pdf(Normal(μDict[fItem], addm.σ), changeMatrix)
        @. cdfUp = cdf(Normal(μDict[fItem], addm.σ), changeUp[:, time])
        @. cdfDown = cdf(Normal(μDict[fItem], addm.σ), changeDown[:, time])
        pdfDict[fItem] = normpdf
        cdfUpDict[fItem] = cdfUp
        cdfDownDict[fItem] = cdfDown
    end
    
    # Iterate over all fixations in this trial.
    for (fItem, fTime) in zip(correctedFixItem, correctedFixTime)
        # We use a normal distribution to model changes in RDV
        # stochastically. The mean of the distribution (the change most
        # likely to occur) is calculated from the model parameters and from
        # the item values.
        μ = μDict[fItem]
        normpdf = pdfDict[fItem]
        cdfUp = cdfUpDict[fItem]
        cdfDown = cdfDownDict[fItem]
        
        # Iterate over the time interval of this fixation.
        for t in 1:Int64(fTime ÷ timeStep)
            # Update the probability of the states that remain inside the 
            # barriers. The probability of being in state B is the sum, 
            # over all states A, of the probability of being in A at the 
            # previous timestep times the probability of changing from A to
            # B. We multiply the probability by the stateStep to ensure
            # that the area under the curves for the probability 
            # distributions probUpCrossing and probDownCrossing add up to 1.
            prStatesNew = stateStep * (normpdf * prStates[:,time])
            prStatesNew[(states .>= barrierUp[t]) .| (states .<= barrierDown[t])] .= 0
            
            # Calculate the probabilities of crossing the up barrier and
            # the down barrier. This is given by the sum, over all states
            # A, of the proability of being in A at the previous timestep
            # times the probability of crossing the barrier if A is the
            # previous state.
            tempUpCross = dot(prStates[:,time], 1 .- cdfUp)
            tempDownCross = dot(prStates[:,time], cdfDown)
            
            # Renormalize to cope with numerical approximations.
            sumIn = sum(prStates[:,time])
            sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
            prStatesNew = prStatesNew * sumIn / sumCurrent
            tempUpCross = tempUpCross * sumIn / sumCurrent
            tempDownCross = tempDownCross * sumIn / sumCurrent

            # Update the probabilities of each state and the probabilities of
            # crossing each barrier at this timestep
            prStates[:,time+1] = prStatesNew
            probUpCrossing[time+1] = tempUpCross
            probDownCrossing[time+1] = tempDownCross
            
            time += 1
        end
    end
    
    # Compute the likelihood contribution of this trial based on the final
    # choice.
    likelihood = 0
    if trial.ddmTrial.choice == -1 # Choice was left.
        if probUpCrossing[end] > 0
            likelihood = probUpCrossing[end]
        end
    elseif trial.ddmTrial.choice == 1 # Choice was right.
        if probDownCrossing[end] > 0 
            likelihood = probDownCrossing[end]
        end
    end
    
    if plotTrial
        # TODO
    end
    
    return likelihood
end

function RNaDDM_get_trial_likelihood(addm::aDDM, trial::aDDMTrial, minValue::Number, maxValue::Number; timeStep::Number = 10.0, 
                                   approxStateStep::Number = 0.1, plotTrial::Bool = false, 
                                   decay::Number = 0.0)
    """
    Computes the likelihood of the data from a single aDDM trial for these
    particular aDDM parameters.
    Args:
      addm: aDDM object.
      trial: aDDMTrial object.
      timeStep: Number, value in milliseconds to be used for binning the
          time axis.
      approxStateStep: Number, to be used for binning the RDV axis.
      plotTrial: Bool, flag that determines whether the algorithm
          evolution for the trial should be plotted.
      decay: Number, corresponds to how barriers change over time
    Returns:
      The likelihood obtained for the given trial and model.
    """
    # Iterate over the fixations and discount the non-decision time.
    if addm.nonDecisionTime > 0
        correctedFixItem = Number[]
        correctedFixTime = Number[]
        remainingNDT = addm.nonDecisionTime
        for (fItem, fTime) in zip(trial.fixItem, trial.fixTime)
            if remainingNDT > 0
                push!(correctedFixItem, 0)
                push!(correctedFixTime, min(remainingNDT, fTime))
                push!(correctedFixItem, fTime)
                push!(correctedFixTime, max(fTime - remainingNDT, 0))
                remainingNDT = remainingNDT - fTime
            else
                push!(correctedFixTime, fItem)
                push!(correctedFixTime, fTime)
            end
        end
    else
        correctedFixItem = trial.fixItem
        correctedFixTime = trial.fixTime
    end
    
    # Iterate over the fixations and get the number of time steps for this trial.
    numTimeSteps = 0
    
    for fTime in correctedFixTime
        numTimeSteps += Int64(fTime ÷ timeStep)
    end
    
    if numTimeSteps < 1
        throw(RuntimeError("Trial response time is smaller than time step."))
    end
    numTimeSteps += 1
    
    # The values of the barriers can change over time.
    barrierUp = addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    barrierDown = -addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    
    # Obtain correct state step.
    halfNumStateBins = ceil(addm.barrier / approxStateStep)
    stateStep = addm.barrier / (halfNumStateBins + 0.5)
    
    # The vertical axis is divided into states.
    states = range(-1 + stateStep / 2, 1 - stateStep/2, step=stateStep)
    
    # Find the state corresponding to the bias parameter.
    biasState = argmin(abs.(states .- addm.bias))
    
    # Initial probability for all states is zero, except the bias state,
    # for which the initial probability is one.
    prStates = zeros(length(states), numTimeSteps)
    prStates[biasState,1] = 1
    
    # The probability of crossing each barrier over the time of the trial.
    probUpCrossing = zeros(numTimeSteps)
    probDownCrossing = zeros(numTimeSteps)
    
    time = 1
    
    # Dictionary of μ values from fItem.
    μDict = Dict{Number, Number}()
    NL = (trial.ddmTrial.valueLeft - minValue) / (maxValue-minValue)
    NR = (trial.ddmTrial.valueRight - minValue) / (maxValue-minValue)
    for fItem in 0:2
        if fItem == 1
            μ = addm.d * (NL - addm.θ*NR)
        elseif fItem == 2
            μ = addm.d * (addm.θ*NL - NR)
        else
            μ = 0
        end
        
        μDict[fItem] = μ
    end 
    
    changeMatrix = states .- reshape(states, 1, :)
    changeUp = (barrierUp .- reshape(states, 1, :))'
    changeDown = (barrierDown .- reshape(states, 1, :) )'
    
    pdfDict = Dict{Number, Any}()
    cdfUpDict = Dict{Number, Any}()
    cdfDownDict = Dict{Number, Any}() 
    
    for fItem in 0:2
        normpdf = similar(changeMatrix)
        cdfUp = similar(changeUp[:, time])
        cdfDown = similar(changeDown[:, time])
        
        @. normpdf = pdf(Normal(μDict[fItem], addm.σ), changeMatrix)
        @. cdfUp = cdf(Normal(μDict[fItem], addm.σ), changeUp[:, time])
        @. cdfDown = cdf(Normal(μDict[fItem], addm.σ), changeDown[:, time])
        pdfDict[fItem] = normpdf
        cdfUpDict[fItem] = cdfUp
        cdfDownDict[fItem] = cdfDown
    end
    
    # Iterate over all fixations in this trial.
    for (fItem, fTime) in zip(correctedFixItem, correctedFixTime)
        # We use a normal distribution to model changes in RDV
        # stochastically. The mean of the distribution (the change most
        # likely to occur) is calculated from the model parameters and from
        # the item values.
        μ = μDict[fItem]
        normpdf = pdfDict[fItem]
        cdfUp = cdfUpDict[fItem]
        cdfDown = cdfDownDict[fItem]
        
        # Iterate over the time interval of this fixation.
        for t in 1:Int64(fTime ÷ timeStep)
            # Update the probability of the states that remain inside the 
            # barriers. The probability of being in state B is the sum, 
            # over all states A, of the probability of being in A at the 
            # previous timestep times the probability of changing from A to
            # B. We multiply the probability by the stateStep to ensure
            # that the area under the curves for the probability 
            # distributions probUpCrossing and probDownCrossing add up to 1.
            prStatesNew = stateStep * (normpdf * prStates[:,time])
            prStatesNew[(states .>= barrierUp[t]) .| (states .<= barrierDown[t])] .= 0
            
            # Calculate the probabilities of crossing the up barrier and
            # the down barrier. This is given by the sum, over all states
            # A, of the proability of being in A at the previous timestep
            # times the probability of crossing the barrier if A is the
            # previous state.
            tempUpCross = dot(prStates[:,time], 1 .- cdfUp)
            tempDownCross = dot(prStates[:,time], cdfDown)
            
            # Renormalize to cope with numerical approximations.
            sumIn = sum(prStates[:,time])
            sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
            prStatesNew = prStatesNew * sumIn / sumCurrent
            tempUpCross = tempUpCross * sumIn / sumCurrent
            tempDownCross = tempDownCross * sumIn / sumCurrent

            # Update the probabilities of each state and the probabilities of
            # crossing each barrier at this timestep
            prStates[:,time+1] = prStatesNew
            probUpCrossing[time+1] = tempUpCross
            probDownCrossing[time+1] = tempDownCross
            
            time += 1
        end
    end
    
    # Compute the likelihood contribution of this trial based on the final
    # choice.
    likelihood = 0
    if trial.ddmTrial.choice == -1 # Choice was left.
        if probUpCrossing[end] > 0
            likelihood = probUpCrossing[end]
        end
    elseif trial.ddmTrial.choice == 1 # Choice was right.
        if probDownCrossing[end] > 0 
            likelihood = probDownCrossing[end]
        end
    end
    
    if plotTrial
        # TODO
    end
    
    return likelihood
end

function RNPaDDM_get_trial_likelihood(addm::aDDM, trial::aDDMTrial, minValue::Number, maxValue::Number, k::Number; timeStep::Number = 10.0, 
                                   approxStateStep::Number = 0.1, plotTrial::Bool = false, 
                                   decay::Number = 0.0)
    """
    Computes the likelihood of the data from a single aDDM trial for these
    particular aDDM parameters.
    Args:
      addm: aDDM object.
      trial: aDDMTrial object.
      timeStep: Number, value in milliseconds to be used for binning the
          time axis.
      approxStateStep: Number, to be used for binning the RDV axis.
      plotTrial: Bool, flag that determines whether the algorithm
          evolution for the trial should be plotted.
      decay: Number, corresponds to how barriers change over time
    Returns:
      The likelihood obtained for the given trial and model.
    """
    # Iterate over the fixations and discount the non-decision time.
    if addm.nonDecisionTime > 0
        correctedFixItem = Number[]
        correctedFixTime = Number[]
        remainingNDT = addm.nonDecisionTime
        for (fItem, fTime) in zip(trial.fixItem, trial.fixTime)
            if remainingNDT > 0
                push!(correctedFixItem, 0)
                push!(correctedFixTime, min(remainingNDT, fTime))
                push!(correctedFixItem, fTime)
                push!(correctedFixTime, max(fTime - remainingNDT, 0))
                remainingNDT = remainingNDT - fTime
            else
                push!(correctedFixTime, fItem)
                push!(correctedFixTime, fTime)
            end
        end
    else
        correctedFixItem = trial.fixItem
        correctedFixTime = trial.fixTime
    end
    
    # Iterate over the fixations and get the number of time steps for this trial.
    numTimeSteps = 0
    
    for fTime in correctedFixTime
        numTimeSteps += Int64(fTime ÷ timeStep)
    end
    
    if numTimeSteps < 1
        throw(RuntimeError("Trial response time is smaller than time step."))
    end
    numTimeSteps += 1
    
    # The values of the barriers can change over time.
    barrierUp = addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    barrierDown = -addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    
    # Obtain correct state step.
    halfNumStateBins = ceil(addm.barrier / approxStateStep)
    stateStep = addm.barrier / (halfNumStateBins + 0.5)
    
    # The vertical axis is divided into states.
    states = range(-1 + stateStep / 2, 1 - stateStep/2, step=stateStep)
    
    # Find the state corresponding to the bias parameter.
    biasState = argmin(abs.(states .- addm.bias))
    
    # Initial probability for all states is zero, except the bias state,
    # for which the initial probability is one.
    prStates = zeros(length(states), numTimeSteps)
    prStates[biasState,1] = 1
    
    # The probability of crossing each barrier over the time of the trial.
    probUpCrossing = zeros(numTimeSteps)
    probDownCrossing = zeros(numTimeSteps)
    
    time = 1
    
    # Dictionary of μ values from fItem.
    μDict = Dict{Number, Number}()
    NL = ((trial.ddmTrial.valueLeft - minValue) / (maxValue-minValue)) + (k/(1-addm.θ))
    NR = ((trial.ddmTrial.valueRight - minValue) / (maxValue-minValue))  + (k/(1-addm.θ))
    for fItem in 0:2
        if fItem == 1
            μ = addm.d * (NL - addm.θ*NR)
        elseif fItem == 2
            μ = addm.d * (addm.θ*NL - NR)
        else
            μ = 0
        end
        
        μDict[fItem] = μ
    end 
    
    changeMatrix = states .- reshape(states, 1, :)
    changeUp = (barrierUp .- reshape(states, 1, :))'
    changeDown = (barrierDown .- reshape(states, 1, :) )'
    
    pdfDict = Dict{Number, Any}()
    cdfUpDict = Dict{Number, Any}()
    cdfDownDict = Dict{Number, Any}() 
    
    for fItem in 0:2
        normpdf = similar(changeMatrix)
        cdfUp = similar(changeUp[:, time])
        cdfDown = similar(changeDown[:, time])
        
        @. normpdf = pdf(Normal(μDict[fItem], addm.σ), changeMatrix)
        @. cdfUp = cdf(Normal(μDict[fItem], addm.σ), changeUp[:, time])
        @. cdfDown = cdf(Normal(μDict[fItem], addm.σ), changeDown[:, time])
        pdfDict[fItem] = normpdf
        cdfUpDict[fItem] = cdfUp
        cdfDownDict[fItem] = cdfDown
    end
    
    # Iterate over all fixations in this trial.
    for (fItem, fTime) in zip(correctedFixItem, correctedFixTime)
        # We use a normal distribution to model changes in RDV
        # stochastically. The mean of the distribution (the change most
        # likely to occur) is calculated from the model parameters and from
        # the item values.
        μ = μDict[fItem]
        normpdf = pdfDict[fItem]
        cdfUp = cdfUpDict[fItem]
        cdfDown = cdfDownDict[fItem]
        
        # Iterate over the time interval of this fixation.
        for t in 1:Int64(fTime ÷ timeStep)
            # Update the probability of the states that remain inside the 
            # barriers. The probability of being in state B is the sum, 
            # over all states A, of the probability of being in A at the 
            # previous timestep times the probability of changing from A to
            # B. We multiply the probability by the stateStep to ensure
            # that the area under the curves for the probability 
            # distributions probUpCrossing and probDownCrossing add up to 1.
            prStatesNew = stateStep * (normpdf * prStates[:,time])
            prStatesNew[(states .>= barrierUp[t]) .| (states .<= barrierDown[t])] .= 0
            
            # Calculate the probabilities of crossing the up barrier and
            # the down barrier. This is given by the sum, over all states
            # A, of the proability of being in A at the previous timestep
            # times the probability of crossing the barrier if A is the
            # previous state.
            tempUpCross = dot(prStates[:,time], 1 .- cdfUp)
            tempDownCross = dot(prStates[:,time], cdfDown)
            
            # Renormalize to cope with numerical approximations.
            sumIn = sum(prStates[:,time])
            sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
            prStatesNew = prStatesNew * sumIn / sumCurrent
            tempUpCross = tempUpCross * sumIn / sumCurrent
            tempDownCross = tempDownCross * sumIn / sumCurrent

            # Update the probabilities of each state and the probabilities of
            # crossing each barrier at this timestep
            prStates[:,time+1] = prStatesNew
            probUpCrossing[time+1] = tempUpCross
            probDownCrossing[time+1] = tempDownCross
            
            time += 1
        end
    end
    
    # Compute the likelihood contribution of this trial based on the final
    # choice.
    likelihood = 0
    if trial.ddmTrial.choice == -1 # Choice was left.
        if probUpCrossing[end] > 0
            likelihood = probUpCrossing[end]
        end
    elseif trial.ddmTrial.choice == 1 # Choice was right.
        if probDownCrossing[end] > 0 
            likelihood = probDownCrossing[end]
        end
    end
    
    if plotTrial
        # TODO
    end
    
    return likelihood
end

function DRNPaDDM_get_trial_likelihood(addm::aDDM, trial::aDDMTrial, k::Number; timeStep::Number = 10.0, approxStateStep::Number = 0.1, plotTrial::Bool = false, decay::Number = 0.0)
    """
    Computes the likelihood of the data from a single aDDM trial for these
    particular aDDM parameters.
    Args:
      addm: aDDM object.
      trial: aDDMTrial object.
      timeStep: Number, value in milliseconds to be used for binning the
          time axis.
      approxStateStep: Number, to be used for binning the RDV axis.
      plotTrial: Bool, flag that determines whether the algorithm
          evolution for the trial should be plotted.
      decay: Number, corresponds to how barriers change over time
    Returns:
      The likelihood obtained for the given trial and model.
    """
    # Iterate over the fixations and discount the non-decision time.
    if addm.nonDecisionTime > 0
        correctedFixItem = Number[]
        correctedFixTime = Number[]
        remainingNDT = addm.nonDecisionTime
        for (fItem, fTime) in zip(trial.fixItem, trial.fixTime)
            if remainingNDT > 0
                push!(correctedFixItem, 0)
                push!(correctedFixTime, min(remainingNDT, fTime))
                push!(correctedFixItem, fTime)
                push!(correctedFixTime, max(fTime - remainingNDT, 0))
                remainingNDT = remainingNDT - fTime
            else
                push!(correctedFixTime, fItem)
                push!(correctedFixTime, fTime)
            end
        end
    else
        correctedFixItem = trial.fixItem
        correctedFixTime = trial.fixTime
    end
    
    # Iterate over the fixations and get the number of time steps for this trial.
    numTimeSteps = 0
    
    for fTime in correctedFixTime
        numTimeSteps += Int64(fTime ÷ timeStep)
    end
    
    if numTimeSteps < 1
        throw(RuntimeError("Trial response time is smaller than time step."))
    end
    numTimeSteps += 1
    
    # The values of the barriers can change over time.
    barrierUp = addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    barrierDown = -addm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    
    # Obtain correct state step.
    halfNumStateBins = ceil(addm.barrier / approxStateStep)
    stateStep = addm.barrier / (halfNumStateBins + 0.5)
    
    # The vertical axis is divided into states.
    states = range(-1 + stateStep / 2, 1 - stateStep/2, step=stateStep)
    
    # Find the state corresponding to the bias parameter.
    biasState = argmin(abs.(states .- addm.bias))
    
    # Initial probability for all states is zero, except the bias state,
    # for which the initial probability is one.
    prStates = zeros(length(states), numTimeSteps)
    prStates[biasState,1] = 1
    
    # The probability of crossing each barrier over the time of the trial.
    probUpCrossing = zeros(numTimeSteps)
    probDownCrossing = zeros(numTimeSteps)
    
    time = 1
    
    # Dictionary of μ values from fItem.
    μDict = Dict{Number, Number}()
    NL = ((trial.ddmTrial.valueLeft - trial.minValue) / (trial.maxValue-trial.minValue)) + (k/(1-addm.θ))
    NR = ((trial.ddmTrial.valueRight - trial.minValue) / (trial.maxValue-trial.minValue)) + (k/(1-addm.θ))
    for fItem in 0:2
        if fItem == 1
            μ = addm.d * (NL - addm.θ*NR)
        elseif fItem == 2
            μ = addm.d * (addm.θ*NL - NR)
        else
            μ = 0
        end
        
        μDict[fItem] = μ
    end 
    
    changeMatrix = states .- reshape(states, 1, :)
    changeUp = (barrierUp .- reshape(states, 1, :))'
    changeDown = (barrierDown .- reshape(states, 1, :) )'
    
    pdfDict = Dict{Number, Any}()
    cdfUpDict = Dict{Number, Any}()
    cdfDownDict = Dict{Number, Any}() 
    
    for fItem in 0:2
        normpdf = similar(changeMatrix)
        cdfUp = similar(changeUp[:, time])
        cdfDown = similar(changeDown[:, time])
        
        @. normpdf = pdf(Normal(μDict[fItem], addm.σ), changeMatrix)
        @. cdfUp = cdf(Normal(μDict[fItem], addm.σ), changeUp[:, time])
        @. cdfDown = cdf(Normal(μDict[fItem], addm.σ), changeDown[:, time])
        pdfDict[fItem] = normpdf
        cdfUpDict[fItem] = cdfUp
        cdfDownDict[fItem] = cdfDown
    end
    
    # Iterate over all fixations in this trial.
    for (fItem, fTime) in zip(correctedFixItem, correctedFixTime)
        # We use a normal distribution to model changes in RDV
        # stochastically. The mean of the distribution (the change most
        # likely to occur) is calculated from the model parameters and from
        # the item values.
        μ = μDict[fItem]
        normpdf = pdfDict[fItem]
        cdfUp = cdfUpDict[fItem]
        cdfDown = cdfDownDict[fItem]
        
        # Iterate over the time interval of this fixation.
        for t in 1:Int64(fTime ÷ timeStep)
            # Update the probability of the states that remain inside the 
            # barriers. The probability of being in state B is the sum, 
            # over all states A, of the probability of being in A at the 
            # previous timestep times the probability of changing from A to
            # B. We multiply the probability by the stateStep to ensure
            # that the area under the curves for the probability 
            # distributions probUpCrossing and probDownCrossing add up to 1.
            prStatesNew = stateStep * (normpdf * prStates[:,time])
            prStatesNew[(states .>= barrierUp[t]) .| (states .<= barrierDown[t])] .= 0
            
            # Calculate the probabilities of crossing the up barrier and
            # the down barrier. This is given by the sum, over all states
            # A, of the proability of being in A at the previous timestep
            # times the probability of crossing the barrier if A is the
            # previous state.
            tempUpCross = dot(prStates[:,time], 1 .- cdfUp)
            tempDownCross = dot(prStates[:,time], cdfDown)
            
            # Renormalize to cope with numerical approximations.
            sumIn = sum(prStates[:,time])
            sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
            prStatesNew = prStatesNew * sumIn / sumCurrent
            tempUpCross = tempUpCross * sumIn / sumCurrent
            tempDownCross = tempDownCross * sumIn / sumCurrent

            # Update the probabilities of each state and the probabilities of
            # crossing each barrier at this timestep
            prStates[:,time+1] = prStatesNew
            probUpCrossing[time+1] = tempUpCross
            probDownCrossing[time+1] = tempDownCross
            
            time += 1
        end
    end
    
    # Compute the likelihood contribution of this trial based on the final
    # choice.
    likelihood = 0
    if trial.ddmTrial.choice == -1 # Choice was left.
        if probUpCrossing[end] > 0
            likelihood = probUpCrossing[end]
        end
    elseif trial.ddmTrial.choice == 1 # Choice was right.
        if probDownCrossing[end] > 0 
            likelihood = probDownCrossing[end]
        end
    end
    
    if plotTrial
        # TODO
    end
    
    return likelihood
end

function aDDM_simulate_trial(addm::aDDM, fixationData::FixationData, valueLeft::Number, valueRight::Number; 
                        timeStep::Number=10.0, numFixDists::Int64=3 , fixationDist=nothing, 
                        timeBins=nothing, cutOff::Number=100000)
    """
    Generates a DDM trial given the item values.
    Args:
      addm: aDDM object.
      fixationData: FixationData object.
      valueLeft: value of the left item.
      valueRight: value of the right item.
      timeStep: Number, value in milliseconds to be used for binning
          time axis.
      numFixDists: Int64, number of fixation types to use in the fixation
          distributions. For instance, if numFixDists equals 3, then 3
          separate fixation types will be used, corresponding to the 1st,
          2nd and other (3rd and up) fixations in each trial.
      fixationDist: distribution of fixations which, when provided, will be
          used instead of fixationData.fixations. This should be a dict of
          dicts of dicts, corresponding to the probability distributions of
          fixation durations. Indexed first by fixation type (1st, 2nd, etc),
          then by the value difference between the fixated and unfixated 
          items, then by time bin. Each entry is a number between 0 and 1 
          corresponding to the probability assigned to the particular time
          bin (i.e. given a particular fixation type and value difference,
          probabilities for all bins should add up to 1).
      timeBins: array containing the time bins used in fixationDist.
    Returns:
      An aDDMTrial object resulting from the simulation.
    """
    fixUnfixValueDiffs = Dict(1 => valueLeft - valueRight, 2 => valueRight - valueLeft)
    
    fixItem = Number[]
    fixTime = Number[]
    fixRDV = Number[]

    RDV = addm.bias
    trialTime = 0
    choice = 0
    tRDV = Number[RDV]
    RT = 0
    uninterruptedLastFixTime = 0
    
    # Sample and iterate over the latency for this trial.
    latency = rand(fixationData.latencies)
    remainingNDT = addm.nonDecisionTime - latency
    for t in 1:Int64(latency ÷ timeStep)
        # Sample the change in RDV from the distribution.
        RDV += rand(Normal(0, addm.σ))
        push!(tRDV, RDV)

        # If the RDV hit one of the barriers, the trial is over.
        if abs(RDV) >= addm.barrier
            choice = RDV >= 0 ? -1 : 1
            push!(fixRDV, RDV)
            push!(fixItem, 0)
            push!(fixTime, t * timeStep)
            trialTime += t * timeStep
            RT = trialTime
            uninterruptedLastFixTime = latency
            return aDDMTrial(tRDV, RT, choice, valueLeft, valueRight, 
                             fixItem=fixItem, fixTime=fixTime, fixRDV=fixRDV, 
                             uninterruptedLastFixTime=uninterruptedLastFixTime)
        end
    end

    # Add latency to this trial's data
    push!(fixRDV, RDV)
    push!(fixItem, 0)
    push!(fixTime, latency - (latency % timeStep))
    trialTime += latency - (latency % timeStep)

    fixNumber = 1
    prevFixItem = -1
    currFixLocation = 0
    decisionReached = false

    while true
        if currFixLocation == 0
            # This is an item fixation; sample its location.
            if prevFixItem == -1
                # Sample the first item fixation for this trial.
                currFixLocation = rand(Bernoulli(1 - fixationData.probFixLeftFirst)) + 1
            elseif prevFixItem in [1, 2]
                currFixLocation = abs(3 - prevFixItem)
            end
            prevFixItem = currFixLocation

            # Sample the duration of this item fixation.
            if fixationDist === nothing
                if fixationData.fixDistType == "simple"
                    currFixTime = rand(reduce(vcat, fixationData.fixations[fixNumber]))
                elseif fixationData.fixDistType == "difficulty" # maybe add reduce() like in simple
                    valueDiff = abs(valueLeft - valueRight)
                    currFixTime = rand(fixationData.fixations[fixNumber][valueDiff])
                elseif fixationData.fixDistType == "fixation"
                    valueDiff = fixUnfixValueDiffs[currFixLocation]
                    currFixTime = rand(fixationData.fixations[fixNumber][valueDiff])
                end
            else 
                # TODO
                throw(error("I HAVE NOT CODED THIS PART JUST YET"))
            end

            if fixNumber < numFixDists
                fixNumber += 1
            end

        else
            # This is a transition.
            currFixLocation = 0
            #Sample the duration of this transition.
            currFixTime = rand(fixationData.transitions)
        end

        # Iterate over the remaining non-decision time
        if remainingNDT > 0
            for t in 1:Int64(remainingNDT ÷ timeStep)
                # Sample the change in RDV from the distribution.
                RDV += rand(Normal(0, addm.σ))
                push!(tRDV, RDV)

                # If the RDV hit one of the barriers, the trial is over.
                if abs(RDV) >= addm.barrier
                    choice = RDV >= 0 ? -1 : 1
                    push!(fixRDV, RDV)
                    push!(fixItem, currFixLocation)
                    push!(fixTime, t * timeStep)
                    trialTime += t * timeStep
                    RT = trialTime
                    uninterruptedLastFixTime = currFixTime
                    decisionReached = true
                    break
                end
            end
        end

        if decisionReached
            break
        end

        remainingFixTime = max(0, currFixTime - max(0, remainingNDT))
        remainingNDT -= currFixTime

        # Iterate over the duration of the current fixation.
        for t in 1:Int64(remainingFixTime ÷ timeStep)
            # We use a distribution to model changes in RDV
            # stochastically. The mean of the distribution (the change
            # most likely to occur) is calculated from the model
            # parameters and from the values of the two items.
            if currFixLocation == 0
                μ = 0
            elseif currFixLocation == 1
                μ = addm.d * (valueLeft - (addm.θ * valueRight))
            elseif currFixLocation == 2
                μ = addm.d * ((addm.θ * valueLeft) - valueRight)
            end

            # Sample the change in RDV from the distribution.
            RDV += rand(Normal(μ, addm.σ))
            push!(tRDV, RDV)

            # If the RDV hit one of the barriers, the trial is over.
            if abs(RDV) >= addm.barrier
                choice = RDV >= 0 ? -1 : 1
                push!(fixRDV, RDV)
                push!(fixItem, currFixLocation)
                push!(fixTime, t * timeStep)
                trialTime += t * timeStep
                RT = trialTime
                uninterruptedLastFixTime = currFixTime
                decisionReached = true
                break
            end
        end

        if decisionReached
            break
        end

        # Add fixation to this trial's data.
        push!(fixRDV, RDV)
        push!(fixItem, currFixLocation)
        push!(fixTime, currFixTime - (currFixTime % timeStep))
        trialTime += currFixTime - (currFixTime % timeStep)

    end
    return aDDMTrial(tRDV, RT, choice, valueLeft, valueRight, fixItem=fixItem, fixTime=fixTime, fixRDV=fixRDV, uninterruptedLastFixTime=uninterruptedLastFixTime)
end


function aDDM_simulate_trial_data(addm::aDDM, fixationData::FixationData, n::Int64; cutOff::Int64 = 20000)
    """
    Args:
      addm: aDDM object.
      fixationData: FixationData object.
      n: Number of trials to be simulated.
      valueLeft: value of the left item.
      valueRight: value of the right item.
    Returns:
      addmTrials: Vector of aDDMTrial.s 
    """
    addmTrials = [aDDM_simulate_trial(addm, fixationData, rand(0:5), rand(0:5), cutOff=cutOff) for _ in 1:n]
    return addmTrials
end


function aDDM_simulate_trial_data_threads(addm::aDDM, fixationData::FixationData, n::Int64; cutOff::Int64 = 20000)
    """
    Args:
      addm: aDDM object.
      fixationData: FixationData object.
      n: Number of trials to be simulated.
      valueLeft: value of the left item.
      valueRight: value of the right item.
    Returns:
      addmTrials: Vector of aDDMTrial.s 
    """
    addmTrials = Vector{aDDMTrial}(undef, n)
    @threads for i in 1:n
        addmTrials[i] = aDDM_simulate_trial(addm, fixationData, rand(0:5), rand(0:5), cutOff=cutOff)
    end

    return addmTrials
end


function aDDM_negative_log_likelihood(addmTrials::Vector{aDDMTrial}, d::Number, σ::Number, θ::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ)
    likelihoods = [aDDM_get_trial_likelihood(addm, addmTrial) for addmTrial in addmTrials]
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end


function aDDM_negative_log_likelihood_threads(addm::aDDM, addmTrials::Vector{aDDMTrial}, d::Number, σ::Number, θ::Number, b::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ; bias=b)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = aDDM_get_trial_likelihood(addm, addmTrials[i])
    end
    
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end

function addDDM_negative_log_likelihood_threads(addm::aDDM, addmTrials::Vector{aDDMTrial}, d::Number, σ::Number, θ::Number, b::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ; bias=b)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = addDDM_get_trial_likelihood(addm, addmTrials[i])
    end
    
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end

function cbAddDDM_negative_log_likelihood_threads(addm::aDDM, addmTrials::Vector{aDDMTrial}, d::Number, σ::Number, θ::Number, b::Number, c::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ; bias=b)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = addDDM_get_trial_likelihood(addm, addmTrials[i]; decay=c)
    end
    
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end

function AddaDDM_negative_log_likelihood_threads(addm::aDDM, addmTrials::Vector{aDDMTrial}, minValue::Number, maxValue::Number, d::Number, σ::Number, θ::Number, b::Number, k::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ; bias=b)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = AddaDDM_get_trial_likelihood(addm, addmTrials[i], minValue, maxValue, k)
    end
    
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end

function DNaDDM_negative_log_likelihood_threads(addm::aDDM, addmTrials::Vector{aDDMTrial}, d::Number, σ::Number, θ::Number, b::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ; bias=b)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = DNaDDM_get_trial_likelihood(addm, addmTrials[i])
    end
    
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end

function DNPaDDM_negative_log_likelihood_threads(addm::aDDM, addmTrials::Vector{aDDMTrial}, d::Number, σ::Number, θ::Number, b::Number, k::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ; bias=b)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = DNPaDDM_get_trial_likelihood(addm, addmTrials[i], k)
    end
    
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end

function GDaDDM_negative_log_likelihood_threads(addm::aDDM, addmTrials::Vector{aDDMTrial}, minValue::Number, maxValue::Number, d::Number, σ::Number, θ::Number, b::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ; bias=b)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = GDaDDM_get_trial_likelihood(addm, addmTrials[i], minValue, maxValue)
    end
    
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end

function RNaDDM_negative_log_likelihood_threads(addm::aDDM, addmTrials::Vector{aDDMTrial}, minValue::Number, maxValue::Number, d::Number, σ::Number, θ::Number, b::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ; bias=b)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = RNaDDM_get_trial_likelihood(addm, addmTrials[i], minValue, maxValue)
    end
    
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end

function RNPaDDM_negative_log_likelihood_threads(addm::aDDM, addmTrials::Vector{aDDMTrial}, minValue::Number, maxValue::Number, d::Number, σ::Number, θ::Number, b::Number, k::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ; bias=b)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = RNPaDDM_get_trial_likelihood(addm, addmTrials[i], minValue, maxValue, k)
    end
    
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end

function DRNPaDDM_negative_log_likelihood_threads(addm::aDDM, addmTrials::Vector{aDDMTrial}, d::Number, σ::Number, θ::Number, b::Number, k::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      addmTrials: Vector of aDDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of aDDMTrials and model.
    """
    # Calculate the negative log likelihood
    addm = aDDM(d, σ, θ; bias=b)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = DRNPaDDM_get_trial_likelihood(addm, addmTrials[i], k)
    end
    
    likelihoods = max.(likelihoods, 1e-64)
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end

function aDDM_total_likelihood(addmTrials::Vector{aDDMTrial}, d::Number, σ::Number, θ::Number)
    addm = aDDM(d, σ, θ)
    likelihoods = Vector{Float64}(undef, length(addmTrials))
    
    @threads for i in 1:length(addmTrials)
        likelihoods[i] = aDDM_get_trial_likelihood(addm, addmTrials[i])
    end

    total_likelihood = sum(likelihoods)
    return total_likelihood
end