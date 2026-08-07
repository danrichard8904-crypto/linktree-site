# Reppstory Link Tree — CLAUDE.md

## BEFORE ANY TASK

**Read `./workflow.md` before doing ANYTHING.** Every task follows the pipeline defined there.

## Fill this in once, at project start

- **Project name:** Reppstory Link Tree
- **What it does (1-2 sentences):** Personal link tree and hair portfolio for a booth-renting barber/stylist
- **Stack:** Astro static site, deployed to GitHub Pages via the gh-pages branch
- **Where mistakes get logged:** `AuditedMistakes.md` (already wired up, don't move it)
- **Model tiers** (see `workflow.md` §0 for the reasoning):
  - Coordinator / Council / Research: claude-opus-4-8
  - Execution / Audit: claude-sonnet-4-6
  - Mechanical audits only (lint, dead-code): claude-haiku-4-5-20251001

## Do not skip

1. `workflow.md` before any task.
2. `AuditedMistakes.md` before touching an area that's bitten you before.
3. Hooks in `.claude/hooks/` run automatically — don't bypass with `--no-verify` equivalents.

## Escape hatch

Single-file change, bug fix under ~5 min, no new deps, no cross-feature impact → `/quick [task]`. See `workflow.md` §2 for the exact definition. Default to the full pipeline; only use `/quick` when the task genuinely fits.
