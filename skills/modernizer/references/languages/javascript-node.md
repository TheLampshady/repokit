# JavaScript/TypeScript Backend (Node/Bun) Recommendations

> Reference for aicodeprep analysis. For frontend, see `javascript-frontend.md`.

## Runtime

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Node.js** | Established | MIT | Universal, largest ecosystem, battle-tested |
| Bun | Modern | MIT | Fast, all-in-one, but less mature |
| Deno | Modern | MIT | Secure by default, TypeScript native |

### Bun vs Node.js: When to Choose

| Factor | Node.js | Bun |
|--------|---------|-----|
| **Production services** | ✅ Recommended | ⚠️ Caution |
| **npm compatibility** | ✅ 100% | ⚠️ ~95%, some native modules fail |
| **Stability** | ✅ Mature, predictable | ⚠️ Breaking changes between versions |
| **Ecosystem** | ✅ Universal support | ⚠️ Some packages don't work |
| **Startup speed** | Slower | ✅ Much faster |
| **CLI tools** | Good | ✅ Great (fast startup matters) |
| **Scripts/tooling** | Good | ✅ Great |

**Bun is good for:**
- CLI tools and scripts (fast startup)
- Build tooling and dev servers
- Greenfield projects with controlled dependencies
- Teams comfortable pinning exact versions

**Node.js is better for:**
- Production backend services
- Projects with many npm dependencies
- Teams needing stability and predictability
- Existing codebases

**Recommendation:**
- Production backends → **Node.js** (stability, compatibility)
- CLI tools / scripts → **Bun** (speed)
- New projects (risk-tolerant) → **Bun** (modern DX)
- Security focus → **Deno**

## Package Management

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **pnpm** | Modern | MIT | Fast, disk efficient, strict, works with Node |
| npm | Established | Artistic-2.0 | Universal, comes with Node |
| Bun | Modern | MIT | Built into Bun runtime, fastest (if using Bun) |
| Yarn v4 | Modern | BSD-2 | Good workspaces, PnP mode |
| Yarn v1 | Legacy | BSD-2 | Still widely used |

**Recommendation:**
- Node.js projects → **pnpm** (modern) or **npm** (established)
- Bun runtime → **Bun** (built-in, no choice needed)
- Monorepos → **pnpm** or **Yarn v4**

## Linting

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **ESLint 9+** | Standard | MIT | Flat config, extensible |
| **Biome** | Modern | MIT | Fast (Rust), linter + formatter |
| ESLint 8 | Established | MIT | Legacy config format |
| TSLint | Deprecated | Apache-2.0 | Merged into ESLint |

**Recommendation:**
- Modern preference → **Biome** (all-in-one, fastest)
- Established preference → **ESLint 9+** (flat config)

## Formatting

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Prettier** | Standard | MIT | Most popular, opinionated |
| **Biome** | Modern | MIT | Includes formatting |
| dprint | Modern | MIT | Fast (Rust), configurable |

**Recommendation:**
- Using Biome → Built-in formatting
- Otherwise → **Prettier**

## Type Checking

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **TypeScript** | Standard | Apache-2.0 | Microsoft, industry standard |
| JSDoc + tsc | Alternative | - | Type checking without .ts files |

**Recommendation:** **TypeScript** with strict mode

## Testing

| Option | Type | License | Runtime | Notes |
|--------|------|---------|---------|-------|
| **Vitest** | Modern | MIT | Any | Fast, Jest-compatible, works with Node or Bun |
| Jest | Established | MIT | Node | Most popular, good mocking, lots of docs |
| Bun test | Modern | MIT | Bun only | Built into Bun, Jest-compatible API |
| Mocha + Chai | Established | MIT | Node | Flexible, mature |
| AVA | Modern | MIT | Node | Concurrent, minimal |

**Mocking HTTP:**
| Option | Type | License | Notes |
|--------|------|---------|-------|
| **MSW** | Modern | MIT | Service worker mocking, works everywhere |
| nock | Established | MIT | HTTP mocking for Node |
| WireMock | Established | Apache-2.0 | Docker-based |

**Recommendation:**
- Node modern → **Vitest** (fast, modern API, portable)
- Node established → **Jest** (most documentation, widest adoption)
- Bun runtime → **Bun test** (built-in) or **Vitest** (portable)
- HTTP mocking → **MSW** (works in Node, Bun, and browser)

## CLI Frameworks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **oclif** | Modern | MIT | Salesforce, TypeScript-first, plugins |
| **Commander.js** | Established | MIT | Most popular, simple API |
| yargs | Established | MIT | Powerful argument parsing |
| Stricli | Modern | Apache-2.0 | Bloomberg, lazy loading |
| meow | Modern | MIT | Minimal, by Sindre Sorhus |
| Ink | Modern | MIT | React for CLIs |

**Recommendation:**
- Enterprise CLIs → **oclif**
- Simple CLIs → **Commander.js** or **meow**
- Interactive CLIs → **Ink**

## Web Frameworks (Backend)

| Option | Type | License | Runtime | Notes |
|--------|------|---------|---------|-------|
| **Fastify** | Modern | MIT | Node | Fast, plugin system, production-ready |
| **Hono** | Modern | MIT | Any | Ultra-fast, works on Node, Bun, Deno, edge |
| Express | Established | MIT | Node | Most popular, huge middleware ecosystem |
| Koa | Established | MIT | Node | Express team, async-first |
| NestJS | Modern | MIT | Node | Angular-style, enterprise patterns |
| Elysia | Modern | MIT | Bun only | Fastest, but Bun-only (not portable) |

**Recommendation:**
- Node production → **Fastify** (fast, mature, great plugin system)
- Node established → **Express** (most resources, middleware)
- Portable (any runtime) → **Hono** (works everywhere including edge)
- Bun-committed → **Elysia** (fastest, but locks you to Bun)
- Enterprise/large teams → **NestJS** (structure, patterns)

## Pre-commit & Hooks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **husky** | Standard | MIT | Most popular for JS |
| **lefthook** | Modern | MIT | Fast (Go), language-agnostic |
| lint-staged | Standard | MIT | Run linters on staged files |
| simple-git-hooks | Modern | MIT | Zero deps, simple |

**Recommendation:** **husky + lint-staged** or **lefthook**

## Project Structure

```
project/
├── package.json
├── tsconfig.json
├── .eslintrc.js / eslint.config.js / biome.json
├── src/
│   ├── index.ts
│   └── ...
├── tests/
│   └── *.test.ts
└── dist/  # Build output
```

## TypeScript Config

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "dist"
  }
}
```
