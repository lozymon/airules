---
name: find-the-flaws
description: Read-only critical review of staged changes or branch diff. Hunts for correctness bugs, logic errors, unhandled edge cases, off-by-one, race conditions, error-handling gaps, resource leaks, performance traps, dead code, and bad assumptions. Reports findings — never modifies code. Use when the user asks "find the flaws", "what's wrong with this", "pick this apart", or before opening a PR.
user-invocable: true
allowed-tools:
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git status:*)
  - Bash(git rev-parse:*)
  - Read
  - Grep
---

# find-the-flaws

Static, read-only critique of changed code for correctness, robustness, and quality issues. **Never edit, never commit, never push** — output findings only.

This is the general-purpose counterpart to `security-audit`: that one focuses on OWASP-style security flaws; this one focuses on everything else that makes code wrong, fragile, or hard to maintain. Run both for full coverage.

## Scope

Reviews **only the diff**, not the whole codebase. Two modes:

- **Staged** (default if there's anything in the index): `git diff --cached`
- **Branch** (no staged changes): `git diff <base>...HEAD`

If both are empty, say so and stop.

This is not a linter or type-checker replacement. It's a fast first-pass review focused on the kinds of flaws an LLM can spot with judgment — the ones that pass static analysis but fail in production.

## Steps

### 1. Determine the diff

```bash
git diff --cached --stat               # if non-empty, use staged
git rev-parse --abbrev-ref HEAD        # current branch
git diff main...HEAD --stat            # otherwise, branch diff
```

If on `main` / `master` with no staged changes, ask the user what to review.

### 2. Read the diff with context

For each changed file, read enough of the surrounding code to understand call sites, invariants, and data flow — not just the patch hunks. Most real flaws only become visible when you see how the changed code interacts with what's around it.

### 3. Check each category

For each category below, scan the diff and report findings with `file:line` and a one-line explanation. Skip categories that don't apply to the language/diff.

#### Correctness — does it do what it claims?

- Off-by-one errors (`<` vs `<=`, `i < len-1`, slicing boundaries)
- Inverted conditions (`if (!err)` where `err` is the success path, or vice versa)
- Wrong operator (`=` vs `==`, `&` vs `&&`, `|` vs `||`)
- Swapped arguments (`copy(dst, src)` called as `copy(src, dst)`)
- Loop variables captured by closure inside the loop
- Integer overflow / underflow on durations, counters, sizes
- Truthiness traps: `if (count)` skipping the `0` case, `if (value)` skipping `""` / `false` / `null`

#### Edge cases & unhandled inputs

- Empty arrays / strings / maps not handled (first/last access, `reduce` without initial value)
- `null` / `undefined` / `None` propagating through chains without guards
- Negative numbers, zero, very large numbers
- Unicode, emoji, RTL text, byte-vs-char length confusion
- Time zones, DST transitions, leap seconds, leap years, dates before 1970 or after 2038
- Floating-point comparison with `==` instead of an epsilon

#### Concurrency & async

- Race conditions on shared state (read-modify-write without locking)
- `await` missing on a promise — silent fire-and-forget
- Mixing `async` and callbacks for the same operation
- `Promise.all` where one rejection kills siblings that should have run independently
- Mutex/lock acquired but not released on the error path
- `setState` in React called with a stale value instead of the updater form

#### Error handling

- Bare `catch` / `except` that swallows the error and continues
- Errors logged but execution continues as if nothing happened
- Generic error messages (`"something went wrong"`) that lose the original cause
- Resources not released on the error path (file handles, sockets, DB connections, locks)
- Retries without backoff, or retries on non-idempotent operations
- `try`/`catch` so wide it hides bugs in unrelated code

#### Resource & lifecycle

- File handles, streams, DB connections opened but not closed (esp. on early returns)
- `useEffect` without a cleanup function for subscriptions / timers / listeners
- Event listeners added but never removed
- Caches that grow without bounds
- Timers (`setInterval`, `setTimeout`) not cleared
- Background tasks spawned without a way to cancel them

#### Performance traps

- N+1 queries inside a loop (DB calls, network calls, file reads)
- Quadratic algorithms over user-controlled input sizes
- Re-computing the same value inside a tight loop
- Synchronous I/O on a request hot path
- Loading entire files / result sets into memory when streaming would do
- Repeated `JSON.parse` / regex compilation in hot code

#### API & contract

- Public function signatures changed without updating callers
- Return type changed (e.g. now returns `null` where it never did before)
- Optional parameter made required, or vice versa
- Error mode changed (throws where it used to return `null`, or vice versa)
- Breaking change to a wire format / DB schema / event payload with no migration

#### Logic & data flow

- Dead code: branches that can never execute, unreachable returns
- Unused variables, parameters, imports
- Duplicated code that should be extracted (only flag if it's genuinely a problem, not stylistic)
- Magic numbers / strings that should be named constants
- Variables shadowing outer scope in confusing ways
- Mutating function arguments when the caller doesn't expect it

#### Tests & assertions

- Test asserts the function ran but not that it did the right thing (`expect(fn).toHaveBeenCalled()` with no value check)
- `expect(...).resolves` without `await` / `return`
- Tests that pass only because of test-ordering side effects
- Snapshots covering output that nobody reads or verifies
- Missing tests for the failure path when only the happy path is covered
- Hardcoded `sleep` / `setTimeout` instead of waiting for an actual condition

#### Bad assumptions

- Hardcoded paths, hostnames, ports that won't survive a different env
- Locale-dependent code (`toLowerCase`, date parsing) without explicit locale
- Assuming a list is sorted, unique, or non-empty when nothing guarantees it
- Assuming a remote service is always reachable / fast / consistent
- Assuming env vars exist without a fallback or clear error

#### Readability red flags (only if egregious)

- Functions doing five unrelated things
- Names that lie about what the code does
- Comments that contradict the code
- Boolean parameters with no name at the call site (`doThing(true, false, true)`)

### 4. Output

Group by severity. Use these levels:

- **Critical** — will cause incorrect behavior, data loss, or crash on a normal code path
- **High** — will cause incorrect behavior on an edge case that's reachable in practice
- **Medium** — fragile, risky, or wrong in a way that may not bite immediately
- **Low** — quality / maintainability issue, not a bug per se

Format:

```
## Find the flaws — <staged | branch <base>...HEAD>

<files reviewed>, <total findings>

### Critical
- <file>:<line> — <one-line description>
  → <recommendation>

### High
...

### Medium
...

### Low
...

### Clean
- <category> — no issues found
```

If a finding requires runtime context to confirm, mark it `[needs verification]` and explain what would confirm or refute it. If you're guessing at intent because the code is ambiguous, say so and ask — don't invent a flaw.

### 5. Don'ts

- ❌ Don't fix anything. Report only.
- ❌ Don't grade the whole codebase — only what's in the diff.
- ❌ Don't pad with stylistic nitpicks to look thorough — say "clean" when a category is clean.
- ❌ Don't re-flag security issues that `security-audit` covers (injection, secrets, crypto, authz). Defer those there.
- ❌ Don't flag "missing comment" or "missing docstring" unless the code is genuinely unreadable without one.
- ❌ Don't invent flaws. If the code is good, say so.
