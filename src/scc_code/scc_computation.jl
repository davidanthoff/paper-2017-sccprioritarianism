using Mimi
using DataFrames
using ProgressMeter

module RICE
    include("../mimi-rice-2010/src/marginaldamage.jl")
end

# 1. Run model and load data
# ==========================

# This function returns a matrix of marginal damages per one t of carbon emission in the
# emissionyear parameter year.
function getmarginaldamages_rice_consumption_based(;emissionyear=2005,datafile=joinpath(dirname(@__FILE__), "..", "data", "RICE_2010_base_000.xlsm"))
    m1, m2 = RICE.getmarginal_rice_models(emissionyear=emissionyear, datafile=datafile)

    run(m1)
    run(m2)

    c1 = m1[:neteconomy, :C]
    c2 = m2[:neteconomy, :C]

    # Calculate the marginal damage between run 1 and 2 for each
    # year/region
    marginaldamage = -(c2.-c1) .* 10^12 / 10^9 / 10

    return marginaldamage
end

function getRICEdata()
    # Convert from $2005 to $2015
    # taken from http://www.bls.gov/data/inflation_calculator.htm
    const priceInflator = 1.22

    rice_regions = ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"]

    RICE_datafile = joinpath(dirname(@__FILE__), "..", "mimi-rice-2010", "data", "RICE_2010_base_000.xlsm")
    m = RICE.getrice(datafile=RICE_datafile)
    run(m)

    pop1 = m[:grosseconomy, :L] .* 10.^6
    cpc1 = m[:neteconomy, :CPC] .* 1000.
    marginaldamage = getmarginaldamages_rice_consumption_based(emissionyear=2015, datafile=RICE_datafile)

    # Interpolate missing years due to 10 year timestep
    marginaldamage = repeat(marginaldamage, inner=[10,1])
    pop1 = repeat(pop1, inner=[10,1])
    cpc1 = repeat(cpc1, inner=[10,1])

    # Remove anything before the year 2015
    cpc1 = cpc1[11:end,:]
    pop1 = pop1[11:end,:]
    marginaldamage = marginaldamage[11:end,:]

    # Adjust price level
    cpc1 = cpc1 .* priceInflator
    marginaldamage = marginaldamage .* priceInflator

    return marginaldamage, cpc1, pop1, rice_regions
end

# This function takes the regional outputs from a model and aggregates them up to global numbers,
# thus emulating an equivalent global model
function getGlobalVersion(marginaldamage, cpc, pop)
    g_md = sum(marginaldamage, 2)
    g_pop = sum(pop, 2)
    g_cpc = sum(cpc .* pop, 2) ./ g_pop

    return g_md, g_cpc, g_pop
end

# This function actually runs all the models, and stores the results in a number of dicts.
function getalldata()
    md_rice, cpc_rice, pop_rice, rice_regions = getRICEdata()
    md_riceg, cpc_riceg, pop_riceg = getGlobalVersion(md_rice, cpc_rice, pop_rice)

    cpcs = Dict{String,Matrix{Float64}}()
    mds = Dict{String,Matrix{Float64}}()
    pops = Dict{String,Matrix{Float64}}()
    regions = Dict{String, Vector{String}}()

    mds["RICE"] = md_rice
    mds["RICEg"] = md_riceg

    cpcs["RICE"] = cpc_rice
    cpcs["RICEg"] = cpc_riceg

    pops["RICE"] = pop_rice
    pops["RICEg"] = pop_riceg

    regions["RICE"] = rice_regions

    return mds, cpcs, pops, regions
end

mds, cpcs, pops, regions = getalldata();

# Write raw maringal damage, consumption per capita and population to output files
writecsv(joinpath(dirname(@__FILE__), "..", "..", "results", "output-marginaldamage.csv"), vcat(hcat(["Year"], reshape(regions["RICE"],(1,12))), hcat(2015:2604, mds["RICE"])))
writecsv(joinpath(dirname(@__FILE__), "..", "..", "results", "output-cpc.csv"), vcat(hcat(["Year"], reshape(regions["RICE"],(1,12))), hcat(2015:2604, cpcs["RICE"])))
writecsv(joinpath(dirname(@__FILE__), "..", "..", "results", "output-population.csv"), vcat(hcat(["Year"], reshape(regions["RICE"],(1,12))), hcat(2015:2604, pops["RICE"])))

# 2. Compute SCC
# ==============

# u, derivative of u and derivative of g function
u(x, η) = η==1. ? log(x) : x^(1-η) / (1-η)
du(x, η) = x^-η
dg(x, γ) = x^-γ

# Marginal welfare function
dSWF(cpc, ρ, γ, η, c₀, t) = dg( u(cpc, η)-u(c₀, η), γ ) * du(cpc, η) * (1.+ρ)^(-t+1)

# Compute the SCC in welfare units. This is the first step for all normalizations
function SCCinWels(cpc, pop, md, ρ, γ, η, c₀)
    # Weight each marginal damage with the corresponding marginal welfare, then sum
    scc = 0.
    for t=1:size(cpc,1), r=1:size(cpc,2)
        scc += md[t,r] * dSWF(cpc[t,r], ρ, γ, η, c₀, t)
    end

    # Convert from $/tC to $/tCO2
    scco2 = scc/(44/12)

    return scco2
end

# Compute the SCC for various normalizations
function SCCinUSD(cpc, pop, md, ρ, γ, η, c₀)
    # First obtain an estimate in wels units
    scc_in_wels = SCCinWels(cpc, pop, md, ρ, γ, η, c₀)

    # Compute world average consumption in period 1
    cons = 0.
    for r=1:size(cpc,2)
        cons += cpc[1,r] * pop[1,r]
    end
    gcpc1 = cons / sum(pop[1,:])

    # First normalize with average per capita consumption at time 1
    scc_in_USD_average = scc_in_wels / dSWF(gcpc1, ρ, γ, η, c₀, 1)
    # Normalize with per capita consumptions of all regions at time 1
    scc_in_USD = [scc_in_wels / dSWF(cpc[1,r], ρ, γ, η, c₀, 1) for r = 1:size(cpc,2)]

    # Normalize with the fair sharing rule
    scc_fair_sharing_rule = scc_in_wels / sum([dSWF(cpc[1,r], ρ, γ, η, c₀, 1) * cpc[1,r] * pop[1,r] / cons for r = 1:size(cpc,2)])

    return scc_in_USD_average, scc_in_USD, scc_fair_sharing_rule, scc_in_wels
end

# This sets up the grid for which we are going to evaluate the SCC
models = ["RICE", "RICEg"]
aggregations = [:Global, :Regional]
ρs = collect(0.:0.005:0.03)
γs = collect(0.:0.25:3.)
ηs = collect(0.:0.25:3.)
# Compute minimum per capita consumption as upper bound for c0 range
min_cpc = minimum([minimum(cpcs[i]) for i in keys(cpcs)])
c₀s = vcat([1.], collect(100.:100.:min_cpc-1.))
if c₀s[end] != min_cpc
    c₀s = vcat(c₀s, [min_cpc-1.])
end;

# Run all parameter combinations, store the results in a DataFrame and write it to disk for the plotting routine
# All numbers are in $/tCO2 in USD2015.

df = DataFrame([String, String, String, Float64, Float64, Float64, Float64, Float64], [:model, :aggregation, :focusregion, :rho, :gamma, :eta, :c0, :SCC], 0)

p = Progress(length(models) * length(ρs) * length(γs) * length(ηs) * length(c₀s), 1)

for model in models, ρ in ρs, γ in γs, η in ηs, c₀ in c₀s
    v_avg, v_foc, scc_fair_sharing, scc_wels = SCCinUSD(cpcs[model], pops[model], mds[model], ρ, γ, η, c₀)
    if model[end] == 'g'
        push!(df, [model[1:end-1], "Global", "Global", ρ, γ, η, c₀, v_avg])
    else
        push!(df, [model, "Regional", "Global-Average", ρ, γ, η, c₀, v_avg])
        push!(df, [model, "Regional", "World-Fair", ρ, γ, η, c₀, scc_fair_sharing])
        push!(df, [model, "Regional", "Utils", ρ, γ, η, c₀, scc_wels])
        for (r,v) in enumerate(v_foc)
            push!(df, [model, "Regional", regions[model][r], ρ, γ, η, c₀, v])
        end
    end
    next!(p)
end
writetable(joinpath(dirname(@__FILE__), "..", "..", "results", "output-scc.csv"), df)

# 3. Other results
# ================

# 3.1. Poorest region
# -------------------

for region in keys(cpcs)
    if !endswith(region, "g")
        poorest_region_index = indmin(cpcs[region][1,:])
        println(region, ": ", regions[region][poorest_region_index])
    end
end
println("Highest C₀: $(c₀s[end])")
