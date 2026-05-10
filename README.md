# airules

Workspace for authoring and publishing ruleshub assets under the `lozymon/` namespace.

See [PLAN.md](PLAN.md) for the full design and roadmap.

## Layout

```
rules/        commands/     skills/       workflows/
agents/       mcp-servers/  packs/
```

Each subdirectory holds individual ruleshub asset packages. Each asset folder is self-contained — its own `ruleshub.json` plus a content file (`CLAUDE.md`, `command.md`, `SKILL.md`, etc.).

## Getting started

```bash
npm install                    # installs ruleshub CLI as devDep
npm run validate               # validates every asset's ruleshub.json
```

## Publishing one asset

```bash
cd rules/typescript-strict
RULESHUB_TOKEN=... npx ruleshub publish
```

Get a token at [ruleshub.dev/dashboard](https://ruleshub.dev/dashboard) → API Keys.

## Authoring conventions

See §4 of [PLAN.md](PLAN.md). Short version:

- Slug: `^[a-z][a-z0-9-]*$`, no type or AI-tool prefix
- SemVer starting `0.1.0`
- MIT license
- Description answers *what does this do?*, ≤200 chars, no trailing period
- Changelog entry on minor/major bumps

## License

MIT for asset content. See each asset's `ruleshub.json` for its declared license.
