# Builds the book's Julia environment. Run once: julia --project=. scripts/setup.jl
# Installs the exact versions pinned in Manifest.toml, as chapter 3 does with
# `Pkg.instantiate()`. To add a package, use `Pkg.add` and commit both .toml files.
using Pkg
Pkg.activate(dirname(@__DIR__))
Pkg.instantiate()
Pkg.precompile()
@info "Environment ready"
