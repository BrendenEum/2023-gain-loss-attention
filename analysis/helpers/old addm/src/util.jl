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

Module: util.jl
Author: Lynn Yang, lynnyang@caltech.edu

Utility functions for the aDDM Toolbox.

Based on Python addm_toolbox from Gabriela Tavares, gtavares@caltech.edu.
"""

using Pkg
Pkg.activate("addm")

include("addm.jl")


function convert_item_values(value)
    return abs((abs(value) - 15) / 5)
end


function load_trial_conditions_from_csv(trialsFileName::String)
    """
    Loads trial conditions from a CSV file. Format expected for trial
    conditions file: value_left, value_right.
    Args:
      trialsFileName: String, name of trial conditions file. 

    Returns:
      A list containing the trial conditions, where each trial condition is a
          tuple with format (value_left, value_right).
    """
    trialConditions = []
    try
        df = DataFrame(CSV.File(trialsFileName, delim=","))
        if (!("value_left" in names(df)) || !("value_right" in names(df)))
            throw(error("Missing field in fixations file. Fields required: value_left, value_right"))
        end
        
        csvfile = CSV.File(trialsFileName)
        
        for row in csvfile
            push!(trialConditions, (Float64(row.value_left), Float64(row.value_right)))
        end
    catch
        println("Error while reading trials file " * trialsFileName)
        return nothing
    end
    
    return trialConditions
end


function load_data_from_csv(expdataFileName, fixationsFileName; convertItemValues=nothing)
    """
    Loads experimental data from two CSV files: an experimental data file and a
    fixations file. If angular distances are used, they are expected to be from
    the set [-15, -10, -5, 0, 5, 10, 15] and will be converted into values in
    [0, 1, 2, 3]. Format expected for experimental data file: parcode, trial,
    rt, choice, item_left, item_right. Format expected for fixations file:
    parcode, trial, fix_item, fix_time.
    Args:
      expdataFileName: String, name of experimental data file.
      fixationsFileName: String, name of fixations file.
      convertItemValues: handle to a function that converts item values.
    Returns:
      A dict, indexed by subjectId, where each entry is a list of aDDMTrial
          objects.
    """
    # Load experimental data from CSV file.
    try 
        df = DataFrame(CSV.File(expdataFileName, delim=","))
    catch
        print("Error while reading experimental data file " * expdataFileName)
        return nothing
    end
    
    df = DataFrame(CSV.File(expdataFileName, delim=","))
    
    if (!("parcode" in names(df)) || !("trial" in names(df)) || !("rt" in names(df)) || !("choice" in names(df))
        || !("item_left" in names(df)) || !("item_right" in names(df)))
        throw(error("Missing field in experimental data file. Fields required: parcode, trial, rt, choice, item_left, item_right"))
    end
    
    data = Dict()
    subjectIds = unique(df.parcode)
    for subjectId in subjectIds
        data[subjectId] = aDDMTrial[]
        parcode_df = df[df.parcode .== subjectId, [:trial, :rt, :choice, :item_left, :item_right]]
        dataSubject = Matrix(parcode_df)
        trialIds = unique(dataSubject[:,1])
        for trialId in trialIds
            trial_df = parcode_df[parcode_df.trial .== trialId, [:rt, :choice, :item_left, :item_right]]
            dataTrial = Matrix(trial_df)
            itemLeft = dataTrial[1,3]
            itemRight = dataTrial[1,4]
            if convertItemValues != nothing
                push!(data[subjectId], aDDMTrial(Number[], dataTrial[1,1], dataTrial[1,2], 
                                                   convertItemValues(itemLeft),
                                                   convertItemValues(itemRight)))
            else
                push!(data[subjectId], aDDMTrial(Number[], dataTrial[1,1], dataTrial[1,2],
                                                   itemLeft, itemRight))
            end
        end
    end
    
    # Load fixation data from CSV file.
    try
        df = DataFrame(CSV.File(fixationsFileName, delim=","))
    catch
        print("Error while reading fixations file " * fixationsFileName)
        return nothing
    end
    
    df = DataFrame(CSV.File(fixationsFileName, delim=","))
    
    if (!("parcode" in names(df)) || !("trial" in names(df)) || !("fix_item" in names(df)) || !("fix_time" in names(df)))
        throw(error("Missing field in fixations file. Fields required: parcode, trial, fix_item, fix_time"))
    end
    
    subjectIds = unique(df.parcode)
    for subjectId in subjectIds
        if !(subjectId in keys(data))
            continue
        end
        parcode_df = df[df.parcode .== subjectId, [:trial, :fix_item, :fix_time]]
        dataSubject = Matrix(parcode_df)
        trialIds = unique(dataSubject[:,1])
        for (t, trialId) in enumerate(trialIds)
            trial_df = parcode_df[parcode_df.trial .== trialId, [:fix_item, :fix_time]]
            dataTrial = Matrix(trial_df)
            data[subjectId][t].fixItem = dataTrial[:,1]
            data[subjectId][t].fixTime = dataTrial[:,2]
        end
    end

    data = Dict(string(subjectId) => trials for (subjectId, trials) in data)

    return data
end


function get_empirical_distributions(data::Dict; timeStep::Number=10, 
                                     maxFixTime::Number=3000, 
                                     numFixDists::Int64=3, fixDistType::String="fixation", 
                                     valueDiffs::Vector{Int64}=collect(-3:1:3), 
                                     subjectIds::Vector{String}=String[], 
                                     useOddTrials::Bool=true,
                                     useEvenTrials::Bool=true, 
                                     useCisTrials::Bool=true,
                                     useTransTrials::Bool=true)
    """
    Creates empirical distributions from the data to be used when generating
    model simulations.
    Args:
      data: a dict, indexed by subjectId, where each entry is a list of
          aDDMTrial objects.
      timeStep: integer, minimum duration of a fixation to be considered, in
          miliseconds.
      maxFixTime: integer, maximum duration of a fixation to be considered, in
          miliseconds.
      numFixDists: integer, number of fixation types to use in the fixation
          distributions. For instance, if numFixDists equals 3, then 3 separate
          fixation types will be used, corresponding to the 1st, 2nd and other
          (3rd and up) fixations in each trial.
      fixDistType: string, one of {'simple', 'difficulty', 'fixation'}, used to
          determine how the fixation distributions should be indexed. If
          'simple', then fixation distributions will be indexed only by type
          (1st, 2nd, etc). If 'difficulty', they will be indexed by type and by
          trial difficulty, i.e., the absolute value for the trial's value
          difference. If 'fixation', they will be indexed by type and by the
          value difference between the fixated and unfixated items.
      valueDiffs: list of integers. If fixDistType is 'difficulty' or
          'fixation', valueDiffs is a range correspoding to the item values to
          be used when indexing the fixation distributions.
      subjectIds: list of strings corresponding to the subjects whose data
          should be used. If not provided, all existing subjects will be used.
      useOddTrials: boolean, whether or not to use odd trials when creating the
          distributions.
      useEvenTrials: boolean, whether or not to use even trials when creating
          the distributions.
      useCisTrials: boolean, whether or not to use cis trials when creating the
          distributions (for perceptual decisions only).
      useTransTrials: boolean, whether or not to use trans trials when creating
          the distributions (for perceptual decisions only).
    Returns:
      A FixationData object.
    """
    fixDistType = String(fixDistType)
    availableTypes = ["simple", "difficulty", "fixation"]
    if (!(fixDistType in availableTypes))
        throw(error("fixDistType must be one of {simple, difficulty, fixation}"))
    end
    
    countLeftFirst = 0
    countTotalTrials = 0
    latenciesList = Number[]
    transitionsList = Number[]
    fixationsList = Dict()
    for fixNumber in 1:numFixDists
        if fixDistType == "simple"
            fixationsList[fixNumber] = Number[]
        else
            fixationsList[fixNumber] = Dict()
            for valueDiff in valueDiffs
                fixationsList[fixNumber][valueDiff] = Number[]
            end
        end
    end
    
    subjectIds = length(subjectIds) > 0 ? [String(subj) for subj in subjectIds] : collect(keys(data))

    for subjectId in subjectIds
        for (trialId, trial) in enumerate(data[subjectId])
            if !useOddTrials && mod(trialId, 2) != 0
                continue
            elseif !useEvenTrials && mod(trialId, 2) == 0
                continue
            end
            isCisTrial = trial.ddmTrial.valueLeft * trial.ddmTrial.valueRight >= 0 ? true : false
            isTransTrial = trial.ddmTrial.valueLeft * trial.ddmTrial.valueRight <= 0 ? true : false
            if (!useCisTrials && isCisTrial && !isTransTrial)
                continue
            elseif (!useTransTrials && isTransTrial && !isCisTrial)
                continue
            end
            
            # Discard trial if it has 1 or less item fixations.
            items = trial.fixItem
            
            if (!any(items!=nothing) || length(vcat(items[findall(x -> x == 1, items)], items[findall(x -> x == 2, items)])) <= 1)
                continue
            end
            
            fixUnfixValueDiffs = Dict(1 => trial.ddmTrial.valueLeft - trial.ddmTrial.valueRight, 
                                      2 => trial.ddmTrial.valueRight - trial.ddmTrial.valueLeft)
            
            # Find the last item fixation in this trial.
            excludeCount = 0
            for i in length(trial.fixItem):-1:1
                excludeCount += 1
                if (trial.fixItem[i] == 1 || trial.fixItem[i] == 2)
                    break
                end
            end
            
            # Iterate over this trial's fixations (skip the last item fixation)
            latency = 0
            firstItemFixReached = false
            fixNumber = 1
            for i in 1:length(trial.fixItem) - excludeCount
                if trial.fixItem[i] != 1 && trial.fixItem[i] != 2
                    if !firstItemFixReached
                        latency += trial.fixTime[i]
                    elseif (trial.fixTime[i] >= timeStep && trial.fixTime[i] <= maxFixTime)
                        push!(transitionsList, trial.fixTime[i])
                    end
                else
                    if !firstItemFixReached
                        firstItemFixReached = true
                        push!(latenciesList, latency)
                    end
                    if fixNumber == 1
                        countTotalTrials += 1
                        if trial.fixItem[i] == 1 # First fixation was left.
                            countLeftFirst += 1
                        end
                    end
                    if (trial.fixTime[i] >= timeStep && trial.fixTime[i] <= maxFixTime)
                        if fixDistType == "simple"
                            push!(fixationsList[fixNumber], trial.fixTime[i])
                        elseif fixDistType == "difficulty"
                            valueDiff = abs(trial.ddmTrial.valueLeft - trial.ddmTrial.valueRight)
                            push!(fixationsList[fixNumber][valueDiff], trial.fixTime[i])
                        elseif fixDistType == "fixation"
                            valueDiff = fixUnfixValueDiffs[trial.fixItem[i]]
                            push!(fixationsList[fixNumber][valueDiff], trial.fixTime[i])
                        end
                    end
                    if fixNumber < numFixDists
                        fixNumber += 1
                    end
                end
            end
        end
    end
    probFixLeftFirst = countLeftFirst / countTotalTrials
    latencies = latenciesList
    transitions = transitionsList
    fixations = Dict()

    for fixNumber in 1:numFixDists
        if fixDistType == "simple"
            fixations[fixNumber] = [fixationsList[fixNumber]]
        else
            fixations[fixNumber] = Dict()
            for valueDiff in valueDiffs
                fixations[fixNumber][valueDiff] = [fixationsList[fixNumber][valueDiff]]
            end
        end
    end

    return FixationData(probFixLeftFirst, latencies, transitions, fixations, fixDistType=fixDistType)
end