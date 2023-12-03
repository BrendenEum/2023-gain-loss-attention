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

Module: ddm.jl
Author: Lynn Yang, lynnyang@caltech.edu

Implementation of the classic drift-diffusion model (DDM), as described by
Ratcliff et al. (1998).

Based on Python addm_toolbox from Gabriela Tavares, gtavares@caltech.edu.
"""

using Pkg
Pkg.activate("addm")

using Random
using Distributions
using CSV
using DataFrames
using Statistics
using LinearAlgebra


struct DDMTrial
    """
    Args:
      RDV: vector of RDV over time.
      RT: response time in milliseconds.
      choice: either -1 (for left item) or +1 (for right item).
      valueLeft: value of the left item.
      valueRight: value of the right item.
    """
    RDV::Vector{Number}
    RT::Number
    choice::Number
    valueLeft::Number
    valueRight::Number

    function DDMTrial(RDV, RT, choice, valueLeft, valueRight)
        new(RDV, RT, choice, valueLeft, valueRight)
    end
end


Base.@kwdef mutable struct DDM
    """
    Implementation of the traditional drift-diffusion model (DDM), as described
    by Ratcliff et al. (1998).

    Args:
      d: Number, parameter of the model which controls the speed of
          integration of the signal.
      σ: Number, parameter of the model, standard deviation for the
          normal distribution.
      barrier: positive Int64, magnitude of the signal thresholds.
      nonDecisionTime: non-negative Number, the amount of time in
          milliseconds during which only noise is added to the nonDecisionTime
          variable.
      bias: Number, corresponds to the initial value of the nonDecisionTime
          variable. Must be smaller than barrier.
      params: Tuple, parameters of the model.
    """
    d::Number
    σ::Number
    barrier::Number
    nonDecisionTime::Number
    bias::Number
    params::Tuple{Number, Number} = (d, σ)

    function DDM(d, σ; barrier=1, nonDecisionTime=0, bias=0.0)
        if barrier <= 0
            throw(ValueError("Error: barrier parameter must larger than zero."))
        elseif bias >= barrier
            throw(ValueError("Error: bias parameter must be smaller than barrier parameter."))
        end
        new(d, σ, barrier, nonDecisionTime, bias, (d, σ))
    end
end


function DDM_get_trial_likelihood(ddm::DDM, trial::DDMTrial; timeStep::Number = 10, 
                                  approxStateStep::Number = 0.1, plotTrial::Bool = false,
                                  decay::Number = 0)
    """
    Computes the likelihood of the data from a single DDM trial for these
    particular DDM parameters.
    Args:
        ddm: DDM object.
        trial: DDMTrial object.
        timeStep: Number, value in milliseconds to be used for binning the
            time axis.
        approxStateStep: Number, to be used for binning the RDV axis.
        plotTrial: Bool, flag that determines whether the algorithm
            evolution for the trial should be plotted.
        decay: float, corresponds to how barriers change over time
    Returns:
        The likelihood obtained for the given trial and model.
    """
    # Get the number of time steps for this trial.
    numTimeSteps = Int64(trial.RT ÷ timeStep)
    if numTimeSteps < 1
        throw(RuntimeError("Trial response time is smaller than time step."))
    end

    # The values of the barriers can change over time.
    barrierUp = ddm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))
    barrierDown = -ddm.barrier ./ (1 .+ decay .* (0:numTimeSteps-1))

    # Obtain correct state step.
    halfNumStateBins = ceil(ddm.barrier / approxStateStep)
    stateStep = ddm.barrier / (halfNumStateBins + 0.5)
    
    # The vertical axis is divided into states.
    states = range(-1 + stateStep / 2, 1 - stateStep/2, step=stateStep)
    
    # Find the state corresponding to the bias parameter.
    biasState = argmin(abs.(states .- ddm.bias))
    
    # Initial probability for all states is zero, except the bias state,
    # for which the initial probability is one.
    prStates = zeros(length(states), numTimeSteps)
    prStates[biasState,1] = 1
    
    # The probability of crossing each barrier over the time of the trial.
    probUpCrossing = zeros(numTimeSteps)
    probDownCrossing = zeros(numTimeSteps)
    
    changeMatrix = states .- reshape(states, 1, :)
    changeUp = (barrierUp .- reshape(states, 1, :))'
    changeDown = (barrierDown .- reshape(states, 1, :) )'
    
    normpdf = similar(changeMatrix)
    
    elapsedNDT = 0
    
    # Iterate over the time of this trial.
    for time in 1:numTimeSteps-1
        # We use a normal distribution to model changes in RDV
        # stochastically. The mean of the distribution (the change most
        # likely to occur) is calculated from the model parameter d and
        # from the item values, except during non-decision time, in which
        # the mean is zero.
        if elapsedNDT < ddm.nonDecisionTime ÷ timeStep
            μ = 0
            elapsedNDT += 1
        else
            μ = ddm.d * (trial.valueLeft - trial.valueRight)
        end
        
        # Update the probability of the states that remain inside the
        # barriers. The probability of being in state B is the sum, over
        # all states A, of the probability of being in A at the previous
        # time step times the probability of changing from A to B. We
        # multiply the probability by the stateStep to ensure that the area
        # under the curves for the probability distributions probUpCrossing
        # and probDownCrossing add up to 1.
        @. normpdf = pdf(Normal(μ, ddm.σ), changeMatrix)
        prStatesNew = stateStep * (normpdf * prStates[:,time])
        prStatesNew[(states .>= 1) .| (states .<= -1)] .= 0
        
        # Calculate the probabilities of crossing the up barrier and the
        # down barrier. This is given by the sum, over all states A, of the
        # probability of being in A at the previous timestep times the
        # probability of crossing the barrier if A is the previous state.
        cdfUp = similar(changeUp[:, time])
        cdfDown = similar(changeDown[:, time])
        @. cdfUp = cdf(Normal(μ, ddm.σ), changeUp[:, time])
        @. cdfDown = cdf(Normal(μ, ddm.σ), changeDown[:, time])
        
        tempUpCross = dot(prStates[:,time], 1 .- cdfUp)
        tempDownCross = dot(prStates[:,time], cdfDown)

        # Renormalize to cope with numerical approximations.
        sumIn = sum(prStates[:,time])
        sumCurrent = sum(prStatesNew) + tempUpCross + tempDownCross
        prStatesNew = prStatesNew * sumIn / sumCurrent
        tempUpCross = tempUpCross * sumIn / sumCurrent
        tempDownCross = tempDownCross * sumIn / sumCurrent

        # Update the probabilities of each state and the probabilities of
        # crossing each barrier at this timestep.
        prStates[:,time+1] = prStatesNew
        probUpCrossing[time+1] = tempUpCross
        probDownCrossing[time+1] = tempDownCross
    end
    
    # Compute the likelihood contribution of this trial based on the final choice.
    likelihood = 0
    if trial.choice == -1 # Choice was left.
        if probUpCrossing[end] > 0
            likelihood = probUpCrossing[end]
        end
    elseif trial.choice == 1 # Choice was right.
        if probDownCrossing[end] > 0
            likelihood = probDownCrossing[end]
        end
    end
    
    if plotTrial
        # TODO
    end
    
    return likelihood
end


function DDM_simulate_trial(ddm::DDM, valueLeft::Number, valueRight::Number;
                            timeStep::Number = 10.0, cutOff::Int64 = 20000)
    """
    Generates a DDM trial given the item values.
    Args:
      ddm: DDM object.
      valueLeft: value of the left item.
      valueRight: value of the right item.
      timeStep: Number, value in milliseconds to be used for binning the
          time axis.
      cutOff: Number, value in milliseconds to be used as a cap if trial
          response time is too long.
    Returns:
      A DDMTrial object resulting from the simulation.
    """
    RDV = ddm.bias
    elapsedNDT = 0
    tRDV = Vector{Number}(undef, cutOff)
    valueDiff = ddm.d * (valueLeft - valueRight)

    for time in 0:cutOff-1
        tRDV[time + 1] = RDV

        # If the RDV hit one of the barriers, the trial is over.
        if abs(RDV) >= ddm.barrier
            choice = RDV >= 0 ? -1 : 1
            return DDMTrial(tRDV[1:time + 1], time * timeStep, choice, valueLeft, valueRight)
        end

        # If the response time is higher than the cutoff, the trial is over.
        if time * timeStep >= cutOff
            choice = RDV >= 0 ? 1 : -1
            return DDMTrial(tRDV[1:time + 1], time * timeStep, choice, valueLeft, valueRight)
        end

        # Sample the change in RDV from the distribution.
        if elapsedNDT < (ddm.nonDecisionTime ÷ timeStep)
            μ = 0
            elapsedNDT += 1
        else
            μ = valueDiff
        end

        RDV += rand(Normal(μ, ddm.σ))
    end

    choice = RDV >= 0 ? 1 : -1
    return DDMTrial(tRDV, cutOff * timeStep, choice, valueLeft, valueRight)
end


function DDM_simulate_trial_data(ddm::DDM, n::Int64; cutOff::Int64 = 20000)
    """
    Generates a vector of DDMTrial simulations.
    Args:
      ddm: DDM object.
      n: Number of trials to be simulated.
      valueLeft: value of the left item.
      valueRight: value of the right item.
    Returns:
      ddmTrials: Vector of DDMTrials.
    """
    ddmTrials = [DDM_simulate_trial(ddm, rand(0:5), rand(0:5), cutOff=cutOff) for _ in 1:n]
    return ddmTrials
end


function DDM_negative_log_likelihood(ddmTrials::Vector{DDMTrial}, d::Number, σ::Number)
    """
    Calculates the negative log likelihood from a given dataset of DDMTrials and parameters
    of a model.
    Args:
      ddmTrials: Vector of DDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the given vector of DDMTrials and model.
    """
    # Calculate the likelihood of each trial.
    ddm = DDM(d, σ)
    likelihoods = [DDM_get_trial_likelihood(ddm, ddmTrial) for ddmTrial in ddmTrials]

    # If likelihood is 0, set it to 1e-64 to avoid taking the log of a 0.
    likelihoods = max.(likelihoods, 1e-64)

    # Sum over all of the negative log likelihoods.
    negative_log_likelihood = -sum(log.(likelihoods))
    
    return negative_log_likelihood
end


function DDM_simulate_trial_data_csv(ddm::DDM, n::Int64; path::String="", 
                             fileName::String="ddm_data.csv", cutOff::Int64=20000)
    """
    Saves a CSV file of simulated DDMTrials.
    Args:
      n: Number of trials
      d: Number, parameter of model which controls the speed of integration
          of the signal.
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
      path: String, path to save CSV file.
    """
    # Generate a list of simulated DDMTrials.
    trials = []
    for i in 1:n
        l = rand(0:5)
        r = rand(0:5)
        trial = DDM_simulate_trial(ddm, l, r, cutOff=cutOff)
        push!(trials, trial)
    end

    # Create a dataframe from the simulated DDMTrials list.
    df = DataFrame(trial=1:n, rt=[trial.RT for trial in trials],
                   choice=[trial.choice for trial in trials],
                   valueLeft=[trial.valueLeft for trial in trials],
                   valueRight=[trial.valueRight for trial in trials])
    
    # Determine file path and save it as a CSV file.
    filePath = path * fileName
    CSV.write(filePath, df)
end


function DDM_negative_log_likelihood_csv(dataFileName::String, d::Number, σ::Number)
    """
    Calculates the negative log likelihood from a CSV file which contains a dataset of 
    DDMTrials and parameters of a model.
    Args:
      dataFileName: CSV file of simulated DDMTrials.
      d: Number, parameter of the model which controls the speed of integration of
          the signal. 
      σ: Number, parameter of the model, standard deviation for the normal
          distribution.
    Returns: 
      The negative log likelihood for the dataset of DDMTrials and model.
    """
    # Load data from CSV file.
    try 
        df = DataFrame(CSV.File(dataFileName, delim=","))
    catch
        print("Error while reading DDM data file " * dataFileName)
        return nothing
    end
    
    df = DataFrame(CSV.File(dataFileName, delim=","))
    
    # Check to make sure all of the fields exist in the data file.
    if (!("trial" in names(df)) || !("rt" in names(df)) || !("choice" in names(df)) || !("valueRight" in names(df))
        || !("valueLeft" in names(df)))
        throw(error("Missing field in experimental data file. Fields required: trial, rt, choice, valueLeft, valueRight"))
    end

    ddm = DDM(d, σ)
    negative_log_likelihood = 0
    for i in 1:size(df)[1]
        ddmTrial = DDMTrial([], df.rt[i], df.choice[i], df.valueLeft[i], df.valueRight[i])

        # Calculate the likelihood of each trial.
        likelihood = DDM_get_trial_likelihood(ddm, ddmTrial)

        # If likelihood is 0, set it to 1e-64 to avoid taking the log of a 0.
        likelihoods = max.(likelihoods, 1e-64)

        # Sum over all of the negative log likelihoods.
        negative_log_likelihood += -log(likelihood)
    end
        
    return negative_log_likelihood
end
