# lozymon/local-review

Reviews your uncommitted working-tree changes (staged + unstaged) and reports issues to fix *before* you commit.

## Install

```bash
npx ruleshub install lozymon/local-review --tool claude-code
```

## What it does

After you type `/local-review`, the assistant:

1. Runs `git status` + `git diff HEAD` to see what's about to be committed.
2. Reads the project's `CLAUDE.md` so project rules trump generic feedback.
3. Reports findings across six dimensions, each with `file:line` references:
   - **Leftovers** — half-finished tests, stray `TODO`/`FIXME`, debug `console.log`/`print`, unused imports, functions whose only callers were deleted earlier in the same diff, commented-out code
   - **Correctness** — bugs, off-by-one, null/undefined, race conditions, swallowed errors, missing `await`
   - **Tests** — new code paths without tests; behavior changes whose tests still pass unchanged
   - **Types** — `any`, `!`, `@ts-ignore`, untyped function boundaries
   - **Secrets** — hardcoded keys, tokens, credentials, internal URLs
   - **Style** — anything in your `CLAUDE.md`
4. Ends with a summary line and a "ready to commit: yes/no" verdict.

Read-only. Never runs `commit`, `add`, `stash`, or any state-changing command.

## When to use

- Before *every* commit. Solo branches included. The marginal cost is ~30 seconds; one caught regression pays for thousands of runs.
- After a refactor, when orphaned helpers and dead branches are easy to miss.
- Before staging a large change, to catch leftovers while context is still fresh.

## When NOT to use

- After you've already committed — at that point fixes need a follow-up commit and the review is mostly theater. Run it before, then commit.
- For reviewing the *whole branch* against `main` — that's [`lozymon/pr-review`](https://ruleshub.dev/lozymon/pr-review), which reads committed history.
- For untracked files you've intentionally left out (build artifacts, scratch files) — they're listed but not reviewed.

## Related

- [`lozymon/pr-review`](https://ruleshub.dev/lozymon/pr-review) — reviews the committed branch diff against a base branch before opening a PR
- [`lozymon/commit-cleanup`](https://ruleshub.dev/lozymon/commit-cleanup) — tidies commit history (squash, rewrite messages) after the local review passes

## License

MIT
