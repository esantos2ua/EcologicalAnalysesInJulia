# Chapter 8 — GLMs. Answers are numbers extracted from fitted models, on the
# ponds with canopy recorded.

merge!(EXERCISES, Dict{String, Function}(

    # 8.1 — Poisson GLM with a categorical predictor
    "8.1" => function (x)
        wants_numbers(x) || return (
            "Pass the coefficients: `coef(g)`.",
            "Passe os coeficientes: `coef(g)`.")
        x isa AbstractVector && length(x) == 4 && return (
            "4 coefficients: that is `g1`. Add `hydro` at the end of the formula.",
            "4 coeficientes: esse é o `g1`. Inclua `hydro` no fim da fórmula.")
        expect_vector(x, [-0.2955819444424689, 0.3308987450570613, -0.011543093000739657,
                          0.04752717672780732, -0.1895805246826413])
    end,

    # 8.2 — interpreting a coefficient on the log scale
    "8.2" => x -> expect_number(x, 0.8273060956543652; traps = (
        (-0.1895805246826413, (
            "That is the coefficient itself, on the log scale. Exponentiate it: `exp(...)`.",
            "Esse é o próprio coeficiente, na escala log. Exponencie-o: `exp(...)`.")),
        (-17.26939043456348, (
            "That is the percentage change. The exercise asks for the multiplicative " *
            "factor, `exp(β)`.",
            "Essa é a variação percentual. O exercício pede o fator multiplicativo, " *
            "`exp(β)`.")),)),

    # 8.3 — dispersion once the missing predictor is in
    "8.3" => x -> expect_number(x, 0.9410041742922786; rtol = 1e-4, traps = (
        (1.8998072869627196, (
            "That is the dispersion of the model from 8.1, without `region`. Add `region`.",
            "Essa é a dispersão do modelo do 8.1, sem `region`. Inclua `region`.")),
        (1.952703419456855, (
            "That is the dispersion of `g1`. Fit the model with `hydro` and `region`.",
            "Essa é a dispersão do `g1`. Ajuste o modelo com `hydro` e `region`.")),)),

    # 8.4 — odds ratio for a 10-point change
    "8.4" => x -> expect_number(x, 1.1881878414800107; traps = (
        (1.0173924499128006, (
            "That is the odds ratio for 1 percentage point. The exercise asks for 10.",
            "Essa é a razão de chances para 1 ponto percentual. O exercício pede 10.")),
        (10.173924499128006, (
            "`10 * exp(β)` is not the same as `exp(10 * β)`. Multiply before exponentiating.",
            "`10 * exp(β)` não é o mesmo que `exp(10 * β)`. Multiplique antes de " *
            "exponenciar.")),
        (0.17242932416539436, (
            "That is on the log-odds scale. Exponentiate it.",
            "Isso está na escala de log-chances. Exponencie.")),)),

    # 8.5 — predicted probability for a new pond
    "8.5" => function (x)
        x isa AbstractVector && length(x) == 1 && (x = only(x))
        expect_number(x, 0.5246412509540388; traps = (
            (0.09864491738025813, (
                "That is on the logit (link) scale. `predict(g4, new)` returns the " *
                "probability directly.",
                "Isso está na escala logit (de ligação). `predict(g4, nova)` retorna a " *
                "probabilidade diretamente.")),))
    end,

    # 8.6 — GLMM
    "8.6" => function (x)
        wants_numbers(x) || return (
            "Pass the fixed effects: `fixef(gm)`.",
            "Passe os efeitos fixos: `fixef(gm)`.")
        expect_vector(x, [0.6004949810030696, 0.3694782152614212, -0.010471183105793884,
                          -0.15990712087588418]; rtol = 1e-3)
    end,
))
