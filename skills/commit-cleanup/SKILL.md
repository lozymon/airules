---
name: commit-cleanup
description: Tidy a feature branch before PR — collapse WIP/fixup commits into meaningful units, rewrite messages to conventional-commits format, and surface anything that shouldn't be committed. Use when the user says "clean up these commits", "squash my WIPs", "rewrite my commit messages", or before opening a PR.
user-invocable: true
allowed-tools:
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(git status:*)
  - Bash(git rev-parse:*)
  - Bash(git rebase:*)
  - Bash(git reset:*)
  - Bash(git commit:*)
  - Bash(git add:*)
  - Bash(git stash:*)
  - Read
  - Edit
---

# commit-cleanup

Reshape the current branch's commit history into a clean, reviewable series before opening a PR. **Always confirm with the user before rewriting history.**

## When to use

- User asks to "clean up commits", "squash WIPs", or "rewrite messages"
- User says they're about to open a PR and the branch has scrappy history
- A `/pr-review` flagged commit-hygiene issues

## When NOT to use

- The branch is already pushed and shared with others — rewriting public history is dangerous. Warn and stop unless the user confirms they own the branch.
- The branch is `main` / `master` / a release branch — never rewrite these.

## Procedure

### 1. Survey the current state

```bash
git rev-parse --abbrev-ref HEAD                  # current branch
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null  # upstream, if any
git log --oneline <base>..HEAD                   # commits to clean up
git status --short                               # uncommitted changes
```

Refuse to proceed if:
- Current branch is `main` / `master` / `develop` / `release/*`
- There are uncommitted changes — ask the user to commit or stash first
- The branch is behind upstream (suggests it's shared)

### 2. Propose a plan, don't execute yet

Read every commit message and diff. Group commits into logical units. Output a plan like:

```
Current: 7 commits
- a1b2c3d wip
- d4e5f6g fix typo
- h7i8j9k more wip
- ...

Proposed: 2 commits
1. feat(auth): add password reset flow
   - merges: a1b2c3d, d4e5f6g, h7i8j9k, ...
2. test(auth): cover password reset edge cases
   - merges: ...
```

**Stop here and ask the user to approve the plan.** Don't proceed without explicit confirmation.

### 3. Execute via `git reset --soft` + re-commit (safest path)

Once approved:

```bash
git reset --soft <base>
# now all changes are staged, history wiped back to base
git reset HEAD <files-to-exclude>      # if any files shouldn't be committed
git commit -m "feat(auth): ..."        # build each unit
git add -p                              # for partial-file splits
git commit -m "test(auth): ..."
```

`reset --soft` is preferred over interactive rebase here — it's mechanical, doesn't drop you into an editor, and the user can see exactly what's staged at each step.

### 4. Conventional-commits format

Every rewritten message must follow:

```
type(scope): short imperative description

[optional body — wrap at 72 cols]
[optional footer: BREAKING CHANGE: ..., Closes #123]
```

Allowed types: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `style`, `perf`, `build`, `ci`.

Scope is optional but encouraged — usually the affected module/area (`auth`, `api`, `web`, `cli`).

### 5. Verify

```bash
git log --oneline <base>..HEAD
git diff <base>..HEAD --stat
```

The diff against base must be **byte-identical** to before cleanup. If it isn't, something was lost — `git reflog` and recover.

### 6. Surface anything suspicious

Before declaring done, check the final diff for:
- `console.log`, `print()`, `dbg!()` debug statements
- TODO/FIXME comments added in this branch
- Commented-out code
- Files that shouldn't be committed (`.env`, `node_modules/`, IDE configs)
- Hardcoded secrets, URLs, tokens

Report these to the user — don't auto-remove them.

## Safety notes

- Never `git push --force` automatically. Tell the user the exact command (`git push --force-with-lease`) and let them run it.
- Never run `git rebase -i` — it requires an interactive editor.
- If the user has uncommitted work, stash it with a clear name before starting; restore at the end.
- If anything goes sideways, `git reflog` lets you recover up to 90 days.
