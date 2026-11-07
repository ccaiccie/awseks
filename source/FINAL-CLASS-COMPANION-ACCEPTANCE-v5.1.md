# Independent companion-only acceptance — EKS v5.1

**FAIL for the two complete companion bundles as packaged. The canonical corrected drawio itself PASSES: the serialization blocker is resolved. Remaining corrections are documentation/license packaging only; do not rebuild the HTML, audio, geometry or volumes.**

Audit: November7,2026, approximately1:01–1:07 PM PST. Read-only release/archive inspection; only this report was written into the source/class tree. No AWS, repository, publication or account actions. Scratch evidence: `/tmp/eks-class-companion-independent-v5.1/`.

## Accepted canonical editable diagram — PASS

`class/diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio`

-1,175,080 bytes; SHA256 **6e73873cc031bf0d84202a45798a1aea6bf966fdc7ffe28f3e20624c46135b23** matches the requested pin.
-All **258** image URI values passed the actual native `mxStylesheet.getCellStyle` implementation previously obtained from the public mxGraph distribution. Every parsed value retains its complete `data:image/svg+xml,` percent-encoded payload.
-All258 decoded SVGs parse and match the current original icon model **byte-for-byte**, including the restored native Kubernetes transforms, hierarchy, blue background and white glyph styling. The previous semicolon/base64 truncation is gone.
-Compared all10 supplied original/roundtrip PNG pairs independently: identical dimensions/pixels. Opened/read an independent contact sheet of those actual images; native glyphs are intact. This verifies the supplied raster evidence, not a newly claimed GUI import. A fresh CairoSVG rasterization attempt was not performed because that optional module is absent; no dependency installation was needed for native parsing/byte-roundtrip acceptance.
-**65 pages,138 edges,138 waypoint arrays,138 entry/exit constraints retained.** The full XML for every edge is unchanged from the already reviewed v5 geometry, not merely the counts. Non-image actor/caption/port-cell XML is unchanged. Existing minor5-diagram-unit border registration noted in the previous audit remains nonblocking and was not silently represented as perfect endpoint-coordinate equality.
-The canonical file in both archives is the exact accepted file.

## Remaining bundle corrections

### P1 — Stale v2 scene/chapter map in BOTH archives

Both ship `build/SCENE-CHAPTER-MAP.md` (under `class/` in repo-sync), whose first line is **“Scene–chapter map (v2)”**. It contains **288 scene IDs**, while the pinned class has335. IDs s0288–s0334 are entirely absent, and earlier IDs no longer describe the current scenes.

Concrete mismatches:

-Map line22: **s0016 = F05 Node ENI / CNI forwarding**; actual pinned HTML **s0016 = F04 Terminal return delivery**.
-Map line32: **s0024 = Images to containers**; actual **s0024 = Linux nets takeaway**.
-Map line34: **s0026 = F03 Deployment watch exchange**; actual **s0026 = Tag versus digest and pull path**.

This is not a harmless version label: the lookup map points readers to the wrong lessons/flows. **Regenerate this single Markdown map from the pinned335-scene DATA/current class-data, then refresh both ZIPs and FILE-MANIFEST hashes.** Do not change the class to match the old map. Current curriculum JSON already has the correct335 count/chapter ranges/timings; it need not be redesigned.

### P2 — Required license files absent from the DOCS ZIP

`package/v5.1/EKS-Masterclass-v5.1-docs-diagrams-labs.zip` includes native icons/diagrams/provenance but contains **no licenses/ members at all**. `build/icon-vector-provenance.json` explicitly references **licenses/drawio-Apache-2.0.txt**, which cannot be opened from that archive.

The repo-sync ZIP correctly includes the existing class/licenses files; the omission is specifically the standalone docs bundle. **Include the existing applicable license/notice files under licenses/ in the docs ZIP**, preserving the provenance reference. This is a packaging requirement, not a request to invent a legal opinion or research new licenses.

### P3 — Conflicting diagrams-folder README still selects v3

Both archives ship `diagrams/README.md` (under `class/` in repo-sync) with:

-`# Diagrams v3`
-`Editable: EKS-Masterclass-v3-Lecture-and-Flow.drawio`
-claims that this old file matches the HTML.

The top-level README/DIAGRAM-INDEX correctly identify v5.1 and explicitly supersede v5, but the folder README still directs a reader opening the diagrams directory to the old materially incomplete v3 artifact. **Update this one README to the accepted v5.1 filename/hash and clearly label all older drawio files historical/noncanonical.** Keeping historical files is fine. Also update the authoritative pipeline's exporter output path if it is intended to describe the final companion step rather than the historical v5 intermediate.

Small nonblocking metadata cleanup: BUILD-STATUS.json has current top-level docsLabsZipBytes547901 but retains stale nested packaging.docsLabsZipBytes368004. Normalize it when repackaging; this is not another class/diagram blocker.

## Archive integrity / repo-sync checks that PASS

### Docs bundle pin and content

Actual547,901-byte ZIP SHA256 **f5f461784e5a1febe001dec42e6c71a1a7185cb9ddc585b6611e39b4c1eac7d8** matches the request; CRC passes. It contains the exact accepted canonical drawio, current clean/spoken transcripts,21 lab shell scripts and source/provenance material. Its two remaining content deficiencies are P1/P2 plus the conflicting README P3; valid CRC alone does not cure them.

### Repo-sync pin, guards and actual assets

Actual1,358,613-byte ZIP SHA256 **35c2f063cf04d5332d7dcb519042a0e68053f424f304521ebc32effe5b3d0ab1** matches; CRC passes.

-All180 FILE-MANIFEST entries match actual archived byte sizes/SHA256s; the declared file set exactly matches payload entries. Targets have no absolute paths or traversal segments.
-All packaged class files match their current local counterparts, including the accepted canonical diagram and current readable transcripts.
-All **64 actual embedded scene SVG strings** from the pinned HTML match the corresponding archived class/build/scenes SVG bytes exactly. They are not stale old icon assets.
-Current curriculum metadata has335 scenes and correct actual chapter names/ranges/timings. **Only the Markdown map is stale** as detailed in P1.
-Manifest merge instructions/neverTouchGlobs protect Terraform/CLI lab trees, .terraform/state, secret/key patterns, .git, HTML and audio/volume artifacts. Listed targets are class/source assets, not lab/runtime destinations.
-No HTML masters, audio files/volumes, private-key/state files or .git/.terraform payloads are present. A scan for recognizable literal AWS access keys/private keys/GitHub token patterns found none; this is not a promise that a general-purpose secret scanner or live repository test ran.
-Existing licenses are included here. Status/README explicitly remain pending independent acceptance; no premature companion PASS is asserted.

## Pinned master and four volumes — unchanged

Master remains **66,655,838 bytes**, SHA256 **a23d6854e93cd4fbb22acded84766b9ae67c6ec159417791f21901ec5d3b7058**. Each current part ZIP is byte-identical to the auditor-owned copy used in the preceding successful recovery tests:

| Part | ZIP SHA256 |
|---|---|
|01|f0c9ada21fdb09241b182b0648ca922a6bcfffaab2a946318bc3a03867b44c31|
|02|098df6825341d72418b79af4d7245bc41ba332334ce82c4cc24469d08d02cf84|
|03|2d5495bf3bd659ec9feb67aa40745e500bd9b977c33bd7399b33b11eb3f599c8|
|04|0c36cbc5b16c84d70a5e9aaf3a936190ea5d7c43f7dde6dece32bfd1a3bffc7c|

Concatenating current bin payloads hashes to the same pinned master. No rebuild or new130-minute audit was performed or needed. Prior HTML/audio/geometry/control acceptance and honest limits carry forward unchanged; no GUI drawio import or AWS/runtime/repository validation is newly claimed.

**Next bounded step:** preserve the accepted canonical drawio, master and volumes. Regenerate only the335-scene Markdown map, include existing license files in docs, correct the diagrams README, and refresh the two companion ZIPs/manifests. The serialization fix is accepted and must not be reopened or rebuilt.**
