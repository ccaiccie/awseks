# Independent final audit — EKS v5.1

**FAIL for the complete delivery package: one narrowly bounded drawio image-serialization defect remains. The reviewed HTML passes the requested bounded technical/visual rechecks. No HTML, curriculum or voice rebuild is needed to fix the remaining defect.**

Audit: November7,2026, approximately12:51–12:59 PST. Exact master: `class/AWS-EKS-Masterclass-Novice-to-Expert-v5.1-YouTube-Edition.html`, **66,655,838 bytes**, SHA256 **a23d6854e93cd4fbb22acded84766b9ae67c6ec159417791f21901ec5d3b7058**. Hash matched before/after. Actual payload:335 scenes,215 demos,120 lectures,26 chapters,276 clips,7795.372 scheduled seconds (2:09:55.372). No release-file edits or observed master mutation. Only this report was written into the source/class tree. Independent images/tests are under `/tmp/eks-class-independent-v5.1/`.

## Only material blocker — M3 native image URLs are broken by drawio style delimiters

Exact file: `class/diagrams/EKS-Masterclass-v5-Lecture-and-Flow.drawio`, also byte-identical inside the v5.1 docs ZIP.

All **258 native image cells** use a style of this form:

`shape=image;image=data:image/svg+xml;base64,PHN2Zy...;imageAspect=1;...`

The literal semicolon before `base64` is a **cell-style delimiter**, not part of the image value. The standard mxGraph stylesheet parser consequently reads **image = data:image/svg+xml**, without the comma or SVG payload. Example: **F01_forward / client-icon**. This affects AWS and Kubernetes images throughout the editable file; counting image objects or decoding the original attribute with a custom regex does not establish native import compatibility.

This was independently reproduced, not inferred from captions: fetched the public native `mxStylesheet.js` implementation, invoked its actual `getCellStyle` on every released image-cell style, and obtained a truncated payload-less image URL for **258/258 cells**. Parser evidence is saved in `/tmp/eks-class-independent-v5.1/mxStylesheet.js` (getCellStyle lines207–265; delimiter at213), with exact released styles in `drawio-image-styles.json`.

Public parser/reference:
- https://jgraph.github.io/mxgraph/javascript/src/js/view/mxStylesheet.js
- https://jgraph.github.io/mxgraph/docs/js-api/files/view/mxStylesheet-js.html

**Bounded fix:** in `scripts/v2/build_drawio_v5.py:34–42,90–94`, serialize the original SVG using a semicolon-free style-safe URI, e.g. `data:image/svg+xml,` + percent-encoded SVG. Preserve the genuine SVG hierarchy/colors/transforms. A scratch candidate using this format survived the actual native parser and round-tripped to the exact original SVG/XML. Scratch only: `proposed-valid-image-style.txt`; the release was not changed.

Regenerate **only the drawio, docs ZIP and affected package manifests/hashes**; retain the reviewed HTML/audio. Verify the parsed image URL includes its complete payload, not merely that the raw XML contains base64. No GUI import was performed, so this report does not claim an observed editor-window failure; it establishes a concrete native style-decoding defect before GUI acceptance.

## v4 M1 — PASS: mechanisms now match the teaching stages

Fresh actual screenshots and a complete215-demo rendered-chip sweep confirm:

- **s0146**, association/service-role trust/tags: IAM classification and **IAM / RBAC** chip, not Service DNAT.
- **s0263**, readiness/EndpointSlice inclusion: dedicated **Control plane** chip, neither IAM nor DNAT.
- All31 control-kind stages use the dedicated control classification; transport/session stages do not light a DNAT chip.
- Nine Service-DNAT stages are actual F06/F07/F08 Service translation, F10 NodePort/reverse mapping and F24 NodePort/reverse mapping. The required genuine translation examples remain.

Actual opened evidence includes `s0146__complete__930.png`, `s0263__complete__1080.png` and `F07_forward__p085__1080.png`.

## v4 M2 — PASS: original native Kubernetes glyphs restored in HTML

For Pod, Service and Deployment, compared embedded icon model against the local authoritative native `build/k8s-icons/{pod,svc,deploy}.svg`: group/path hierarchy, transforms, styles/fills and original viewBox all match exactly. The lost transforms and blue-for-white substitutions are repaired.

Fresh rendered F07 forward/reverse images show intact blue native symbols with white inner glyphs, not slivers/fragments. Laptop/runner role corrections remain. Native artwork fits its actor cards and the fresh token/connector checks below found no tested artwork-region clearance failures. The **HTML native art passes**; the remaining drawio problem is its URL serialization, not its underlying SVG payload.

## v4 M3 — Geometry repaired; only the image serialization above blocks acceptance

Independently parsed the actual editable XML rather than trusting its parity report:

-65 pages cover all64 paths actually used by the class; the additional unused F29_return page has no corresponding rendered scene.
-All138 edges have ordered source/target pairs matching the canonical HTML segments.
-All138 waypoint arrays match their corresponding HTML segment's **intermediate points exactly**, including reverse and subordinate exchanges.
-All138 edges now have real entry/exit constraints; these are not decorative port circles only.
-Compound actor-card bounds match the actual embedded HTML SVG actor rectangles; native image offsets are36×36 at card+12,+12 rather than the previous unrelated78×78 icon-only layout.

**Nonblocking registration detail:** constrained editable endpoints sit on the200×100 card borders, while all276 canonical HTML segment endpoints are5 diagram units inside those borders following card expansion. This is a small blank-border offset, not an artwork crossing, missing hop, wrong port side or semantic mismatch. Exact endpoint coordinates are therefore **not byte-identical**; do not describe this as perfect numeric parity. It is not used to block delivery. Intermediate geometry, actor positions and port directions match. Editor auto-router/import behavior was not GUI-certified.

## v4 M4 — PASS: request/reply ports and new narration agree

Actual **s0145** requests node10.42.16.10:**49001**→EKS Auth:443. Actual **s0147** replies EKS Auth:443→node10.42.16.10:**49001**. Separate agent→Pod80→49000 connection is preserved.

The response maps to new clip **2f12dfc5a2ad40e2**, embedded MP3 SHA256 **1521be41d2a442d2a67377010463ffaf55bdb87833a1f7750719884a8c79872a**. Its actual audio bytes differ from the old wrong49100 clip. Current clean text says49001 and spoken text says **“forty-nine thousand one”**; plan, embedded mapping, delivered MP3 and readable transcripts agree. Full clip decoding passes. Acoustic/ASR word verification is not claimed.

## Preserved PASS criteria — freshly rechecked

### Geometry, hop order, context and readability

Fresh offline rendering of all335 scenes at **1920×1080 and1920×930**. All215 demos sampled at0,.025,…,1: **17,630 actual state samples**.

- Zero tested raw out-of-range hop states, token metadata/actual-hop disagreements or first/last segment-position errors.
- Zero tested visible packet-circle/stroke intersections with actor/caption/header bounds; zero hidden-away-from-processing samples.
- Zero tested static/active connector intersections with unrelated actor/caption/header rectangles.
- No bottom-band/topology overlap. Context remains bottom-only.
- All64 used paths have complete segment coverage. No decreasing-hop contiguous exchange-stage order remains.
- F03 watch/status direction, F13 return0→1→2, F14/F15 application-response tuples and F26 forward-allow/reverse-drop semantics remain intact.

At930, F13 s0175–s0178 still have a3px right-column scroll-metric excess and s0199 .lv a6px metric excess. Fresh opened images show complete final sentences, both full command blocks and the complete warning. No unique guidance was hidden; these are not promoted to material blockers. The former large duplicated-STATE clipping is fixed.

Actual opened images include mechanisms, glyphs, reverse route lookup, credential response, complete S3 context, lecture and settled commands. This is not a claim that every frame of every scene received manual review.

### Curriculum, commands and source pipeline

All120 lecture titles, clean narration and visual content match preserved v3 exactly. Expanded causal mechanisms, observations and Terraform instruction are retained. No curriculum reduction was made to obtain these fixes.

All33 actual command blocks pass Bash syntax checks and contain real newlines. The reviewed complete04-app scene retains parent LAB_ROOT/STATE_DIR setup and namespace-first order; staged teardown retains exact-STACK guards/checkpoints. Terraform remains three paced scenes. This is static teaching validation, not successful AWS/Terraform execution.

README now clearly names the authoritative v5.1 pipeline, preserved inputs, deprecation shims and packaging entrypoint. Both legacy shims parse and deliberately exit instead of masquerading as builders. No full source-to-TTS regeneration was performed by this audit.

### All audio and current exports

All **276 embedded clips** fully decoded with ffmpeg. Embedded SHA256 and delivered MP3 byte identities pass. All **335 clean/spoken scene mappings** match the narration plan and current readable transcripts exactly. This proves artifact integrity and mapping, not pronunciation, acoustic naturalness or exact spoken-word synchronization.

### Exact v5.1 recovery and packaging

Independent copied-ZIP tests in `/tmp/eks-v5_1-independent-recovery-s3854y_c/`:

-Fresh ZIP-only recovery produces the exact66,655,838-byte pinned HTML hash.
-Identical existing destination succeeds without replacement/mtime change.
-Nonidentical sentinel is refused and preserved.
-Corrupt part fails atomically without trusted output/partials; previous valid output remains intact.
-Docs ZIP CRC passes; packaged drawio and clean/spoken transcripts are byte-identical to current files;21 shell scripts included.

Four ZIP sizes: **13,180,880;14,001,242;14,005,914;7,421,487 bytes**, all below25MB. ZIP integrity does not resolve the editable-image content defect above.

### Player and honest limits

Genuine headless fullscreen launch advanced audio. Space pause/resume and C-tray Stop worked. Stop paused media, returned launch and cleared frame/delay/watch/alarm handles. No application exceptions logged in the main test. Helper relaxes autoplay restrictions. Geometry matrices are injected-state tests, not uninterrupted real-time playback.

No full130-minute playback/listening, ASR, exact-word timing, GUI drawio import, user-device/browser certification, AWS deployment, Terraform apply, repository action or publication is claimed. One public mxGraph parser/documentation read was used for the concrete editable-style test; no accounts/repositories were modified or cloned.

## Correct HTML preview candidates — not complete-package PASS signoff

These actual fresh captures were opened/read and are suitable once the companion-file blocker is repaired:

- Lecture: `/tmp/eks-class-independent-v5.1/s0002__complete__1080.png`
- Commands: `/tmp/eks-class-independent-v5.1/s0325__complete__930.png`
- Native icons + DNAT: `/tmp/eks-class-independent-v5.1/F07_forward__p085__1080.png`
- Matching return route context: `/tmp/eks-class-independent-v5.1/F07_return__p085__930.png`

**Next action: repair only the258 image URI style values and rebuild the companion ZIP/manifests. Preserve the reviewed HTML, audio, curriculum and successful engine corrections.**
