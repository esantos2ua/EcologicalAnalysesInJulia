# Exercise checker for "Ecological Analyses in Julia".
#
# Students do not include this file directly. They load it once per session from
# the book folder through one of the two language entry points:
#
#     include("exercises/check.jl")      # English feedback, `check`
#     include("exercises/checar.jl")     # Portuguese feedback, `checar`
#
# and then check an exercise by its number, passing their answer (a value or a
# function):
#
#     check("4.3", simpson)
#
# Each exercise is a function that receives the answer and returns `nothing` when
# it passes, or a `(en, pt)` pair of messages describing the first problem found.
# Messages should say what the answer did and what was expected, in plain
# language — never just "wrong".
#
# The book's solution chunks call `Checks.verify`, which throws on failure, so a
# solution and its checker can never silently disagree: the build breaks instead.

module Checks

using Statistics
import TOML

const LANG = Ref(:en)

msg(en, pt) = LANG[] === :pt ? pt : en
show_value(x) = sprint(show, x; context = :compact => true)

# Runs `f(args...)`, turning an exception into a readable problem report.
function attempt(f, args...)
    try
        return (ok = true, value = f(args...))
    catch e
        call = "f(" * join(show_value.(args), ", ") * ")"
        if e isa MethodError && e.f === f
            return (ok = false, value = (
                "Your function has no method for this input: $call. " *
                "Check the argument types in its definition.",
                "Sua função não tem método para esta entrada: $call. " *
                "Confira os tipos dos argumentos na definição."))
        end
        name = nameof(typeof(e))
        return (ok = false, value = (
            "Your function threw a $name on $call.",
            "Sua função lançou um $name em $call."))
    end
end

close_to(a::Number, b::Number) = isapprox(a, b; atol = 1e-8)
close_to(a::AbstractArray, b::AbstractArray) =
    size(a) == size(b) && all(close_to.(a, b))
close_to(a::Tuple, b::Tuple) = length(a) == length(b) && all(close_to.(a, b))
close_to(a, b) = isequal(a, b)

const EXERCISES = Dict{String, Function}()

# --- helpers shared by the chapter files ------------------------------------

# Column `col` of a table (DataFrame or anything with named properties), or
# `nothing` when there is no such column.
column(x, col::Symbol) = col in propertynames(x) ? getproperty(x, col) : nothing
is_table(x) = !(x isa AbstractArray || x isa Number || x isa AbstractString) &&
              !isempty(propertynames(x))
col_names(x) = join(string.(propertynames(x)), ", ")

# A number close to `want`. `traps` pairs values that a common mistake produces
# with the message explaining that mistake.
function expect_number(x, want; rtol = 1e-6, traps = ())
    x isa Number || return (
        "Expected a single number, got $(show_value(x)).",
        "Esperava um único número, recebi $(show_value(x)).")
    isapprox(x, want; rtol) && return nothing
    for (value, message) in traps
        isapprox(x, value; rtol) && return message
    end
    return ("Expected $(round(want; sigdigits = 4)), got $(round(x; sigdigits = 4)).",
            "Esperava $(round(want; sigdigits = 4)), recebi $(round(x; sigdigits = 4)).")
end

# A numeric vector close to `want`, element by element.
function expect_vector(x, want; rtol = 1e-6, traps = ())
    x isa AbstractVector{<:Number} || return (
        "Expected a vector of numbers, got $(show_value(x)).",
        "Esperava um vetor de números, recebi $(show_value(x)).")
    length(x) == length(want) && all(isapprox.(x, want; rtol)) && return nothing
    for (value, message) in traps
        length(x) == length(value) && all(isapprox.(x, value; rtol)) && return message
    end
    length(x) == length(want) || return (
        "Expected $(length(want)) values, got $(length(x)).",
        "Esperava $(length(want)) valores, recebi $(length(x)).")
    return ("Expected $(show_value(round.(want; sigdigits = 4))), " *
            "got $(show_value(round.(x; sigdigits = 4))).",
            "Esperava $(show_value(round.(want; sigdigits = 4))), " *
            "recebi $(show_value(round.(x; sigdigits = 4))).")
end

# A table with the given columns. `want` is a vector of `column => values`
# pairs; rows are compared in order, after sorting by `sortby` when given.
function expect_table(x, want; sortby = nothing, rtol = 1e-6)
    is_table(x) || return (
        "Expected a table (a DataFrame), got $(show_value(x)).",
        "Esperava uma tabela (um DataFrame), recebi $(show_value(x)).")
    for (col, _) in want
        column(x, col) === nothing && return (
            "Your table has the columns $(col_names(x)); it needs one named `$col`.",
            "Sua tabela tem as colunas $(col_names(x)); ela precisa de uma chamada `$col`.")
    end
    n = length(last(first(want)))
    got = Dict(col => collect(column(x, col)) for (col, _) in want)
    length(got[first(first(want))]) == n || return (
        "Expected $n rows, got $(length(got[first(first(want))])).",
        "Esperava $n linhas, recebi $(length(got[first(first(want))])).")
    if sortby !== nothing
        order = sortperm(string.(got[sortby]))
        got = Dict(col => v[order] for (col, v) in got)
    end
    for (col, values) in want
        g = got[col]
        same = values isa AbstractVector{<:Number} ?
            all(isapprox.(g, values; rtol)) : all(string.(g) .== string.(values))
        same || return (
            "Column `$col` is $(show_value(g)); expected $(show_value(values)).",
            "A coluna `$col` é $(show_value(g)); esperava $(show_value(values)).")
    end
    return nothing
end

include("ch04.jl")
include("ch05.jl")
include("ch06.jl")
include("ch07.jl")
include("ch08.jl")

function problem(id::AbstractString, answer)
    haskey(EXERCISES, id) || throw(ArgumentError(msg(
        "No exercise \"$id\". Available: $(join(sort(collect(keys(EXERCISES))), ", ")).",
        "Não existe o exercício \"$id\". Disponíveis: $(join(sort(collect(keys(EXERCISES))), ", ")).")))
    return EXERCISES[id](answer)
end

"""
    check(id, answer)

Check your answer to exercise `id` (e.g. `"4.3"`) and print feedback.
`answer` is a value or, for exercises that ask you to write one, a function.
"""
function check(id::AbstractString, answer)
    p = problem(id, answer)
    if p === nothing
        printstyled("✓ ", msg("Correct!", "Correto!"); color = :green, bold = true)
        println()
    else
        printstyled("✗ ", msg("Not yet. ", "Ainda não. "); color = :red, bold = true)
        println(msg(p...))
    end
    return nothing
end

"""
    check("setup")

Check that the computer is ready for the book (chapter 3): Julia version,
working folder, active environment, data and installed packages.
"""
function check(id::AbstractString)
    id == "setup" || throw(ArgumentError(msg(
        "Exercise \"$id\" needs an answer: `check(\"$id\", your_answer)`.",
        "O exercício \"$id\" precisa de uma resposta: `checar(\"$id\", sua_resposta)`.")))
    book = dirname(@__DIR__)
    project = joinpath(book, "Project.toml")
    deps = collect(keys(get(TOML.parsefile(project), "deps", Dict())))
    missing_pkgs = filter(p -> Base.find_package(p) === nothing, sort(deps))
    items = [
        (VERSION >= v"1.10",
         ("Julia $VERSION", "Julia $VERSION"),
         ("Julia $VERSION is too old; the book needs 1.10 or newer. Run `juliaup update`.",
          "Julia $VERSION é antigo demais; o livro precisa da 1.10 ou mais nova. " *
          "Rode `juliaup update`.")),
        (samefile(pwd(), book),
         ("Working folder is the book folder", "A pasta de trabalho é a pasta do livro"),
         ("Working folder is $(pwd()), not the book folder. Use File → Open Folder… " *
          "and restart the REPL.",
          "A pasta de trabalho é $(pwd()), não a pasta do livro. Use File → Open " *
          "Folder… e reinicie o REPL.")),
        (Base.active_project() !== nothing && samefile(Base.active_project(), project),
         ("Book environment is active", "O ambiente do livro está ativo"),
         ("The active environment is $(Base.active_project()), not the book's. Click " *
          "`Julia env` in the status bar and choose the book folder.",
          "O ambiente ativo é $(Base.active_project()), não o do livro. Clique em " *
          "`Julia env` na barra de status e escolha a pasta do livro.")),
        (isfile(joinpath(book, "data", "ponds.csv")),
         ("Data file found: data/ponds.csv", "Arquivo de dados encontrado: data/ponds.csv"),
         ("data/ponds.csv is missing. Download the book folder again.",
          "data/ponds.csv não foi encontrado. Baixe a pasta do livro de novo.")),
        (isempty(missing_pkgs),
         ("All $(length(deps)) packages installed", "Todos os $(length(deps)) pacotes instalados"),
         ("Not installed yet: $(join(missing_pkgs, ", ")). Run `using Pkg; Pkg.instantiate()`.",
          "Ainda não instalados: $(join(missing_pkgs, ", ")). Rode " *
          "`using Pkg; Pkg.instantiate()`.")),
    ]
    for (ok, good, bad) in items
        if ok
            printstyled("✓ "; color = :green, bold = true)
            println(msg(good...))
        else
            printstyled("✗ "; color = :red, bold = true)
            println(msg(bad...))
        end
    end
    if all(first, items)
        printstyled(msg("Ready. Continue with the first script.",
                        "Tudo pronto. Siga para o primeiro script."); color = :green, bold = true)
        println()
    end
    return nothing
end

"Used by the book build: throws if `answer` does not pass exercise `id`."
function verify(id::AbstractString, answer)
    p = problem(id, answer)
    p === nothing || error("Solution to exercise $id fails its check: $(p[1])")
    return nothing
end

end # module
