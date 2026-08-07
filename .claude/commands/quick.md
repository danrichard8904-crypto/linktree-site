# /quick

The escape hatch. Use for a task that's genuinely small — see the eligibility test below before invoking this instead of `/workflow`.

## Eligibility (workflow.md §2)

- Single-file change, OR bug fix under ~5 minutes, AND
- No new features, no new dependencies, no cross-domain-unit impact, AND
- Doesn't touch `the gh-pages deploy branch, astro.config.mjs base path, and public/photos media`

If any condition fails, don't use `/quick` — run `/workflow` instead. Guessing wrong here just means the mistake gets caught late (a missing audit) rather than early (a rejected council vote), so default to `/workflow` when unsure.

## Protocol

1. Read `./AuditedMistakes.md` — even a quick task should check for a known-bad pattern in the file it's touching.
2. Dispatch one exec agent for the single file in scope — match by path per `coordinator.md`'s ambiguous-file rule. If ambiguous, stop and fall through to `/workflow`.
3. Run `auditor-lint` (always). Run `auditor-security` if the file touches auth/data-access/an external API surface.
4. Pass → commit (never to main) → done. Fail → same exec agent, one retry with the failure as a targeted brief. Fails again → escalate to operator, do not loop.

## Output

```yaml
workflow_result:
  task: "{task title}"
  commit_hash: "{short hash}"
  path: quick
  status: success | aborted
  abort_reason: null | "{reason if aborted}"
```
