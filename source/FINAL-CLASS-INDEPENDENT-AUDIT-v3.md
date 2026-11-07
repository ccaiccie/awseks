# Independent acceptance audit — EKS class v3

**FAIL — C1/C2 still contain bounded teaching-state errors; C3 native artwork/editable parity is incomplete. C5/C6/C7 pass the checked acceptance criteria.**

Audit: November 7, 2026, approximately 12:15–12:22 PST. Exact master: `class/AWS-EKS-Masterclass-Novice-to-Expert-v3-YouTube-Edition.html`, **66,622,401 bytes**, SHA256 **b77a0e7d5e9d7bdfff8e5a1d7f95ccde341fc56804b35a42077889cfde8f9526**. Hash matched at the beginning and end; no master mutation observed. Actual payload: 338 scenes, 218 demos, 26 chapters, 277 embedded clips, 7,844.368 scheduled seconds (2:10:44.368). This audit uses actual v3 payloads and fresh headless captures, not old captions or v2 pictures.

Only this report was written into the source/class tree. Independent screenshots and recovery/reproduction fixtures are under `/tmp/`. No AWS, repository, publication or signed-in-browser actions.

## C1 — Distance/endpoint repair PASS; remaining semantic binding/order FAIL

**Verified repaired:** all 64 used paths have complete union coverage of their defined segments. Every one of the 218 demos was sampled at progress 0, .025, …, 1 at both 1080 and 930: **17,876 states**. Actual cumulative-distance state index agrees with the declared hopRange and token segment; first/last positions agree with the intended ports to the tested tolerance. Zero out-of-range states, visible token-circle/stroke intersections with tested actor/caption/header bounds, or hidden-away-from-processing samples. The old equal-index/distance bug is gone. Fresh connector checks also found no intersections with unrelated actor/caption/header rectangles at either height. These geometric checks do not certify semantic direction.

Remaining concrete mismatches:

1. **F03 status travels in the opposite direction to its explanation.** Actual scenes **s0029, s0042, s0094** say “Node reports status to API” but select `F03_sub2`, hopRange **[0,0] = api→node**. Fresh `s0029__p085__930.png` visibly has the token moving API→kubelet while the card says node→API. Bind the status explanation to **hop1 node→api**; retain a separately explained API→node watch/update exchange. Do not hide this with ownerlock. Root: generic arrival-biased selection in `scripts/v2/bind_stages.py:118–143,288–310` is not sufficient to identify a message's direction.

2. **F13 return is played out of order despite zero uncovered hops.** Consecutive actual stages are **s0178 [1,1] vpce→vpc**, then **s0179 [0,0] aws→vpce**, then **s0180 [2,2] vpc→pod**. The private route lookup is animated before the response has reached the endpoint. Fresh `s0178__p065__1080.png` and `s0179__p065__930.png` show this reversal in the actual course. Insert the missing aws→vpce delivery **before** the endpoint-subnet lookup; then complete vpc→pod. Root: terminal stages are appended after existing return stages at `bind_stages.py:315–333`. Assert chronological per-exchange coverage, not only set coverage. This was the one decreasing-index contiguous path group found in the chronological scan.

3. **The highlighted mechanism is not always the mechanism occurring.** `engine/graphics.js:25–26` maps every `session` to **Service DNAT**. Consequently actual F01 “Local SigV4 token signing + TLS,” F12 IGW→external terminal delivery, and F13 S3-prefix-list exchange highlight Service DNAT although none is performing Kubernetes Service DNAT. See `F01-native-admin-icon__1080.png`, `s0079__p085__1080.png`, `s0181__p065__930.png`. Use explicit per-stage mechanism metadata, or no active module for plain transport/completion; use VPC route lookup for the actual prefix-list decision. Keep Service DNAT exclusively for the illustrated service translation. This matters to the requested route-versus-DNAT-versus-IAM distinction.

## C2 — Old credential/NACL defects repaired; signed-app response tuple still FAIL

**Verified repaired:** F26 request segments all have forward roles and its reverse NACL stop carries 8080→49152; actual s0245/s0247 screenshots confirm allowed blue request versus red reverse drop. F22 actual s0116/s0283 explain HTTP403 on the existing TLS session. F23 s0124/s0287 explain CNI error events/no application packet. F14 s0150/s0151 and F15 s0156 now have genuine credential-response tuples and explanations distinct from application calls.

**Remaining:** the *subsequent signed application* return leg copies its outbound request's metadata:

- **s0153**, `F14_sub1 [1,1]`, actual **aws→pod**: BEFORE still **10.42.16.101:49002 → AWS API endpoint:443**; title still says signed application API **request**. Narration literally says “Hop aws→pod. Packet before: 10.42.16.101:49002 to AWS API endpoint:443”.
- **s0158**, `F15_sub1 [1,1]`, actual **aws→pod**: BEFORE still **10.42.16.101:49004 → AWS resource:443** and repeats the signed-call title.

Fresh `s0153__p085__1080.png` and `s0158__p085__930.png` show the server→Pod token and outbound tuple together. Keep s0152/s0157 as the signed requests. Give their response stages reverse **API:443→Pod:49002/49004** tuples and application-response wording; the server response is not another SDK request-signing action. Root: `bind_stages.py:341–366` copies the same signed request processing record into both subflow directions. Regenerate affected narration/transcripts and clips, not just captions.

## C3 — Native AWS improvement real; Kubernetes clipping and editable parity FAIL

The new drawio is **not** the old byte-identical box copy: it has 29 pages and genuine AWS4 resource stencils. HTML NACL/unspecified AWS API mappings and Internet/control topology bands are substantially improved. Preserve these improvements.

However:

- **Native Kubernetes artwork is visibly clipped to thin blue slivers.** Fresh **s0132** (F07) at 1080 shows slivers instead of Pod symbols on Client Pod A, Backend Pod B and the service/netfilter actor. The same defect is visible in the other reviewed Pod scenes at both heights. `build/icons.svg.json` entries `k8s_pod`, `k8s_service`, `k8s_deploy` set `viewBox="0 0 18.035334 17.500378"` while retained paths contain substantial **negative x** coordinates (e.g. x≈−15 through +1.6). The original coordinate translation/viewport has not been preserved. `build_scenes_icons.py:72–77` embeds these malformed viewports unchanged. Preserve original transforms/viewBox or normalize actual bounds before fitting the icon; do not crop the symbol to make a collision check pass.
- **Global ID-to-icon mapping remains semantically overbroad:** `build_scenes_icons.py:15–16` maps every client/runner to Pod. Actual F01 Admin laptop therefore receives the Pod artwork, as does F02's runner regardless of its actual deployment role. Use scenario/actor role overrides, not a global client==Pod rule. Fixing the viewport will otherwise expose the incorrect symbol more clearly.
- **Editable diagram lacks the very exchanges taught in HTML.** Exact `diagrams/EKS-Masterclass-v3-Lecture-and-Flow.drawio` contains only primary forward edges, no separate reverse/subordinate edges and no native Kubernetes symbols (Pod objects are generic rectangles). Actual XML examples: **F03 only client→api**, leaving scheduler/node/registry disconnected; **F14 only pod→agent→auth**, leaving the AWS API disconnected and omitting credentials/application exchanges; **F18 only pvc→sched**, leaving CSI/EC2/node disconnected; **F07 only a→proxy→vpc→b**, no reverse conntrack journey. The docs ZIP contains this exact same file. Add editable matching reverse/subflow pages or clearly separated connectors with actual ports and correct symbols. A few authentic AWS stencils do not establish parity with the delivered class. GUI import is not claimed.

## C4 — Full source fields preserved; narrow display regression

The prior character-slicing defect has not returned. However **s0181–s0184**, F13 S3-layer subexchange, overflow the middle bottom-band column at **both heights**. At1080 its clientHeight/scrollHeight is **292/343**; at930 **252/343**. `base.css:19` hides this overflow. Fresh `s0181__p065__930.png` visibly cuts the repeated STATE paragraph mid-sentence at the bottom; the right column is also a few pixels over at930. This is largely redundant text already present in DETAIL, not newly missing unique AWS guidance. Bounded fix: remove the redundant repeated STATE paragraph or pace complete fields, keeping complete DETAIL and the bottom-only band; do not shrink everything or reintroduce character slicing. This display defect is not the basis for claiming a new curriculum-depth failure.

## C5 — PASS for the checked command/material corrections

All actual command blocks pass `bash -n`; no literal backslash+n separators remain. Actual **s0327/s0328/s0329** are separate Terraform prerequisites, init/fmt/validate/plan, and apply/output scenes with real copyable newlines. Fresh settled s0328 at930 is readable. STATE_DIR initialization, 04-app-before06/07, and exact-STACK cleanup guards remain; settled **s0335** visibly shows guarded90→91→92, prior checkpoints and no-finalizer shortcut. **s0056** now distinguishes Deployment template/reference from live Pod environment and warns about image/tool availability. These are static/teaching checks, not successful AWS/Terraform execution.

### Damaged legacy source: impact explicitly bounded

`class/scripts/course_model.py` still fails Python parsing at **line198**, unterminated string literal. Do not describe the old pipeline as reproducible or use it for the next rebuild. But the active `scripts/v2/build_class_data_v3.py:9–10` reads preserved v2 data plus v3 bound stages, not this file. Executing that builder into a new auditor-owned temporary output tree reproduced the current pre-spoken scene data **exactly** (338 scenes). This independently bounds the legacy damage: it does not break the pinned standalone player or alter current student scripts. The distributed docs/labs archive does not include this broken builder. Document the authoritative replacement pipeline/deprecate or restore the legacy file before future source-driven rebuilds; no extra playback blocker is assigned solely for this internal maintenance issue.

## C6 — PASS: substantive expanded content retained

The v2-expanded lectures in Ch4/5/16/20/24 are retained: mechanisms and observations for configuration/probes/drain, managed-control-plane responsibility, TLS/health diagnostics, metrics/log/event causality, and Terraform prerequisites/pins/phase ownership/commands. Active v3 generation preserves these lecture records except the deliberate command/ConfigMap corrections. No arbitrary longer-duration requirement is being added. The class now schedules 2:10:44; this is not evidence of AWS runtime acceptance or repository implementation verification.

## C7 — PASS: recovery safety, current exports and usability

Independent tests using copied ZIPs and temporary destinations:

- Fresh directory containing only four part ZIPs and helper recovers the exact **66,622,401-byte master hash**.
- Existing identical destination succeeds without replacement/mtime change.
- Existing nonidentical sentinel is refused and remains unchanged.
- Corrupted last part fails without creating a trusted output or leaving partials; prior valid output remains intact.
- Docs/labs ZIP CRC passes; packaged drawio and both readable transcripts match current files byte-for-byte.

Part ZIP sizes: **13,260,963;14,001,328;13,994,764;7,399,775 bytes** — all below25MB. Full single ZIP is48,656,852 bytes, so use the documented parts/helper rather than pretending a single under25MB archive exists. The four-part workflow is now understandable and safe, not unexplained concatenation.

## Audio/player evidence and honest limits

All **277 embedded clips** fully decoded through ffmpeg. Embedded SHA256s and delivered MP3 bytes match. Every one of **338 clean/spoken scene mappings** matches the current narration plan and refreshed readable transcripts. That confirms artifact integrity, not acoustic pronunciation or semantic truth of the remaining wrong sentences.

Fresh offline headless fullscreen launch played audio; Space pause/resume, C tray and Stop worked. Stop paused media, returned launch and cleared frame/delay/watch/alarm handles; no application runtime exceptions in the main test. The helper relaxes autoplay restrictions. State/geometry samples were injected into actual rendered scenes, including progress endpoints/settling; they are not a continuous real-time listening test. A separate late diagnostic encountered an auditor-harness SVGRect serialization error after its two-height line checks; this was not a player exception or evidence of a class failure.

No full130-minute playback, ASR, exact spoken-word timing, every-frame manual inspection, user-browser certification, GUI drawio import, AWS deployment or Terraform/repository execution is claimed. Actual independent images were opened/read, including F03 direction, F14/F15 responses, F26 allowance/drop, F12 terminal, F13 return/S3, F07 artwork, Terraform and teardown. **No final PASS preview is endorsed while the bounded semantic/artifact defects above remain.**

**Next correction set:** fix F03 status binding; insert F13 return completion in physical order; give signed-app response legs response metadata/narration; stop generic session→Service-DNAT highlighting; normalize native K8s SVG coordinates and role mapping; genuinely complete editable reverse/subflow parity; remove duplicated overflowing STATE fields. Preserve the working cumulative-distance engine, terminal coverage, credential responses, NACL direction, command guards/depth and atomic recovery.
