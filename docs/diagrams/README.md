# Repo sketches

These Mermaid, draw.io, and SVG files are short layouts for the Terraform and AWS CLI chapters in this repository. They are **not** the class diagrams.

The class diagrams are `class/diagrams/*.svg`, `class/diagrams/eks-scenarios.drawio`, and the PNG previews next to them. See [docs/class-index.md](../class-index.md).

Regenerate the sketches with `python3 scripts/render_diagrams.py`. That script does not read `class/FLOW-SCENARIOS.json` and must not overwrite `class/diagrams/`.
