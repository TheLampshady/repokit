# Deep Scan

The whole-repo pass of `sync`. Everything normal sync does, plus four checks that only make sense across the entire repository at once.

**Invoke:** `/repokit:dockit sync --deep`, or ask for a "deep scan", "full scan", "check everything", "scan everything".

**When it's worth it:** after a refactor or rename, after a first `init` (to see whether generation actually did well), and on a slow cadence — monthly is plenty. Normal sync is diff-scoped and fast; this one reads every doc and every source file.

**Writes nothing extra.** Normal sync's updates still apply. Everything this pass finds is reported, and human-required items route to `/repokit status`.

---

## Why these four live here and not in normal sync

Normal sync looks at what changed. That's the right scope for keeping docs current, and it's what keeps sync fast enough to run after every change. But four failure modes are structurally invisible to a diff-scoped pass:

| Check | Why a diff can't catch it |
|---|---|
| Reference verification | A path breaks when the *code* moves, not when the doc changes — the doc is never in the diff |
| Promotion offers | Whether an `intended` path has been adopted is a whole-repo question, and the answer must stay opt-in |
| Reverse check | Code that was never documented never appears in a doc diff |
| Filter re-application | Docs written before a filter existed were never tested against it |

**Note what isn't here.** There is no conformance re-check on an unmarked rule. Dockit measures a rule once, when writing it, and never re-measures ([CHOICE-MINING.md § On sync](./CHOICE-MINING.md#on-sync-a-choice-is-not-re-litigated)). "How many files currently follow this rule" is a linter's question, and a deep scan is not the place to smuggle it back in.

---

## Check 1 — Reference verification

Read every doc and confirm each claim points at something real.

### Collect

- `README.md` (root and service-level)
- `docs/**/*.md`
- `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `CONTRIBUTING.md`, `CHANGELOG.md`
- Any `.md` reached by a link from the above

Skip `node_modules/`, `.git/`, `vendor/`, `dist/`, `build/`.

### Extract and verify

| Reference type | Looks like | Verify by |
|---|---|---|
| File paths | `` `src/auth/middleware.ts` ``, "see `config/database.yml`" | Path exists relative to repo root. For globs, at least one match |
| Internal doc links | `[Architecture](docs/ARCHITECTURE.md)`, `[setup](../ENV.md#local)` | Target resolves from the containing file; anchors match a real heading slug |
| Code identifiers | `` `authenticate()` ``, `` `UserService` class `` | Grep source for definitions/exports. Be pragmatic — `` `true` ``, `` `null` ``, `` `string` `` aren't references |
| Commands | `npm run build`, `make test` | `scripts` in `package.json`; `Makefile` targets; custom scripts exist and are executable. Skip external tools (`npx`, `pip install`, `cargo build`) |
| Env vars | `DATABASE_URL`, `$API_KEY` | Present in `.env.example`, `docker-compose.yml`, source (`os.environ` / `process.env`), or CI `env:` blocks |
| Dependencies | "requires Redis 7+" | Named in `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, or compose file; version constraint matches |
| **Named anti-patterns** | "direct `os.environ` reads bypass validation", "importing `vendor_sdk` skips auth" | The named accessor or import still appears somewhere in the source, **or** the sanctioned path it points at still exists. Neither → the rule is describing a hazard the project no longer has |

**Why anti-patterns are a reference type.** A boundary rule's anti-pattern is the part an agent acts on, so a stale one is expensive: a rule warning about `os.environ` in a project that has moved to a different config library trains the agent to look for the wrong thing. Report it, never repair it — the rule might need repointing at the new anti-pattern, or might not apply at all. That's a judgment call.

### Classify

| Status | Meaning |
|---|---|
| `verified` | Exists exactly as documented — omit from the report, it's noise |
| `broken` | Doesn't exist |
| `moved` | A likely match exists elsewhere (fuzzy match on basename or similar identifier) |
| `unverified` | Can't be checked automatically — external URLs, ambiguous references |

Report `moved` with the suggested new location: `src/utils/auth.ts` → `src/lib/auth.ts`.

---

## Check 2 — Reverse check

Everything above asks "does the doc match the code?" This asks the opposite: **what exists in the code that no doc mentions?**

Silent omission is the statistically dominant form of doc drift — most code changes never trigger a doc update at all — and a diff-scoped pass is blind to it by construction.

- Score every source file the way [FOUNDATIONS-DETECTION.md](./FOUNDATIONS-DETECTION.md) does. Any file above threshold that has no row in `FOUNDATIONS.md` is an undocumented foundation.
- Diff the commands in `Makefile` / `package.json` scripts against the ones documented anywhere.
- Diff env vars read in source against those documented in `ENVIRONMENTS.md`.
- List top-level modules or packages with no mention in any doc.

Report these as gaps to fill, not as errors.

---

## Check 3 — Promotion offers for `intended`

The one check that looks at an existing rule's relationship to the code, and it is deliberately confined here: `--deep` is opt-in, slow, and explicitly a re-examination. Normal sync never does this.

For every foundation at `status: intended` and every rule marked `[intended]`, ask one question: **do consumers exist now?**

| Finding | Offer |
|---|---|
| Consumers exist | *"`Settings` now has 12 consumers — drop the `[intended]` marker?"* Review-queue question, never applied automatically |
| Still none | **Report nothing.** That's the status doing its job |

**One-directional, without exception.** This check can only ever offer to *remove* a marker. It never adds one, never reports falling adoption on an unmarked rule, and never converts an `active` foundation back to `intended` — that would be a decay flag, which is banned everywhere in dockit ([CHOICE-MINING.md § On sync](./CHOICE-MINING.md#on-sync-a-choice-is-not-re-litigated)).

And it never fires on elapsed time. An `intended` rule that has sat unadopted for a year is reported the same way as one written yesterday: not at all.

---

## Check 4 — Filter re-application

Docs written before the mining filters existed were never tested against them, and a rule can stop being surprising as the ecosystem moves.

Re-run both filters from [CHOICE-MINING.md](./CHOICE-MINING.md#the-two-filters) over every existing Convention and Rule:

1. **Name the alternative** — can a plausible alternative the team rejected still be named? If not, it's an ecosystem default, not a decision.
2. **Machine-enforced** — has a linter, formatter, type checker, or CI gate started enforcing this since it was written? Then the doc line is dead weight.

Flag candidates; **never delete**. A rule that fails filter 1 today may have been a real decision when written, and removing a line from a human-authored Rule is not a machine's call. Route to `/repokit status`.

---

## Report format

```markdown
## Deep Scan

**Scanned:** 14 docs · 312 source files

| Check | Result |
|-------|--------|
| References | 4 broken · 2 moved · 3 unverified · 2 stale anti-patterns ⚠️ |
| Undocumented | 3 modules · 1 likely foundation |
| Promotion offers | 1 `intended` path now has consumers |
| Filter re-check | 4 rules would not be written today |

### Stale anti-patterns  ⚠️
| Doc | Rule | Problem |
|-----|------|---------|
| PRINCIPLES.md | "Use `SearchClient` — direct `vendor_sdk` imports skip auth" | `vendor_sdk` appears nowhere in source; dependency dropped? |
| FOUNDATIONS.md | `core.cache` → "`redis.Redis(` direct construction bypasses the pool" | `redis` not in `pyproject.toml` |

### Promotion offers
| Doc | Marked `intended` | Now |
|-----|-------------------|-----|
| FOUNDATIONS.md | `core.settings` | 12 consumers across 4 features — drop the marker? |

### Broken references
| Doc | Line | Reference | Detail |
|-----|------|-----------|--------|
| README.md | 12 | `src/old-auth/handler.ts` | Not found |
| README.md | 34 | `npm run deploy` | No `deploy` script in package.json |

### Moved
| Doc | Line | From | Likely now |
|-----|------|------|-----------|
| README.md | 45 | `src/auth/handler.ts` | `src/lib/auth/handler.ts` |

### Undocumented
- `app/core/ratelimit.py` — fan-in 14 across 4 features, no FOUNDATIONS row
- `make seed-demo` — in Makefile, documented nowhere

### Would not be written today
| Doc | Rule | Filter |
|-----|------|--------|
| PRINCIPLES.md | "Type hints on all functions" | mypy enforces it — machine-enforced |
| PRINCIPLES.md | "Tests live in `tests/`" | No alternative to name — ecosystem default |

**7 items need a decision.** Run `/repokit status` to walk them.
```

Omit any section with no findings. If everything is clean, say so in one line and stop.

---

## Scope

The deep scan checks **verifiable claims** — things resolvable by reading the filesystem. It does not:

- Judge whether prose explanations are accurate or well written
- Check external URLs (needs network; offer as a separate pass if asked)
- Verify documented behaviour against runtime behaviour (that's testing)
- Auto-fix anything it finds

Long-form prose is the known gap. A paragraph describing how the auth flow works can drift while every grep-able reference inside it stays valid. Catching that needs a model reading code and prose side by side — a different mechanism, not this one.
