<div align="center">

# Análises Ecológicas em Julia

**Uma introdução aberta e bilíngue à análise de dados ecológicos em Julia**

[English](README.md) · **Português**

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)
[![Ler online](https://img.shields.io/badge/ler-online-9558b2)](https://esantos2ua.github.io/EcologicalAnalysesInJulia/pt/)
[![Julia 1.12](https://img.shields.io/badge/Julia-1.12-9558b2?logo=julia&logoColor=white)](https://julialang.org)
[![Texto: CC BY-NC-SA 4.0](https://img.shields.io/badge/texto-CC%20BY--NC--SA%204.0-lightgrey)](LICENSE-TEXT)
[![Código: MIT](https://img.shields.io/badge/c%C3%B3digo-MIT-lightgrey)](LICENSE)

[**Ler online**](https://esantos2ua.github.io/EcologicalAnalysesInJulia/pt/) ·
[**Baixar PDF**](https://github.com/esantos2ua/EcologicalAnalysesInJulia/releases/latest) ·
[**Como citar**](#como-citar)

</div>

---

O livro tem uma edição em português, *Análises Ecológicas em Julia*, e uma em inglês,
*Ecological Analyses in Julia*. As duas foram escritas do zero para Julia e seguem os
mesmos capítulos.

## Relação com *Análises Ecológicas no R*

Este projeto é **inspirado em** *Análises Ecológicas no R* e segue a sequência de
capítulos daquele livro, para que os dois possam ser lidos lado a lado, se assim o leitor quiser. Este projeto **não**
reproduz o conteúdo do original: o texto, os exemplos, os dados e os exercícios foram
escritos do zero para Julia. Os autores do original não participam deste projeto, não
o revisaram e não o endossam.

> Da Silva FR, Gonçalves-Souza T, Paterno GB, Provete DB, Vancine MH. 2022.
> *Análises ecológicas no R*. Nupeea: Recife, PE; Canal 6: São Paulo. 640 p.
> ISBN 978-85-7917-564-0. <https://analises-ecologicas.com/>

O original é gratuito online sob CC BY-NC 4.0 e também existe impresso. Se este livro
for útil para você, o *Análises ecológicas no R* provavelmente será ainda mais.

## Relação com o *ecoR*

Os capítulos 7 (análise exploratória), 10 (funções) e 11 (reamostragem e simulação)
são **inspirados** nos módulos de análise exploratória, programação e reamostragem do
*ecoR*, a wiki do curso de R do Instituto de Biociências da Universidade de São Paulo,
produzida e mantida por Alexandre Adalardo de Oliveira (com base, em parte, em material
de João Luis Ferreira Batista e Paulo Inácio K. L. Prado). O texto, os exemplos e os
exercícios foram escritos do zero; os autores do ecoR não os revisaram. O ecoR é
gratuito em <https://ecor.ib.usp.br/> sob CC BY-SA 4.0.

## Escopo

Esta edição cobre os **capítulos 1 a 11**: noções básicas da linguagem, manipulação de dados, visualização, análise exploratória, modelos lineares e GLMs, e depois escrita de funções e reamostragem. Os capítulos de ecologia de comunidades do *Análises ecológicas no R* (análise multivariada, rarefação, estimadores de riqueza, diversidade taxonômica, filogenética e
funcional, dados geoespaciais) estão **fora do escopo por enquanto**: Julia ainda não tem equivalentes maduros de `vegan`, `iNEXT`, `picante` ou `FD`, e escrever esses capítulos significaria escrever os pacotes primeiro (algo completamente fora do meu escopo).

| # | Capítulo | Pacotes principais |
|---|---|---|
| 1 | Introdução | — |
| 2 | Da pergunta ao modelo | — (planejado; só roteiro e referências) |
| 3 | Pré-requisitos | `Pkg` |
| 4 | Introdução ao Julia | Base |
| 5 | Manipulação de dados | `TidierData.jl`, `DataFrames.jl` |
| 6 | Visualização | `TidierPlots.jl`, `AlgebraOfGraphics.jl`, `CairoMakie.jl` |
| 7 | Análise exploratória | `TidierData.jl`, `CairoMakie.jl`, `StatsBase.jl` |
| 8 | Modelos lineares | `GLM.jl`, `HypothesisTests.jl`, `MixedModels.jl` |
| 9 | GLMs | `GLM.jl`, `MixedModels.jl` |
| 10 | Escrevendo suas próprias funções | Base, `Test` |
| 11 | Reamostragem e simulação | `Random`, `StatsBase.jl`, `GLM.jl`, `HypothesisTests.jl` |

## Como gerar o livro

```bash
julia --project=. scripts/setup.jl     # instala as dependências (só na primeira vez)
julia --project=. scripts/make_data.jl # gera os dados de exemplo
./scripts/build.sh                     # gera as duas edições em _book/
```

Para gerar só uma edição:

```bash
quarto render pt   # ou: quarto render en
```

Pré-visualização ao vivo enquanto escreve:

```bash
quarto preview pt
```

## Organização do repositório

```
pt/  en/             um projeto de livro Quarto por edição, capítulos espelhados
pt/_quarto.yml       configuração da edição pt-BR -> pt/_book (copiado para _book/pt)
en/_quarto.yml       configuração da edição em inglês -> en/_book (copiado para _book/en)
pt/_freeze en/_freeze  cache de execução versionado (só capítulos alterados rodam de novo)
_shared/common.yml   configuração comum (motor Julia, formato, opções de execução)
_shared/             bibliografia, temas SCSS, cabeçalho HTML
data/ponds.csv       dados de exemplo simulados (gere de novo com scripts/make_data.jl)
exercises/           corretor de exercícios: check.jl (en) / checar.jl (pt) carregam Checks.jl
scripts/             instalação do ambiente, geração de dados, build, zenodo.py
pdf/                 PDFs do livro, gerados pelo workflow "Build PDFs for release"
Project.toml         ambiente Julia do livro
Manifest.toml        versões fixas dos pacotes
.github/workflows/   publica no GitHub Pages a cada push na main; gera PDFs para releases
```

## Dados de exemplo

`data/ponds.csv` é um levantamento **simulado** de anuros em 180 lagoas de três regiões. A simulação é proposital: como o processo que gerou os dados é conhecido (`scripts/make_data.jl`), cada modelo ajustado nos capítulos 8 e 9 pode ser comparado com a verdade, e o texto mostra essa comparação.

## Regras de fontes

Algumsas regras que estou tentando seguir:

1. **Afirmações precisam de fontes.** Afirmações comparativas ou sobre desempenho (entre o R e Julia) citam referências verificáveis.
2. **Avaliações do ecossistema têm data.** Afirmações sobre o que falta em Julia indicam o mês em que foram verificadas, porque ficam desatualizadas.

## Como citar

Cada versão do livro é arquivada no Zenodo com um DOI próprio. O DOI abaixo sempre aponta para a versão mais recente. Isso é importante, pois como se trata de um projeto vivo e dinâmico, conseguimos garantir que novas referências e citações serão consideradas e autores receberão os créditos. Os metadados de citação estão em [`CITATION.cff`](CITATION.cff), que alimenta o botão "Cite this repository" do GitHub.
Cada release traz os PDFs das duas edições.

> Santos E. 2026. *Ecological Analyses in Julia* (v1.0.0). Zenodo.
> <https://doi.org/10.5281/zenodo.XXXXXXX>

Processo de lançamento de versões: [RELEASE.md](RELEASE.md).

## Licença

Texto: [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.pt-br) ([LICENSE-TEXT](LICENSE-TEXT)).
Código: [MIT](https://opensource.org/licenses/MIT) ([LICENSE](LICENSE)).
