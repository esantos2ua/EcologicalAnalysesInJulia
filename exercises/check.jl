# English entry point for the exercise checker. Load it with:
#
#     include("exercises/check.jl")
#
# and check an exercise by its number: `check("4.3", simpson)`.
# Safe to run more than once in the same session.

isdefined(Main, :Checks) || include(joinpath(@__DIR__, "Checks.jl"))
Checks.LANG[] = :en
check(args...) = Checks.check(args...)
