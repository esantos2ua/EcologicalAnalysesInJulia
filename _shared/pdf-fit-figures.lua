-- PDF edition only (see */_quarto-pdf.yml). Figures from Julia carry a fixed
-- size in inches taken from their pixel size, which can exceed the text width.
-- Dropping it lets Pandoc's \pandocbounded scale each figure to fit the page.
function Image(img)
  img.attributes.width = nil
  img.attributes.height = nil
  return img
end
