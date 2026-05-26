---
name: recap
description: Summarize the work just done in the current session — files changed, why, how to verify, and what's left. Use when the user types "/recap", asks "summarize what you did", "what changed?", "give me a recap", or wants a scannable wrap-up before they review the diff.
user-invocable: true
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git rev-parse:*)
  - Read
---

# recap

Produce a short, scannable summary of what was done in this session. Optimize for the user skimming it in 15 seconds before they open the diff.

## When to use

- User asks for a "recap", "summary", "what did you do", "what changed".
- End of a non-trivial task, before the user reviews or commits.

## When NOT to use

- For trivial Q&A or single-edit changes — the diff speaks for itself.
- Mid-task — wait until work is at a natural stopping point.

## Procedure

### 1. Gather the ground truth

```bash
git rev-parse --abbrev-ref HEAD                  # current branch
git status --short                               # uncommitted changes
git diff --stat                                  # unstaged scope
git diff --cached --stat                         # staged scope
git log --oneline @{u}..HEAD 2>/dev/null         # new commits, if upstream exists
```

Cross-check against the conversation: don't list files touched by Claude that aren't in the diff (means they were reverted or never written), and don't omit files in the diff that Claude *did* write.

### 2. Output format

Render exactly these four sections. Keep each tight — bullets, not paragraphs.

```markdown
**Changed**
- `path/to/file.ts:42` — one-line reason
- `path/to/other.ts` — one-line reason

**Why**
1–2 sentences. Motivation, not mechanics.

**Verify**
- Concrete command(s) or steps the user can run
- e.g. `npm test -- auth.spec.ts`, "click Save and confirm toast appears"

**Next**
- Anything deferred, skipped, or worth a separate PR
- Or "nothing" if the task is complete
```

### 3. Rules for each section

- **Changed** — list user-meaningful files only. Skip whitespace-only edits, auto-formatted imports, lockfile churn. If >10 files changed, group by area: `auth/* — 4 files`, `tests/* — 3 files`.
- **Why** — the motivation the user gave, in their language. Don't restate the code.
- **Verify** — must be something the user can actually do. "Run the tests" is too vague; name the test file or the manual step.
- **Next** — be honest. If something was skipped, say so. If a TODO was added, mention it. Don't pretend the work is more complete than it is.

### 4. Honesty checklist

Before printing the recap, verify:

- Every file in **Changed** appears in `git diff` / `git status` output.
- Nothing in the **Why** was invented — it traces back to the conversation.
- **Verify** steps were actually run during the session, or are reasonable to run now. Don't claim tests pass if they weren't run.
- **Next** doesn't hide unfinished work behind vague phrasing ("further polish needed" = what specifically?).

## Don'ts

- ❌ Don't restate the diff line by line — the user can read it.
- ❌ Don't pad with what *wasn't* changed.
- ❌ Don't claim success for things you didn't verify (tests passing, builds clean) — say "not run" instead.
- ❌ Don't bury follow-ups in prose; they go in **Next** as bullets.
- ❌ Don't recap trivial single-file edits — just say "done".
