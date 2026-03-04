# Frontend

React single-page application for the e-commerce platform.

## Overview

| Attribute | Value |
|-----------|-------|
| Port | 3000 |
| Tech Stack | React 18, TypeScript, Vite, TailwindCSS |
| Entry Point | `src/main.tsx` |

## Quick Start

```bash
# From this directory
pnpm install
pnpm dev
```

## Structure

```text
frontend/
├── src/
│   ├── main.tsx           # App entry point
│   ├── App.tsx            # Root component
│   ├── components/        # Shared components
│   ├── features/          # Feature modules
│   │   ├── auth/          # Authentication
│   │   ├── products/      # Product catalog
│   │   ├── cart/          # Shopping cart
│   │   └── checkout/      # Checkout flow
│   ├── hooks/             # Custom hooks
│   ├── lib/               # Utilities
│   └── styles/            # Global styles
├── public/                # Static assets
└── tests/                 # Test files
```

## Key Files

| File | Purpose |
|------|---------|
| `src/main.tsx` | Application bootstrap |
| `src/App.tsx` | Route configuration |
| `src/lib/api.ts` | API client setup |
| `src/lib/auth.ts` | Auth utilities |
| `tailwind.config.js` | Tailwind configuration |

## Routes

| Route | Component | Description |
|-------|-----------|-------------|
| `/` | `HomePage` | Landing page |
| `/products` | `ProductList` | Product catalog |
| `/products/:id` | `ProductDetail` | Product detail |
| `/cart` | `CartPage` | Shopping cart |
| `/checkout` | `CheckoutFlow` | Checkout process |
| `/account` | `AccountPage` | User account |

### State Management

- **Server state**: React Query
- **Client state**: Zustand
- **Form state**: React Hook Form

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `VITE_API_URL` | Yes | - | Backend API URL |
| `VITE_STRIPE_KEY` | Yes | - | Stripe publishable key |
| `VITE_GA_ID` | No | - | Google Analytics ID |

### Config Files

| File | Purpose |
|------|---------|
| `vite.config.ts` | Vite bundler config |
| `tailwind.config.js` | Tailwind CSS config |
| `tsconfig.json` | TypeScript config |

## Commands

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start dev server |
| `pnpm build` | Build for production |
| `pnpm preview` | Preview production build |
| `pnpm test` | Run tests |
| `pnpm lint` | Run ESLint |
| `pnpm storybook` | Start Storybook |

## Testing

```bash
# Run all tests
pnpm test

# Run with coverage
pnpm test:coverage

# Run specific test
pnpm test ProductCard
```

## Dependencies

### Internal

| Dependency | Purpose |
|------------|---------|
| `@ecommerce/ui` | Shared UI components |
| `@ecommerce/types` | Shared TypeScript types |

### External

| Package | Version | Purpose |
|---------|---------|---------|
| `react` | 18.x | UI framework |
| `@tanstack/react-query` | 5.x | Server state |
| `zustand` | 4.x | Client state |
| `react-hook-form` | 7.x | Form handling |

## Common Tasks

### Adding a New Feature

1. Create feature folder in `src/features/`
2. Add route in `App.tsx`
3. Create components, hooks, and API calls
4. Add tests

### Adding a New Component

1. Create in `src/components/` or feature folder
2. Export from index file
3. Add Storybook story
4. Add tests

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Hot reload not working | Restart dev server |
| Type errors from shared packages | Run `pnpm build` in packages |
| API calls failing | Check `VITE_API_URL` is set |

## Related Documentation

- [Root README](../README.md) - Project overview
- [Architecture](../docs/ARCHITECTURE.md) - System design
- [Environments](../docs/ENVIRONMENTS.md) - Environment setup
- [Backend README](../backend/README.md) - API documentation
