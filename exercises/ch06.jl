# Chapter 6 — visualization. Figures are compared with the solution by eye;
# only saving (6.6) is checked, by reading the PNG header of the saved file.

# Width and height, in pixels, of a PNG file, or `nothing` if it is not a PNG.
function png_size(path)
    bytes = open(io -> read(io, 24), path)
    length(bytes) == 24 && bytes[1:8] == [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a] ||
        return nothing
    be32(i) = Int(bytes[i]) << 24 | Int(bytes[i+1]) << 16 | Int(bytes[i+2]) << 8 | Int(bytes[i+3])
    return (be32(17), be32(21))
end

merge!(EXERCISES, Dict{String, Function}(

    # 6.6 — saving a figure at publication resolution
    "6.6" => function (path)
        path isa AbstractString || return (
            "Pass the file name as a string, e.g. `check(\"6.6\", \"focal-by-region.png\")`.",
            "Passe o nome do arquivo como texto, por exemplo " *
            "`checar(\"6.6\", \"focal-by-region.png\")`.")
        isfile(path) || return (
            "There is no file $path in $(pwd()). Did `save` run, and with this name?",
            "Não existe o arquivo $path em $(pwd()). O `save` rodou, e com esse nome?")
        wh = png_size(path)
        wh === nothing && return (
            "$path is not a PNG file. Save it with the `.png` extension.",
            "$path não é um arquivo PNG. Salve com a extensão `.png`.")
        w, h = wh
        (w, h) == (2400, 1050) && return nothing
        (w, h) == (1600, 700) && return (
            "The image is 1600 × 700 px: that is the default of 2 pixels per unit. " *
            "Pass `px_per_unit = 3` to `save`.",
            "A imagem tem 1600 × 700 px: é o padrão de 2 pixels por unidade. " *
            "Passe `px_per_unit = 3` ao `save`.")
        return ("The image is $w × $h px; expected 2400 × 1050 (a figure of " *
                "size = (800, 350), saved with px_per_unit = 3).",
                "A imagem tem $w × $h px; esperava 2400 × 1050 (uma figura com " *
                "size = (800, 350), salva com px_per_unit = 3).")
    end,
))
