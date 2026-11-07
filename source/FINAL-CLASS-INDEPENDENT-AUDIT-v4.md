# Independent acceptance audit — EKS class v4

**FAIL — most v3 corrections are real, but native Kubernetes artwork/editable geometry and two incorrect mechanism classifications remain. A previously missed F14 reply-port inconsistency also needs a small correction.**

Audit cut: November 7, 2026, approximately 12:35–12:41 PST. Exact master: `class/AWS-EKS-Masterclass-Novice-to-Expert-v4-YouTube-Edition.html`, **66,530,841 bytes**, SHA256 **ca48d8c98c91e4b446445c8901a19fbc9ccbbbbaec2cf87ff0dd88b1e3eac145**. Hash matched before/after. Actual embedded model: **335 scenes,215 demos,120 lectures,26 chapters,276 clips,7795.468 scheduled seconds (2:09:55.468)**. No observed master mutation. Only this report was written into the source/class tree; independent captures/test fixtures are under `/tmp/`.

## Material corrections still required

### M1 / C1 — Service DNAT is still falsely asserted in two control/identity stages

The generic session→Service-DNAT mapping is fixed: actual F01 signing/TLS, terminal transport and F13 S3 stages no longer activate that chip. However actual v4 still contains:

- **s0146 / F14**, `Association + service role trust + tags`: the bottom-right plane explicitly says **SERVICE VIP / KUBE-PROXY DNAT** and highlights **Service DNAT**, while processing EKS Auth/IAM association/trust/tags. Fresh proof: `/tmp/eks-class-independent-v4/s0146__p085__1080.png`.
- **s0263 / F19**, `Readiness and EndpointSlice inclusion`: the HPA/capacity control workflow again labels the readiness/controller update **Service VIP / kube-proxy DNAT**. No application Service packet is being translated in this stage. Fresh proof: `/tmp/eks-class-independent-v4/s0263__complete__930.png`.

Actual embedded events have `kind:"service"`; `scripts/v2/build_class_data_v3.py:55–56` labels that as DNAT, and `engine/graphics.js:25–31` displays it. **Fix:** assign explicit IAM/identity to F14 trust validation and control-plane readiness/EndpointSlice membership to F19. Do not infer Kubernetes Service DNAT from the words “service role” or “EndpointSlice”. Retain the correctly classified F06/F07/F08/NodePort translation stages. This is a mechanism error, not aesthetic highlighting.

### M2 / C3 — Kubernetes SVGs remain corrupted, not normalized native glyphs

F01 now has an appropriate laptop and F02 an EC2 runner: those role overrides pass. But Pod/Service glyphs still appear as disconnected blue fragments rather than the original symbols. Fresh actual images: `F07-native-pod__930.png`, `s0129__p085__1080.png`, `s0146__p085__1080.png` in `/tmp/eks-class-independent-v4/`.

Concrete independent browser measurement for embedded `k8s_pod`:

- declared viewBox: **−7.85234 −8.30443 23.06269 24.45388**;
- first path actual getBBox: **x=−15.207956,y=4.271027,width=16.834223,height=16.334127**;
- therefore substantial painted geometry is still outside the viewport on the left and bottom;
- all five retained paths have fill **#326CE5**.

The authoritative local native source `class/build/k8s-icons/pod.svg:55–99` contains essential parent transforms (lines59,62,79), blue background and **white** border/cube paths (lines74,83,90,97). The embedded `build/icons.svg.json` has flattened away those transforms and changed all fills to blue. Merely changing a viewBox cannot restore the symbol. **Fix:** embed the original native SVG hierarchy/transforms/fill styling, or correctly flatten the transforms while preserving colors. Then fit the genuine completed glyph, check computed painted bounds and rerun collision samples. Apply the same correction to Service/Deployment variants and their editable images. No topology redesign is needed.

### M3 / C3 — Drawio now has all exchanges, but still no matching editable connector geometry

`diagrams/EKS-Masterclass-v4-Lecture-and-Flow.drawio` is a genuine improvement:65 pages cover all64 paths used by the class, including reverse/subordinate exchanges. Ordered source/target pairs match every corresponding HTML path. Native AWS references and Kubernetes image objects now exist. The packaged copy matches the reviewed file.

However **all138 actual edges** have:

- **zero** waypoint arrays;
- **zero** explicit entry/exit port constraints;
- only `edgeStyle=orthogonalEdgeStyle;...` and an empty `<mxGeometry relative="1" as="geometry"/>`.

Example **F07_return/e0** connects b→vpc with no coordinates, while HTML explicitly routes through its separate bottom return lane. **F14_sub1/e0/e1** likewise have no explicit lanes or ports; editor auto-routing decides the request/reply geometry. Decorative node-port circles are not connected constraints. F02's editable EC2 actor is an icon-only78×78 shape at(121,280), not the HTML's matching compound card/icon/label arrangement. Thus edge-pair parity is not layout/port/waypoint parity.

**Fix:** export canonical segment waypoints plus explicit source/target ports into real mxGeometry/edge constraints; preserve the HTML compound actor geometry, captions and native artwork. Do not rely on editor auto-routing or a zero-count topology-only parity report (`build/drawio-parity-v4.json`) as a geometry certificate. Check the actual exported XML arrays/constraints against HTML endpoints/intermediate points. GUI import remains untested here.

### M4 / C2 — Previously missed F14 credential reply uses a different connection port

This is **not a new v4 regression**, but a concrete inconsistency missed in earlier acceptance checks:

- **s0145** request: `10.42.16.10:49001 → eks-auth regional endpoint:443 TCP`.
- **s0147** response, described/narrated as the existing exchange: `eks-auth regional endpoint:443 → 10.42.16.10:49100 TCP`.

That reply does not reverse the illustrated request tuple. `scripts/v2/bind_stages.py:178` hardcodes49100. **Fix:** use **49001** for the illustrated response destination port (or consistently change both ends of the same exchange). Preserve the separate agent→Pod169.254.170.23:80→Pod:49000 connection. Regenerate the affected response clip/transcripts because the current narration explicitly speaks49100. The newly corrected *application* replies s0150/s0155 are accurate and should not be reverted.

## Verified v3 repairs and preserved PASS criteria

### C1 — Corrected direction/order and animation engine PASS

- F03 has explicit **watch api→node hop0**, then **status node→api hop1**: actual s0034/s0035, s0046/s0047, s0097/s0098. Fresh opened s0034/s0035 screenshots agree with direction, context and token movement.
- F13 actual **s0179→s0180→s0181** now covers aws→vpce→vpc→Pod in **0→1→2** order; no decreasing-hop contiguous path group remains in the chronological scan. Actual screenshots s0179/s0180/s0181 were captured at both heights.
- All64 used paths have complete defined-segment coverage. All215 demos were freshly rendered at **1080 and930**,41 progress positions including0/1: **17,630 state samples**. Zero raw out-of-range hop states, metadata/actual-hop disagreement, endpoint-position errors, tested visible-circle+stroke intersections with actor/caption/header bounds, or hidden-away-from-processing samples. Fresh connector checks found no intersections with unrelated actor/caption/header rectangles. Source/destination borders are not treated as unrelated obstacles; all token clearance tests include the full actor bounds.
- These are real rendered-state tests, not merely manifest counts; geometry does not excuse M1–M4's semantic/artifact defects.

### C2 — New application replies, allowance/drop and error semantics PASS, except M4

Actual **s0150(F14)** now carries `AWS API endpoint:443→10.42.16.101:49002`; **s0155(F15)** carries `AWS resource:443→10.42.16.101:49004`. The new clean/spoken text calls these server application responses, not repeated signing actions or credential delivery. Actual images show aws→Pod movement with reverse tuples and no false Service-DNAT highlight. Clip/plan/export hashes match the new text (audio verification below). Their embedded MP3 hashes also differ from the corresponding old v3 response clips; these are not merely relabeled old audio. The new F03 watch/status MP3 hashes likewise differ from the old combined descriptions.

Credential delivery remains separate. F26 allowed forward/denied return roles and reverse8080→49152 tuples remain; HTTP403/CNI failure response teaching is retained. No live AWS correctness claim follows.

### C4 — Unique content retained; prior large clipping fixed

All120 lecture titles, clean narration and visual payloads match v3 **exactly**. The215-vs218 demo difference is **three removed redundant/wrongly bound F03 status scenes**, one per F03 occurrence—not STATE-row removal. Explicit watch/status pairs now teach those messages. The276-vs277 clip count is consistent with the revised/deduplicated narration model. Readiness/EndpointSlice/controller and separate registry-byte mechanisms remain elsewhere in actual lessons; no chapter or lab was removed.

F13 S3 subflow s0175–s0178 retains complete DETAIL, including ordinary CNI SNAT, managed-S3-prefix-list winner, no ENI/SG on a gateway endpoint, endpoint/bucket/IAM policy and node-role image pulls. Redundant STATE copies are gone. Fresh s0175 at930 shows the complete middle paragraph; no unique sentence is hidden.

Full335-scene DOM sweep at both heights found no substantial context or command clipping/bottom-band overlap. Four F13 right columns report only **3px** scroll-metric excess at930; the opened screenshot retains complete final wording. One lecture s0199 .lv reports6px excess, but its independently opened settled930 screenshot visibly includes both full command blocks and the complete warning. These small metrics are **not** promoted to material blockers. The former51/91px clipped STATE paragraph is repaired.

### C5/C6 — Commands/guards and depth PASS within static scope

All33 actual command blocks pass Bash syntax checks and contain real newlines, not literal backslash+n separators. Terraform remains three paced scenes. Actual s0199 visibly shows parent LAB_ROOT/STATE_DIR initialization and namespace-first04-app; s0332 retains guarded staged90→91→92 cleanup. The ConfigMap/template-versus-process correction and all expanded Ch4/5/16/20/24 lecture content are unchanged. No AWS/Terraform execution or practice-repo verification occurred.

Both deprecated legacy source files are now explicit, syntactically valid shims; `scripts/course_model.py:7–16` names the authoritative v4 pipeline and preserved inputs. The top-level README lists correct artifact/recovery information but does **not** yet repeat/link that pipeline. Adding the pipeline link is a documentation follow-up, not an additional release blocker. No full source-to-audio rebuild was performed by this audit.

### C7 — Recovery/package/transcripts PASS

Independent temporary tests using copied part ZIPs/helper:

- fresh ZIP-only recovery produces exactly66,530,841 bytes and the pinned master SHA;
- identical destination is preserved without mtime change;
- nonidentical sentinel is refused and left unchanged;
- corrupt part fails atomically, leaves no trusted output/partial and preserves the earlier valid output;
- docs ZIP CRC passes; current drawio and clean/spoken transcripts are byte-identical to packaged copies;21 shell scripts are included.

Four ZIP sizes: **13,269,568;13,989,806;14,008,276;7,331,714 bytes**, all below25MB. Recovery fixture: `/tmp/eks-v4-independent-recovery-pl0rz442/`.

## Audio/player evidence and honest limits

All **276 embedded clips** fully decoded with ffmpeg. Embedded SHA256s and delivered MP3 byte identities pass. All **335 clean/spoken mappings** match the current narration plan and readable transcripts exactly. This is artifact/text integrity, not ASR, acoustic/pronunciation approval or proof that a technically wrong sentence is true.

The exact master was genuinely launched fullscreen in headless Chrome; audio time advanced. Space pause/resume and C-tray Stop worked; Stop paused media, returned launch and cleared frame/delay/watch/alarm handles. No application exceptions were logged in the main test. The helper relaxes autoplay restrictions. Progress matrices and settled snapshots are injected-state sampling, not uninterrupted real-time playback.

Actual fresh images were opened/read for watch/status, application responses, F14/F19 mechanism defects, normalized-icon failure, laptop/runner roles, S3 context and complete command setup. No full130-minute listening/playback, exact spoken-word synchronization, ASR, every-frame/manual review of every scene, GUI drawio import, user-device/browser certification, AWS deployment or repository action is claimed.

**No final PASS preview is endorsed while M1–M4 remain.** Bounded correction set: correct two mechanism kinds; restore original K8s SVG transforms/colors; export real editable ports/waypoints/compound geometry; reverse F14's node-auth reply to port49001 and regenerate its affected narration/export. Preserve all independently verified repairs above.
