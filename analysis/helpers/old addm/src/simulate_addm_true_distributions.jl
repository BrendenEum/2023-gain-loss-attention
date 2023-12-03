"""
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

Module: simulate_addm_true_distributions.jl
Author: Lynn Yang, lynnyang@caltech.edu

Generates aDDM simulations with an approximation of the "true" fixation
distributions. When creating fixation distributions, we leave out the last
fixation from each trial, since these are interrupted when a decision is made
and therefore their duration should not be sampled. Since long fixations are
more likely to be interrupted, they end up not being included in the
distributions. This means that the distributions we use to sample fixations are
biased towards shorter fixations than the "true" distributions. Here we use the
uninterrupted duration of last fixations to approximate the "true"
distributions of fixations. We do this by dividing each bin in the empirical
fixation distributions by the probability of a fixation in that bin being the
last fixation in the trial. The "true" distributions estimated are then used to
generate aDDM simulations.

Based on Python addm_toolbox from Gabriela Tavares, gtavares@caltech.edu.
"""

include("addm.jl")
include("util.jl")


function main(d::Number, σ::Number, θ::Number; trialsFileName=nothing, expdataFileName=nothing,
              fixationsFileName=nothing, binStep::Number=10, maxFixBin::Number=3000,
              numFixDists::Int64=3, numIterations::Int64=3, simulationsPerCondition::Int64=800,
              subjectIds::Vector{Any}=[], saveSimulations=false, verbose=false)
    """
    Args:
    d: float, aDDM parameter for generating artificial data.
    sigma: float, aDDM parameter for generating artificial data.
    theta: float, aDDM parameter for generating artificial data.
    trialsFileName: string, path of trial conditions file.
    expdataFileName: string, path of experimental data file.
    fixationsFileName: string, path of fixations file.
    binStep: int, size of the bin step to be used in the fixation
        distributions.
    maxFixBin: int, maximum fixation length to be used in the fixation
        distributions.
    numFixDists: int, number of fixation distributions.
    numIterations: int, number of iterations used to approximate the true
        distributions.
    simulationsPerCondition: int, number of simulations to be generated per
        trial condition.
    subjectIds: list of strings corresponding to the subject ids. If not
        provided, all existing subjects will be used.
    saveFigures: boolean, whether or not save figures comparing choice and RT
        curves for data and simulations.
    verbose: boolean, whether or not to increase output verbosity.
    """
    # Load trial conditions.
    if trialsFileName === nothing
        # TODO: I'm confused about this part of the code and what it decisions
    end
    trialConditions = load_trial_conditions_from_csv(trialsFileName)

    # Load experimental data from CSV file.
    if verbose
        print("Loading experimental data...")
    end
    if expdataFileName === nothing
        # TODO: Again, I'm confused
    end
    if fixationsFileName === nothing
        # TODO
    end
    data = load_data_from_csv(expdataFileName, fixationsFileName, convertItemValues=convert_item_values)

    # Time bins to be used in the fixation distributions.
    bins = 

end