# Chapter 8 — linear models. Answers are numbers extracted from fitted models
# (p-values, coefficients, intervals), on the ponds with canopy recorded.

const NOT_A_NUMBER_MODEL = (
    "Pass a number extracted from the model (with `coef`, `pvalue`, …), not the model.",
    "Passe um número extraído do modelo (com `coef`, `pvalue`, …), não o modelo.")

wants_numbers(x) = x isa Number || x isa AbstractArray || x isa AbstractString

merge!(EXERCISES, Dict{String, Function}(

    # 8.1 — Welch t test
    "8.1" => function (x)
        wants_numbers(x) || return (
            "That is the test itself. Pass its p-value: `pvalue(test)`.",
            "Esse é o próprio teste. Passe o valor-p dele: `pvalue(teste)`.")
        expect_number(x, 0.10269215805061108; traps = (
            (0.10286026670632867, (
                "That is the equal-variance test. R's default, and the one asked for, " *
                "is Welch's: `UnequalVarianceTTest`.",
                "Esse é o teste com variâncias iguais. O padrão do R, e o pedido, é o de " *
                "Welch: `UnequalVarianceTTest`.")),))
    end,

    # 8.2 — simple regression
    "8.2" => function (x)
        wants_numbers(x) || return NOT_A_NUMBER_MODEL
        x isa Number && isapprox(x, -0.04966562886720355; rtol = 1e-6) && return (
            "That is the slope. Pass both coefficients: `coef(m)`.",
            "Essa é a inclinação. Passe os dois coeficientes: `coef(m)`.")
        expect_vector(x, [38.134435320100685, -0.04966562886720355]; traps = (
            ([116.2727523510521, -1.8807366059918855], (
                "The formula is reversed: the response goes on the left of `~`, " *
                "`body_size ~ canopy`.",
                "A fórmula está invertida: a resposta fica à esquerda do `~`, " *
                "`body_size ~ canopy`.")),))
    end,

    # 8.3 — confidence interval, compared with the true value
    "8.3" => function (x)
        wants_numbers(x) || return NOT_A_NUMBER_MODEL
        x isa AbstractMatrix && return (
            "That is the table of all intervals. Pass only the `temp_c` row: " *
            "`confint(m)[2, :]`.",
            "Essa é a tabela com todos os intervalos. Passe só a linha de `temp_c`: " *
            "`confint(m)[2, :]`.")
        expect_vector(x, [0.7785892869884607, 1.0167713699307568]; traps = (
            ([0.7833747897981913, 1.0195263197723599], (
                "That interval comes from a model without `hydro`. Add it to the formula.",
                "Esse intervalo vem de um modelo sem `hydro`. Inclua-o na fórmula.")),
            ([0.7979047326189066, 0.9974559243003109], (
                "That is a 90% interval. The default, `confint(m)`, gives 95%.",
                "Esse é um intervalo de 90%. O padrão, `confint(m)`, dá 95%.")),))
    end,

    # 8.4 — choosing the reference level
    "8.4" => function (x)
        want = ["(Intercept)", "temp_c", "region: Amazon", "region: Cerrado"]
        x isa AbstractVector{<:AbstractString} || return (
            "Pass the coefficient names: `coefnames(m)`.",
            "Passe os nomes dos coeficientes: `coefnames(m)`.")
        x == want && return nothing
        "region: Atlantic" in x && return (
            "Atlantic still appears as a coefficient, so it is not the reference. " *
            "Use `DummyCoding(base = \"Atlantic\")`.",
            "Atlantic ainda aparece como coeficiente, então não é a referência. " *
            "Use `DummyCoding(base = \"Atlantic\")`.")
        return ("Expected $(show_value(want)), got $(show_value(x)). Is the formula " *
                "`body_size ~ temp_c + region`?",
                "Esperava $(show_value(want)), recebi $(show_value(x)). A fórmula é " *
                "`body_size ~ temp_c + region`?")
    end,

    # 8.5 — diagnostics: share of large residuals
    "8.5" => x -> expect_number(x, 0.057803468208092484; traps = (
        (10, ("That is how many residuals are large. Divide by the number of residuals " *
              "to get the proportion.",
              "Esse é o número de resíduos grandes. Divida pelo total de resíduos para " *
              "obter a proporção.")),
        (5.7803468208092484, ("That is a percentage. Give the proportion, between 0 and 1.",
                              "Isso é uma porcentagem. Dê a proporção, entre 0 e 1.")),)),

    # 8.6 — random intercept
    "8.6" => function (x)
        wants_numbers(x) || return (
            "Pass the fixed effects: `fixef(mm)`.",
            "Passe os efeitos fixos: `fixef(mm)`.")
        expect_vector(x, [13.183682687070387, 0.9217361109462527]; rtol = 1e-3)
    end,
))
