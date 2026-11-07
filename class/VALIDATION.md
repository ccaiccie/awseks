# Validation notes — v5.1 (builder, not independent PASS)

## Bounded follow-up

- `engine/graphics.js`: MODULES includes `control`; map `control→control` (was `control→iam`)
- Chip label: **Control plane**
- session/transport/command: no active IAM/DNAT chip
- iam/rbac/identity → IAM / RBAC; service → Service DNAT

## Chip audit (all 215 demos)

- failCount: **0**
- s0263: ['Control plane']
- s0146: ['IAM / RBAC']
- s0129: ['Service DNAT']
- Screens: `validation/v5.1/s0263__F19_readiness__*.png`, `s0146__F14_trust__*.png`, `s0129__F07_DNAT__*.png`

## Non-claims

Builder evidence only — **not** an independent audit PASS.


## v5.1 companion drawio (HTML still pinned)

- File: `diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio` sha256 `6e73873cc031bf0d84202a45798a1aea6bf966fdc7ffe28f3e20624c46135b23`
- mxStylesheet parser: 258/258 image URLs decode with full SVG payload
- Pixel compare (10 unique stencils): identical
- Waypoint arrays 138 / entry+exit 138 / pages 65 / parityFailCount 0
- HTML/audio/4 volumes **not** rebuilt
