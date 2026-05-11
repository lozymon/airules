---
name: businessmap
description: Interact with Businessmap (formerly Kanbanize) via its MCP server — query and search cards, create and update cards, move cards between columns, add comments, and log work/time. Use when the user asks about Businessmap/Kanbanize cards, boards, columns, workflows, "the kanban", "my cards", "move card to <column>", "add a comment to <card>", "log <time> on <card>", or links to a Businessmap/Kanbanize URL.
user-invocable: true
allowed-tools:
  - mcp__businessmap__*
  - Bash(git log:*)
  - Bash(git rev-parse:*)
  - Bash(git branch:*)
---

# businessmap

Talk to Businessmap (Kanbanize) through its MCP server. This skill is a thin orchestrator: it does **not** call the Businessmap REST API directly — every interaction goes through `mcp__businessmap__*` tools exposed by the MCP server.

## Prerequisites

The Businessmap MCP server must be installed and registered with Claude Code. If `mcp__businessmap__*` tools are not listed in the available tools when this skill runs, stop and tell the user:

> The Businessmap MCP server isn't connected. Install and register it (see the server's README), then re-run this skill.

Do not fall back to `curl`/direct API calls — the user explicitly chose MCP-based auth.

## Step 1 — Discover available tools

Different Businessmap MCP servers expose different tool names. Before assuming, list what's available by inspecting the `mcp__businessmap__*` entries in the current tool set. Map the user's intent onto the closest tool. Likely names include:

- `mcp__businessmap__search_cards` / `get_cards` / `list_cards`
- `mcp__businessmap__get_card`
- `mcp__businessmap__create_card`
- `mcp__businessmap__update_card`
- `mcp__businessmap__move_card`
- `mcp__businessmap__add_comment`
- `mcp__businessmap__log_work` / `log_time`
- `mcp__businessmap__list_boards` / `get_board`
- `mcp__businessmap__list_workflows` / `list_columns` / `list_lanes`

If a needed capability is missing, say so plainly — don't fabricate a workaround.

## Step 2 — Resolve context

Many requests are ambiguous without a board, workflow, or card ID. Resolve in this order:

1. **Explicit in user message** — IDs, URLs, board names. A Businessmap URL like `https://<acct>.kanbanize.com/ctrl_board/<board_id>/cards/<card_id>` gives you both IDs directly.
2. **Inferred from current branch** — many teams encode the card ID in branch names (e.g. `feat/12345-add-search`, `bugfix/BM-789`). Run `git rev-parse --abbrev-ref HEAD` and pattern-match for plausible IDs.
3. **Ask the user** — if still ambiguous, ask. Don't guess a board.

For the "current branch → card" lookup, treat the inferred ID as a hypothesis: confirm by fetching the card first and showing the title before acting on it.

## Step 3 — Run the operation

### Query / search

For "show me my cards", "what's in the doing column", "find cards tagged `release-blocker`":

- Default to the active board if known; otherwise list boards and ask.
- Prefer narrow filters (assignee + column + board) over fetching everything client-side.
- When showing results, keep it compact: `#<id> — <title> [<column>, <assignee>]`. Don't dump full card JSON unless asked.

### Create / update

For "create a card titled X", "set deadline to Friday", "assign #123 to me", "move #123 to Done":

- Echo the exact change you're about to make and the target card (id + title) before calling the mutation. One-line confirmation is fine — don't ask for permission a second time if the user's request was unambiguous.
- Convert relative dates to absolute ISO dates using today's date from context.
- For "move to <column>", first verify the column exists in the card's workflow — moving to a column from a different workflow will fail or move silently to the wrong place.

### Comment / log work

For "comment on #123 with the PR link", "log 2h on #123":

- For comments referencing a commit or PR, include the link verbatim. Don't shorten or rewrite.
- For work logging, pass duration in whatever unit the MCP tool expects (commonly minutes or hours — check the tool schema).

## Step 4 — Report back

After the operation, summarize in one or two lines: what changed, with the card ID and a link if the MCP returned one. For queries, lead with the count, then the list.

If a tool call fails, surface the raw MCP error — don't paraphrase it away. The user needs to see whether it's auth, a missing field, or a permissions issue.

## Don'ts

- Don't bypass the MCP server with direct HTTP calls, even if you know the API.
- Don't bulk-mutate (move/update/delete > 5 cards) without an explicit confirmation from the user in this turn.
- Don't invent card IDs, column names, or custom field keys. If you don't know one, list what exists and ask.
- Don't guess at relative dates — convert with today's date from conversation context.
- Don't paginate silently through huge result sets. Cap at ~50 items and tell the user there's more.
