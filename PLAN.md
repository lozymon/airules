# Agents — roadmap

Forward-looking list of subagents to publish under `lozymon/`. Bias: agents that are **read-heavy and parallelizable** (save main context, play to subagent strengths) or that have a **fixed, valuable output format**. Skip ideas that would just wrap inline behavior Claude already does well.

Today: 0 agents. 7 skills (`businessmap`, `commit-cleanup`, `draft-issue`, `drill-me`, `find-the-flaws`, `security-audit`, `test-runner`), 3 commands, 3 rules.

## Candidates

### Review / critique
Complements existing skills (`find-the-flaws`, `security-audit`). These run as one-shot read-only critics.

- **api-design-reviewer** — review a proposed TS interface / REST endpoint / GraphQL schema for consistency, error handling, evolvability
- **doc-drift-detector** — read README + docs, compare against code, surface docs that lie
- **naming-reviewer** — flag bad names in changed code (acronyms, lying names, ambiguous abbreviations, type-redundant suffixes)

### Authoring
Fixed output formats, run on a diff or range. Save main context by keeping the writing pass in a subagent.

- **pr-description-author** — given branch diff, produce Summary / Why / Test plan / Risk / Reviewer notes
- **release-notes-writer** — user-facing release notes grouped by user impact (not commit type); pairs with `commit-cleanup`
- **rfc-author** — deeper interview than an ADR; outputs RFC with prior art, options, FAQs

### Research
Read-only and parallelizable — these earn the subagent overhead most clearly.

- **dep-auditor** — audit package manifests for outdated, vulnerable, abandoned, duplicated deps
- **dead-code-hunter** — find exports/files with no inbound references; smart about dynamic imports, plugin patterns, framework conventions
- **migration-impact-scanner** — given a renamed type / changed signature / deleted helper, map every call site and grade migration difficulty per call site

### Testing
- **edge-case-generator** — given a function signature + behavior description, propose a comprehensive list of edge cases worth covering

## Suggested build order

1. **pr-description-author** — highest leverage; universal need; fixed output; complements existing review skills
2. **dep-auditor** — read-only, parallelizable, clear value, well-scoped
3. **dead-code-hunter** — strong fit for subagent (heavy reading), genuinely hard to do well inline
4. **doc-drift-detector** — read-heavy, fixed output (drift report), pairs with naming/api review
5. **migration-impact-scanner** — high value when needed; lower frequency
6. **release-notes-writer** — depends on `commit-cleanup` workflow being in use
7. **api-design-reviewer** — useful but narrower audience (TS / REST / GraphQL teams)
8. **naming-reviewer** — narrowest scope; build last or fold into `find-the-flaws`
9. **edge-case-generator** — useful but needs careful prompt design to avoid generic output
10. **rfc-author** — overlaps with `drill-me`'s decision/spec scaffolds; build only if RFC-specific format earns its place

## Open decisions before building

- **Agent definition format** — confirm the schema (`agents/<name>/agent.md` + `ruleshub.json`?) and a reference example. The workspace currently has `agents/` but no assets in it.
- **Tool allowlists per agent** — should agents inherit a base allowlist (Read, Grep, Bash for git) or declare from scratch each time?
- **Output conventions** — agents that report back to a parent should agree on a fixed report format (e.g., findings grouped by severity, like `find-the-flaws`). Worth a shared style guide before authoring multiple agents.
- **Naming** — agents/skills with overlapping names (e.g., a future `pr-review` agent vs. the existing `pr-review` command) need disambiguation.
