# Chapter 9 — writing your own functions. Most answers are functions, which are
# called on test inputs; 9.5 is a table computed from data/ponds.csv.

# Runs `f(args...; kwargs...)` and returns the exception it throws, or `nothing`.
function thrown(f, args...; kwargs...)
    try
        f(args...; kwargs...)
        return nothing
    catch e
        return e
    end
end

# The docstring text attached to function `f`, or `nothing`. Reads the module's
# docs metadata directly, because `Base.Docs.doc` needs the REPL to be loaded.
function docstring(f)
    m = parentmodule(f)
    b = Base.Docs.Binding(m, nameof(f))
    meta = Base.Docs.meta(m)
    haskey(meta, b) || return nothing
    return join((join(string.(d.text)) for d in values(meta[b].docs)), "\n")
end

not_a_function(n) = (
    "Pass the function itself, without parentheses: `check(\"$n\", name)`.",
    "Passe a própria função, sem parênteses: `checar(\"$n\", nome)`.")

merge!(EXERCISES, Dict{String, Function}(

    # 9.1 — variance-to-mean ratio
    "9.1" => function (f)
        f isa Function || return not_a_function("9.1")
        for x in ([2, 4, 6], [0, 0, 10], [5, 5, 5], [1, 3, 2, 8, 0, 4])
            r = attempt(f, x)
            r.ok || return r.value
            got, want = r.value, var(x) / mean(x)
            close_to(got, want) && continue
            close_to(got, var(x; corrected = false) / mean(x)) && return (
                "vmr($(show_value(x))) returned $(show_value(got)), using the population " *
                "variance. Use the sample variance, `var(x)`, which divides by n − 1.",
                "vmr($(show_value(x))) retornou $(show_value(got)), usando a variância " *
                "populacional. Use a variância amostral, `var(x)`, que divide por n − 1.")
            want != 0 && close_to(got, 1 / want) && return (
                "vmr($(show_value(x))) returned $(show_value(got)): mean over variance. " *
                "The ratio is variance over mean.",
                "vmr($(show_value(x))) retornou $(show_value(got)): média sobre variância. " *
                "A razão é variância sobre média.")
            return ("vmr($(show_value(x))) returned $(show_value(got)); expected $(show_value(want)).",
                    "vmr($(show_value(x))) retornou $(show_value(got)); esperava $(show_value(want)).")
        end
        nothing
    end,

    # 9.2 — keyword arguments with defaults
    "9.2" => function (f)
        f isa Function || return not_a_function("9.2")
        x = [12.4, 8.1, 15.7, 9.3, 11.0]
        cases = [
            ((;), (x .- mean(x)) ./ std(x), "standardize(x)"),
            ((; scale = false), x .- mean(x), "standardize(x; scale = false)"),
            ((; center = false), x ./ std(x), "standardize(x; center = false)"),
            ((; center = false, scale = false), x, "standardize(x; center = false, scale = false)"),
        ]
        for (kw, want, call) in cases
            e = thrown(f, x; kw...)
            if e isa MethodError
                return ("$call failed: Julia found no method accepting those keywords. " *
                        "Keyword arguments go after a semicolon: " *
                        "`standardize(x; center = true, scale = true)`.",
                        "$call falhou: Julia não achou um método que aceite essas palavras-" *
                        "chave. Argumentos nomeados vêm depois de um ponto e vírgula: " *
                        "`standardize(x; center = true, scale = true)`.")
            elseif e !== nothing
                return ("$call threw `$(nameof(typeof(e)))`.",
                        "$call lançou `$(nameof(typeof(e)))`.")
            end
            got = f(x; kw...)
            close_to(got, want) || return (
                "$call returned $(show_value(round.(got; digits = 3))); expected " *
                "$(show_value(round.(want; digits = 3))).",
                "$call retornou $(show_value(round.(got; digits = 3))); esperava " *
                "$(show_value(round.(want; digits = 3))).")
        end
        nothing
    end,

    # 9.3 — refusing bad input
    "9.3" => function (f)
        f isa Function || return not_a_function("9.3")
        r = attempt(f, [2, 4, 6])
        r.ok || return r.value
        close_to(r.value, 1.0) || return (
            "vmr([2, 4, 6]) should still return 1.0; got $(show_value(r.value)).",
            "vmr([2, 4, 6]) ainda deveria retornar 1.0; recebi $(show_value(r.value)).")
        for (x, why_en, why_pt) in (
                ([3], "a single value (the variance needs at least two)",
                      "um único valor (a variância precisa de pelo menos dois)"),
                ([1, -2, 3], "a negative count", "uma contagem negativa"),
                ([0, 0, 0], "all zeros (the mean is zero)", "só zeros (a média é zero)"))
            e = thrown(f, x)
            e === nothing && return (
                "vmr($(show_value(x))) returned a value, but its input has $why_en. " *
                "It should throw an error.",
                "vmr($(show_value(x))) retornou um valor, mas a entrada tem $why_pt. " *
                "A função deveria lançar um erro.")
            e isa ArgumentError || return (
                "vmr($(show_value(x))) threw `$(nameof(typeof(e)))`. Throw an " *
                "`ArgumentError` instead: it tells the caller the problem is the input.",
                "vmr($(show_value(x))) lançou `$(nameof(typeof(e)))`. Lance um " *
                "`ArgumentError`: ele diz a quem chamou que o problema está na entrada.")
        end
        nothing
    end,

    # 9.4 — documenting a function
    "9.4" => function (f)
        f isa Function || return not_a_function("9.4")
        doc = docstring(f)
        doc === nothing && return (
            "`$(nameof(f))` has no docstring yet. Put a string in triple quotes right " *
            "above `function $(nameof(f))` and run the definition again.",
            "`$(nameof(f))` ainda não tem docstring. Coloque um texto entre aspas triplas " *
            "logo acima de `function $(nameof(f))` e rode a definição de novo.")
        length(strip(doc)) < 40 && return (
            "The docstring is very short. Say what the function computes, what it " *
            "expects and what it returns.",
            "A docstring está muito curta. Diga o que a função calcula, o que ela espera " *
            "e o que retorna.")
        nothing
    end,

    # 9.5 — your function inside a grouped summary
    "9.5" => x -> (is_table(x) && column(x, :vmr) !== nothing && length(column(x, :vmr)) == 180) ? (
        "Your table has one row per pond: Tidier applied `vmr` to each pond separately. " *
        "Write `~vmr(richness)` inside `@summarize`.",
        "Sua tabela tem uma linha por lagoa: o Tidier aplicou `vmr` a cada lagoa " *
        "separadamente. Escreva `~vmr(richness)` dentro do `@summarize`.") :
        expect_table(x, [:region => ["Amazon", "Atlantic", "Cerrado"],
                                   :vmr => [3.150972017085146, 2.0820159151193636,
                                            1.770593962999026]];
                               sortby = :region),

    # 9.6 — Morisita's index
    "9.6" => function (f)
        f isa Function || return not_a_function("9.6")
        morisita_ref(x) = length(x) * sum(x .* (x .- 1)) / (sum(x) * (sum(x) - 1))
        for x in ([1, 1, 1, 1], [4, 0, 0, 0], [2, 2, 0, 0], [3, 1, 0, 2, 5, 0])
            r = attempt(f, x)
            r.ok || return r.value
            got, want = r.value, morisita_ref(x)
            close_to(got, want) && continue
            N = sum(x)
            close_to(got, length(x) * sum(x .* (x .- 1)) / N^2) && return (
                "morisita($(show_value(x))) returned $(show_value(got)). The denominator " *
                "is N(N − 1), not N².",
                "morisita($(show_value(x))) retornou $(show_value(got)). O denominador é " *
                "N(N − 1), não N².")
            return ("morisita($(show_value(x))) returned $(show_value(got)); expected " *
                    "$(show_value(want)).",
                    "morisita($(show_value(x))) retornou $(show_value(got)); esperava " *
                    "$(show_value(want)).")
        end
        nothing
    end,
))
