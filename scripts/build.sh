#!/usr/bin/env bash
# Renders both language editions and assembles them under _book/ with a
# language-picker landing page.
#
# Each edition is its own Quarto project (pt/, en/) and renders into its own
# pt/_book and en/_book; they are copied here rather than rendered straight into
# a shared tree, because Quarto warns when output-dir escapes the project root.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> rendering pt-BR"
quarto render pt

echo "==> rendering en"
quarto render en

echo "==> assembling _book/"
rm -rf _book
mkdir -p _book
cp -R pt/_book _book/pt
cp -R en/_book _book/en
# book PDFs (built by .github/workflows/pdf.yml) behind each edition's download button
[ -f pdf/analises-ecologicas-em-julia-pt.pdf ] && cp pdf/analises-ecologicas-em-julia-pt.pdf _book/pt/
[ -f pdf/ecological-analyses-in-julia-en.pdf ] && cp pdf/ecological-analyses-in-julia-en.pdf _book/en/

cat > _book/index.html <<'HTML'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Ecological Analyses in Julia</title>
<style>
  :root { color-scheme: light dark; }
  body { margin:0; min-height:100vh; display:grid; place-items:center;
         font-family: -apple-system, "Segoe UI", system-ui, sans-serif;
         background:#fbfbfc; color:#1f2328; }
  @media (prefers-color-scheme: dark) { body { background:#16181d; color:#d9dde3; } }
  main { text-align:center; padding:2rem; max-width:34rem; }
  h1 { font-size:1.6rem; font-weight:600; margin:0 0 .4rem; }
  p  { opacity:.72; margin:0 0 2rem; line-height:1.5; }
  .langs { display:flex; gap:1rem; justify-content:center; flex-wrap:wrap; }
  a { display:block; padding:1rem 1.6rem; border-radius:10px; text-decoration:none;
      border:1px solid rgba(128,128,128,.32); color:inherit; min-width:11rem; }
  a:hover { border-color:#9558b2; }
  a strong { display:block; font-size:1.05rem; }
  a span { opacity:.62; font-size:.85rem; }
</style>
</head>
<body>
<main>
  <h1>Ecological Analyses in Julia</h1>
  <p>An open, bilingual introduction to ecological data analysis in Julia.<br>
     Choose a language / Escolha um idioma.</p>
  <div class="langs">
    <a href="pt/"><strong>Português</strong><span>Análises Ecológicas em Julia</span></a>
    <a href="en/"><strong>English</strong><span>Ecological Analyses in Julia</span></a>
  </div>
</main>
</body>
</html>
HTML

echo "==> done: _book/index.html"
