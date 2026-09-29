# Generates the book's example dataset: a SIMULATED anuran survey of 180 ponds
# across three regions. Simulated on purpose — the data-generating process is known,
# so every model fitted in chapters 7 and 8 can be checked against the truth.
#
# Run: julia --project=. scripts/make_data.jl
using DataFrames, CSV, Random, Distributions

Random.seed!(2024)

n_ponds  = 180
regions  = ["Atlantic", "Cerrado", "Amazon"]

# region-level intercept offsets (log scale) -> a random-effect structure to recover
region_offset = Dict("Atlantic" => 0.00, "Cerrado" => -0.35, "Amazon" => 0.42)

region = rand(regions, n_ponds)
area   = round.(exp.(rand(Normal(5.0, 0.9), n_ponds)), digits = 1)   # m^2
canopy = round.(clamp.(rand(Beta(2, 2), n_ponds) .* 100, 0, 100), digits = 1)  # %
temp   = round.(rand(Normal(24.5, 2.6), n_ponds), digits = 1)        # deg C
hydro  = rand(["permanent", "temporary"], n_ponds)

# TRUE model for richness: log(mu) = 0.9 + 0.28*log(area) - 0.011*canopy + region
log_mu = @. 0.9 + 0.28 * log(area) - 0.011 * canopy + 0.03 * (temp - 24.5)
log_mu .+= [region_offset[r] for r in region]
log_mu .+= [h == "permanent" ? 0.22 : 0.0 for h in hydro]
richness = rand.(Poisson.(exp.(log_mu)))

# TRUE model for occurrence of a focal species: logit(p) = -1.2 + 0.02*canopy - ...
logit_p = @. -1.2 + 0.021 * canopy - 0.35 * (hydro == "temporary") + 0.15 * (temp - 24.5)
focal = rand.(Bernoulli.(1 ./ (1 .+ exp.(-logit_p))))

# a continuous response for the linear-model chapter: mean body size (mm)
# NOTE: the noise vector is drawn separately -- `@.` would broadcast a single
# scalar draw across every pond instead of giving each its own residual.
noise = rand(Normal(0, 2.4), n_ponds)
body_size = round.(38.0 .+ 0.9 .* (temp .- 24.5) .- 0.04 .* canopy .+ noise, digits = 2)

ponds = DataFrame(
    pond_id   = ["P" * lpad(i, 3, '0') for i in 1:n_ponds],
    region    = region,
    hydro     = hydro,
    area_m2   = area,
    canopy    = canopy,
    temp_c    = temp,
    richness  = richness,
    focal     = Int.(focal),
    body_size = body_size,
)

# a few missing values, because real datasets have them
for i in rand(1:n_ponds, 7)
    ponds.canopy[i] = NaN
end
ponds = transform(ponds, :canopy => ByRow(x -> isnan(x) ? missing : x) => :canopy)

outpath = joinpath(dirname(@__DIR__), "data", "ponds.csv")
CSV.write(outpath, ponds)
@info "wrote dataset" outpath nrow(ponds) ncol(ponds)
