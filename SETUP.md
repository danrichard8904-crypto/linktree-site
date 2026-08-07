# SETUP.md — fill in the blanks for a new project

Do this once, right after cloning the template into a new project. ~20-30 min total.

## 1. Global find-and-replace (~5 min)

Replace these placeholders across every file (`CLAUDE.md`, `workflow.md`, `.claude/**`):

| Placeholder | Replace with | Example |
|---|---|---|
| `Reppstory Link Tree` | your project's name | `RecipeBox` |
| `Personal link tree and hair portfolio for a booth-renting barber/stylist` | one sentence, what it does | `A recipe manager with meal planning` |
| `Astro static site, deployed to GitHub Pages via the gh-pages branch` | your stack | `Next.js / Supabase / Vercel` |
| `claude-opus-4-8` | model for coordinator/council/research | `claude-opus-4-7` |
| `claude-sonnet-4-6` | model for execution/most audits | `claude-sonnet-4-6` |
| `claude-haiku-4-5-20251001` | model for lint/dead-code/mistake-logger | `claude-haiku-4-5-20251001` |
| `the gh-pages deploy branch, astro.config.mjs base path, and public/photos media` | what `/quick` must never touch | `auth, payments, migrations` |
| `page` | what a "domain unit" means here | `feature` (app) or `service` (backend) |

Not sure on model tiers yet? Default: strongest model you have for Orchestrator, a strong-but-cheaper model for Execution, cheapest for Mechanical. See `workflow.md §0` for the reasoning.

## 2. Define your domain units (~5-10 min)

Open `workflow.md §3.3`. List the 2-6 vertical slices of your app that can each be owned by one agent without stepping on another's files.

- Tiny app (a weekend project): 1-2 units is fine — e.g. `frontend`, `backend`. You may not need domain agents at all; the subsystem exec agents (§3.4) may be enough.
- Medium app: one unit per feature area — e.g. `auth`, `dashboard`, `billing`.
- Don't over-split. A unit with nothing that will ever conflict with another unit doesn't need to be separate.

For each unit, create an agent file from the template:
```
cp .claude/agents/_TEMPLATE-domain.md .claude/agents/agent-{{unit}}.md
```
Fill in its `Owns:` scope and description. Delete `_TEMPLATE-domain.md` usage note comments once you're done, or leave the template files in place for the next unit you add later.

## 3. Define your execution agents (~5 min)

Look at `.claude/agents/EXAMPLE-exec-ui.md` and `.claude/agents/EXAMPLE-research-code.md` — these show a filled-in instance. For a typical app you need at minimum:

- `exec-code` / `exec-ui` (frontend/backend split) — or `exec-{{subsystem}}` per layer your stack actually has
- `research-code` / `research-ui` — matching research counterparts

Copy from `_TEMPLATE-exec.md` / `_TEMPLATE-research.md` for anything beyond the two examples. Rename `EXAMPLE-*.md` files to drop the `EXAMPLE-` prefix once you've adapted them, or delete and recreate from template.

## 4. Pick your verify method (~5 min)

What does "actually works" mean for this project? Fill in `_TEMPLATE-verify.md` → `.claude/agents/verify-{{runtime}}.md`:

- Web app → browser automation (Playwright, or the `claude-in-chrome` MCP tools)
- API/backend-only → a real HTTP call against a running instance
- CLI tool → an actual invocation with real args, checking real output
- Data pipeline → run it against a small real/fixture dataset, check the output

## 5. Tune the council lenses (~5 min)

`.claude/council/01..05-*.md` ship with generic starter lenses (Architect, Security, Quality, Product, Ops). Read each and fill in the `[FILL: ...]` checklist items with your project's actual invariants — e.g. security's "name yours" line, ops's migration conventions.

If a lens genuinely doesn't apply (e.g. no "Ops" risk for a static site with no deploy pipeline), you can drop it — 4 members is fine. Keep the ratification math in `workflow.md §4` consistent with however many you end up with.

## 6. Wire up your project's real commands (~5 min)

- `.claude/agents/auditor-lint.md` — fill in your real typecheck/lint commands.
- `.claude/settings.json` → `permissions.allow` — add your project's actual `npm run <script>` / equivalent commands so Claude Code doesn't prompt for permission on every routine command.
- `coordinator.md` → `Project-Wide Rules` — the handful of "never bypass this" rules specific to your stack.

## 7. Decide your default ceremony level

Read `workflow.md §6`. For a brand-new simple app, it's fine to lean on `/quick` heavily at first and only invoke the full pipeline once there's something real to protect (users, data, a deploy). Don't force full council-and-audit ceremony on day one of an empty repo — that's solving a problem you don't have yet.

## 8. Delete what you don't need

This template intentionally ships more scaffolding than a brand-new project needs (18-agent LLM-workflow-style ceremony is overkill here — see `workflow.md §6` for when to scale up). It's fine, even expected, to:

- Delete council lenses that don't apply.
- Skip domain agents entirely for a 1-2 person tiny project — subsystem exec agents alone are enough.
- Leave `_TEMPLATE-*.md` and `EXAMPLE-*.md` files in `.claude/agents/` as reference even after you've built your real roster — they don't get invoked, they're just scaffolding.

## Done

Once the above is filled in, delete this file's "do this once" framing isn't required — SETUP.md can stay in the repo as documentation of what was customized and why, or be deleted. Your call.
