# Chapter 7 — exploratory data analysis, on data/atlantic_bird_traits.csv (a subset of
# ATLANTIC BIRD TRAITS, Rodrigues et al. 2019). Answers are numbers computed from it.

merge!(EXERCISES, Dict{String, Function}(

    # 7.1 — reading missing-value codes
    "7.1" => x -> expect_number(x, 60819; traps = (
        (72483, ("That is every record. The file writes missing values as the text \"NA\": " *
                 "read it with `missingstring = \"NA\"` and count the non-missing masses.",
                 "Esse é o total de registros. O arquivo escreve valores faltantes como o " *
                 "texto \"NA\": leia com `missingstring = \"NA\"` e conte as massas não faltantes.")),
        (11664, ("That is the number of records *without* a body mass.",
                 "Esse é o número de registros *sem* massa corporal.")),)),

    # 7.2 — two kinds of missing
    "7.2" => x -> expect_number(x, 0.47551540822059907; traps = (
        (0.45536194693928234, (
            "Your denominator includes records where sex was never recorded (`missing`). " *
            "Divide by the records where it was recorded, \"Unknown\" included.",
            "O seu denominador inclui registros em que o sexo nunca foi anotado (`missing`). " *
            "Divida pelos registros em que ele foi anotado, incluindo \"Unknown\".")),
        (0.5244845917794009, (
            "That is the share *not* determined. The exercise asks for Male or Female.",
            "Essa é a fração *não* determinada. O exercício pede Male ou Female.")),)),

    # 7.3 — what is an individual?
    "7.3" => x -> expect_number(x, 4503; traps = (
        (4530, ("Close: some \"rings\" are colour-band codes made only of letters, such as " *
                "\"BRD\", shared by many birds. Drop the codes without digits.",
                "Quase: alguns \"anéis\" são códigos de anilhas coloridas feitos só de letras, " *
                "como \"BRD\", compartilhados por muitas aves. Descarte os códigos sem dígitos.")),
        (12899, ("That is the number of *records* of recaptured birds. Count the rings.",
                 "Esse é o número de *registros* de aves recapturadas. Conte os anéis.")),)),

    # 7.4 — mean and median
    "7.4" => x -> expect_vector(x, [66.0, 66.74542818610924]; traps = (
        ([66.74542818610924, 66.0], (
            "Right numbers, wrong order: median first, then mean.",
            "Números certos, ordem errada: primeiro a mediana, depois a média.")),)),

    # 7.5 — flagging outliers relative to the species
    "7.5" => x -> expect_number(x, 291; traps = (
        (308, ("Keep only species with at least 10 mass records: with fewer, the median " *
               "itself is unreliable.",
               "Fique só com espécies com pelo menos 10 registros de massa: com menos, a " *
               "própria mediana não é confiável.")),
        (90, ("You counted only masses above 3× the median. Count those below 1/3 too.",
              "Você contou só as massas acima de 3× a mediana. Conte também as abaixo de 1/3.")),
        (670, ("That is the count for 2× and 1/2. The exercise asks for 3× and 1/3.",
               "Essa é a contagem para 2× e 1/2. O exercício pede 3× e 1/3.")),)),

    # 7.6 — collinearity between traits
    # Species medians of all 780 names; dropping the 8 "Genus sp." names gives
    # 0.93225, also accepted.
    "7.6" => x -> expect_number(x, 0.9326447165263585; rtol = 1e-3),
))
