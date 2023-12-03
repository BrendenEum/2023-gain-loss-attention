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

Module: plot.jl
Author: Lynn Yang, lynnyang@caltech.edu

Visualization functions for the aDDM Toolbox.
"""
using Pkg
Pkg.activate("addm")

using Plots
using Printf

include("ddm.jl")
include("addm.jl")


function plot_value_diff_distributions(n::Int64, d::Float64, σ::Float64, leftRates::Array{Float64, 1},
                                       rightRates::Array{Float64, 1}, filePath::String)
    iter = 0
    for l in leftRates
        for r in rightRates
            iter += 1
            trialChoices = []
            trialRTs = []
            for i in 1:n
                ddm = DDM(d, σ)
                trial = simulate_trial(ddm, l, r)
                append!(trialChoices, trial.choice)
                append!(trialRTs, trial.RT)
            end
            
            leftChosen = mean((ones(n)-trialChoices)./2)
            println(leftChosen)
            
            h = stephist(trialRTs, fill=true, fillalpha=0.5, color=:lightblue)
            title!(@sprintf("Distribution of RTs for V_l=%i and V_r=%i", l, r))
            xlabel!("Response Time (ms)")
            ylabel!("Frequency")
            display(h)
            name = @sprintf("ddm_distr_L%i_R%i_fig%i.png", l, r, iter)
            fileName = joinpath(filePath, name)
            savefig(h, fileName)
        end
    end
end


function plot_value_diff_rdv_timeseries(d::Float64, σ::Float64, leftRates::Array{Float64, 1}, 
                             rightRates::Array{Float64, 1}, filePath::String)
    iter = 0
    for l in leftRates
        for r in rightRates
            iter += 1
            ddm = DDM(d, σ)
            trial = simulate_trial(ddm, l, r)
            tRDV = trial.RDV
            timeseries = 0:10:trial.RT
            p = plot(timeseries, tRDV, label="RDV")
            plot!(timeseries, ones(length(timeseries)), label="right", color=:black)
            plot!(timeseries, -ones(length(timeseries)), label="left", color=:black)
            plot!(legend=:topleft)
            title!(@sprintf("Timeseries of RDV for V_l=%i and V_r=%i", l, r))
            xlabel!("Time (ms)")
            ylabel!("RDV")
            display(p)
            name = @sprintf("RDV_timeseries_L%i_R%i_fig%i.png", l, r, iter)
            filepath = joinpath("images", name)
            savefig(p, filepath)
        end
    end
end


function plot_σ_diff_timeseries(d::Float64, σList::Array{Float64, 1}, leftRate::Float64,
                                rightRate::Float64, filePath::String)
    iter = 0
    for σ in σList
        iter += 1
        ddm = DDM(d, σ)
        trial = simulate_trial(ddm, leftRate, rightRate)
        tRDV = trial.RDV
        timeseries = 0:10:trial.RT
        p = plot(timeseries, tRDV, label="RDV")
        plot!(timeseries, ones(length(timeseries)), label="right", color=:black)
        plot!(timeseries, -ones(length(timeseries)), label="left", color=:black)
        plot!(legend=:topleft)
        title!(@sprintf("Timeseries of RDV for σ=%.3f", σ))
        xlabel!("Time (ms)")
        ylabel!("RDV")
        display(p)
        name = @sprintf("RDV_timeseries_L%i_R%i_σ%.3f_fig%i.png", leftRate, rightRate, σ, iter)
        filepath = joinpath("images", name)
        savefig(p, filepath)
    end
end

n = 10000
leftRates = [0.0, 2.0, 4.0]
rightRates = [0.0, 1.0, 3.0]
leftRate = 0.0
rightRate = 0.0
σList = [0.001, 0.01, 0.025, 0.1]

plot_value_diff_distributions(n, 0.0002, 0.01, leftRates, rightRates, "images")
plot_value_diff_rdv_timeseries(0.0002, 0.01, leftRates, rightRates, "images")
plot_σ_diff_timeseries(0.0002, σList, leftRate, rightRate, "images")