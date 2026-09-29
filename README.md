# Ecological Analyses in Julia / Análises Ecológicas em Julia

An open, bilingual (pt-BR + English) book on ecological data analysis in Julia.

## Relationship to *Análises Ecológicas no R*

This project is **inspired by** *Análises Ecológicas no R* and follows its chapter
sequence so the two can be read side by side. It does **not** reproduce that book's
content: the text, examples, dataset and exercises here are written from scratch for
Julia. The original's authors have no involvement in this project, have not reviewed
it, and do not endorse it.

> Da Silva FR, Gonçalves-Souza T, Paterno GB, Provete DB, Vancine MH. 2022.
> *Análises ecológicas no R*. Nupeea: Recife, PE; Canal 6: São Paulo. 640 p.
> ISBN 978-85-7917-564-0. <https://analises-ecologicas.com/>

The original is free online under CC BY-NC 4.0 and available in print. If this book is
useful to you, theirs will probably be more so.

## Relationship to *ecoR*

Chapters 9 (functions) and 10 (resampling and simulation) are **inspired by** the
programming and resampling modules of *ecoR*, the R course wiki of the Instituto de
Biociências, Universidade de São Paulo, produced and maintained by Alexandre Adalardo
de Oliveira (based in part on material by João Luis Ferreira Batista and Paulo Inácio
K. L. Prado). The text, examples and exercises are written from scratch; ecoR's authors
have not reviewed them. ecoR is free at <https://ecor.ib.usp.br/> under CC BY-SA 4.0.

## Scope

This edition covers **chapters 1–10**: language basics, data wrangling, visualization,
linear models and GLMs, then writing functions and resampling. The community-ecology chapters of the original (multivariate
analysis, rarefaction, richness estimators, taxonomic/phylogenetic/functional
diversity, geospatial data) are **out of scope for now** — Julia has no mature
equivalents of `vegan`, `iNEXT`, `picante` or `FD`, and writing those chapters means
writing the packages first.

| # | Chapter | Primary stack |
|---|---|---|
| 1 | Introduction | — |
| 2 | From question to model | — (planned; outline + references only) |
| 3 | Prerequisites | `Pkg` |
| 4 | Julia basics | Base |
| 5 | Data wrangling | `TidierData.jl`, `DataFrames.jl` |
| 6 | Visualization | `TidierPlots.jl`, `AlgebraOfGraphics.jl`, `CairoMakie.jl` |
| 7 | Linear models | `GLM.jl`, `HypothesisTests.jl`, `MixedModels.jl` |
| 8 | GLMs | `GLM.jl`, `MixedModels.jl` |
| 9 | Writing your own functions | Base, `Test` |
| 10 | Resampling and simulation | `Random`, `StatsBase.jl`, `GLM.jl`, `HypothesisTests.jl` |

## Building

```bash
julia --project=. scripts/setup.jl     # install dependencies (first time only)
julia --project=. scripts/make_data.jl # generate the example dataset
./scripts/build.sh                     # render both editions into _book/
```

To render a single edition:

```bash
quarto render pt   # or: quarto render en
```

Live preview while writing:

```bash
quarto preview en
```

## Repository layout

```
pt/  en/             one Quarto book project per edition, chapter sources mirrored
pt/_quarto.yml       pt-BR book config    -> pt/_book (copied to _book/pt)
en/_quarto.yml       English book config  -> en/_book (copied to _book/en)
pt/_freeze en/_freeze  committed execution cache (only changed chapters re-run)
_shared/common.yml   shared config (Julia engine, format, execute options)
_shared/             bibliography, SCSS themes, HTML header
data/ponds.csv       simulated example dataset (regenerate with scripts/make_data.jl)
exercises/           exercise checker: check.jl (en) / checar.jl (pt) load Checks.jl
scripts/             environment setup, data generation, build
Project.toml         the book's Julia environment
Manifest.toml        pinned package versions
.github/workflows/   renders and deploys to GitHub Pages on push to main
```

## Example data

`data/ponds.csv` is a **simulated** anuran survey of 180 ponds across three regions.
It is simulated deliberately: because the data-generating process is known
(`scripts/make_data.jl`), every model fitted in chapters 7–8 can be checked against
the truth, which is shown explicitly in the text.

## Sourcing rules

Two rules this repository is held to:

1. **No claim without a source.** Comparative and performance claims either cite a
   verifiable reference or are removed. `_shared/references.bib` contains only entries
   checked against a primary or publisher source — never added from memory.
2. **Ecosystem assessments are dated.** Statements about what Julia lacks are stamped
   with the month they were checked, because they expire.

## License

Text: [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
Code: [MIT](https://opensource.org/licenses/MIT).
