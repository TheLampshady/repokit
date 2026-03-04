# JavaScript/TypeScript Frontend Recommendations

> Reference for aicodeprep analysis. For Node/Bun backend, see `javascript-node.md`.

## Package Management

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **pnpm** | Modern | MIT | Fast, disk efficient, strict, most compatible |
| npm | Established | Artistic-2.0 | Universal, comes with Node |
| Yarn v4 | Modern | BSD-2 | Good workspaces, PnP mode |
| Bun | Modern | MIT | Fastest, but see compatibility notes below |

**Bun for Frontend:**
Bun works well as a package manager for frontend projects since most frontend tooling is pure JS. However, if your project shares code with a Node.js backend, using pnpm across both keeps things consistent.

**Recommendation:**
- Most projects → **pnpm** (fast, compatible, works everywhere)
- Established preference → **npm**
- Frontend-only + speed priority → **Bun** (as package manager)

## Build Tools / Bundlers

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Vite** | Modern | MIT | Fast dev server, Rollup-based prod |
| **Turbopack** | Modern | MPL-2.0 | Vercel, Rust-based, Next.js native |
| esbuild | Modern | MIT | Extremely fast, Go-based |
| Rollup | Established | MIT | Best for libraries |
| webpack | Established | MIT | Most configurable, large ecosystem |
| Parcel | Modern | MIT | Zero-config |

**Recommendation:**
- Most projects → **Vite**
- Next.js → **Turbopack** (built-in)
- Libraries → **Rollup** or **Vite library mode**
- Legacy projects → **webpack**

## Linting

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **ESLint 9+** | Standard | MIT | Flat config, extensible |
| **Biome** | Modern | MIT | Fast (Rust), linter + formatter |
| ESLint 8 | Established | MIT | Legacy config format |

**Framework plugins:**
- eslint-plugin-react
- eslint-plugin-react-hooks
- @typescript-eslint

**Recommendation:**
- Modern preference → **Biome**
- Established preference → **ESLint 9+ flat config**

## Formatting

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Prettier** | Standard | MIT | Most popular |
| **Biome** | Modern | MIT | Built-in formatter |
| dprint | Modern | MIT | Fast, configurable |

**Recommendation:** **Prettier** or **Biome**

## Testing

### Unit / Component Tests

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Vitest** | Modern | MIT | Fast, Vite-native |
| Jest | Established | MIT | Most popular |
| Testing Library | Standard | MIT | Component testing (use with Vitest/Jest) |

### E2E Tests

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Playwright** | Modern | Apache-2.0 | Multi-browser, codegen, MCP support |
| Cypress | Established | MIT | Good DX, single browser per test |
| Puppeteer | Established | Apache-2.0 | Chrome/Firefox only |

**Recommendation:**
- Unit/Component → **Vitest + Testing Library**
- E2E → **Playwright**

## Frameworks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **React** | Standard | MIT | Most popular, huge ecosystem |
| **Next.js** | Modern | MIT | React meta-framework, SSR/SSG |
| Vue | Established | MIT | Approachable, good docs |
| Nuxt | Modern | MIT | Vue meta-framework |
| Svelte | Modern | MIT | Compile-time, small bundle |
| SvelteKit | Modern | MIT | Svelte meta-framework |
| Solid | Modern | MIT | Fine-grained reactivity |
| Qwik | Modern | MIT | Resumability, instant load |
| Astro | Modern | MIT | Content-focused, islands |

**Recommendation:**
- Most apps → **React** or **Next.js**
- Content sites → **Astro**
- Simpler DX → **Vue/Nuxt** or **Svelte/SvelteKit**

## UI Component Libraries (React + Tailwind)

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **shadcn/ui** | Modern | MIT | Copy-paste, AI-readable, Radix-based |
| Radix UI | Modern | MIT | Unstyled primitives |
| Headless UI | Modern | MIT | Tailwind Labs |
| MUI | Established | MIT | Material Design |
| Chakra UI | Established | MIT | Good defaults |
| Ant Design | Established | MIT | Enterprise, Chinese origin |
| Mantine | Modern | MIT | Full-featured |

**Recommendation:**
- AI workflows → **shadcn/ui** (components in your code)
- Unstyled control → **Radix UI**
- Quick start → **MUI** or **Chakra UI**

## State Management (React)

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Zustand** | Modern | MIT | Simple, no boilerplate |
| **Jotai** | Modern | MIT | Atomic, bottom-up |
| TanStack Query | Modern | MIT | Server state |
| Redux Toolkit | Established | MIT | Still relevant for complex apps |
| Recoil | Modern | MIT | Facebook, atomic |
| MobX | Established | MIT | Observable-based |

**Recommendation:**
- Client state → **Zustand** or **Jotai**
- Server state → **TanStack Query**
- Complex global state → **Redux Toolkit**

## Forms (React)

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **React Hook Form** | Modern | MIT | Performant, uncontrolled |
| **Zod** | Modern | MIT | Schema validation, pairs with RHF |
| Formik | Established | Apache-2.0 | Popular, more boilerplate |
| Yup | Established | MIT | Schema validation |

**Recommendation:** **React Hook Form + Zod**

## Styling

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Tailwind CSS** | Modern | MIT | Utility-first, AI-friendly |
| CSS Modules | Established | - | Scoped CSS |
| styled-components | Established | MIT | CSS-in-JS |
| Emotion | Established | MIT | CSS-in-JS |
| vanilla-extract | Modern | MIT | Zero-runtime CSS-in-TS |
| Panda CSS | Modern | MIT | Build-time CSS-in-JS |

**Recommendation:**
- Most projects → **Tailwind CSS**
- Component libraries → **vanilla-extract** or **Panda CSS**

## Pre-commit & Hooks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **husky** | Standard | MIT | Most popular |
| **lefthook** | Modern | MIT | Fast (Go) |
| lint-staged | Standard | MIT | Run linters on staged files |

**Recommendation:** **husky + lint-staged**

## Project Structure (React/Next.js)

```
project/
├── package.json
├── tsconfig.json
├── tailwind.config.ts
├── src/
│   ├── app/          # Next.js App Router
│   ├── components/
│   │   └── ui/       # shadcn/ui components
│   ├── lib/
│   └── hooks/
├── tests/
│   └── *.test.tsx
└── public/
```

## TypeScript Config (Frontend)

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "skipLibCheck": true
  }
}
```
