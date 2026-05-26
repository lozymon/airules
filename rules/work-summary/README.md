# lozymon/work-summary

Always-on rule that ends every non-trivial task with a four-line summary block (Changed / Why / Verify / Next) so the user can skim what happened without reading the diff.

## Install

```bash
npx ruleshub install lozymon/work-summary --tool claude-code
```

## What it does

Injects guidance into every session telling the assistant to close any non-trivial task with this block:

```
**Changed:** <files touched — paths, optionally with line refs>
**Why:** <one sentence — motivation, not mechanics>
**Verify:** <one concrete command or manual step the user can run>
**Next:** <anything deferred, or "nothing">
```

The rule also defines when to _skip_ the block (pure Q&A, trivial one-line edits, read-only operations) so it doesn't pad short answers.

## When to use

- You want a consistent, scannable wrap-up after every task — no trigger word needed
- You review a lot of assistant output and want a fixed shape to skim

## When NOT to use

- You'd rather opt in per-task — install [`lozymon/recap`](https://ruleshub.dev/lozymon/recap) (slash-command skill) instead
- You already have a stricter CLAUDE.md that controls end-of-task formatting

## Related

- [`lozymon/recap`](https://ruleshub.dev/lozymon/recap) — on-demand version (same block, triggered by `/recap`)
- [`lozymon/handoff`](https://ruleshub.dev/lozymon/handoff) — heavier hand-off doc for switching off mid-work

## License

MIT
