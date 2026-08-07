# /workflow

Invoke the full project workflow. Runs Blueprint → Council → Research → Execute → Audit → Verify → Complete on the task you describe.

## Bootstrap (every invocation, no exceptions)

1. Read `./workflow.md` — full pipeline rules
2. Read `./CLAUDE.md` — project constraints
3. Read `./AuditedMistakes.md` — current mistake ledger
4. Read `.claude/agents/coordinator.md` — coordinator protocol

## Invocation Steps

### `/quick` escape hatch (check FIRST before any other step)

If the invocation args include `/quick`, or the task is obviously eligible per `workflow.md §2`:

- **Eligibility check:** single-file change, bug fix under ~5 min, no new deps, no cross-domain-unit impact, doesn't touch `the gh-pages deploy branch, astro.config.mjs base path, and public/photos media`. If not eligible, fall through to the full pipeline.
- **Quick path:** skip Blueprint, skip Council, skip Research, skip the `auditor-intent` gate.
- **Execute:** spawn the exec agent matching the file path (see the ambiguous-file rule in `coordinator.md`). If ambiguous, fall through to full pipeline.
- **Audit:** `auditor-lint` always; `auditor-security` if the file touches auth/data-access/an external API.
- **Complete:** git commit (never to main), emit completion frontmatter below.
- **Do not proceed to the full pipeline steps below.**

---

### Step 1: Identify the task

Use the task as described by the operator. [FILL: if this project pulls tasks from a tracker instead of an inline description, describe the fetch step here — e.g. "fetch the next 'Not Started' card from {{tracker}}, sorted by priority, mark In Progress."]

### Step 2: Assign coordinator

Spawn `coordinator` (model: `claude-opus-4-8`) with the task description, any acceptance criteria, and the current `AuditedMistakes.md` content.

The coordinator self-reads `workflow.md` on task receipt per `coordinator.md §Mandatory Reads` — this command does not paste workflow.md's text directly.

### Step 3: Full pipeline

Coordinator runs the pipeline per `workflow.md`:

1. **Blueprint** → `.planning/blueprints/{phase}-{NN}-BLUEPRINT.md`
2. **Council** → members in parallel per `.claude/council/README.md`; apply the ratification rule from `workflow.md §4`
3. **Research** → relevant research agents in parallel
4. **Intent Gate** → `auditor-intent` must return `status: pass`
5. **Execute** → exec/domain agents, one per subsystem/domain unit
6. **Audit** → auditor agents in parallel per `workflow.md §3.7` blast-radius scaling
7. **Verify** → the verify agent(s) matching what changed
8. **Complete** → commit, emit completion frontmatter

### Step 4: Completion

In this exact order:
1. `git commit` on the active feature branch — **never on main**. Capture the short commit hash.
2. [FILL: any tracker sync — mark done, append summary, using the hash from step 1]
3. Emit completion frontmatter (below).
4. Report to operator (< 150 words).

### Completion Frontmatter

```yaml
workflow_result:
  task: "{task title}"
  commit_hash: "{short hash}"
  date: "{YYYY-MM-DD}"
  path: full | quick
  agents_dispatched: {count}
  mistakes_logged: true | false
  status: success | aborted
  abort_reason: null | "{reason if aborted}"
```

## Hard Rules

- Never start execution without an approved Blueprint AND council ratification (unless `/quick`).
- Coordinator stays on its assigned model the entire run — never downgrade mid-task.
- [FILL: your project-wide invariants from `workflow.md`'s Coordinator §Project-Wide Rules — repeat them here so they're enforced at dispatch time too]
- Never push directly to main — feature branch only; verify branch before every `git commit` in Completion phase.
- Council threshold dead zone (exact split, e.g. 3/5 ratify) is NOT a pass — escalate to operator.
- Never operate inside a git worktree unless the coordinator deliberately set one up — see `workflow.md §3.9`.

## Agent Roster

See `workflow.md §3` for the full roster table and `.claude/council/README.md` for council members. Keep this list in sync as you add/remove agents for this project.
