# AuditedMistakes.md

The project's persistent mistake ledger. Every `auditor-pattern-match` pass reads this file first. Every confirmed recurring-pattern mistake gets appended here by `auditor-mistake-logger` — no other agent writes to this file.

**Append-only.** Never rewrite or delete an entry. If a pattern recurs, add a "Recurred: {date}" note to the existing entry.

## Entry schema

```markdown
## {YYYY-MM-DD} — {short title}

**Area:** {files/subsystem}
**What happened:** {the mistake, concretely}
**Caught by:** {auditor/council member/step}
**Fix applied:** {what resolved it this time}
**Pattern to watch for:** {what a future task should check to avoid repeating this}
```

---

<!-- Entries start below. This ledger is empty at template creation — that's expected for a new project. -->

## 2026-08-07 — Verified encoder settings instead of decoded pixels; green bleed survived three "fixes"

**Area:** `public/photos/portfolio/*.mp4`, video encode pipeline

**What happened:** Two clips (`IMG_4998`, `IMG_4999`) showed a green cast at loop start. Three consecutive fixes were shipped and each was declared done after confirming the *encoder settings* looked right — closed GOP, `has_b_frames=0`, CFR 30, `bt709` colour tags all verified via ffprobe. The glitch persisted every time because none of those was the cause. The actual cause was a camera sensor-warmup green band baked into the source footage from ~0.1s to ~0.8s. The 0.3s trim applied at the time started playback *inside* that band, so the output still opened on green frames. A correct-looking encode of bad frames is still bad frames.

**Caught by:** In-browser pixel measurement — seeking each `<video>`, drawing to a canvas, and counting green-dominant pixels via `getImageData`. Reported `IMG_4998` 23.8% green / `IMG_4999` 20.9% green while every ffprobe check was passing. Frame-by-frame scan of the sources then located the band precisely.

**Fix applied:** Re-encoded both clips starting at 1.0s, past the measured band. Confirmed by re-running the identical pixel measurement against the live site: both now 0.0% green, all 8 clips ~0%.

**Pattern to watch for:** Container metadata is not pixel content. When the complaint is about something *visible*, the verification must sample rendered output, not configuration. Related trap from the same session: a "all placeholders resolved" pass was reported after grepping for the exact strings the replacement used, so it inherited the fix's own blind spot and missed the `{{NAME — annotated}}` form. **A check that shares the fix's assumption cannot catch the fix being wrong** — verify through a different mechanism than the one that made the change. Also: seeking decodes frames even in a backgrounded tab where `requestAnimationFrame` is suspended, so canvas pixel sampling works when playback-based verification does not.

**Still open:** `IMG_4927` measures white% = 8.1% — the only clip with a nonzero white reading, unchanged across every fix. Not yet investigated; may be the reported "white block bleeding".
