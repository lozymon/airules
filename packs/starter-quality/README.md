# lozymon/starter-quality

Baseline code-quality pack for TypeScript projects. Installs three assets:

| Asset | Type | What it does |
| --- | --- | --- |
| [lozymon/typescript-strict](https://ruleshub.dev/lozymon/typescript-strict) | rule | Strict TS rules — no `any`, exhaustive switches, narrow types |
| [lozymon/pr-review](https://ruleshub.dev/lozymon/pr-review) | command | `/pr-review` slash command — reviews the current branch's diff |
| [lozymon/commit-cleanup](https://ruleshub.dev/lozymon/commit-cleanup) | skill | Tidies WIP commits and rewrites messages to conventional-commits |

## Install

```bash
npx ruleshub install lozymon/starter-quality --tool claude-code
```

## When to use this pack

- New TypeScript project that doesn't have CLAUDE.md / commit conventions yet
- Existing project where you want a quick baseline before layering project-specific rules on top

## When NOT to use it

- If you already have strict TypeScript and commit hygiene dialed in — install the individual assets you actually want instead.
- If your project isn't TypeScript-heavy. The `typescript-strict` rule has no effect on Python/Go/Rust files, but its presence in CLAUDE.md is noise.

## License

MIT
