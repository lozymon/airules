# airules — Plan

Workspace for authoring and publishing many ruleshub assets (rules, commands, skills, workflows, agents, mcp-servers, packs) under the `lozymon/` namespace.

---

## 1. Workspace layout (flat by type)

```
airules/
├── README.md                       # what this repo is, how to publish
├── PLAN.md                         # this file
├── .gitignore                      # node_modules, dist, .env
├── package.json                    # dev tooling: ruleshub CLI as devDep
├── scripts/
│   ├── validate-all.sh             # walks every asset dir, runs `ruleshub validate`
│   └── publish-all.sh              # publishes only assets with bumped versions
├── rules/
│   └── <slug>/
│       ├── ruleshub.json
│       └── CLAUDE.md
├── commands/
│   └── <slug>/
│       ├── ruleshub.json
│       └── command.md
├── skills/
│   └── <slug>/
│       ├── ruleshub.json
│       └── SKILL.md
├── workflows/
│   └── <slug>/
│       ├── ruleshub.json
│       └── workflow.md
├── agents/
│   └── <slug>/
│       ├── ruleshub.json
│       └── agent.md
├── mcp-servers/
│   └── <slug>/
│       ├── ruleshub.json
│       └── README.md
└── packs/
    └── <slug>/
        ├── ruleshub.json           # only `includes`, no content file
        └── README.md
```

Each asset folder is a self-contained ruleshub package: `cd <folder> && ruleshub publish`.

---

## 2. Asset types — what to produce in each

| Type         | Folder         | Content file              | Target effect (claude-code)                |
| ------------ | -------------- | ------------------------- | ------------------------------------------ |
| `rule`       | `rules/`       | `CLAUDE.md`               | injected into project CLAUDE.md            |
| `command`    | `commands/`    | `command.md`              | `.claude/commands/<slug>.md`               |
| `skill`      | `skills/`      | `SKILL.md`                | `.claude/skills/<slug>/SKILL.md`           |
| `workflow`   | `workflows/`   | `workflow.md`             | multi-step playbook                        |
| `agent`      | `agents/`      | `agent.md`                | `.claude/agents/<slug>.md`                 |
| `mcp-server` | `mcp-servers/` | `README.md` + JSON snippet | `.claude/settings.json` `mcpServers` entry |
| `pack`       | `packs/`       | (none — `includes` only)  | bundles dependencies                       |

---

## 3. `ruleshub.json` templates

Standard fields for every asset:

```json
{
  "$schema": "https://ruleshub.dev/schema/ruleshub.json",
  "name": "lozymon/<slug>",
  "version": "0.1.0",
  "type": "<rule|command|skill|workflow|agent|mcp-server|pack>",
  "description": "<one line, ≤200 chars>",
  "license": "MIT",
  "tags": ["<tag1>", "<tag2>"],
  "projectTypes": ["<node|python|generic|...>"],
  "targets": { "claude-code": { "file": "<content-file>" } }
}
```

Pack variant:

```json
{
  "$schema": "https://ruleshub.dev/schema/ruleshub.json",
  "name": "lozymon/<pack-slug>",
  "version": "0.1.0",
  "type": "pack",
  "description": "<bundle description>",
  "license": "MIT",
  "tags": [],
  "projectTypes": [],
  "includes": [
    "lozymon/<asset-a>@^0.1.0",
    "lozymon/<asset-b>@^0.1.0"
  ]
}
```

---

## 4. Naming & versioning conventions

- **Slug** — kebab-case, matches `^[a-z][a-z0-9-]*$`. No leading digit, no underscores, no double-hyphens.
- **No type prefix in slug** — the folder already encodes the type. Avoid `rule-typescript-strict`.
- **No AI-tool prefix in slug** — assets are provider-agnostic; tool targeting belongs in `targets`. Avoid `claude-typescript-strict`.
- **SemVer** — start at `0.1.0`. Breaking content changes bump major; content additions minor; typo fixes patch.
- **Tags** — lowercase, hyphenated, max ~5 per asset. Reuse existing tags where possible.
- **Description** — imperative mood, no trailing period. Answers *what does this do?* — not *why does it exist?* (the schema enforces ≤200 chars).
- **Changelog** — required on minor/major bumps, optional on patch. Free-form, one line per change.

---

## 5. Publish flow

1. `ruleshub validate` inside each asset folder — schema check (or `npm run validate` for the whole workspace)
2. Bump `version` in `ruleshub.json`; update `changelog` if minor/major
3. `RULESHUB_TOKEN=… ruleshub publish` (or `bash scripts/publish-one.sh <path>`)
4. Pack assets publish **after** their dependencies — manual order, no topo sort yet

Token: get from ruleshub.dev/dashboard → API Keys; store in `.env` (gitignored) or shell rc.

---

## 6. Initial roadmap

### Tier 1 — tight starter set (built ✅)

Four assets that exercise every flow (rule + command + skill + pack `includes`).

- [x] `rules/typescript-strict` — no `any`, prefer `unknown`, exhaustive switch checks
- [x] `commands/pr-review` — review a diff against project rules
- [x] `skills/commit-cleanup` — squash WIP commits, rewrite messages to convention
- [x] `packs/starter-quality` — bundles the three above

### Tier 1.5 — round out general-purpose (built ✅)

- [x] `rules/git-commit-conventions` — conventional-commits format, allowed types, do's/don'ts
- [x] `rules/no-secrets-in-code` — env vars only, what counts as a secret, rotation guidance
- [x] `commands/bug-fix` — reproduce → root cause → failing test → minimal fix → verify
- [x] `commands/refactor-extract` — behavior-preserving extraction with baseline + verification
- [x] `skills/test-runner` — detect framework, run suite or focused subset, summarize failures
- [x] `skills/security-audit` — read-only OWASP-style review of staged/branch diff
- [x] `packs/dev-baseline` — eight language-agnostic assets (no `typescript-strict`)
- [x] `packs/dev-baseline-ts` — `dev-baseline` + `typescript-strict` (nine assets, TS-flavored)
- [ ] `rules/python-typed` — deferred (do when first Python project pulls it in)
- [ ] `packs/dev-baseline-py` — deferred (parallel to `-ts`, swaps in `python-typed`)

### Tier 2 — framework specialization

- React / Next.js pack — rules + page/component scaffolds + hook fixer skill
- NestJS pack — extends existing `lozymon/nestjs-rules` samples
- Django pack — model/view/serializer rules + migration command
- FastAPI pack — router/dependency rules + endpoint scaffold

### Tier 3 — devops & integrations

- Dockerfile rules (multi-stage, non-root user, healthcheck)
- GitHub Actions workflows (test/lint/release templates)
- MCP server configs: Postgres, GitHub, Sentry, Linear

---

## 7. Locked decisions

- [x] **Repo init**: `git init` from day one — version bumps as commits, history per asset
- [x] **Local CLI**: `ruleshub` installed as devDep, `npm run validate` / `npm run publish`
- [x] **Tier 1**: 4 assets (typescript-strict / pr-review / commit-cleanup / starter-quality)
- [x] **License default**: MIT for all assets
- [x] **No topo-sort script** — manual publish order is fine until 20+ assets

---

## 8. Next steps

1. Scaffold workspace skeleton: `README.md`, `.gitignore`, `package.json`, `scripts/`
2. Create Tier 1 assets one at a time (real content, not placeholders)
3. Validate all → publish dry-run → publish
4. Move to Tier 1.5 once Tier 1 is live and we know the shape works
