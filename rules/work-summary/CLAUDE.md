# Work Summary

When you finish a non-trivial task, end your final message with a brief summary block so the user can skim what happened without reading the whole transcript or diff.

## Format

End the message with exactly this four-line block, in this order:

```
**Changed:** <files touched — paths, optionally with line refs>
**Why:** <one sentence — motivation, not mechanics>
**Verify:** <one concrete command or manual step the user can run>
**Next:** <anything deferred, or "nothing">
```

Example:

```
**Changed:** src/auth/reset.ts:14-58, tests/auth/reset.spec.ts (new)
**Why:** Wire up password-reset email flow so users locked out of accounts can self-serve.
**Verify:** `npm test -- reset.spec.ts`
**Next:** Rate-limiting on the /reset endpoint is still TODO.
```

## When to include the block

- After writing or editing code, configuration, or content files.
- After running a multi-step operation (migration, refactor, dependency change).
- After investigating something where the user wants action items, not just findings.

## When to skip the block

- Pure Q&A: the user asked a question and you answered in prose.
- Single-line trivial edits where the diff is self-evident (rename one variable, fix one typo).
- Read-only operations (showing a file, summarizing the codebase) where there's nothing to "verify" or "next".

If in doubt, include the block — it's cheap.

## Rules for each line

- **Changed** — list user-meaningful files only. Skip whitespace-only edits and auto-import reordering. If >10 files, group by area (`auth/* — 4 files`).
- **Why** — the motivation in plain language. Don't restate the diff.
- **Verify** — must be something the user can actually do _right now_. "Run the tests" is too vague; name the test file or the manual step.
- **Next** — be honest. If something was skipped, say so concretely ("rate-limiting still TODO"), not vaguely ("further polish needed"). Write "nothing" if the task is complete.

## Honesty rules

- Don't claim tests pass if you didn't run them. Say "not run" in **Verify**.
- Don't list files in **Changed** that weren't actually modified (check `git status` / `git diff` if uncertain).
- Don't pad **Next** with imaginary follow-ups to look thorough — if it's done, say "nothing".
