# Final bounded packaging re-audit — EKS v5.1

**FAIL — P1/P2/P3 are now resolved, but two circular/stale manifest checksum assertions prevent final package-integrity acceptance. HTML, canonical drawio, curriculum and volumes remain accepted/unchanged. Only packaging metadata needs correction.**

Audit date: November 7, 2026 (PST). No release artifacts edited; only this report written. No AWS, runtime, publication or repository actions.

## Exact artifacts reviewed

| Artifact | Bytes | SHA256 |
|---|---:|---|
|Docs/diagrams/labs ZIP|600856|4e7d98b3b4f951532975c088609fa89a23a2a77b4da39e5562805e13bc7aaf1a|
|Repo-sync ZIP|1403891|3eb94f621461176a3b704bfda0063c8f9c350db68684a7c180db8c7f47ee940c|
|Pinned HTML|66655838|a23d6854e93cd4fbb22acded84766b9ae67c6ec159417791f21901ec5d3b7058|
|Canonical v5.1 drawio|1175080|6e73873cc031bf0d84202a45798a1aea6bf966fdc7ffe28f3e20624c46135b23|

Both ZIP CRC checks pass. All four volume ZIPs are byte-identical to the prior auditor-owned successful recovery fixtures.

## P1 / P2 / P3 — PASS

**P1:** Both archives now contain335 exact scene records and26 chapter headers. Independently compared every JSON record's ID, chapter number/name, type, role, title, path, hopRange, owner, direction and kind with the actual pinned HTML DATA, and every clipId with its embedded narration map. All match. Every Markdown scene line contains its correct current title; no missing IDs. The former v2/288-scene mismatch is fixed.

**P2:** Both archives contain8 license/attribution files, identical to their current source files. The previously missing licenses/drawio-Apache-2.0.txt provenance target resolves. The21 lab shell scripts and current readable transcripts remain included in the docs ZIP.

**P3:** Main README, diagram index and diagrams-folder README now consistently select the accepted v5.1 filename/hash and mark older artifacts historical/noncanonical. The prior contradictory v3 folder README is fixed. Full package acceptance is still marked pending rather than falsely claimed. Canonical drawio-only PASS is truthful because it was independently accepted previously.

## Remaining integrity defects

### F1 — Repo-sync FILE-MANIFEST has one incorrect protected merge record

Both FILE-MANIFEST.json and the two copies of AUTHORITATIVE-RELEASE-MANIFEST-v5.1.json assert this record:

`class/AUTHORITATIVE-RELEASE-MANIFEST-v5.1.json`

- Declared: **59176 bytes**, SHA256 **056b7953d17d25b2a3423dbbafea22a89cd38e11a384803812765e2f5d8f9e1f**.
- Actual archived file: **59529 bytes**, SHA256 **d68d4a3c54b6abcc9f3f1e103efe5182a777f41030a96cd987507d433b41db10**.

All other183 declared records pass their archived byte/hash checks. A consumer honoring the manifest's integrity guards will reject this one file. The authoritative manifest also lists its own old hash inside itself; regenerating this self-reference repeatedly cannot produce a valid cryptographic fixed point.

**Fix:** exclude the authoritative manifest's own copies from its internal hash inventory (or explicitly mark them non-self-hashed). Freeze its final bytes first. Then generate FILE-MANIFEST externally against those frozen copies. Do not ask a manifest to certify its own SHA256. The source/authoritative alias is also currently outside FILE-MANIFEST's listed184 payloads; list it externally or explicitly designate it as a control-file exception.

### F2 — Embedded docs PACKAGE-MANIFEST still identifies the previous ZIP

Inside the **600856-byte** docs ZIP, PACKAGE-MANIFEST-v5.1.json still declares:

- `docsLabsZipBytes: 547901`
- `docsLabsZipSha256: f5f461784e5a1febe001dec42e6c71a1a7185cb9ddc585b6611e39b4c1eac7d8`

Those values identify the previous archive, not the reviewed one. The local/repo-sync copy and external AUTHORITATIVE manifest correctly say600856 /4e7d98..., so the internal and external copies conflict.

**Fix:** remove/null the containing-archive size/hash from metadata embedded within that same archive, with an explicit pointer to the detached authoritative release checksum. Do not embed an earlier archive's checksum as though it validates the current archive. Keep final archive hashes in a detached manifest generated after ZIP creation; avoid creating another self-hash cycle.

These are concrete checksum/guard failures, not demands to redesign the class or add new scope. P1/P2/P3 should not be rebuilt again.

## Other manifest/assets/guard checks — PASS

- All184 declared repo target paths are relative and traversal-free; none targets HTML/audio/volume/private-key/state/.git/.terraform data. Merge instructions and neverTouchGlobs continue to protect the CLI/Terraform/runtime trees.
- All64 actual embedded scene SVGs from the pinned HTML match the corresponding archived final assets byte-for-byte; canonical native art is not stale.
- Current map/title/clip assignments, license payloads, canonical diagram and clean/spoken transcripts match in both packages.
- External AUTHORITATIVE release fields correctly identify the pinned HTML, canonical drawio,335/215/120/26/276 counts,7795.372 seconds and actual docs ZIP600856/4e7d98... . Its defective self-record is isolated in F1.
- The refreshed BUILD-STATUS no longer claims the old368004-byte docs ZIP; its self-archive checksum fields are null, which is a sound approach to copy into the internal package manifest.
- No new class-content or rendering review was required. Earlier HTML acceptance, native-parser258/258 roundtrip acceptance,65-page/138-edge geometry checks,276 audio decodes, command/recovery tests and their honest limitations carry forward unchanged.

## Scope and outcome

No full130-minute playback, ASR, exact-word sync, GUI drawio import, live AWS deployment, Terraform execution or repository merge is claimed or was repeated. Only this report was written. Prior accepted HTML/canonical drawing remain usable; **do not rebuild them**.

**Next bounded action:** correct only manifest self-reference/order, repack the metadata-bearing ZIPs and refresh detached checksums. Final combined package PASS can then be based on the preserved earlier HTML/drawio acceptance plus these completed packaging checks.
