---
name: security-audit
description: Read-only security review of staged changes or branch diff. Looks for injection, XSS, hardcoded secrets, weak crypto, missing auth checks, unsafe deserialization, SSRF, path traversal, and obviously bad patterns. Reports findings — never modifies code. Use before opening a PR or when the user asks "any security issues with this".
user-invocable: true
allowed-tools:
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git status:*)
  - Bash(git rev-parse:*)
  - Read
  - Grep
---

# security-audit

Static, read-only review of changed code for security issues. **Never edit, never commit, never push** — output findings only.

## Scope

Reviews **only the diff**, not the whole codebase. Two modes:

- **Staged** (default if there's anything in the index): `git diff --cached`
- **Branch** (no staged changes): `git diff <base>...HEAD`

If both are empty, say so and stop.

This is not a substitute for a real SAST tool (Semgrep, CodeQL, Snyk). It's a fast first-pass smell-check focused on what an LLM can actually read with judgment.

## Steps

### 1. Determine the diff

```bash
git diff --cached --stat               # if non-empty, use staged
git rev-parse --abbrev-ref HEAD        # current branch
git diff main...HEAD --stat            # otherwise, branch diff
```

If on `main` / `master` with no staged changes, ask the user what to review.

### 2. Read the diff

For each changed file, read enough of the surrounding code to understand the context — not just the patch hunks. A line that *looks* fine in isolation can be vulnerable when you see how its inputs flow.

### 3. Check each category

For each category below, scan the diff and report findings with `file:line` and a one-line explanation. Skip categories that don't apply to the language/diff.

#### Injection — SQL, NoSQL, command, LDAP

- String concatenation into SQL queries (`"SELECT ... WHERE id = " + userId`)
- Template literals with untrusted values inside `query()` / `execute()`
- `child_process.exec` / `os.system` with concatenated user input
- MongoDB queries built from raw user objects (`{ $where: req.body.filter }`)

✅ Good: parameterized queries, prepared statements, ORM with bound params, `execFile` with arg array

#### XSS — output encoding

- `dangerouslySetInnerHTML`, `v-html`, `innerHTML =` with user data
- Server-rendered templates that disable auto-escaping
- Markdown / HTML rendered without a sanitizer (DOMPurify, bleach)

#### Hardcoded secrets

- API keys, tokens, passwords, private keys committed in source
- Look for `sk-…`, `xoxb-…`, `ghp_…`, `glpat-…`, `AKIA…`, `-----BEGIN`
- Constants named `*_KEY`, `*_TOKEN`, `*_SECRET` with non-empty literal values
- See `lozymon/no-secrets-in-code` for the full rule

#### Weak / wrong crypto

- `MD5`, `SHA1` for anything security-related (passwords, tokens, signatures)
- `Math.random()` / `random.random()` used for tokens, IDs, session keys
- Custom encryption — almost always wrong
- Hardcoded IVs / nonces, or reused nonces with the same key
- `Cipher.getInstance("AES")` (defaults to ECB on most JVMs)

✅ Good: `crypto.randomUUID`, `secrets.token_urlsafe`, libsodium, established AEAD modes (GCM, ChaCha20-Poly1305), `bcrypt`/`argon2` for passwords

#### Missing auth / authz

- New endpoint without an auth guard or middleware on routes that need one
- Authorization checks that compare user ID from the URL to nothing (IDOR)
- "Admin" actions gated only by a UI hide, not a server check

#### Unsafe deserialization

- `pickle.loads`, `yaml.load` (without `SafeLoader`), `Marshal.load`, Java native serialization on untrusted data
- `JSON.parse` is fine — the problem is *what you do with the result*

#### SSRF

- `fetch(url)` / `requests.get(url)` where `url` comes from user input without an allowlist
- Webhook / proxy endpoints that accept arbitrary URLs
- URL-fetching without blocking link-local / private IP ranges (169.254.169.254, 10.0.0.0/8, etc.)

#### Path traversal

- File paths built from user input without normalization
- `os.path.join(base, user_input)` doesn't prevent `../` — check after with `os.path.commonpath` or equivalent
- `fs.readFile(req.params.filename)` straight off the wire

#### Other smells

- `eval`, `Function(...)` constructor, `setTimeout(string)`, `vm.runInThisContext` on untrusted input
- CORS set to `*` or reflecting the `Origin` header without checks, with `credentials: true`
- `cookie` set without `Secure` / `HttpOnly` / `SameSite` for session/auth cookies
- Logging of secrets, tokens, full request bodies in error paths
- Disabled TLS verification (`rejectUnauthorized: false`, `verify=False`)
- Permissive file modes (`chmod 777`) on writable dirs

### 4. Output

Group by severity. Use these levels:

- **Critical** — exploitable in this diff with default config (e.g. SQLi from a route reachable without auth)
- **High** — exploitable with reasonable assumptions (e.g. missing authz on an admin route)
- **Medium** — risky pattern, may not be exploitable depending on context (e.g. weak randomness for non-secrets)
- **Low** — code-smell, should be fixed but not urgent (e.g. logging request bodies)

Format:

```
## Security audit — <staged | branch <base>...HEAD>

<files reviewed>, <total findings>

### Critical
- <file>:<line> — <one-line description>
  → <recommendation>

### High
...

### Medium
...

### Low
...

### Clean
- <category> — no issues found
```

If a finding requires runtime context to confirm exploitability, mark it `[needs verification]` and explain what would confirm or refute it.

### 5. Don'ts

- ❌ Don't fix anything. Report only.
- ❌ Don't grade the whole codebase — only what's in the diff.
- ❌ Don't fabricate CVEs or claim a finding maps to a specific known vulnerability without certainty.
- ❌ Don't pad with low-severity findings to look thorough — say "clean" when a category is clean.
- ❌ Don't run dependency scans here — that's a different skill / tool.
