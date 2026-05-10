# Git Commit Conventions

All commit messages follow [Conventional Commits](https://www.conventionalcommits.org/). This makes history scannable and lets tooling generate changelogs and bump versions automatically.

## Format

```
<type>(<scope>): <subject>

<body — optional>

<footer — optional>
```

Example:

```
feat(auth): add password reset flow

Adds /reset endpoint and email-based confirmation token.
Tokens expire after 30 minutes.

Closes #142
```

## Allowed types

| Type       | Use for                                                       |
| ---------- | ------------------------------------------------------------- |
| `feat`     | A new feature visible to users                                |
| `fix`      | A bug fix visible to users                                    |
| `refactor` | Code change that neither adds a feature nor fixes a bug       |
| `perf`     | Performance improvement                                       |
| `test`     | Adding or correcting tests                                    |
| `docs`     | Documentation only                                            |
| `style`    | Formatting, whitespace, missing semicolons (no logic change)  |
| `build`    | Build system, dependencies, package manifests                 |
| `ci`       | CI configuration and scripts                                  |
| `chore`    | Maintenance with no production code change (deps, tooling)    |
| `revert`   | Reverts a previous commit (subject: `revert: <orig subject>`) |

If you can't pick one, the commit probably bundles unrelated changes — split it.

## Subject rules

- **Imperative mood** — `add login` not `added login` or `adds login`. Read it as "this commit will…".
- **Lowercase first letter**, no trailing period.
- **≤72 characters total** including the `type(scope):` prefix.
- **Don't repeat the type in the subject** — `fix(auth): fix broken login` is redundant.

## Scope

Optional but encouraged. Usually a module, package, or area: `auth`, `api`, `web`, `cli`, `db`. Use the path the user would search for, not the full file path.

For monorepos, use the package name: `feat(@org/types): ...`.

## Body

- Wrap at 72 columns.
- Explain **why**, not what — the diff already shows what.
- Use bullet points for multiple unrelated points within a single logical change.
- Reference issues in the footer, not the body.

## Footer

Two footer types matter:

```
BREAKING CHANGE: <description of what breaks and how to migrate>
Closes #<issue>
```

- `BREAKING CHANGE` triggers a major version bump under SemVer-aware release tooling.
- Alternatively, mark the type with `!`: `feat(api)!: drop deprecated /v1 endpoint`.
- `Closes`, `Fixes`, `Refs` link to issues — GitHub auto-closes on merge.

## Don'ts

- ❌ `wip`, `fixup`, `more changes`, `address pr feedback` — never commit these to a long-lived branch. Squash before merging.
- ❌ `Update file.ts` — say what changed and why.
- ❌ Mixing types: `feat: add login and fix typo in readme` → split into two commits.
- ❌ Commit messages that only restate the diff: `feat(auth): add login function` for a commit whose only change is adding `function login()`.
- ❌ Skipping the type to seem informal: `fixed the bug` → `fix: <what was broken>`.

## Squash before merge

Feature branches accumulate WIP commits. Squash them into the meaningful units before merging — see the `commit-cleanup` skill if available.
