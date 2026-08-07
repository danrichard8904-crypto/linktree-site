# Reppstory Link Tree — workflow.md

## BEFORE ANY TASK

**Read `./workflow.md` before doing ANYTHING.** This file is mandatory. Every task follows the pipeline defined here.

---

## 0. Model tiers

Assign models by what the work actually requires, not uniformly:

| Tier | Use for | Suggested model |
|---|---|---|
| Orchestrator | Coordinator, Council, Research/Blueprint — cross-cutting judgment calls | claude-opus-4-8 |
| Execution | exec-* agents, most auditors, verify agents — bounded, well-specified work | claude-sonnet-4-6 |
| Mechanical | Lint, dead-code, formatting-only auditors — no judgment required | claude-haiku-4-5-20251001 |

**Why tier at all:** orchestration and cross-feature judgment calls are where a stronger model earns its cost; lint/dead-code checks don't need it. Getting this wrong in either direction either wastes budget or under-powers the decisions that actually matter.

---

## 1. Core Protocol

```
/quick [task] → EXECUTE (bypass) → AUDIT (lint only)
        ↓ OR
PLAN → BRAINSTORM (optional) → BLUEPRINT → COUNCIL → RESEARCH → EXECUTE → AUDIT → VERIFY
```

Every task follows this sequence unless `/quick` is invoked.

- **Brainstorm** (optional): use when the task itself is underspecified — "what should this even do." Skip it when the task is already clear.
- **Blueprint**: a short written plan — what changes, which files, what the acceptance criteria are. Council reviews the blueprint, not the code.
- **Council**: independent lenses ratify or reject the blueprint before any code is written. See §4.
- **Research**: gathers the specific facts execution needs (existing patterns, schema, API shape) so exec agents aren't guessing.
- **Execute**: one agent per subsystem touched. See §5.
- **Audit**: parallel, one audit type per agent. See §6.
- **Verify**: proves the change actually works — not "the code looks right," but an observed run.

---

## 2. Quick Task Escape Hatch

**Trigger:** user types `/quick [task]`

**Definition — a quick task is:**
- Single-file change, OR
- Bug fix under ~5 minutes, AND
- No new features, no new dependencies, no cross-page impact

**Allowed with `/quick`:** fix a type error, add error handling to one function, update a comment, change one style rule.

**NOT allowed with `/quick`:** new feature implementation, multi-file refactors, anything touching the gh-pages deploy branch, astro.config.mjs base path, and public/photos media, anything crossing a domain-unit boundary.

**Protocol:** execute directly → run the mechanical/lint auditor → done. No full audit, no council.

---

## 3. Agent Roster

Full spec per agent lives in `.claude/agents/`. This table lists roles and triggers only — load the spec file when dispatching.

### 3.1 Coordinator

| Role | ID | File | Purpose |
|---|---|---|---|
| Coordinator | `coordinator` | `.claude/agents/coordinator.md` | Orchestrates all agents, owns blast radius, resolves cross-domain conflicts |

### 3.2 Research Agents

Fill in per project — these gather facts before execution. Starter set (delete what you don't need, add what you do):

| Role | ID | File | Purpose |
|---|---|---|---|
| Research — Code | `research-code` | `.claude/agents/research-code.md` | Existing backend patterns, data flow, API wiring |
| Research — UI | `research-ui` | `.claude/agents/research-ui.md` | Component structure, design tokens, layout conventions |
| Research — {{DOMAIN}} | `research-{{domain}}` | `.claude/agents/research-{{domain}}.md` | {{what it gathers}} |

### 3.3 Domain Agents — [FILL: define your domain units]

**A domain unit is a slice of the project one agent can own end-to-end without stepping on another agent's files.** For a simple app this might be 2-3 units (e.g. `frontend`, `backend`, `data`); for a bigger app, more (e.g. one per feature area). Each agent owns its unit exclusively — if a change's blast radius crosses into another unit's files, stop, report to coordinator, wait for coordination.

| Role | ID | File | Domain |
|---|---|---|---|
| {{Domain 1}} | `agent-{{domain1}}` | `.claude/agents/agent-{{domain1}}.md` | {{what it owns}} |
| {{Domain 2}} | `agent-{{domain2}}` | `.claude/agents/agent-{{domain2}}.md` | {{what it owns}} |

### 3.4 Execution Agents

**One execution agent per subsystem per task. Never combine subsystems into one agent regardless of task size.**

| Role | ID | File | Owns |
|---|---|---|---|
| Execute — Code | `exec-code` | `.claude/agents/exec-code.md` | Backend/business-logic files |
| Execute — UI | `exec-ui` | `.claude/agents/exec-ui.md` | Frontend files only |
| Execute — {{Infra/Server}} | `exec-{{infra}}` | `.claude/agents/exec-{{infra}}.md` | {{routes, infra-as-code, etc.}} |

If a task spans N subsystems, dispatch N execution agents. Frontend + backend = 2 agents minimum.

### 3.5 Auditor Agents

**One audit type per agent. Always run in parallel. Never combine audit types into one agent.**

A generic starter set — keep the ones that apply, delete the rest, add project-specific ones (e.g. an RLS auditor, a Stripe-chain auditor) as your stack demands:

| # | ID | File | Purpose | Redundant when... |
|---|---|---|---|---|
| 0 | `auditor-intent` | `.claude/agents/auditor-intent.md` | Blueprint→Execution scope-drift check | `/quick` tasks only |
| 1 | `auditor-graph` | `.claude/agents/auditor-graph.md` | Structural/dependency audit | Never — mandatory |
| 2 | `auditor-dead-code` | `.claude/agents/auditor-dead-code.md` | Dead code, unused imports | No imports removed, no files deleted |
| 3 | `auditor-pattern-match` | `.claude/agents/auditor-pattern-match.md` | `AuditedMistakes.md` recurrence check | First time in this area |
| 4 | `auditor-new-mistakes` | `.claude/agents/auditor-new-mistakes.md` | New mistakes not yet in the log | Always runs |
| 5 | `auditor-mistake-logger` | `.claude/agents/auditor-mistake-logger.md` | Appends confirmed mistakes to the log | No mistakes found |
| 6 | `auditor-lint` | `.claude/agents/auditor-lint.md` | Type-check + lint | Always runs |
| 7 | `auditor-security` | `.claude/agents/auditor-security.md` | Auth, sanitization, secret/env leaks | Nothing touching auth/data access |
| 8 | `auditor-cross-domain` | `.claude/agents/auditor-cross-domain.md` | Blast radius + conflict detection across domain units | Single isolated file |

### 3.6 Verify Agents

| Role | ID | File | Purpose |
|---|---|---|---|
| Verify — {{Runtime}} | `verify-{{runtime}}` | `.claude/agents/verify-{{runtime}}.md` | Observed run proving the change works (browser automation, API call, CLI run — whatever "actually working" means for this project) |

### 3.7 Agent Scaling via Blast Radius

**Minimum 2 agents on every full-pipeline task. A single agent is a protocol violation** (it means no independent check exists on the work).

| Blast radius result | Minimum agents |
|---|---|
| Risk score < 40, < 3 dependent files | 2 agents (1 exec + `auditor-graph`) |
| Risk score 40-70, 3-8 dependent files | 3 agents minimum |
| Risk score > 70, 8+ dependent files | 4+ agents, parallel waves mandatory |
| Touches 2+ domain units | 1 execution agent per unit, always |

Blast radius is a judgment call the coordinator makes from the blueprint — file count touched, whether shared/sensitive systems are involved, whether the change is additive vs. structural.

### 3.8 Cross-Agent Communication Protocol

1. Every agent produces a short report on completion (what changed, what it touched, any concerns).
2. The next agent in sequence reads the previous agent's report before starting.
3. If an agent detects its change's blast radius crosses into another domain unit: stop, report it, notify coordinator. Do not resume until coordinator confirms the conflict is resolved.
4. All coordination decisions get logged in the blueprint for operator visibility.

### 3.9 Worktree Restriction

Sub-agents operate on files in the main working directory — never in git worktrees, unless a task explicitly calls for isolated parallel edits and the coordinator has set one up deliberately.

---

## 4. Council

**Purpose:** independent lenses ratify or reject the blueprint before code gets written. Catches design problems while they're still cheap to fix.

Roster and convening protocol: `.claude/council/README.md`. Starter lenses (swap for what actually matters to your project):

| # | Lens | Watches for |
|---|---|---|
| 1 | Architect | Structural soundness, circular deps, layering violations |
| 2 | Security | Auth bypass, secret exposure, unsanitized input |
| 3 | Quality | Test coverage, `AuditedMistakes.md` recurrence |
| 4 | Product | Acceptance criteria, scope creep |
| 5 | Ops | Deploy/migration safety, rollback path |

**Ratification rule (starter — tune to taste):**
- 4-5/5 RATIFY (with or without required changes) → proceed
- Any RATIFY_WITH_CHANGES → apply the changes before dispatching execution
- 3+ REJECT → abort, report blockers to operator, do not proceed without re-submission
- Exact split (e.g. 3 ratify / 2 reject on a 5-member council) → **dead zone, not a pass** — escalate to operator

Skip council entirely for `/quick` tasks and for genuinely small full-pipeline tasks where you've decided the ceremony isn't worth it — but make that a deliberate choice, not a default.

---

## 5. The Mistake Ledger

`AuditedMistakes.md` at the repo root. Every auditor that finds a real, confirmed mistake appends an entry. Every research/audit pass that touches a previously-bitten area reads this file first (`auditor-pattern-match`'s whole job).

This is what makes the pipeline **improve over time** instead of re-discovering the same bug in every task. Don't let it go stale — a mistake that isn't logged gets re-made.

---

## 6. When to scale this down (or up)

This pipeline is a default, not a law:

- **Scale down** for a genuinely tiny project (one file, no users yet, throwaway prototype) — use `/quick` for almost everything, skip council, keep the mistake ledger.
- **Scale up** toward a full council-plus-ledger-plus-retrospective framework (see the reference in `SETUP.md`) once the system is shared, sensitive, or has already burned you more than once in the same way — that's the signal a retrospective layer earns its keep, not project age alone.

Match the ceremony to the actual cost of getting it wrong.
