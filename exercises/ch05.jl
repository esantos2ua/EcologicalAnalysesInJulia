# Chapter 5 — data wrangling with Tidier. Answers are numbers or tables
# computed from data/ponds.csv. Expected values are fixed here; if the dataset is
# regenerated, the book build fails at `Checks.verify` until they are updated.

const FOCAL_BY_REGION = [:region => ["Cerrado", "Amazon", "Atlantic"],
                         :prop_focal => [0.48484848484848486, 0.4375, 0.42424242424242425]]

function check_focal_by_region(x)
    is_table(x) && column(x, :region) !== nothing && column(x, :prop_focal) !== nothing &&
        string.(collect(x.region)) == reverse(last(FOCAL_BY_REGION[1])) && return (
            "Right numbers, but sorted from lowest to highest. Sort in descending order.",
            "Números certos, mas em ordem crescente. Ordene de forma decrescente.")
    return expect_table(x, FOCAL_BY_REGION)
end

merge!(EXERCISES, Dict{String, Function}(

    # 5.1 — @chain, @filter, @arrange
    "5.1" => function (x)
        want = ["P130", "P034", "P143"]
        ids = is_table(x) ? column(x, :pond_id) : x
        ids === nothing && return (
            "Your table has no `pond_id` column. Keep it, or pass the vector of ids.",
            "Sua tabela não tem a coluna `pond_id`. Mantenha-a, ou passe o vetor de ids.")
        ids isa AbstractVector || return (
            "Expected the pond ids, got $(show_value(x)).",
            "Esperava os ids das lagoas, recebi $(show_value(x)).")
        ids = string.(collect(ids))
        length(ids) == 3 || return (
            "Expected 3 ponds, got $(length(ids)). Keep only the first 3 rows.",
            "Esperava 3 lagoas, recebi $(length(ids)). Fique só com as 3 primeiras linhas.")
        ids == want && return nothing
        sort(ids) == sort(want) && return (
            "Right ponds, wrong order: the largest should come first.",
            "Lagoas certas, ordem errada: a maior deve vir primeiro.")
        return ("Expected $(show_value(want)), got $(show_value(ids)). Did you filter to " *
                "the Cerrado and sort by area in descending order?",
                "Esperava $(show_value(want)), recebi $(show_value(ids)). Você filtrou o " *
                "Cerrado e ordenou pela área em ordem decrescente?")
    end,

    # 5.2 — combining conditions, with missing values in the way
    "5.2" => x -> expect_number(x, 18; traps = (
        (20, ("You counted ponds with richness *up to* the median (`<=`). The exercise " *
              "asks for *below* it (`<`).",
              "Você contou lagoas com riqueza *até* a mediana (`<=`). O exercício pede " *
              "*abaixo* dela (`<`).")),)),

    # 5.3 — @mutate
    "5.3" => function (x)
        is_table(x) || return (
            "Pass the whole table, with the new column added.",
            "Passe a tabela inteira, com a nova coluna adicionada.")
        v = column(x, :rich_per_100m2)
        v === nothing && return (
            "Your table has the columns $(col_names(x)); it needs one named `rich_per_100m2`.",
            "Sua tabela tem as colunas $(col_names(x)); ela precisa de uma chamada " *
            "`rich_per_100m2`.")
        length(v) == 180 || return (
            "Expected all 180 ponds, got $(length(v)) rows. `@mutate` should not drop rows.",
            "Esperava as 180 lagoas, recebi $(length(v)) linhas. `@mutate` não deve " *
            "remover linhas.")
        want = 5.624396937815734
        isapprox(mean(v), want / 100; rtol = 1e-6) && return (
            "Those are species per m². Multiply by 100 to get species per 100 m².",
            "Isso é espécies por m². Multiplique por 100 para ter espécies por 100 m².")
        return expect_number(mean(v), want)
    end,

    # 5.4 — @group_by + @summarize + @arrange
    "5.4" => check_focal_by_region,

    # 5.5 — missing values per group
    "5.5" => function (x)
        is_table(x) && column(x, :n_missing) !== nothing &&
            sum(column(x, :n_missing)) == 173 && return (
                "Those are the ponds *with* canopy recorded. Count the missing ones.",
                "Essas são as lagoas *com* dossel medido. Conte as que faltam.")
        return expect_table(x, [:region => ["Amazon", "Atlantic", "Cerrado"],
                                :n_missing => [2, 2, 3]]; sortby = :region)
    end,

    # 5.6 — joins
    "5.6" => x -> expect_table(x, [:biome_type => ["forest", "savanna"],
                                   :mean_rich => [8.491228070175438, 4.787878787878788]];
                               sortby = :biome_type),

    # 5.7 — native DataFrames.jl
    "5.7" => check_focal_by_region,
))
