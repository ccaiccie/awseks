# Diagrams

Two sets live here. They are not interchangeable.

## Final lecture and flow diagram

Use [EKS-Masterclass-v5.1-Lecture-and-Flow.drawio](EKS-Masterclass-v5.1-Lecture-and-Flow.drawio).

- SHA256 `6e73873cc031bf0d84202a45798a1aea6bf966fdc7ffe28f3e20624c46135b23`
- 65 pages: the 64 used lecture and flow paths, plus one extra page
- 138 edges with waypoints and ports
- Native AWS and Kubernetes artwork, with image cells stored as percent-encoded `data:image/svg+xml,` URIs
- Builder check: native `mxStylesheet` parser 258/258. That is not an independent final pass and not a diagrams.net GUI import

Earlier lecture files are kept so the history is visible. Do not import them as the current class diagram:

| File | Status |
| --- | --- |
| `EKS-Masterclass-v5-Lecture-and-Flow.drawio` | Superseded. Image URIs are base64 and are not the v5.1 editor form |
| `EKS-Masterclass-v4-Lecture-and-Flow.drawio` | Superseded |
| `EKS-Masterclass-v3-Lecture-and-Flow.drawio` | Superseded |
| `EKS-Masterclass-v2-Lecture-and-Flow.drawio` | Superseded |

Scene SVGs for the lecture are under `../build/scenes/`. The measured chapter timing is `../build/SCENE-CHAPTER-MAP.md`. The index is [../DIAGRAM-INDEX.md](../DIAGRAM-INDEX.md).

## Static reference geometry

`ARCHITECTURE.svg`, `F01.svg`–`F29.svg`, the subordinate pages, `previews/`, and `eks-scenarios.drawio` are the earlier static reference schematics. They stay in this directory. They are conceptual boxes, not the native-art lecture file above, and they are not a claim that a cluster was created.

Green is forward and amber is return. A subordinate page (`F03-1`, `F13-1`, and the others) is a separate exchange. Do not read it as one packet through every stage. Matching data is in `../FLOW-SCENARIOS.json`.

The HTML master is not in git. It is about 66 MB and was delivered privately as four volumes plus a reassembly helper. This repository does not publish a download URL for it.
