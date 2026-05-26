# lozymon/recap

On-demand skill that produces a short, scannable summary of the work just done in a session — files changed, why, how to verify, and what's left.

## Install

```bash
npx ruleshub install lozymon/recap --tool claude-code
```

## What it does

After you say `/recap` (or "summarize what you did", "what changed?"), the assistant:

1. Reads `git status` / `git diff` to ground the summary in actual changes.
2. Cross-checks against the session transcript so nothing is invented or omitted.
3. Outputs a four-section block:
   - **Changed** — user-meaningful files (with line refs)
   - **Why** — motivation in 1–2 sentences
   - **Verify** — a concrete command or manual step
   - **Next** — deferred work, or "nothing"

Optimized for the user skimming in 15 seconds before opening the diff.

## When to use

- End of a non-trivial task, before review or commit
- After a multi-step operation (refactor, migration, dependency change)
- Any time you want a wrap-up without rereading the chat

## When NOT to use

- Pure Q&A or single-edit changes — the diff speaks for itself
- Mid-task — wait for a natural stopping point
- Hand-off to a different person/session — use [`lozymon/handoff`](https://ruleshub.dev/lozymon/handoff) instead

## Related

- [`lozymon/work-summary`](https://ruleshub.dev/lozymon/work-summary) — always-on rule version (appends the same block automatically, no trigger word)
- [`lozymon/handoff`](https://ruleshub.dev/lozymon/handoff) — heavier hand-off doc for switching off mid-work

## License

MIT
