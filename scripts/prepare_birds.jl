# Builds data/atlantic_bird_traits.csv, the subset of ATLANTIC BIRD TRAITS used in the
# exploratory-analysis chapter, from the original file of the data paper:
#
#   Rodrigues RC, Hasui É, Assis JC, et al. (179 authors). 2019. ATLANTIC BIRD
#   TRAITS: a data set of bird morphological traits from the Atlantic forests of
#   South America. Ecology 100(6): e02647. https://doi.org/10.1002/ecy.2647
#
# "No copyright or proprietary restrictions are associated with the use of this data
# set. Please cite this data paper when the data are used in publications or teaching
# and educational activities." (from the paper's abstract)
#
# The original file, ATLANTIC_BIRD_TRAITS_completed_2018_11_d05.csv, is in the paper's
# supporting information (ecy2647-sup-0001-DataS1.zip). Download it by hand from
# https://doi.org/10.1002/ecy.2647 (the publisher blocks scripted downloads), then run:
#
#   julia --project=. scripts/prepare_birds.jl path/to/ATLANTIC_BIRD_TRAITS_completed_2018_11_d05.csv
#
# All 72 483 rows are kept, with the errors, outliers and "NA" codes of the original:
# finding them is the point of the chapter. Only the columns it uses are kept, with
# their original names. Nothing is cleaned or corrected here.
using CSV, DataFrames, SHA

const EXPECTED_SHA256 = "970f5f964216a49fc7c32202d7cac4a3cff162f25a7361720215295ab7318611"

const COLUMNS = [
    "ID_ABT", "Order", "Family", "Binomial",
    "Body_mass.g.", "Wing_length.mm.", "Tail_length.mm.", "Tarsus_length.mm.",
    "Bill_length.mm.", "Age", "Sex", "Status", "Recapture", "Ring",
    "Latitude_decimal_degrees", "Longitude_decimal_degrees", "Altitude", "Year",
    "Main_researcher", "Outside.range", "Obs.spp",
]

source = only(ARGS)
digest = bytes2hex(open(sha256, source))
digest == EXPECTED_SHA256 ||
    error("$source does not match the 2018-11-05 release (sha256 $digest).")

# Read everything as text, so the original codes (including "NA") are written back
# exactly as they were.
birds = CSV.read(source, DataFrame; types = String, missingstring = nothing)
@assert nrow(birds) == 72_483
birds = birds[:, COLUMNS]

outpath = joinpath(dirname(@__DIR__), "data", "atlantic_bird_traits.csv")
CSV.write(outpath, birds)
@info "wrote subset" outpath nrow(birds) ncol(birds)
