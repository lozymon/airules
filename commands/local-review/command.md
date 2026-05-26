---
description: Review uncommitted working-tree changes before committing.
allowed-tools:
  - Bash(git diff:*)
  - Bash(git status:*)
  - Read
  - Grep
---

# /local-review — Pre-commit Review

Reviews your uncommitted changes (staged + unstaged) and reports issues to fix before committing. Meant to be a habitual ~30-second checkpoint, not an occasional gate. Run it before every commit; the marginal cost is small and one caught regression pays for thousands of runs.

The common mistake: running this *after* the commit. At that point fixes need a follow-up commit; the whole point of the pre-commit review is that it's free to act on.

## Steps

1. **Gather the diff**:

   ```bash
   git status --short
   git diff HEAD --stat
   git diff HEAD
   ```

   If `git diff HEAD` is empty and `git status` shows nothing, say "nothing to review — working tree clean" and stop.

2. **Read CLAUDE.md** — if the project has one, load it before reviewing. Project-specific rules trump generic feedback.

3. **Review across these dimensions** — for each, list specific findings with `file:line`. If there are no issues in a dimension, say "clean" — don't pad.

   - **Leftovers** — half-finished tests, `TODO`/`FIXME`/`XXX` added in this diff, `console.log` / `print` / `dbg!` debugging statements, unused imports, dead functions whose only callers were removed earlier in the diff, commented-out code
   - **Correctness** — bugs, off-by-one, null/undefined handling, race conditions, swallowed errors, missing await
   - **Tests** — new code paths without tests; behavior changes whose tests still pass unchanged (suspicious); test names that don't match what they assert
   - **Types** — `any`, non-null assertions (`!`), `@ts-ignore`, untyped function boundaries
   - **Secrets** — hardcoded keys, tokens, credentials, internal URLs
   - **Style** — violations of any rule in the project's CLAUDE.md

4. **Output format**

   ```
   ## Local Review — <N> files (+<add>/-<del>)

   Untracked: <list, or "none">

   ### Leftovers
   - <finding> (path/file.ts:42)

   ### Correctness
   - clean

   ...

   ### Summary
   - <X> blocking issues
   - <Y> non-blocking suggestions
   - Ready to commit: yes / no
   ```

5. **Don't fix anything** — report only. The user decides what to address.

## Notes

- Untracked files appear in `git status` but not in `git diff HEAD`. List them under "Untracked" so the user can confirm they're intentional, but don't try to review their contents unless explicitly asked.
- If the diff is huge (>1000 lines changed), warn that the commit likely needs splitting, then proceed with the review anyway.
- Never run `git commit`, `git add`, `git stash`, `git checkout`, or any state-changing command. Read-only review only.
