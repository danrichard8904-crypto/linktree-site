---
name: council-roster
description: Council member roster, model, spec paths, and convening protocol. Required reading before any council convene.
---

# Council Roster

All members run on `claude-opus-4-8` and vote in parallel. Each reads only its own spec file plus the Blueprint and blast-radius inputs — keep them independent, that's what makes the ratification signal meaningful.

| # | ID | Spec File | Lens |
|---|---|---|---|
| 1 | `council-architect` | `.claude/council/01-architect.md` | Structural soundness, circular deps, layering violations |
| 2 | `council-security` | `.claude/council/02-security.md` | Auth bypass, secret exposure, unsanitized input |
| 3 | `council-quality` | `.claude/council/03-quality.md` | Test coverage, `AuditedMistakes.md` recurrence |
| 4 | `council-product` | `.claude/council/04-product.md` | Acceptance criteria, scope creep |
| 5 | `council-ops` | `.claude/council/05-ops.md` | Migration/deploy safety, rollback path |

[FILL: swap, rename, add, or remove lenses to match what actually matters for this project. A content site might not need a "migration safety" lens; a data pipeline might want a "cost/quota" lens instead of "product".]

## Convening Protocol

1. Coordinator writes `task-bus.md` with the current blueprint path and blast-radius results.
2. Dispatch all council members in parallel. Pass each: the Blueprint file path, the blast-radius output, the task-bus.md path.
3. Wait for all verdicts.
4. Apply ratification rules from `workflow.md` §4.

## Vote Format Reference

Each council member emits:
```yaml
council: {member-id}
model: claude-opus-4-8
verdict: RATIFY | RATIFY_WITH_CHANGES | REJECT
findings: [...]
required_changes: [...]
risk_level: low | medium | high | critical
```
