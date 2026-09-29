# Chapter 11 — resampling and simulation. Random answers differ from run to run
# and between Julia versions (a minor release may change the random stream), so
# they are accepted within Monte Carlo error of a long-run reference value,
# computed once with 200 000 resamples or 10 000 simulations.

# A number within `tol` of `want`, with traps as in `expect_number`.
function expect_near(x, want, tol; traps = (), hint = ("", ""))
    x isa AbstractVector && length(x) == 1 && (x = only(x))
    x isa Number || return (
        "Expected a single number, got $(show_value(x)).",
        "Esperava um único número, recebi $(show_value(x)).")
    abs(x - want) <= tol && return nothing
    for (value, rtol, message) in traps
        isapprox(x, value; rtol) && return message
    end
    return ("Got $(round(x; sigdigits = 3)); expected about $(round(want; sigdigits = 3)) " *
            "(± $(round(tol; sigdigits = 2)), since random answers vary)." * hint[1],
            "Recebi $(round(x; sigdigits = 3)); esperava cerca de " *
            "$(round(want; sigdigits = 3)) (± $(round(tol; sigdigits = 2)), já que " *
            "respostas aleatórias variam)." * hint[2])
end

const MORE_RESAMPLES = (
    " With few resamples the answer is noisy: use at least 9 999.",
    " Com poucas reamostragens a resposta fica ruidosa: use pelo menos 9 999.")

# Presence–absence matrix used in the chapter's null-model section (species × ponds).
const COOCCURRENCE = [1 1 1 0 1 1 0 0 0 0 0 1;
                      1 0 1 1 1 1 0 1 0 0 0 0;
                      0 1 1 1 1 1 0 0 0 1 0 0;
                      1 0 0 0 0 0 1 1 1 0 1 1;
                      0 0 1 0 0 0 1 1 0 1 1 1;
                      0 1 0 0 0 0 1 0 1 1 1 1]

merge!(EXERCISES, Dict{String, Function}(

    # 11.3 — bootstrap distribution of the mean
    "11.3" => function (f)
        f isa Function || return not_a_function("11.3")
        x = [34.6, 30.4, 34.4, 39.3, 36.1, 38.2, 33.0, 35.7, 41.2, 32.8,
             37.5, 36.9, 31.1, 35.0, 38.8, 34.1, 36.3, 33.7, 40.1, 35.5]
        B = 20_000
        r = attempt(f, x, B)
        r.ok || return r.value
        v = r.value
        v isa AbstractVector{<:Number} || return (
            "boot_means(x, B) should return a vector of B means; got $(show_value(v)).",
            "boot_means(x, B) deveria retornar um vetor com B médias; recebi $(show_value(v)).")
        length(v) == B || return (
            "boot_means(x, $B) returned $(length(v)) values; expected $B.",
            "boot_means(x, $B) retornou $(length(v)) valores; esperava $B.")
        se = std(x) / sqrt(length(x))
        std(v) < 1e-8 && return (
            "All bootstrap means are identical: you resampled without replacement, which " *
            "only reorders the data. Use `sample(x, length(x))` (with replacement).",
            "Todas as médias bootstrap são iguais: você reamostrou sem reposição, o que só " *
            "reordena os dados. Use `sample(x, length(x))` (com reposição).")
        abs(mean(v) - mean(x)) < 0.05 * se || return (
            "The bootstrap means are centred on $(round(mean(v); digits = 2)), not on the " *
            "sample mean $(round(mean(x); digits = 2)). Resample `x` itself, all of it.",
            "As médias bootstrap estão centradas em $(round(mean(v); digits = 2)), e não na " *
            "média amostral $(round(mean(x); digits = 2)). Reamostre o próprio `x`, inteiro.")
        want = se * sqrt((length(x) - 1) / length(x))
        abs(std(v) / want - 1) < 0.05 || return (
            "The spread of the bootstrap means is $(round(std(v); digits = 3)); expected " *
            "about $(round(want; digits = 3)). Is each resample the same size as `x`?",
            "A dispersão das médias bootstrap é $(round(std(v); digits = 3)); esperava cerca " *
            "de $(round(want; digits = 3)). Cada reamostra tem o mesmo tamanho de `x`?")
        nothing
    end,

    # 11.1 — permutation test for a difference in means
    "11.1" => x -> expect_near(x, 0.0367, 0.01; hint = MORE_RESAMPLES, traps = (
        (0.03697255308114836, 1e-6, (
            "That is Welch's t test. Here the p-value should come from your permutations.",
            "Esse é o teste t de Welch. Aqui o valor-p deve vir das suas permutações.")),
        (0.0184, 0.3, (
            "That looks like a one-sided p-value. Compare absolute values, " *
            "`abs(d) >= abs(observed)`, to get the two-sided one.",
            "Isso parece um valor-p unilateral. Compare valores absolutos, " *
            "`abs(d) >= abs(observado)`, para obter o bilateral.")),)),

    # 11.2 — permutation test for a regression slope
    "11.2" => x -> expect_near(x, 0.2608, 0.02; hint = MORE_RESAMPLES, traps = (
        (0.1304, 0.15, (
            "That looks like a one-sided p-value. Compare absolute slopes.",
            "Isso parece um valor-p unilateral. Compare inclinações em valor absoluto.")),)),

    # 11.4 — bootstrap percentile interval
    "11.4" => function (x)
        x isa AbstractVector{<:Number} && length(x) == 2 || return (
            "Pass the interval as two numbers, `[lower, upper]`.",
            "Passe o intervalo como dois números, `[inferior, superior]`.")
        isapprox(x[1], 9.384117221613428; atol = 0.01) && return (
            "That is the t interval, not the bootstrap one. Take the 2.5% and 97.5% " *
            "quantiles of your bootstrap means.",
            "Esse é o intervalo t, não o bootstrap. Tire os quantis de 2,5% e 97,5% das " *
            "suas médias bootstrap.")
        want = [9.5, 12.956521739130435]
        all(abs.(x .- want) .<= 0.07) && return nothing
        return ("Got $(show_value(round.(x; digits = 2))); expected about " *
                "$(show_value(round.(want; digits = 2))) (± 0.07). Did you use the Amazon " *
                "ponds with canopy recorded, and 9 999 or more resamples?",
                "Recebi $(show_value(round.(x; digits = 2))); esperava cerca de " *
                "$(show_value(round.(want; digits = 2))) (± 0,07). Você usou as lagoas da " *
                "Amazônia com dossel medido, e 9 999 reamostragens ou mais?")
    end,

    # 11.5 — power by simulation, with unbalanced sampling
    "11.5" => x -> expect_near(x, 0.600, 0.05; traps = (
        (0.400, 0.12, (
            "That is the proportion of simulations *without* a significant result. Power " *
            "is the proportion with p < 0.05.",
            "Essa é a proporção de simulações *sem* resultado significativo. O poder é a " *
            "proporção com p < 0,05.")),
        (0.808, 0.06, (
            "That is the power with half the ponds temporary. Set `p_temporary = 0.2`.",
            "Esse é o poder com metade das lagoas temporárias. Use `p_temporary = 0.2`.")),),
        hint = (" Use at least 1 000 simulations of 60 ponds each.",
                " Use pelo menos 1 000 simulações de 60 lagoas cada.")),

    # 11.6 — the C-score
    "11.6" => function (f)
        f isa Function || return not_a_function("11.6")
        for (M, want) in (([1 0; 0 1], 1.0), ([1 1; 1 1], 0.0),
                          ([1 1 0; 0 1 1; 1 0 1], 1.0), (COOCCURRENCE, 13.866666666666667))
            r = attempt(f, M)
            r.ok || return r.value
            close_to(r.value, want) && continue
            M === COOCCURRENCE && close_to(r.value, 3.1515151515151514) && return (
                "You treated columns as species. Here species are rows and ponds are " *
                "columns: count occurrences with `sum(M, dims = 2)`.",
                "Você tratou as colunas como espécies. Aqui as espécies são linhas e as " *
                "lagoas, colunas: conte as ocorrências com `sum(M, dims = 2)`.")
            return ("cscore($(show_value(M))) returned $(show_value(r.value)); expected " *
                    "$(show_value(want)).",
                    "cscore($(show_value(M))) retornou $(show_value(r.value)); esperava " *
                    "$(show_value(want)).")
        end
        nothing
    end,
))
