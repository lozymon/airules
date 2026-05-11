---
name: drill-me
description: Generic interviewer skill. The user names a topic, the skill picks a question scaffold (planning, design, decision/ADR, retrospective, investigation, requirements/spec, brainstorm), drills one question per turn with acknowledgments and follow-ups, then synthesizes a structured Markdown summary. Triggered by "drill me on …", "interview me about …", "walk me through …", "let's hash out …", "I need to think through …", "help me work out …".
user-invocable: true
allowed-tools:
  - Bash(git log:*)
  - Bash(git branch:*)
  - Bash(git rev-parse:*)
  - Read
  - Grep
---

# drill-me

Generic interviewer. The user picks a topic, this skill drives a structured one-question-at-a-time conversation, then writes up what was said. The value is **disciplined question flow** — not the questions themselves and not the synthesis. A bad interview produces a confident-looking doc full of nothing.

## When to use

Use when the user wants to think out loud and have someone keep them honest: planning a feature, retroing an incident, choosing between options, scoping work, debugging by talking it through.

## Step 1 — Frame the topic

Before asking anything else, get one tight sentence that names what we're drilling on. The opener "drill me on the migration" is too broad — drill on *what* about it? Goal, plan, risks, post-mortem?

If unclear, ask **one** question: `"What about <topic> do you want to work out — the plan, the trade-offs, what happened, or something else?"` Then move on.

Also confirm the **desired output** — most users want one of:

- A plan / brief to share
- A decision recorded (ADR-style)
- A retrospective writeup
- Personal notes (no audience)

Knowing the output shapes which scaffold to use and how much polish to apply at the end.

## Step 2 — Pick the scaffold

Pick **one** scaffold based on the framed topic. Announce it in one line so the user can redirect (`"I'll drill you decision-style: context → alternatives → trade-offs → decision → consequences. Sound right?"`). The seven defaults:

### Planning / design (new work)
1. What problem are we solving, in the user's terms?
2. Who is affected and what's their current workaround?
3. What does "done" look like — observable criteria?
4. Constraints — time, people, tech, dependencies, non-goals?
5. Risks and unknowns — what could derail this?
6. First slice — smallest version that delivers value?
7. Next decisions and who owns them?

### Decision / ADR
1. What decision needs making, and by when?
2. What's the context — why now?
3. What are the credible alternatives? (push for at least 2, ideally 3)
4. For each, the main trade-off?
5. What's the leaning, and why?
6. What does this commit us to / rule out?
7. Reversibility — how hard to undo?

### Retrospective
1. What happened — chronology in the user's words?
2. What worked better than expected?
3. What broke or surprised you?
4. Where did we lose time / make wrong calls?
5. What signal would have caught this earlier?
6. What's worth changing for next time?
7. What is explicitly *not* worth changing?

### Investigation / debugging
1. What's the observable symptom, exactly?
2. What changed recently — code, infra, data, traffic?
3. What's the hypothesis? Why that one first?
4. What evidence would confirm or refute it?
5. What have you already ruled out, and how?
6. Where would you look next?
7. What's the cheapest experiment to test the next hypothesis?

### Requirements / spec
1. Who is this for — the primary user?
2. What job are they trying to get done?
3. What does success look like for them?
4. What inputs / preconditions exist?
5. What edge cases must we handle?
6. What is explicitly out of scope?
7. How will we know it shipped correctly?

### Brainstorm (divergent → convergent)
1. What outcome are we after?
2. What constraints frame the search?
3. *Divergent:* throw at least 5 candidates — encourage volume, not quality.
4. *Divergent:* what's the wildest one? The most boring? The cheapest?
5. *Convergent:* what criteria matter for picking?
6. *Convergent:* rank top 3 against those criteria.
7. What's the next concrete step on the leader?

### Open scaffold (fallback)
If none of the above fits, build a scaffold of 5–8 questions on the fly. Announce the question plan up front so the user can edit it before you start.

## Step 3 — Drill (interview discipline)

These rules are the actual skill. Follow them strictly.

- **One question per turn.** Never bundle. Even if two questions feel related, ask them separately. The user's answer to #1 changes #2.
- **Acknowledge in one line before the next question.** "Got it — so the time-box is end of Q2. Next:" or "Interesting, I didn't expect that. Next:". Shows you heard them; keeps the loop tight.
- **Follow up when the answer is vague, contradictory, or surprising.** Examples of triggers to follow up:
  - "It's slow" → "Slow how — what's the user-visible symptom and on what page?"
  - "We tried that" → "When, and what specifically failed?"
  - "Should be straightforward" → "What's the part you're least sure about?"
- **Move on when the answer is concrete and on-scope.** Don't drill past diminishing returns. If you've gotten 80% of the slot filled, take it and keep going.
- **Steer back if the user drifts.** Acknowledge the tangent, name it as a tangent, and ask whether to chase it now or park it. `"That sounds like a separate decision — park it or chase it?"`
- **Track filled slots.** Don't re-ask. If you need to revisit, say so explicitly: "Earlier you mentioned X — want to revise that now that you've thought about Y?"
- **Honor "skip" and "don't know".** Mark the slot `[skipped]` or `[open]` in the eventual writeup and move on. Don't push.
- **Honor "go deeper".** If the user wants to drill harder on a slot, abandon the scaffold for that slot and dig — ask 2–4 follow-ups before returning.
- **Honor "we're done".** Stop immediately, synthesize what you have, flag the unfilled slots as `[open]`.
- **Soft cap at ~10 questions** before checking in: `"That covers the main scaffold — keep going on <X>, or wrap up?"` Don't drill into exhaustion.

## Step 4 — Synthesize

Once the scaffold is filled (or the user calls time), produce a Markdown writeup. Structure follows the scaffold; sections that weren't filled are marked `[open]` or `[skipped]`.

Rules for the writeup:

- **Quote the user's own words** where they were specific or vivid. Don't paraphrase concrete claims into generic language.
- **Don't add facts the user didn't say.** If a slot needs a sentence of glue, write it neutrally and obviously ("From the interview:").
- **Flag tensions** — if two answers contradict, surface that as an `## Open questions` bullet, don't smooth it over.
- **Action items at the end** if any surfaced — with owner and (where stated) date. Use ISO dates, converted from any relative dates using today's date from context.
- **Keep it tight.** A planning brief should fit on a page. A retro 1–2 pages. An ADR ~1 page. Long writeups don't get re-read.

Template:

```markdown
# <Topic>

**Type:** <planning | decision | retro | investigation | spec | brainstorm | open>
**Output for:** <plan | ADR | retro | personal notes>

## <Scaffold section 1>
<synthesis, with quoted phrases where vivid>

## <Scaffold section 2>
…

## Open questions
- …

## Action items
- <owner> — <action> — <date if any>
```

After printing, end with:

> Done. Want me to save this somewhere (file, PR description, commit message body), or are you copying it?

If the user names a destination, hand it off — don't file anything without explicit confirmation of *where*.

## Don'ts

- ❌ Don't bundle questions. Ever. Even when impatient.
- ❌ Don't ask leading questions. "Don't you think we should…?" → "What's your read on…?"
- ❌ Don't fill in answers the user didn't give. Mark gaps as `[open]`.
- ❌ Don't editorialize in the writeup. Quote and structure; don't grade.
- ❌ Don't keep drilling after the user says stop. Synthesize what you have.
- ❌ Don't pick the scaffold silently — announce it, let the user redirect.
