---
description: Fix a bug methodically — reproduce, find the root cause, write a failing test, apply the smallest fix, verify.
argument-hint: "<bug description or issue link>"
allowed-tools:
  - Bash(git:*)
  - Bash(npm:*)
  - Bash(pnpm:*)
  - Bash(yarn:*)
  - Bash(pytest:*)
  - Bash(cargo:*)
  - Read
  - Edit
  - Grep
---

# /bug-fix — Methodical Bug Fix

Fix the bug described in `$ARGUMENTS` without expanding scope. Follow the steps in order — don't skip ahead even if the cause "looks obvious."

## Steps

### 1. Understand the report

Re-read what the user said. If `$ARGUMENTS` is a link, fetch and read it. Confirm:
- What's the observed behavior?
- What's the expected behavior?
- What inputs trigger it?
- Was this working before? When did it break? (`git log` if you have a hint.)

If anything is ambiguous, ask the user **before** touching code.

### 2. Reproduce

Get the failing case running locally. This is non-negotiable.

- If reproduction needs a specific command, run it and capture the output.
- If it requires data setup, write the setup as a test, not as a one-off script.
- If you cannot reproduce after a reasonable attempt, stop and report what you tried — don't guess at a fix.

A bug you can't reproduce can't be confirmed fixed.

### 3. Find the root cause

Once reproducing, trace **why**. Read the actual code path. Don't assume.

- Use `grep` and `git blame` to locate the relevant logic and find when it changed.
- Add print/log statements only if reading isn't enough. Remove them after.
- Distinguish "the symptom" (`undefined is not a function`) from "the cause" (a config field is missing because…).

If the cause turns out to be in a different layer than expected (the bug was "UI" but the cause is in the API), say so explicitly before fixing — the user may want to scope the fix differently.

### 4. Write a failing test

Before changing production code, write a test that fails for exactly this bug. Run it — confirm it fails for the right reason, not a setup problem.

If the codebase has no tests, ask the user whether to:
- Add minimal test infrastructure as part of this fix, or
- Skip the test (note this explicitly in the PR — it's a known gap)

### 5. Apply the smallest fix

Change the **minimum** needed to make the test pass.

- ❌ Don't refactor surrounding code "while you're here."
- ❌ Don't add error handling for unrelated paths.
- ❌ Don't update unrelated dependencies.
- ❌ Don't reformat the file.
- ✅ Fix the cause, not just the symptom (unless the user explicitly asks for a quick patch and you can't address the cause now — note that in a `TODO` with context).

If you find adjacent issues, list them at the end of your reply for the user to decide on as separate work.

### 6. Verify

- Run the new test → passes
- Run the rest of the test suite → no new failures
- Manually exercise the original repro → fixed

If anything went red that was green before, stop and investigate before declaring done.

### 7. Report

Output:

```
## Bug fix: <one-line description>

### Root cause
<2-3 sentences>

### Fix
- <file>:<line> — what changed and why

### Tests
- Added: <test name(s)>
- Suite: passing (X tests)

### Adjacent issues found (not fixed)
- <issue> — <where>

### Suggested commit message
fix(<scope>): <subject>
```

Don't commit. Hand the message to the user.
