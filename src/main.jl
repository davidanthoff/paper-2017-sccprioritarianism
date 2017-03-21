using RCall

# Run the model and write output to results folder
include("scc_code/scc_computation.jl")

# Run plotting code and save figures in plots folder

r_plot_code_directory = joinpath(dirname(@__FILE__), "plot_code")
R"""
setwd($r_plot_code_directory)
source("./make_figures.r")
"""
