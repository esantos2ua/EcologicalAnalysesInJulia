<div align="center">

# Ecological Analyses in Julia

**An open, bilingual introduction to ecological data analysis in Julia**

**English** · [Português](README.pt-BR.md)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23126524.svg)](https://doi.org/10.5281/zenodo.23126524)
[![Read online](https://img.shields.io/badge/read-online-9558b2)](https://esantos2ua.github.io/EcologicalAnalysesInJulia/en/)
[![Julia 1.12](https://img.shields.io/badge/Julia-1.12-9558b2?logo=julia&logoColor=white)](https://julialang.org)
[![Text: CC BY-NC-SA 4.0](https://img.shields.io/badge/text-CC%20BY--NC--SA%204.0-lightgrey)](LICENSE-TEXT)
[![Code: MIT](https://img.shields.io/badge/code-MIT-lightgrey)](LICENSE)

[**Read online**](https://esantos2ua.github.io/EcologicalAnalysesInJulia/en/) ·
[**Download PDF**](https://github.com/esantos2ua/EcologicalAnalysesInJulia/releases/latest) ·
[**How to cite**](#how-to-cite)

</div>

---

The book has a Brazilian Portuguese edition, *Análises Ecológicas em Julia*, and an
English edition. Both are written from scratch for Julia and follow the same chapters.

## Relationship to *Análises Ecológicas no R*

This project is **inspired by** *Análises Ecológicas no R* and follows its chapter
sequence so the two can be read side by side, if the reader wishes. This project does
**not** reproduce that book's
content: the text, examples, dataset and exercises here are written from scratch for
Julia. The original's authors have no involvement in this project, have not reviewed
it, and do not endorse it.

> Da Silva FR, Gonçalves-Souza T, Paterno GB, Provete DB, Vancine MH. 2022.
> *Análises ecológicas no R*. Nupeea: Recife, PE; Canal 6: São Paulo. 640 p.
> ISBN 978-85-7917-564-0. <https://analises-ecologicas.com/>

The original is free online under CC BY-NC 4.0 and available in print. If this book is
useful to you, *Análises Ecológicas no R* will probably be even more so.

## Relationship to *ecoR*

Chapters 7 (exploratory data analysis), 10 (functions) and 11 (resampling and
simulation) are **inspired by** the exploratory-analysis, programming and resampling
modules of *ecoR*, the R course wiki of the Instituto de
Biociências, Universidade de São Paulo, produced and maintained by Alexandre Adalardo
de Oliveira (based in part on material by João Luis Ferreira Batista and Paulo Inácio
K. L. Prado). The text, examples and exercises are written from scratch; ecoR's authors
have not reviewed them. ecoR is free at <https://ecor.ib.usp.br/> under CC BY-SA 4.0.

## Scope

This edition covers **chapters 1–11**: language basics, data wrangling, visualization,
exploratory data analysis, linear models and GLMs, then writing functions and
resampling. The community-ecology chapters of *Análises Ecológicas no R* (multivariate
analysis, rarefaction, richness estimators, taxonomic/phylogenetic/functional
diversity, geospatial data) are **out of scope for now** — Julia has no mature
equivalents of `vegan`, `iNEXT`, `picante` or `FD`, and writing those chapters means
writing the packages first (something well outside my scope).

| # | Chapter | Primary stack |
|---|---|---|
| 1 | Introduction | — |
| 2 | From question to model | — (planned; outline + references only) |
| 3 | Prerequisites | `Pkg` |
| 4 | Julia basics | Base |
| 5 | Data wrangling | `TidierData.jl`, `DataFrames.jl` |
| 6 | Visualization | `TidierPlots.jl`, `AlgebraOfGraphics.jl`, `CairoMakie.jl` |
| 7 | Exploratory data analysis | `TidierData.jl`, `CairoMakie.jl`, `StatsBase.jl` |
| 8 | Linear models | `GLM.jl`, `HypothesisTests.jl`, `MixedModels.jl` |
| 9 | GLMs | `GLM.jl`, `MixedModels.jl` |
| 10 | Writing your own functions | Base, `Test` |
| 11 | Resampling and simulation | `Random`, `StatsBase.jl`, `GLM.jl`, `HypothesisTests.jl` |

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
scripts/             environment setup, data generation, build, zenodo.py
pdf/                 book PDFs, built by the "Build PDFs for release" workflow
Project.toml         the book's Julia environment
Manifest.toml        pinned package versions
.github/workflows/   deploys to GitHub Pages on push to main; builds PDFs for releases
```

## Example data

`data/ponds.csv` is a **simulated** anuran survey of 180 ponds across three regions.
It is simulated deliberately: because the data-generating process is known
(`scripts/make_data.jl`), every model fitted in chapters 8–9 can be checked against
the truth, which is shown explicitly in the text.

## Sourcing rules

Some rules I am trying to follow:

1. **Claims need sources.** Comparative or performance claims (between R and Julia) cite
   verifiable references.
2. **Ecosystem assessments are dated.** Statements about what Julia lacks are stamped
   with the month they were checked, because they expire.

## How to cite

Each version of the book is archived on Zenodo with its own DOI. The DOI below always
resolves to the latest version. This matters because this is a living, evolving
project: it ensures that new references and citations are taken into account and that
authors receive credit. Citation metadata live in [`CITATION.cff`](CITATION.cff),
which powers GitHub's "Cite this repository" button. Each release includes PDFs of both
editions.

> Santos E. 2026. *Ecological Analyses in Julia* (v1.0.0). Zenodo.
> <https://doi.org/10.5281/zenodo.23126524>

Release process (in Portuguese): [RELEASE.md](RELEASE.md).

## License

Text: [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) ([LICENSE-TEXT](LICENSE-TEXT)).
Code: [MIT](https://opensource.org/licenses/MIT) ([LICENSE](LICENSE)).
