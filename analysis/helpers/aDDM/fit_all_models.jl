#=
This script will read already-transformed data containing trial-by-trial details and fixations and fit the aDDM to this data. It uses the Tavares Toolbox (Tavares et al. 2017), rewritten for Julia by Lynn in Summer 2023. See Zeynep Enkavi's https://github.com/aDDM-Toolbox/ADDM.jl for the toolbox. 

I've made a changes to the toolbox in order to suit my project. Some of these are small changes, like changing object types, saving outputs to csv files, or changing the grid for grid search. I don't document small changes since they'll probably change over multiple iterations. I do document major changes to the toolbox: 
(1) The toolbox now fits the model to the output of load_data_from_csv instead of simulating data; 
(2) The toolbox no longer throws a domain error when \theta \notin [0,1];
(3) There are multiple versions of the aDDM now, like an additive model of attention (addDDM), a divisive normalization version (DNaDDM), and a range normalized version (RNaDDM).

The model is not heirarchical, so there's no need to fit on the joint dataset.
=#

# Preamble

pwd();
cd("/Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM");
Base.load_path();
include("addm_grid_search.jl");
Base.load_path();
import Pkg;
using DataFrames;
using CSV;

# Common Model Settings
# %change in total NLL that needs to be achieved to terminate the iterative grid searchh = .1%

grid_search_terminate_threshold = .0001 
include("make_new_grid.jl")

# aDDM: original aDDM with unbounded θ

include("fit_aDDM.jl")
#fit_aDDM(study="dots", dataset="e")
#fit_aDDM(study="numeric", dataset="e")
#fit_aDDM(study="food", dataset="e")
#
#fit_aDDM(study="dots", dataset="c")
#fit_aDDM(study="numeric", dataset="c")
#fit_aDDM(study="food", dataset="c")

# addDDM: additive model of attention, as with Michael Frank's work

include("fit_addDDM.jl")
#fit_addDDM(study="dots", dataset="e")
#fit_addDDM(study="numeric", dataset="e")
#fit_addDDM(study="food", dataset="e")
#
#fit_addDDM(study="dots", dataset="c")
#fit_addDDM(study="numeric", dataset="c")
#fit_addDDM(study="food", dataset="c")

# DNaDDM: aDDM, but values are divisive normalizated

include("fit_DNaDDM.jl")
#fit_DNaDDM(study="dots", dataset="e")
#fit_DNaDDM(study="numeric", dataset="e")
#fit_DNaDDM(study="food", dataset="e")
#
#fit_DNaDDM(study="dots", dataset="c")
#fit_DNaDDM(study="numeric", dataset="c")
#fit_DNaDDM(study="food", dataset="c")

# DNPaDDM: aDDM, but values are divisive normalizated to [k, k+1] where k is a fitted constant.
# This is mathematically equivalent to divisive normalized values with both additive and multiplicative attentional effects.

include("fit_DNPaDDM.jl")
#           fit_DNPaDDM(study="dots", dataset="e")
#           fit_DNPaDDM(study="numeric", dataset="e")
#fit_DNaDDM(study="food", dataset="e")
#
#fit_DNaDDM(study="dots", dataset="c")
#fit_DNaDDM(study="numeric", dataset="c")
#fit_DNaDDM(study="food", dataset="c")

# RNaDDM: aDDM, but values are range normalizated

include("fit_RNaDDM.jl")
#fit_RNaDDM(study="dots", dataset="e")
#fit_RNaDDM(study="numeric", dataset="e")
#fit_RNaDDM(study="food", dataset="e")
#
#fit_RNaDDM(study="dots", dataset="c")
#fit_RNaDDM(study="numeric", dataset="c")
#fit_RNaDDM(study="food", dataset="c")

# RNPaDDM: aDDM, but values are range normalizated to [k, k+1] where k is a fitted constant.
# Turns out, this is mathematically equivalent to range normalized values with both an additive AND multiplicative attentional bias.

include("fit_RNPaDDM.jl")
#fit_RNPaDDM(study="dots", dataset="e")
#fit_RNPaDDM(study="numeric", dataset="e")
#fit_RNPaDDM(study="food", dataset="e")
#
#fit_RNPaDDM(study="dots", dataset="c")
#fit_RNPaDDM(study="numeric", dataset="c")
#fit_RNPaDDM(study="food", dataset="c")

include("fit_DRNPaDDM.jl")
#fit_DRNPaDDM(study="dots", dataset="e")
fit_DRNPaDDM(study="numeric", dataset="e")
#fit_DRNPaDDM(study="food", dataset="e")
#
#fit_DRNPaDDM(study="dots", dataset="c")
#fit_DRNPaDDM(study="numeric", dataset="c")
#fit_DRNPaDDM(study="food", dataset="c")