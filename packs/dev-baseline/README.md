# lozymon/dev-baseline

Language-agnostic code-quality + security baseline. Eight assets that work across any language and any project type.

| Asset | Type | What it does |
| --- | --- | --- |
| [git-commit-conventions](https://ruleshub.dev/lozymon/git-commit-conventions) | rule | Conventional Commits format and allowed types |
| [no-secrets-in-code](https://ruleshub.dev/lozymon/no-secrets-in-code) | rule | Env vars only, never log/commit/embed secrets |
| [pr-review](https://ruleshub.dev/lozymon/pr-review) | command | `/pr-review` — review the current branch before opening a PR |
| [bug-fix](https://ruleshub.dev/lozymon/bug-fix) | command | `/bug-fix` — reproduce → root cause → failing test → minimal fix |
| [refactor-extract](https://ruleshub.dev/lozymon/refactor-extract) | command | `/refactor-extract` — behavior-preserving extraction with verification |
| [commit-cleanup](https://ruleshub.dev/lozymon/commit-cleanup) | skill | Tidy WIP commits and rewrite messages to convention |
| [test-runner](https://ruleshub.dev/lozymon/test-runner) | skill | Detect framework, run suite or focused subset, summarize failures |
| [security-audit](https://ruleshub.dev/lozymon/security-audit) | skill | Read-only OWASP-style review of staged/branch diff |

## Install

```bash
npx ruleshub install lozymon/dev-baseline --tool claude-code
```

## Pick the right pack for your stack

| Project | Install |
| --- | --- |
| Any language — universal baseline | `lozymon/dev-baseline` (this) |
| TypeScript / Node / React / Next | [`lozymon/dev-baseline-ts`](https://ruleshub.dev/lozymon/dev-baseline-ts) — adds `typescript-strict` |
| Minimal three-asset starter (TS) | [`lozymon/starter-quality`](https://ruleshub.dev/lozymon/starter-quality) |

`dev-baseline-ts` is a strict superset of `dev-baseline` — install one, not both.

## When to use

- Polyglot or non-TS project that wants strong defaults from day one
- A project where you want the workflow assets (review, bug-fix, refactor) without language-specific rules

## When NOT to use

- You already have a stronger / project-specific CLAUDE.md and don't want generic rules merged in.
- You're on TypeScript — install `dev-baseline-ts` instead for the strict-types rule.

## License

MIT
