# Builds the book's Julia environment. Run once: julia --project=. scripts/setup.jl
using Pkg
Pkg.activate(dirname(@__DIR__))

pkgs = [
    # data
    "DataFrames", "CSV", "CategoricalArrays", "RDatasets",
    # tidier layer
    "TidierData", "TidierPlots", "TidierFiles", "TidierCats",
    # plotting
    "CairoMakie", "AlgebraOfGraphics",
    # stats / models
    "StatsBase", "Statistics", "Distributions", "StatsModels",
    "GLM", "MixedModels", "HypothesisTests", "Effects",
    # misc
    "Random",
]

Pkg.add(pkgs)
Pkg.precompile()
@info "Environment ready" length(pkgs)
