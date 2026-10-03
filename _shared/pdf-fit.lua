-- PDF edition only (see */_quarto-pdf.yml): keeps figures and tables inside
-- the text block.

-- Figures from Julia carry a fixed size in inches taken from their pixel size,
-- which can exceed the text width. Dropping it lets Pandoc's \pandocbounded
-- scale each figure to fit the page.
function Image(img)
  img.attributes.width = nil
  img.attributes.height = nil
  return img
end

-- DataFrames print as raw LaTeX tabulars; wide ones (many columns) run past
-- the right margin. Wrap each in an adjustbox that shrinks it to the text
-- width when needed (narrow tables are left at their natural size).
function RawBlock(el)
  if (el.format == "latex" or el.format == "tex") and el.text:find("\\begin{tabular}", 1, true) then
    local text = el.text
      :gsub("\\begin{tabular}", "\\begin{adjustbox}{max width=\\linewidth}\\begin{tabular}")
      :gsub("\\end{tabular}", "\\end{tabular}\\end{adjustbox}")
    return pandoc.RawBlock(el.format, text)
  end
end
