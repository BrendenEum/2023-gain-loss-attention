function make_new_grid(estimates::DataFrame, data::Dict{String, Vector{aDDMTrial}}, dStepSize::Number, σStepSize::Number, θStepSize::Number, bStepSize::Number, iteration::Number; bounded_theta::Bool)
    
    dGrid = Any[]
    σGrid = Any[]
    θGrid = Any[]
    bGrid = Any[]

    iteration = iteration-1 # Iteration in the while loops below start at 2 since we run the fitting once before the loop. Correct for this.
    ind = 1
    for subject in collect(keys(data))

        d = estimates[(estimates.subject .== subject), "d"][1]
        σ = estimates[(estimates.subject .== subject), "s"][1]
        θ = estimates[(estimates.subject .== subject), "t"][1]
        b = estimates[(estimates.subject .== subject), "b"][1]

        dLow = max(0.00001, d-(dStepSize/(2^iteration)));
        dHigh = d+(dStepSize/(2^iteration));
        σLow = max(0.001, σ-(σStepSize/(2^iteration)));
        σHigh = σ+(σStepSize/(2^iteration));
        if !bounded_theta
            θLow = θ-(θStepSize/(2^iteration));
            θHigh = θ+(θStepSize/(2^iteration));
        else
            θLow = max(0, θ-(θStepSize/(2^iteration)));
            θHigh = min(1, θ+(θStepSize/(2^iteration)));
        end
        bLow = max(-.99, b-(bStepSize/(2^iteration)));
        bHigh = min(.99, b+(bStepSize/(2^iteration)));

        push!(dGrid, float([dLow, d, dHigh]))
        push!(σGrid, float([σLow, σ, σHigh]))    
        push!(θGrid, float([θLow, θ, θHigh]))           
        push!(bGrid, float([bLow, b, bHigh]))  

        ind += 1
    end
    return dGrid, σGrid, θGrid, bGrid
end

function make_new_grid_plus_models(estimates::DataFrame, data::Dict{String, Vector{aDDMTrial}}, dStepSize::Number, σStepSize::Number, θStepSize::Number, bStepSize::Number, kStepSize::Number, iteration::Number; bounded_theta::Bool)
    
    dGrid = Any[]
    σGrid = Any[]
    θGrid = Any[]
    bGrid = Any[]
    kGrid = Any[]

    iteration = iteration-1 # Iteration in the while loops below start at 2 since we run the fitting once before the loop. Correct for this.
    ind = 1
    for subject in collect(keys(data))

        d = estimates[(estimates.subject .== subject), "d"][1]
        σ = estimates[(estimates.subject .== subject), "s"][1]
        θ = estimates[(estimates.subject .== subject), "t"][1]
        b = estimates[(estimates.subject .== subject), "b"][1]
        k = estimates[(estimates.subject .== subject), "k"][1]

        dLow = max(0.00001, d-(dStepSize/(2^iteration)));
        dHigh = d+(dStepSize/(2^iteration));
        σLow = max(0.001, σ-(σStepSize/(2^iteration)));
        σHigh = σ+(σStepSize/(2^iteration));
        if !bounded_theta
            θLow = θ-(θStepSize/(2^iteration));
            θHigh = θ+(θStepSize/(2^iteration));
        else
            θLow = max(0, θ-(θStepSize/(2^iteration)));
            θHigh = min(1, θ+(θStepSize/(2^iteration)));
        end
        bLow = max(-.99, b-(bStepSize/(2^iteration)));
        bHigh = min(.99, b+(bStepSize/(2^iteration)));
        kLow = max(0, k-(kStepSize/(2^iteration)));
        kHigh = k+(kStepSize/(2^iteration));

        push!(dGrid, float([dLow, d, dHigh]))
        push!(σGrid, float([σLow, σ, σHigh]))    
        push!(θGrid, float([θLow, θ, θHigh]))           
        push!(bGrid, float([bLow, b, bHigh]))  
        push!(kGrid, float([kLow, k, kHigh]))  

        ind += 1
    end
    return dGrid, σGrid, θGrid, bGrid, kGrid
end

function make_new_grid_collapse_models(estimates::DataFrame, data::Dict{String, Vector{aDDMTrial}}, dStepSize::Number, σStepSize::Number, θStepSize::Number, bStepSize::Number, cStepSize::Number, iteration::Number; bounded_theta::Bool)
    
    dGrid = Any[]
    σGrid = Any[]
    θGrid = Any[]
    bGrid = Any[]
    cGrid = Any[]

    iteration = iteration-1 # Iteration in the while loops below start at 2 since we run the fitting once before the loop. Correct for this.
    ind = 1
    for subject in collect(keys(data))

        d = estimates[(estimates.subject .== subject), "d"][1]
        σ = estimates[(estimates.subject .== subject), "s"][1]
        θ = estimates[(estimates.subject .== subject), "t"][1]
        b = estimates[(estimates.subject .== subject), "b"][1]
        c = estimates[(estimates.subject .== subject), "c"][1]

        dLow = max(0.00001, d-(dStepSize/(2^iteration)));
        dHigh = d+(dStepSize/(2^iteration));
        σLow = max(0.001, σ-(σStepSize/(2^iteration)));
        σHigh = σ+(σStepSize/(2^iteration));
        if !bounded_theta
            θLow = θ-(θStepSize/(2^iteration));
            θHigh = θ+(θStepSize/(2^iteration));
        else
            θLow = max(0, θ-(θStepSize/(2^iteration)));
            θHigh = min(1, θ+(θStepSize/(2^iteration)));
        end
        bLow = max(-.99, b-(bStepSize/(2^iteration)));
        bHigh = min(.99, b+(bStepSize/(2^iteration)));
        cLow = max(0, c-(cStepSize/(2^iteration)));
        cHigh = c+(cStepSize/(2^iteration));

        push!(dGrid, float([dLow, d, dHigh]))
        push!(σGrid, float([σLow, σ, σHigh]))    
        push!(θGrid, float([θLow, θ, θHigh]))           
        push!(bGrid, float([bLow, b, bHigh]))  
        push!(cGrid, float([cLow, c, cHigh]))  

        ind += 1
    end
    return dGrid, σGrid, θGrid, bGrid, cGrid
end