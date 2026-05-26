---
name: handoff
description: Produce a detailed handoff document for the next person — or the next Claude session — picking up this work. Captures context, branch state, what's done, what's broken, surprises, and concrete next steps. Use when the user says "/handoff", "write a handoff", "I'm switching off this", "hand this to <name>", or before a context-window reset.
user-invocable: true
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git branch:*)
  - Bash(git rev-parse:*)
  - Bash(git stash:*)
  - Read
---

# handoff

Generate a self-contained document that lets a stranger (or future-you) resume this work without replaying the conversation. The bar: someone reading only the handoff can take the next concrete step.

## When to use

- User is stopping work mid-task and someone else will pick it up.
- Long task is about to overflow the context window — capture state before compaction.
- End of day, end of session, or before switching branches.
- User explicitly asks for a "handoff", "context dump", "pick-up doc", "notes for the next person".

## When NOT to use

- For a finished task — use the `recap` skill or the `work-summary` rule instead.
- For trivial single-session work — overkill.

## Procedure

### 1. Gather state from the repo

```bash
git rev-parse --abbrev-ref HEAD                  # current branch
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null  # upstream
git log --oneline -10                            # recent commits
git log --oneline @{u}..HEAD 2>/dev/null         # unpushed commits
git status --short                               # uncommitted / untracked
git diff --stat                                  # unstaged scope
git diff --cached --stat                         # staged scope
git stash list                                   # any stashed work
```

If you can't run a command (e.g. no upstream), note it in the doc rather than silently omitting.

### 2. Pull context from the conversation

Reconstruct, from the transcript:

- **Goal** — what the user was trying to accomplish, in their words.
- **Decisions made** — non-obvious choices (`we picked X over Y because…`).
- **Dead ends** — things tried that didn't work. Save the next person from repeating them.
- **Open questions** — things that couldn't be answered without the user.
- **Surprises** — anything in the codebase that was non-obvious or worked differently than expected.

### 3. Output format

Render exactly this structure. Omit sections that genuinely have nothing — don't pad with "N/A".

```markdown
# Handoff: <one-line topic>

**Date:** <YYYY-MM-DD>
**Branch:** <branch> (<commits ahead/behind upstream, or "no upstream">)
**Last commit:** <sha> — <subject>

## Goal

<2–4 sentences. What the user was trying to do, and why. Use their words where possible.>

## State

- **Working tree:** <clean | N modified, M untracked | <files staged>>
- **Stash:** <none | one entry: "WIP on X">
- **CI / tests:** <last known status, or "not run this session">

## What's done

- `path/file.ts:42` — <what changed and why>
- …

## What's in progress / broken

- `path/file.ts:88` — <what's half-written, what error it produces, what's missing>
- Failing test: `path/spec.ts::name` — <one-line symptom>
- …

## Decisions made

- **<decision>** — <reason in one sentence>
- …

## Dead ends

- Tried <approach>; didn't work because <reason>. Don't retry unless <condition>.
- …

## Surprises / gotchas

- <Something non-obvious about the code, the build, the data, the env.>
- …

## Open questions

- <Question that needs the user / a domain expert.>
- …

## Next steps

1. <Concrete action, with file:line where applicable>
2. <…>
3. <…>

## How to resume

```bash
git checkout <branch>
# any setup commands the next person needs
```
```

### 4. Quality bar

Before printing, check:

- **Self-contained** — a reader who hasn't seen the transcript can act on it.
- **Concrete file refs** — `path/file.ts:line` beats "the auth module".
- **Honest about failure** — failing tests, half-written code, and dead ends are *more* valuable to the next person than to the current user. Don't soften them.
- **Next steps are actionable** — each one is something the reader can start within a minute, not a research project.
- **No invented state** — only describe what the repo and the conversation actually show. If unsure, mark it `?` and flag it as an open question.

### 5. Save it somewhere durable

By default, print the handoff to the chat. If the user wants it persisted, offer:

- Write to `HANDOFF.md` at the repo root (will be gitignored or committed — ask).
- Write to `docs/handoffs/<YYYY-MM-DD>-<topic>.md` if that directory exists.
- Paste into the PR description (`gh pr edit --body-file …`).

Don't write the file without confirming the path — handoffs sometimes contain context the user doesn't want committed.

## Don'ts

- ❌ Don't include the entire diff — link to it (`git diff <base>..HEAD`) or summarize.
- ❌ Don't invent decisions, dead ends, or surprises to fill the template. Omit empty sections.
- ❌ Don't hide that something's broken. The next person needs to know.
- ❌ Don't write a handoff for a task that's actually done — use `recap` instead.
- ❌ Don't commit the handoff file without asking — it may contain internal context.
