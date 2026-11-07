# AWS EKS Masterclass — Novice to Expert (v5.1)

Continuous animated HTML masterclass. **v1–v5 preserved** under `v*-preserved/`.

## Counts (exact)

| Metric | Value |
|--------|------:|
| Scenes | **335** |
| Demos | **215** |
| Lectures | **120** |
| Chapters | **26** |
| Unique audio clips | **276** |
| Scheduled duration | **2:09:55** (7795.372 s) |

## Pinned master (do not rebuild)

- File: `AWS-EKS-Masterclass-Novice-to-Expert-v5.1-YouTube-Edition.html`
- Bytes: 66655838
- SHA256: `a23d6854e93cd4fbb22acded84766b9ae67c6ec159417791f21901ec5d3b7058`

## Canonical editable diagram

- File: [`diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio`](diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio)
- Bytes: 1175080
- SHA256: `6e73873cc031bf0d84202a45798a1aea6bf966fdc7ffe28f3e20624c46135b23`
- See [`diagrams/README.md`](diagrams/README.md) — older drawio names are historical only.

## Scene / chapter map

- [`build/SCENE-CHAPTER-MAP.md`](build/SCENE-CHAPTER-MAP.md) — **335** records, exact IDs from class-data
- [`build/SCENE-CHAPTER-MAP.json`](build/SCENE-CHAPTER-MAP.json) — machine-readable

## Authoritative build pipeline

Do **not** use deprecated `scripts/course_model.py` / `scripts/course_model_part1.py` (exit-shims).

1. `scripts/v2/bind_stages.py` → `build/v5-bound-stages.json`
2. `scripts/v2/build_scenes_icons.py` → `build/scenes/*.svg`
3. `scripts/v2/build_drawio_v5.py` → `diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio` (companion; percent-encoded SVG URIs)
4. `scripts/v2/build_class_data_v3.py` → `build/class-data.json`
5. `scripts/prepare_speech.py` / `scripts/generate_audio.py`
6. `scripts/build_html.py` → pinned HTML (accepted — do not rebuild for packaging fixes)
7. Packaging helpers under `scripts/v2/package_v5_1.py` for volumes; docs ZIP refreshed separately for companion packaging

## Package

- Volumes: `package/v5.1/volumes/AWS-EKS-Masterclass-v5.1.part0{1..4}.zip` + `reassemble_eks_masterclass_v5_1.py` (**unchanged**)
- Docs/diagrams/labs/licenses: `package/v5.1/EKS-Masterclass-v5.1-docs-diagrams-labs.zip`
- Manifest: [`PACKAGE-MANIFEST-v5.1.json`](PACKAGE-MANIFEST-v5.1.json)
- Licenses: [`licenses/`](licenses/) (drawio Apache-2.0, Kubernetes/community Apache-2.0, IBM Plex OFL, Kokoro/Misaki)

## Status

Companion packaging refresh for acceptance P1/P2/P3. HTML/audio/volumes/canonical drawio geometry **unchanged**. Independent companion re-audit still required for full package PASS.

No AWS apply · No YouTube publish · No practice-repo edits from this agent.
