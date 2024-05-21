using RCall

@time begin

    R"""
    source("make_Stage2_parameter_grids.R")
    """

    include("fit_Stage2.jl")

    R"""
    source("make_Stage3_parameter_grids.R")
    """

    include("fit_Stage3.jl")

end