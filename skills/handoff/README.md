# lozymon/handoff

On-demand skill that produces a self-contained handoff document — context, branch state, what's done, what's broken, decisions, dead ends, gotchas, open questions, next steps — so someone else (or a future session) can pick up the work without replaying the conversation.

## Install

```bash
npx ruleshub install lozymon/handoff --tool claude-code
```

## What it does

Triggered by `/handoff`, "write a handoff", "I'm switching off this", or before a context-window reset. The assistant:

1. Gathers state from the repo: branch, upstream, recent commits, unpushed commits, working tree, stashes, diff stats.
2. Reconstructs context from the conversation: goal, decisions, dead ends, surprises, open questions.
3. Renders a structured document with these sections:
   - Goal, State, What's done, What's in progress / broken
   - Decisions made, Dead ends, Surprises / gotchas
   - Open questions, Next steps, How to resume

The bar: a stranger reading only the handoff can take the next concrete step.

## When to use

- Stopping work mid-task, someone else picking it up
- Long task about to overflow the context window — capture state before compaction
- End of day / end of session / before switching branches
- Before posting an extended `gh pr edit --body-file …`

## When NOT to use

- Task is *finished* — use [`lozymon/recap`](https://ruleshub.dev/lozymon/recap) or [`lozymon/work-summary`](https://ruleshub.dev/lozymon/work-summary) instead
- Trivial single-session work — overkill

## Related

- [`lozymon/recap`](https://ruleshub.dev/lozymon/recap) — short wrap-up for completed tasks
- [`lozymon/work-summary`](https://ruleshub.dev/lozymon/work-summary) — always-on rule that appends a recap block automatically

## License

MIT
