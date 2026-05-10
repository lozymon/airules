# No Secrets in Code

Source files must never contain credentials. This applies to all committed files — not just production code, but also tests, scripts, fixtures, READMEs, and config templates.

## What counts as a secret

- API keys, tokens, bearer tokens
- OAuth client secrets, signing keys, webhook secrets
- Database connection strings with embedded passwords
- Private keys (RSA, ECDSA, SSH, GPG, JWT signing keys)
- Service-account JSON files
- Encryption keys, IV/salts that are meant to stay private
- Internal hostnames or admin URLs that aren't meant to be public
- Anything labeled "DO NOT SHARE" by a third party

If unsure, treat it as a secret.

## Rules

### 1. Read from environment variables, never hardcode

```ts
// Bad
const apiKey = "sk-1234567890abcdef";

// Good
const apiKey = process.env.API_KEY;
if (!apiKey) throw new Error("API_KEY is required");
```

Validate at startup, not at first use. A missing required env var should crash the process immediately so it's caught in CI / staging, not at 3am in production.

### 2. Never commit `.env` files

`.gitignore` must include:

```
.env
.env.local
.env.*.local
```

Commit a `.env.example` (or `.env.template`) with **placeholder** values and comments. Never real values, even "dev" ones.

### 3. Never log secrets

```ts
// Bad
logger.info(`Fetching with token ${token}`);

// Good
logger.info(`Fetching with token ${token.slice(0, 4)}...`);
// Or just
logger.info("Fetching with auth token");
```

Same applies to error objects — many libraries include the request headers in errors. Strip `Authorization`, `Cookie`, `X-Api-Key` before logging.

### 4. Never put secrets in URLs (query strings, paths)

URLs land in server access logs, browser history, referrer headers, and CDN logs. Use headers (`Authorization: Bearer ...`) or POST bodies.

### 5. Never check secrets into history, even temporarily

If a secret was committed — even to a feature branch, even in a now-deleted file:

1. Treat it as compromised. Rotate it immediately.
2. Then remove it from history (`git filter-repo` or BFG), force-push, and notify collaborators.

`git rm` alone doesn't help — the secret is still in earlier commits.

### 6. Use a secret manager in production

Local dev: `.env` file (gitignored).
CI: encrypted secrets in the CI provider (GitHub Actions secrets, GitLab CI variables).
Production: a real secret manager — AWS Secrets Manager, HashiCorp Vault, Doppler, Infisical, GCP Secret Manager. Never `.env` files on production servers.

### 7. Never embed secrets in client-side code

Anything shipped to a browser or mobile app is public. If a third-party service requires an API key in the client, it must be a key with a restricted scope (e.g. domain-locked) — never your full-access server key.

For server-only secrets in Next.js: use `process.env.X` (no `NEXT_PUBLIC_` prefix). For Vite: never reference them outside `import.meta.env` server entry points.

## Pre-commit detection

Use a tool like `gitleaks`, `trufflehog`, or `detect-secrets` in pre-commit hooks. They catch obvious patterns (`AKIA…`, `sk-…`, `-----BEGIN PRIVATE KEY-----`, etc.) before push.

A pre-commit hook isn't a substitute for the rules above — it's a safety net for when someone forgets.

## Common smells to flag

- A constant named `*_KEY`, `*_TOKEN`, `*_SECRET`, `*_PASSWORD` with a non-empty string literal
- A 40-character hex string that doesn't look like a hash of stable input
- Strings starting with `sk-`, `xoxb-`, `ghp_`, `glpat-`, `Bearer ey…`
- `-----BEGIN ` anywhere in the codebase outside test fixtures
- A `.env` file that isn't in `.gitignore`
- An access log that includes `Authorization` headers
