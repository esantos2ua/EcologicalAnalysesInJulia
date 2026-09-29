# Versão em português do verificador de exercícios. Carregue com:
#
#     include("exercises/checar.jl")
#
# e verifique um exercício pelo número: `checar("4.3", simpson)`.
# Pode ser rodado mais de uma vez na mesma sessão.

isdefined(Main, :Checks) || include(joinpath(@__DIR__, "Checks.jl"))
Checks.LANG[] = :pt
checar(args...) = Checks.check(args...)
