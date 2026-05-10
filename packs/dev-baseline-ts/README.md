# lozymon/dev-baseline-ts

TypeScript-flavored baseline. Strict superset of [`lozymon/dev-baseline`](https://ruleshub.dev/lozymon/dev-baseline) — same eight language-agnostic assets plus [`typescript-strict`](https://ruleshub.dev/lozymon/typescript-strict).

| Asset | Type | What it does |
| --- | --- | --- |
| [typescript-strict](https://ruleshub.dev/lozymon/typescript-strict) | rule | No `any`, exhaustive switches, narrow types — TS-only |
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
npx ruleshub install lozymon/dev-baseline-ts --tool claude-code
```

## When to use

- Any TypeScript project — Node API, Next.js / React app, CLI, library
- Monorepo with TS packages
- You want a strong default baseline for a new TS codebase

## When NOT to use

- Non-TS or polyglot projects → use [`lozymon/dev-baseline`](https://ruleshub.dev/lozymon/dev-baseline) instead.
- You only need the bare three-asset starter → use [`lozymon/starter-quality`](https://ruleshub.dev/lozymon/starter-quality).
- You already have a strong project-specific CLAUDE.md and don't want generic rules merged in.

## Relationship to other packs

```
starter-quality       (3 assets, TS-flavored)
dev-baseline          (8 assets, language-agnostic)
dev-baseline-ts       (9 assets — dev-baseline + typescript-strict)
```

Install **one** of these. They overlap heavily.

## License

MIT
