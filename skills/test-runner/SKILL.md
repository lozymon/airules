---
name: test-runner
description: Detect the project's test framework, run the suite (or a focused subset), and summarize failures with file:line and the assertion that failed. Use when the user says "run the tests", "are tests passing", "run the auth tests", or after edits that should be verified.
user-invocable: true
allowed-tools:
  - Bash(npm:*)
  - Bash(pnpm:*)
  - Bash(yarn:*)
  - Bash(npx:*)
  - Bash(pytest:*)
  - Bash(python:*)
  - Bash(cargo:*)
  - Bash(go:*)
  - Bash(rspec:*)
  - Bash(bundle:*)
  - Bash(mvn:*)
  - Bash(gradle:*)
  - Bash(dotnet:*)
  - Bash(jest:*)
  - Bash(vitest:*)
  - Bash(ls:*)
  - Bash(cat:*)
  - Read
  - Grep
---

# test-runner

Run the project's tests and report results. Detect the framework from project files — don't guess.

## When to use

- User asks "run the tests" / "are tests passing"
- User asks for a focused subset: "run the auth tests", "test the login flow"
- After edits that should be verified before declaring done

## When NOT to use

- The change is documentation-only (READMEs, comments) — say so and skip.
- The user explicitly says they don't want tests run.

## Detection — read in this order

Stop at the first match. Don't run multiple test commands hoping one works.

| File / signal | Likely framework | Default command |
| --- | --- | --- |
| `package.json` with `"test"` script | npm-based | `<pm> test` (pm = pnpm/yarn/npm based on lockfile) |
| `package.json` with `vitest` dep | Vitest | `<pm> exec vitest run` |
| `package.json` with `jest` dep | Jest | `<pm> exec jest` |
| `pyproject.toml` with `pytest` / `tool.pytest` | pytest | `pytest` (or `uv run pytest` if `uv.lock` present) |
| `Cargo.toml` | Rust | `cargo test` |
| `go.mod` | Go | `go test ./...` |
| `Gemfile` with `rspec` | RSpec | `bundle exec rspec` |
| `pom.xml` | Maven | `mvn test` |
| `build.gradle*` | Gradle | `./gradlew test` |
| `*.csproj` / `*.sln` | .NET | `dotnet test` |

If `package.json` declares a `"test"` script, **prefer it** over inferring — it's what CI runs.

If detection fails entirely, ask the user how they run tests.

## Running

### Full suite (default)

Run the detected command, capture stdout + stderr.

### Focused subset

If the user asked for a specific area, narrow the run:

- **Vitest / Jest**: `<cmd> <path>` or `<cmd> -t "<test name pattern>"`
- **pytest**: `pytest <path>` or `pytest -k <expression>`
- **cargo**: `cargo test <module>` or `cargo test <test_name>`
- **go**: `go test ./<package>/...` or `go test -run <regex>`

When narrowing, prefer path-based filtering over name-based — it's faster and less ambiguous.

### Watch mode

Don't run watch mode. It doesn't terminate.

## Output

After the run, produce a structured summary — not the raw test output.

### If green

```
✓ <framework>: <N> passed in <duration>
  (ran: <command>)
```

### If red

```
✗ <framework>: <P> passed, <F> failed in <duration>
  (ran: <command>)

Failures:

1. <test name> (<file>:<line>)
   <one-line failure reason — assertion + values>

2. <test name> (<file>:<line>)
   <one-line failure reason>

[full output truncated — N more lines]
```

For each failure include:
- The exact test name as the framework reports it
- File and line of the failing assertion (not the test file's first line)
- The assertion gist: `expected 5, got 3` — not the full diff unless tiny

If many tests fail with the same root error (e.g. compile error, missing dep), say so once and skip the per-failure detail.

### If the run never started

```
✗ test run failed to start
  Reason: <missing dep / config error / command not found>
  Suggested fix: <one concrete next step>
```

## Don'ts

- ❌ Don't modify code to make tests pass — that's a separate task.
- ❌ Don't write new tests — different skill.
- ❌ Don't run `--watch`, `--ui`, or any mode that doesn't terminate.
- ❌ Don't dump raw test output as the entire response. Summarize.
- ❌ Don't claim tests pass if they were skipped — count skipped separately.
