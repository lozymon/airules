# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A workspace for authoring and publishing **ruleshub assets** under the `lozymon/` namespace. There is no application code here — each subdirectory of [rules/](rules/), [commands/](commands/), [skills/](skills/), [workflows/](workflows/), [agents/](agents/), [mcp-servers/](mcp-servers/), and [packs/](packs/) holds a self-contained ruleshub package consisting of a `ruleshub.json` manifest plus one content file.

Read [PLAN.md](PLAN.md) before authoring new assets — §2 defines content-file conventions per type, §3 has manifest templates, §4 has naming/versioning rules.

## Common commands

```bash
npm run validate                            # validate every asset's ruleshub.json
bash scripts/publish-one.sh <type>/<slug>   # publish single asset (needs RULESHUB_TOKEN)
cd <type>/<slug> && npx ruleshub validate   # validate a single asset
```

`scripts/validate-all.sh` walks all seven type directories at depth 2 looking for `ruleshub.json` — a new asset is picked up as soon as its manifest exists.

## Asset anatomy

Each asset folder must contain exactly two files: `ruleshub.json` and the type's content file (mapping in [PLAN.md](PLAN.md) §2 — e.g. rules use `CLAUDE.md`, commands use `command.md`, skills use `SKILL.md`). The manifest's `targets.<tool>.file` points at that content file; valid tool keys are `claude-code`, `cursor`, `copilot`, `windsurf`, `cline`, `aider`, `continue` — add an entry per tool you want the asset to target. Packs are the exception: they have no content file, only an `includes` array of `name@semver` dependencies.

**Important pitfall:** the `CLAUDE.md` files under `rules/<slug>/` are *ruleshub asset content* — bodies of rules that get injected into a consumer's project. They are NOT Claude Code instructions for this repository. This root `CLAUDE.md` is the only one Claude Code reads as project guidance.

## Naming and versioning (enforced by convention, not tooling)

From [PLAN.md](PLAN.md) §4:

- Slug is kebab-case `^[a-z][a-z0-9-]*$` — no type prefix (`rule-foo` ❌, the folder already encodes type), no tool prefix (`claude-foo` ❌, assets are provider-agnostic).
- SemVer starting `0.1.0`. Breaking content changes bump major; content additions minor; typo fixes patch.
- License defaults to MIT.
- Description: imperative mood, ≤200 chars, no trailing period, answers *what* not *why*.
- Changelog entry required on minor/major bumps.

## Publishing notes

- Token comes from ruleshub.dev/dashboard → API Keys; pass via `RULESHUB_TOKEN` env var (not committed).
- No topo-sort: pack assets must be published **after** their `includes` dependencies — order manually.
- `scripts/publish-one.sh` runs `ruleshub validate` before `ruleshub publish` and aborts if either step fails.
