---
name: draft-issue
description: Coach the user through writing a high-quality issue — bug, feature, subtask, or other — using type-specific required fields and a pre-flight quality check. Output is provider-neutral Markdown ready to paste into any tracker (GitHub, Linear, Jira, Businessmap, Notion). Optionally hands off via gh/MCP if available. Supports drill mode (one question at a time), batch mode (fill the gaps), and template mode (blank scaffold only). Triggered by "create an issue", "file a bug", "draft a feature request", "open a ticket", "log a bug", "make a subtask", "drill me through an issue".
user-invocable: true
allowed-tools:
  - Bash(git log:*)
  - Bash(git branch:*)
  - Bash(git rev-parse:*)
  - Bash(git status:*)
  - Bash(gh issue:*)
  - mcp__businessmap__*
  - mcp__linear__*
  - mcp__jira__*
---

# draft-issue

Help the user write an issue that is **actionable, searchable, and unambiguous** — regardless of which tracker it ends up in. The value of this skill is the template and the quality check, not the API call.

## Interaction mode

Pick one of three modes before asking anything. **Adaptive default** unless the user names a mode:

- **Drill mode** — ask **one question per turn**, wait for the answer, then ask the next. Use when the user's opening is sparse ("file a bug for the login button"), or when they explicitly say `drill me`, `ask me one at a time`, `walk me through`, `interview me`. Order: classify type → required fields in the order listed below → ask once per optional field with `(skip)` as an explicit option.
- **Batch mode** — read what the user already gave you, extract fields, and ask for **only the missing required fields** in a single grouped message. Use when the opening message contains a paragraph or more of substantive context (multiple fields' worth of info). Optional fields stay optional — don't badger.
- **Template mode** — hand back a blank Markdown scaffold with `<…>` placeholders, no questions asked. Use only when the user says `just the template`, `give me the scaffold`, `no questions`.

Adaptive heuristic: if the opening message is under ~one short paragraph or only names the topic, default to **drill mode**. If it's structured and field-rich, default to **batch mode**. State which mode you've chosen in one short line before the first question so the user can redirect (`"Drilling one question at a time — switch to batch if you'd rather dump everything at once."`).

In drill mode, never ask two questions in the same turn — even if they feel related. Wait for the answer, acknowledge briefly (one line), ask the next. Track which fields are filled so you don't re-ask.

## Step 1 — Classify the issue type

Ask the user what they're filing if it isn't already clear. Four types:

| Type | Use when |
|------|----------|
| **bug** | Existing behavior is wrong, broken, or unintended |
| **feature** | New capability or material change to existing behavior |
| **subtask** | A scoped slice of work that belongs under a parent issue |
| **other** | Idea, chore, spike, tech-debt, research, decision — anything that doesn't fit above |

Don't guess. "The login button is slow" could be a bug *or* a perf feature depending on whether it ever worked. Ask.

## Step 2 — Collect required fields

Walk through the type-specific fields below. **Refuse to draft a final issue with required fields missing** — say what's missing and ask. Optional fields can be left blank; the template should make that visible.

### Bug — required

- **Title** — `<observable behavior> when <trigger>`. Never just "X is broken" or "doesn't work". Must be searchable a year from now.
- **Environment** — app version, OS / browser / device, account type, environment (prod/staging/local). Skip irrelevant axes; don't pad.
- **Steps to reproduce** — numbered, atomic, deterministic. Each step is something a stranger can do. "Click the button" — *which* button, on *which* page.
- **Expected behavior** — what should happen.
- **Actual behavior** — what does happen. Concrete diff from expected, including error messages verbatim.
- **Frequency** — `always` / `intermittent (N out of M tries)` / `one-time`.

### Bug — strongly recommended

- **Regression?** — did this ever work? If yes, when did it break (last known good version / commit)?
- **Evidence** — screenshot, screen recording, log excerpt, stack trace. Quote logs verbatim in a fenced code block; don't paraphrase.
- **Workaround** — if the user has one.
- **Severity / impact** — who is blocked, how many, from doing what. Avoid `critical`/`high`/`low` labels without a sentence of justification.

### Feature — required

- **Title** — name the capability as a noun phrase, or use `<who> can <do what> so that <outcome>`. Not "Add X button" — what does the button *do*?
- **Problem statement** — the user's pain in their words, not a solution dressed up as a problem. If you wrote "we need to add caching", the *problem* is "page load takes 8s on the dashboard" — write that instead.
- **Acceptance criteria** — testable, observable bullet points. Each one a reader can verify by inspection or test. "Fast" is not acceptance criteria; "p95 < 500ms on the dashboard endpoint" is.

### Feature — strongly recommended

- **Proposed solution** — high-level approach. Mark as `[proposed]` so reviewers know it's negotiable.
- **Out of scope** — what we are explicitly *not* doing. Prevents scope creep more than any other field.
- **Alternatives considered** — at least one, with reason rejected. If there are none, write "no alternatives considered" rather than leaving it blank.
- **Open questions** — bullet list. Surface unknowns now, not after estimation.
- **Success metric** — how we know it worked, post-ship.

### Subtask — required

- **Parent issue** — link or ID. Refuse to finalize without this; a subtask without a parent is just an issue.
- **Title** — scoped to the parent. Prefix with parent ID if the tracker doesn't auto-link (e.g. `[BM-1234] migrate users table to new schema`).
- **Scope** — single deliverable, one sentence.
- **Definition of done** — checklist of observable completion criteria.

### Subtask — optional

- **Dependencies** — sibling subtasks that must precede this one.
- **Estimate** — only if the team uses estimates.

### Other — required

- **Title** — descriptive, not "misc" or "cleanup".
- **Motivation** — why now, why bother. If it doesn't have a forcing function, that's fine, but say so.
- **Definition of done** — even for spikes ("decision documented in `docs/decisions/`"), even for chores.

### Other — optional

- **Decision needed by** — if time-sensitive. Convert relative dates to ISO using today's date.
- **Stakeholders** — people who must be looped in.

## Step 3 — Pull free context from the repo

When useful, populate fields automatically before asking the user:

- **Current branch / recent commits** — `git rev-parse --abbrev-ref HEAD`, `git log --oneline -5`. Often hints at what the user is working on and what version "this" refers to.
- **For a bug "in this code"**: the file/line the user is editing is the natural anchor for the reproducer.
- **For a feature**: scan the README or relevant module for prior context so the proposal doesn't ignore existing structure.

Always present pulled context for confirmation — don't silently bake assumptions into the draft.

## Step 4 — Pre-flight quality check

Before producing the final draft, run through these red flags. Fix each one with the user before finalizing — don't ship a draft you know is bad.

- **Title is generic** — "doesn't work", "improve performance", "fix the thing", "needs refactoring". Rewrite with a specific behavior.
- **Title uses internal jargon** without expansion (`fix the FOO pipeline`) — name it so a new hire can find it.
- **Bug missing repro** — without it the issue is unactionable. Refuse to finalize.
- **Bug missing expected vs actual** — ambiguous; the reader has to guess what "wrong" means.
- **Feature framed as solution** — "add a cache" instead of "page load is slow". Push back, restate the problem.
- **Feature missing acceptance criteria** — there's no way to tell when it's done. Refuse to finalize.
- **Acceptance criteria are subjective** — "fast", "intuitive", "robust". Make them measurable or observable.
- **Subtask missing parent** — it's not a subtask, it's an issue. Either link a parent or reclassify.
- **Vague severity** — "high priority" with no justification. Tie severity to user impact.
- **Wall of text** — no headings, no bullets. Restructure.
- **Stack trace paraphrased** — quote logs and errors verbatim in fenced code blocks.

## Step 5 — Output the draft

Render as **portable Markdown**. Use headings, bullets, fenced code blocks. This format pastes cleanly into GitHub, Linear, Notion, and Businessmap (Markdown mode). Jira uses different markup — note that if the user names Jira as the destination.

Template:

```markdown
# <Title>

**Type:** <bug | feature | subtask | other>
<for subtask only:> **Parent:** <link or ID>

## <Problem statement | Steps to reproduce | Scope | Motivation>
…

## <Expected | Acceptance criteria | Definition of done>
…

## <Actual | Proposed solution | Dependencies>
…

## Additional context
- Environment: …
- Evidence: …
- Out of scope: …
- Open questions: …
```

Adapt section names to the type. Omit empty sections rather than leaving "TBD" placeholders.

After printing the draft, end with:

> Ready to paste. Want me to file it via `gh issue create` / Linear MCP / Businessmap MCP, or are you handling that?

## Step 6 — Optional handoff

Only if the user asks:

- **GitHub** — `gh issue create --title "…" --body "$(cat <<'EOF' … EOF)"`. Check `gh auth status` first; if not authed, hand back the Markdown and stop.
- **Linear** — call `mcp__linear__create_issue` (or whichever creation tool the registered Linear MCP exposes — inspect available tools first).
- **Businessmap** — defer to the `businessmap` skill; don't duplicate its logic here.
- **Anything else** — print the Markdown and tell the user to paste it.

For any handoff, echo the destination (repo / team / board) and confirm before filing. Don't file into the wrong place.

## Don'ts

- ❌ Don't finalize an issue with required fields missing. Ask, or refuse.
- ❌ Don't invent reproducer steps, error messages, or stack traces. If the user didn't provide them, leave the section empty and flag it.
- ❌ Don't write a 500-word essay when 5 bullets do the job. Concise issues get read.
- ❌ Don't paraphrase logs/errors — quote verbatim in fenced blocks.
- ❌ Don't pick a tracker for the user. The skill's job is the draft, not the destination.
- ❌ Don't auto-label `severity: high` without a justification line — it trains people to ignore severity.
