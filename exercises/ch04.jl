# Chapter 4 — Julia basics. Answers are values (4.1, 4.2) or functions the
# student wrote (4.3–4.6), which are called on test inputs.

# Reference implementations used by the checks — not shown to students.
simpson_ref(a) = 1 - sum((a ./ sum(a)) .^ 2)
function shannon_ref(a)
    p = filter(>(0), a ./ sum(a))
    return -sum(p .* log.(p))
end

const AREAS = [174.1, 161.6, 233.9, 174.5, 1980.0]

merge!(EXERCISES, Dict{String, Function}(

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
))
