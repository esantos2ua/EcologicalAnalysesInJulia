#!/usr/bin/env python3
"""Regenerates .zenodo.json from CITATION.cff and _shared/references.bib.

Run from the repository root before every release:

    python3 scripts/zenodo.py

Steps:
  1. `cffconvert --format zenodo` turns CITATION.cff into Zenodo metadata
     (same as The Turing Way).
  2. Zenodo accepts one license per record, so the first license listed in
     CITATION.cff (the text license) is kept.
  3. The record is typed as a book instead of software.
  4. Every DOI in the .bib becomes a related identifier with relation "cites",
     so the references enter the DOI metadata.
  5. References without a DOI are listed on screen.

Requires cffconvert: `pip install cffconvert`.
"""

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CFF = ROOT / "CITATION.cff"
BIB = ROOT / "_shared" / "references.bib"
OUT = ROOT / ".zenodo.json"

ENTRY = re.compile(r"@(\w+)\s*\{\s*([^,\s]+)\s*,(.*?)(?=^@|\Z)", re.S | re.M)
DOI = re.compile(r"\bdoi\s*=\s*[{\"]\s*([^}\"]+?)\s*[}\"]", re.I)


def cffconvert():
    try:
        result = subprocess.run(
            ["cffconvert", "--infile", str(CFF), "--format", "zenodo"],
            check=True, capture_output=True, text=True,
        )
    except FileNotFoundError:
        sys.exit("error: cffconvert not found. Install it with: pip install cffconvert")
    except subprocess.CalledProcessError as e:
        sys.exit(f"error: cffconvert failed (is CITATION.cff valid?)\n{e.stderr}")
    return json.loads(result.stdout)


def bib_dois():
    """Returns ([(key, doi)], [(key, type)] without a DOI), in file order."""
    with_doi, without = [], []
    for kind, key, body in ENTRY.findall(BIB.read_text(encoding="utf-8")):
        if kind.lower() in ("comment", "preamble", "string"):
            continue
        m = DOI.search(body)
        if m:
            doi = re.sub(r"^(https?://(dx\.)?doi\.org/|doi:)", "", m.group(1), flags=re.I)
            with_doi.append((key, doi))
        else:
            without.append((key, kind.lower()))
    return with_doi, without


def main():
    meta = cffconvert()

    ids = meta.get("license", {}).get("id")
    if isinstance(ids, list):
        meta["license"] = {"id": ids[0].lower()}  # Zenodo ids are lowercase

    meta["upload_type"] = "publication"
    meta["publication_type"] = "book"

    with_doi, without = bib_dois()
    seen, related = set(), []
    for _, doi in with_doi:
        if doi.lower() not in seen:
            seen.add(doi.lower())
            related.append({"identifier": doi, "relation": "cites"})
    meta["related_identifiers"] = related

    OUT.write_text(json.dumps(meta, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(f"wrote {OUT.relative_to(ROOT)}: version {meta.get('version')}, "
          f"{len(related)} cited DOIs")
    if without:
        print(f"\nwarning: {len(without)} reference(s) in {BIB.relative_to(ROOT)} have no DOI "
              "(not included in .zenodo.json):")
        for key, kind in without:
            print(f"  - {key} (@{kind})")


if __name__ == "__main__":
    main()
