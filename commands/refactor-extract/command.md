---
description: Extract a function, component, or module from a larger one without changing observable behavior.
argument-hint: "<what to extract — file:line or natural description>"
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

# /refactor-extract — Behavior-Preserving Extraction

Extract the code specified in `$ARGUMENTS` into its own function / component / module **without changing observable behavior**.

## What this is for

- Pulling a 200-line function apart into named pieces
- Lifting reusable logic out of a component
- Moving a class into its own file
- Renaming for clarity (still a "refactor" in the strict sense — same behavior)

## What this is NOT for

- Adding features (use a normal feature branch)
- Fixing bugs (use `/bug-fix`)
- Performance changes that alter behavior or output shape
- API changes visible to callers — that's not extraction, that's a redesign

If your task involves any of those, stop and tell the user — pick a different command.

## Steps

### 1. Pin the baseline

```bash
git status                         # must be clean — refuse if not
<test command>                     # must be green — refuse if not
```

If tests are red, fix them first — refactoring on top of red tests means you can't tell if you broke something.

If there are no tests covering the code you're extracting, **say so explicitly** and ask the user whether to:
- Add characterization tests first (recommended for non-trivial code), or
- Proceed without tests, accepting the risk

Never silently proceed without a way to verify.

### 2. Identify the boundary

Read the target code. Decide:
- **Inputs** — what variables does it read? (parameters of the new function)
- **Outputs** — what does it produce or mutate? (return value(s) and/or out-params)
- **Side effects** — IO, logging, mutation of shared state
- **Dependencies** — imports needed in the new location

If the boundary requires more than ~5 parameters, the extraction is probably wrong — either the wrong slice or the original function had hidden coupling. Surface this to the user.

### 3. Extract mechanically

- Create the new function/file with the identified signature.
- Move the code body in. Don't rewrite it. **Same logic, same order, same names** unless renaming is the explicit purpose.
- Replace the original site with a call to the new function.
- Update imports.

If you find yourself "improving" the extracted code, stop. Land the extraction first, then propose improvements as a separate change.

### 4. Verify

```bash
<test command>                     # must still be green
git diff --stat                    # sanity-check the surface area
```

The diff should look like:
- New file or function added
- Original site shrunk to a call
- No semantic changes elsewhere

If the diff has unrelated changes (formatting, logic tweaks, "while-you're-here" cleanups), revert those.

### 5. Report

```
## Refactor: extract <name>

### Boundary
- Inputs: <params>
- Outputs: <return>
- Side effects: <list or "none">

### Files changed
- <new-file>: new
- <original>: <N> lines removed, replaced with call

### Verification
- Tests: passing (X tests, same count as before)
- Behavior: identical

### Suggested commit message
refactor(<scope>): extract <name> from <original>
```

Don't commit. Hand the message and diff to the user for review.

## Safety notes

- Never extract across module/package boundaries without confirming the user wants the new dependency direction.
- Never extract code that touches unstated globals, captured closures, or `this` without making those explicit in the new signature.
- If the language has a built-in "extract function" refactoring (e.g. IDE actions), prefer that — but you still own the verification.
