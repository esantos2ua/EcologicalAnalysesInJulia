# Como lançar uma versão nova

Cada release no GitHub gera um DOI novo no Zenodo. O processo segue o modelo do
[The Turing Way](https://github.com/the-turing-way/the-turing-way/blob/main/release-workflow.md).

## Números de versão

Use versionamento semântico, sempre com `v` na tag:

- `v1.0.0` → `v2.0.0`: mudança grande (reorganização do livro, capítulos removidos).
- `v1.0.0` → `v1.1.0`: conteúdo novo (capítulo ou seção nova).
- `v1.0.0` → `v1.0.1`: correções (erros de digitação, links, pequenos ajustes).

## Só uma vez: ligar o repositório ao Zenodo

1. Entre em <https://zenodo.org> com sua conta do GitHub.
2. Vá em **Account → GitHub**.
3. Ative o repositório `esantos2ua/EcologicalAnalysesInJulia`.

Faça isso **antes** do primeiro release. Releases publicados antes da ligação não
recebem DOI.

## Passo a passo

1. **Atualize o `CITATION.cff`.** Mude `version` (sem o `v`, por exemplo `1.1.0`)
   e `date-released` (a data de hoje, `AAAA-MM-DD`). Em `preferred-citation` (a
   citação como livro que o GitHub mostra), mude também `version` e `year`. Se
   entrou alguém novo como autor, acrescente nos dois lugares, com o ORCID.

   Atualize também o histórico de versões no fim do livro: `pt/historico.qmd` e
   `en/changelog.qmd`. Acrescente a versão nova no topo, com a data e o que mudou.
   O mesmo texto serve para a descrição do release no passo 5.

2. **Gere o `.zenodo.json`.**

   ```bash
   pip install cffconvert   # só na primeira vez
   python3 scripts/zenodo.py
   ```

   O script lista as referências do `.bib` que não têm DOI. Elas não entram nos
   metadados do Zenodo. Se alguma tiver DOI, acrescente no `.bib` e rode o script
   de novo.

3. **Faça commit e push** do `CITATION.cff` e do `.zenodo.json` para a `main`.

4. **Gere os PDFs.** No GitHub, abra **Actions → Build PDFs for release → Run
   workflow** (na `main`). Espere terminar (uns 15 minutos). O Action faz commit
   dos PDFs em `pdf/`, e assim eles entram no arquivo do Zenodo.

5. **Crie o release.** No GitHub, abra **Releases → Draft a new release**:
   - Tag: `v1.1.0` (o mesmo número do `CITATION.cff`, com `v`).
   - Branch: `main`.
   - Título: `v1.1.0`. Na descrição, escreva o que mudou.
   - Clique em **Publish release**.

   O Action **Attach PDFs to release** confere se a tag, o `CITATION.cff` e o
   `.zenodo.json` têm o mesmo número e anexa os PDFs ao release. Se os números
   forem diferentes, ele falha e avisa.

6. **Confira no Zenodo.** Em alguns minutos a versão aparece em
   <https://zenodo.org/account/settings/github/>. Confira título, autor, licença,
   versão e a lista de referências citadas ("Related works"), e se os PDFs estão
   dentro do .zip.

## Depois do primeiro release

O Zenodo cria dois DOIs:

- um **DOI conceitual**, que aponta sempre para a versão mais recente;
- um **DOI da versão**, para cada release.

Coloque o DOI conceitual:

- nos dois READMEs (`README.md` e `README.pt-BR.md`): troque `XXXXXXX`;
- no `CITATION.cff`: campo `doi:` no topo e em `preferred-citation`.

Depois rode `python3 scripts/zenodo.py` de novo e faça commit.

## Se algo der errado

- **O release não apareceu no Zenodo:** confira se o repositório está ativado no
  Zenodo (veja "Só uma vez" acima) e se o `.zenodo.json` é um JSON válido.
- **O Action de PDF falhou:** abra o log em **Actions**. Normalmente é um erro em
  algum código de capítulo.
- **Errou o número da versão:** apague o release e a tag no GitHub *antes* de o
  Zenodo publicar. Depois que o DOI existe, não dá para apagar; lance uma versão
  corrigida (por exemplo `v1.0.1`).
