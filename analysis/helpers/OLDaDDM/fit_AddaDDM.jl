##################################################################
# FUNCTION: Fitting using custom grid
##################################################################

function fit_AddaDDM_custom_resolution(addm::aDDM, data::Dict{String, Vector{aDDMTrial}}, dGrid::Vector{Any}, σGrid::Vector{Any}, θGrid::Vector{Any}, bGrid::Vector{Any}, kGrid::Vector{Any}, subjectCount::Number; minValue::Number=-6, maxValue::Number=-1)
    """
    """

    #print("Approx how many likelihoods to calculate per subject: ")
    #print(length(dGrid[1])*length(σGrid[1])*length(θGrid[1])*length(bGrid[1]))

    dList = Vector{Float64}(undef, subjectCount)
    σList = Vector{Float64}(undef, subjectCount)
    θList = Vector{Float64}(undef, subjectCount)
    bList = Vector{Float64}(undef, subjectCount)
    kList = Vector{Float64}(undef, subjectCount)
    NLLsList = Vector{Float64}(undef, subjectCount);

    ind = 1
    @showprogress for subject in collect(keys(data))

        dEst, σEst, θEst, bEst, kEst, NLL_Indiv = AddaDDM_grid_search(addm, data, minValue, maxValue, dGrid[ind], σGrid[ind], θGrid[ind], bGrid[ind], kGrid[ind], subject)
    
        dList[ind] = dEst[1]
        σList[ind] = σEst[1]
        θList[ind] = θEst[1]
        bList[ind] = bEst[1]
        kList[ind] = kEst[1]
        NLLsList[ind] = NLL_Indiv
        ind += 1
    
    end

    df = DataFrame(
        subject = collect(keys(data)),
        d = dList,
        s = σList,
        t = θList,
        b = bList,
        k = kList
    )
    df = sort(df, :subject)
    return df, NLLsList
end

##################################################################
# FUNCTION: Fit, iterate until ΔNLL<threshold
##################################################################

function fit_AddaDDM(; study::String = "error", dataset::String = "error")

    ########
    # Prep
    ########

    println("AddaDDM"); println(study); println(dataset);

    addm = aDDM(.005, .07, .3); # These can be anything. They exist because you need an aDDM object. (d, s, t).

    expdataGain = "../../../data/processed_data/" * study * "/" * dataset * "/expdataGain.csv"
    fixationsGain = "../../../data/processed_data/" * study * "/" * dataset * "/fixationsGain.csv"
    expdataLoss = "../../../data/processed_data/" * study * "/" * dataset * "/expdataLoss.csv"
    fixationsLoss = "../../../data/processed_data/" * study * "/" * dataset * "/fixationsLoss.csv"
    dataGain = load_data_from_csv(expdataGain, fixationsGain, convertItemValues=nothing);
    dataLoss = load_data_from_csv(expdataLoss, fixationsLoss, convertItemValues=nothing);

    subjectCount = length(collect(keys(dataGain)))

    pChangeNLLThreshold = 0.001 # How little should NLL change in order for us to stop zooming in with grid search? 0.1%

    dStepSize = .004 # Step sizes for the grids.
    σStepSize = .04
    θStepSize = .5
    bStepSize = .9
    kStepSize = 1.5

    dInitialGrid = Any[]
    σInitialGrid = Any[]
    θInitialGrid = Any[]
    bInitialGrid = Any[]
    kInitialGrid = Any[]
    for subject in collect(keys(dataGain))
        push!(dInitialGrid, float([0.001:dStepSize:.009;]))  
        push!(σInitialGrid, float([0.01:σStepSize:.09;]))      
        push!(θInitialGrid, float([0:θStepSize:1;]))    
        push!(bInitialGrid, float([-.9:bStepSize:.9;]))  
        push!(kInitialGrid, float([0:kStepSize:3;]))      
    end

    println(dInitialGrid[1])
    println(σInitialGrid[1])
    println(θInitialGrid[1])
    println(bInitialGrid[1])
    println(kInitialGrid[1])

    ########
    # Gain Data Fit: loop until small change in NLL
    ########

    println("Gain")

    oldGainEstimates, oldNLLs = fit_AddaDDM_custom_resolution(addm, dataGain, dInitialGrid, σInitialGrid, θInitialGrid, bInitialGrid, kInitialGrid, subjectCount; minValue=1, maxValue=6)
    oldNLL = sum(oldNLLs)
    println("Iteration 1"); print("Old NLL missing"); print("New NLL "); println(oldNLL); print("Percent Change missing"); println(oldGainEstimates);

    iteration = 2
    Δ = 100
    while Δ > grid_search_terminate_threshold
        
        dGrid, σGrid, θGrid, bGrid, kGrid = make_new_grid_plus_models(oldGainEstimates, dataGain, dStepSize, σStepSize, θStepSize, bStepSize, kStepSize, iteration; bounded_theta=true)
        newGainEstimates, newNLLs = fit_AddaDDM_custom_resolution(addm, dataGain, dGrid, σGrid, θGrid, bGrid, kGrid, subjectCount; minValue=1, maxValue=6)
        newNLL = sum(newNLLs)
        Δ = (oldNLL-newNLL)/oldNLL
        if Δ < 0
            global gainEstimates_RNP = oldGainEstimates
            global NLL = oldNLLs
        else
            global gainEstimates_RNP = newGainEstimates
            global NLL = newNLLs
        end

        print("Iteration "); println(iteration); print("Old NLL "); println(oldNLL); print("New NLL "); println(newNLL); print("Percent Change "); println(Δ); println(gainEstimates_RNP); iteration += 1; oldGainEstimates = newGainEstimates; oldNLL = newNLL; 

    end

    gainOutPath = "../../outputs/temp/" * study * "_"
    CSV.write(gainOutPath * "AddaDDM_GainEst_" * dataset * ".csv", gainEstimates_RNP)
    CSV.write(gainOutPath * "AddaDDM_GainNLL_" * dataset * ".csv", Tables.table(NLL), writeheader=false)

    ########
    # Loss Data Fit: loop until small change in NLL
    ########

    println("Loss")

    oldLossEstimates, oldNLLs = fit_AddaDDM_custom_resolution(addm, dataLoss, dInitialGrid, σInitialGrid, θInitialGrid, bInitialGrid, kInitialGrid, subjectCount)
    oldNLL = sum(oldNLLs)
    println("Iteration 1"); print("Old NLL missing"); print("New NLL "); println(oldNLL); print("Percent Change missing"); println(oldLossEstimates);

    iteration = 2
    Δ = 100
    while Δ > grid_search_terminate_threshold
        
        dGrid, σGrid, θGrid, bGrid, kGrid = make_new_grid_plus_models(oldLossEstimates, dataLoss, dStepSize, σStepSize, θStepSize, bStepSize, kStepSize, iteration; bounded_theta=true)
        newLossEstimates, newNLLs = fit_AddaDDM_custom_resolution(addm, dataLoss, dGrid, σGrid, θGrid, bGrid, kGrid, subjectCount)
        newNLL = sum(newNLLs)
        Δ = (oldNLL-newNLL)/oldNLL
        if Δ < 0
            global lossEstimates_RNP = oldLossEstimates
            global NLL = oldNLLs
        else
            global lossEstimates_RNP = newLossEstimates
            global NLL = newNLLs
        end

        print("Iteration "); println(iteration); print("Old NLL "); println(oldNLL); print("New NLL "); println(newNLL); print("Percent Change "); println(Δ); println(lossEstimates_RNP); iteration += 1; oldLossEstimates = newLossEstimates; oldNLL = newNLL; 

    end

    lossOutPath = "../../outputs/temp/" * study * "_"
    CSV.write(lossOutPath * "AddaDDM_LossEst_" * dataset * ".csv", lossEstimates_RNP)
    CSV.write(lossOutPath * "AddaDDM_LossNLL_" * dataset * ".csv", Tables.table(NLL), writeheader=false)
end
