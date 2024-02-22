using ADDM
using CSV
using DataFrames
using StatsPlots

data = ADDM.load_data_from_csv("../../../data/expdata.csv", "../../../data/fixations.csv")