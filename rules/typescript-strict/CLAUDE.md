# TypeScript Strict

Rules to keep TypeScript code honest. These apply to all `.ts` and `.tsx` files in the project.

## `tsconfig.json`

These compiler options must be enabled. If they aren't, fix `tsconfig.json` first — every other rule below assumes them.

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

---

## Never use `any`

Type explicitly, or use `unknown` and narrow.

```ts
// Bad
function parse(input: any) { ... }

// Good — caller must narrow
function parse(input: unknown): Parsed { ... }
```

`any` at module boundaries leaks into every caller. Treat external data (`JSON.parse`, `fetch().json()`, env vars) as `unknown` and validate before use — Zod, a type guard, or an explicit assertion with a runtime check.

---

## No non-null assertions (`!`)

`value!` silently lies to the type system. If you know the value is non-null, prove it:

```ts
// Bad
const user = users.find(u => u.id === id)!;

// Good
const user = users.find(u => u.id === id);
if (!user) throw new Error(`User ${id} not found`);
```

The only acceptable use of `!` is in test files where you've just asserted the value exists (`expect(x).toBeDefined()`).

---

## Exhaustive switches

Every `switch` over a union must handle every variant. Use a `never` check in the default branch:

```ts
type Status = "pending" | "active" | "archived";

function label(s: Status): string {
  switch (s) {
    case "pending":  return "Pending";
    case "active":   return "Active";
    case "archived": return "Archived";
    default: {
      const _exhaustive: never = s;
      throw new Error(`Unhandled status: ${_exhaustive}`);
    }
  }
}
```

When a new variant is added to `Status`, this fails to compile until the switch is updated. That's the point.

---

## Prefer narrow types over wide

- `string` is rarely the right type. If a field is one of a known set of values, use a union: `"pending" | "active"`.
- Don't use `object` — use a real shape or `Record<string, unknown>`.
- Don't use `Function` — type the signature: `(x: number) => string`.
- IDs from different tables should be distinct types — use branded types or per-table aliases (`type UserId = string & { __brand: "UserId" }`).

---

## Type imports

Use `import type` for type-only imports. It signals intent and lets bundlers strip them.

```ts
import type { User } from "./types";
import { fetchUser } from "./api";
```

---

## Inference vs. annotation

- **Annotate function parameters and return types** — public API, exported functions, anything across a module boundary.
- **Let inference handle locals** — `const x = compute()` is clearer than `const x: SomeType = compute()`.
- **Annotate empty arrays/objects** — `const items: Item[] = []` (otherwise inferred as `never[]`).

---

## No `// @ts-ignore`

If you need to silence the compiler, use `// @ts-expect-error` with a comment explaining why. `@ts-expect-error` fails when the underlying error goes away, prompting cleanup; `@ts-ignore` rots silently.

```ts
// @ts-expect-error — upstream types are wrong, see github.com/lib/repo/issues/123
foo.bar = 1;
```

---

## Errors are `unknown`, not `Error`

In a `catch` block, the caught value is `unknown` (with `useUnknownInCatchVariables`, the default under `strict`). Narrow before use:

```ts
try {
  await doThing();
} catch (err) {
  if (err instanceof Error) {
    logger.error(err.message);
  } else {
    logger.error(String(err));
  }
}
```

---

## Don't re-export to widen types

Exporting a value as a wider type than its definition defeats inference for every consumer. If you find yourself doing `export const x: Foo = bar as Foo`, the underlying type is wrong — fix that instead.
