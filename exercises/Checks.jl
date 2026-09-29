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

# Reference implementations used by the checks — not shown to students.
simpson_ref(a) = 1 - sum((a ./ sum(a)) .^ 2)
function shannon_ref(a)
    p = filter(>(0), a ./ sum(a))
    return -sum(p .* log.(p))
end

const AREAS = [174.1, 161.6, 233.9, 174.5, 1980.0]

const EXERCISES = Dict{String, Function}(

    # 4.1 — indexing with `end`
    "4.1" => function (x)
        expected = AREAS[1:end-1]
        x isa AbstractVector || return (
            "Expected a vector, got $(show_value(x)).",
            "Esperava um vetor, recebi $(show_value(x)).")
        length(x) == 5 && return (
            "`clean` still has all 5 values. Drop the last one.",
            "`limpo` ainda tem os 5 valores. Tire o último.")
        close_to(x, AREAS[2:end]) && return (
            "You dropped the first pond instead of the last.",
            "Você tirou a primeira lagoa em vez da última.")
        close_to(x, expected) || return (
            "Expected $(show_value(expected)), got $(show_value(x)).",
            "Esperava $(show_value(expected)), recebi $(show_value(x)).")
        nothing
    end,

    # 4.2 — broadcasting
    "4.2" => function (x)
        x isa AbstractVector || return (
            "Expected a vector with one value per pond, got $(show_value(x)).",
            "Esperava um vetor com um valor por lagoa, recebi $(show_value(x)).")
        length(x) == length(AREAS) || return (
            "Expected $(length(AREAS)) values (one per pond), got $(length(x)).",
            "Esperava $(length(AREAS)) valores (um por lagoa), recebi $(length(x)).")
        close_to(x, log.(AREAS)) && return (
            "Those are natural logs (`log`). The exercise asks for base 10: `log10`.",
            "Esses são logaritmos naturais (`log`). O exercício pede base 10: `log10`.")
        close_to(x, log10.(AREAS)) || return (
            "Expected $(show_value(log10.(AREAS))), got $(show_value(x)).",
            "Esperava $(show_value(log10.(AREAS))), recebi $(show_value(x)).")
        nothing
    end,

    # 4.3 — writing a function
    "4.3" => function (f)
        f isa Function || return (
            "Pass the function itself: `check(\"4.3\", simpson)`, without parentheses.",
            "Passe a própria função: `checar(\"4.3\", simpson)`, sem parênteses.")
        for a in ([3, 1], [1, 1, 1, 1], [10], [45, 12, 0, 8, 23, 0, 3])
            r = attempt(f, a)
            r.ok || return r.value
            got, want = r.value, simpson_ref(a)
            close_to(got, want) && continue
            close_to(got, 1 - want) && return (
                "simpson($(show_value(a))) returned $(show_value(got)), which is Σpᵢ². " *
                "The index is 1 − Σpᵢ².",
                "simpson($(show_value(a))) retornou $(show_value(got)), que é Σpᵢ². " *
                "O índice é 1 − Σpᵢ².")
            close_to(got, 1 - sum(a .^ 2)) && return (
                "simpson($(show_value(a))) returned $(show_value(got)). You squared the " *
                "counts; divide by the total first to get proportions pᵢ.",
                "simpson($(show_value(a))) retornou $(show_value(got)). Você elevou as " *
                "contagens ao quadrado; divida pelo total antes para obter as proporções pᵢ.")
            return (
                "simpson($(show_value(a))) returned $(show_value(got)); expected $(show_value(want)).",
                "simpson($(show_value(a))) retornou $(show_value(got)); esperava $(show_value(want)).")
        end
        nothing
    end,

    # 4.4 — adding a method (multiple dispatch)
    "4.4" => function (f)
        f isa Function || return (
            "Pass the function itself, without parentheses.",
            "Passe a própria função, sem parênteses.")
        M = [1 1; 3 1; 10 0]
        want = [simpson_ref(row) for row in eachrow(M)]
        hasmethod(f, Tuple{typeof(M)}) || return (
            "`simpson` has no method for a Matrix yet. Define one with " *
            "`simpson(M::Matrix) = ...`.",
            "`simpson` ainda não tem método para Matrix. Defina um com " *
            "`simpson(M::Matrix) = ...`.")
        r = attempt(f, M)
        if !r.ok
            return (
                r.value[1] * " If your vector method is `simpson(a::Vector)`, note that " *
                "`eachrow` gives views, not Vectors: loosen it to `AbstractVector`.",
                r.value[2] * " Se o seu método para vetores é `simpson(a::Vector)`, note " *
                "que `eachrow` gera views, não Vectors: afrouxe para `AbstractVector`.")
        end
        got = r.value
        got isa Number && return (
            "simpson(M) returned a single number. Compute one index per row (site).",
            "simpson(M) retornou um único número. Calcule um índice por linha (local).")
        close_to(got, [simpson_ref(col) for col in eachcol(M)]) && return (
            "You computed one index per column. Rows are sites here: use `eachrow`.",
            "Você calculou um índice por coluna. Aqui as linhas são os locais: use `eachrow`.")
        close_to(got, want) || return (
            "simpson($(show_value(M))) returned $(show_value(got)); expected $(show_value(want)).",
            "simpson($(show_value(M))) retornou $(show_value(got)); esperava $(show_value(want)).")
        r = attempt(f, [3, 1])
        (r.ok && close_to(r.value, 0.375)) || return (
            "The Matrix method works, but simpson([3, 1]) no longer gives 0.375. " *
            "Did you overwrite the vector method?",
            "O método para Matrix funciona, mas simpson([3, 1]) não dá mais 0.375. " *
            "Você sobrescreveu o método para vetores?")
        nothing
    end,

    # 4.5 — missing values
    "4.5" => function (f)
        f isa Function || return (
            "Pass the function itself, without parentheses.",
            "Passe a própria função, sem parênteses.")
        cases = ([70.0, 42.6, missing, 49.4, missing, 81.2], [12.0, 14.0], [missing, 5.0])
        for x in cases
            r = attempt(f, x)
            r.ok || return r.value
            got = r.value
            want = (count(ismissing, x), mean(skipmissing(x)))
            got isa Tuple && length(got) == 2 || return (
                "Return a tuple `(n_missing, mean)`, e.g. `return (n, m)`. " *
                "Got $(show_value(got)).",
                "Retorne uma tupla `(n_faltantes, média)`, por exemplo `return (n, m)`. " *
                "Recebi $(show_value(got)).")
            ismissing(got[2]) && return (
                "The mean came back `missing`. Skip the missing values before averaging.",
                "A média veio `missing`. Pule os valores faltantes antes de tirar a média.")
            close_to(got, want) || return (
                "f($(show_value(x))) returned $(show_value(got)); expected $(show_value(want)).",
                "f($(show_value(x))) retornou $(show_value(got)); esperava $(show_value(want)).")
        end
        nothing
    end,

    # 4.6 — loops
    "4.6" => function (f)
        f isa Function || return (
            "Pass the function itself, without parentheses.",
            "Passe a própria função, sem parênteses.")
        for a in ([45, 12, 8, 23, 3], [45, 12, 0, 8, 23, 0, 3], [5, 5], [7])
            r = attempt(f, a)
            r.ok || return r.value
            got, want = r.value, shannon_ref(a)
            close_to(got, want) && continue
            got isa Number && isnan(got) && return (
                "f($(show_value(a))) returned NaN. A zero count gives 0 * log(0); " *
                "skip zeros inside the loop (`p == 0 && continue`).",
                "f($(show_value(a))) retornou NaN. Uma contagem zero gera 0 * log(0); " *
                "pule os zeros dentro do loop (`p == 0 && continue`).")
            close_to(got, -want) && return (
                "f($(show_value(a))) returned $(show_value(got)): right size, wrong sign. " *
                "H = −Σ pᵢ log pᵢ.",
                "f($(show_value(a))) retornou $(show_value(got)): tamanho certo, sinal " *
                "errado. H = −Σ pᵢ log pᵢ.")
            return (
                "f($(show_value(a))) returned $(show_value(got)); expected $(show_value(want)).",
                "f($(show_value(a))) retornou $(show_value(got)); esperava $(show_value(want)).")
        end
        nothing
    end,
)

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
