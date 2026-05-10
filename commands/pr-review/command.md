---
description: Review the current branch's diff against project rules before opening a PR.
argument-hint: "[base-branch]"
allowed-tools:
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git status:*)
  - Bash(git rev-parse:*)
  - Read
  - Grep
---

# /pr-review — Pre-PR Review

Reviews the current branch's diff against `$1` (default: `main`) and reports issues to fix before opening a PR.

## Steps

1. **Determine base branch** — use `$1` if provided, otherwise default to `main`. Verify it exists with `git rev-parse --verify <base>`. If not, try `master`. If neither exists, ask the user.

2. **Gather the diff**:

   ```bash
   git fetch origin <base> --quiet 2>/dev/null || true
   git diff <base>...HEAD --stat
   git diff <base>...HEAD
   git log <base>..HEAD --oneline
   ```

3. **Read CLAUDE.md** — if the project has one, load it before reviewing. Project-specific rules trump generic feedback.

4. **Review across these dimensions** — for each, list specific findings with `file:line`. If there are no issues in a dimension, say "clean" — don't pad.

   - **Correctness** — bugs, off-by-one, null/undefined handling, race conditions, error swallowing
   - **Scope creep** — changes outside the stated purpose of the branch (look at branch name and recent commits)
   - **Tests** — new code paths without tests; modified behavior whose tests still pass unchanged (suspicious); test names that don't match what they assert
   - **Types** — `any`, non-null assertions (`!`), `@ts-ignore`, untyped function boundaries
   - **Logging & secrets** — `console.log` left in, hardcoded keys/tokens/URLs, env vars accessed without a fallback strategy
   - **Style** — violations of any rule in the project's CLAUDE.md
   - **Commit hygiene** — WIP commits, fixup commits, commits that don't match the project's commit-message convention

5. **Output format**

   ```
   ## PR Review: <branch> → <base>

   <commit count> commits, <files changed> files (+<add>/-<del>)

   ### Correctness
   - <finding> (path/file.ts:42)
   - clean

   ### Scope creep
   ...

   ### Summary
   - <X> blocking issues
   - <Y> non-blocking suggestions
   - Ready to open PR: yes / no
   ```

6. **Don't fix anything** — this command reports only. The user decides what to address.

## Notes

- If the branch is identical to base (no commits ahead), say so and stop.
- If the diff is huge (>1000 lines changed), warn the user that this PR likely needs splitting, then proceed with the review anyway.
- Never run `git push`, `git commit`, or any state-changing command. Read-only review only.
