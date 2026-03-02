# Rust Recommendations

> Reference for aicodeprep analysis. See main SKILL.md for usage.

## Package Management

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **cargo** | Standard | MIT/Apache-2.0 | Built-in, excellent |

**Recommendation:** **cargo** (only option, and it's great)

## Linting

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **clippy** | Standard | MIT/Apache-2.0 | Official Rust linter |
| rust-analyzer | Standard | MIT/Apache-2.0 | IDE lints (VS Code) |

**Recommendation:** **clippy** (official, comprehensive)

## Formatting

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **rustfmt** | Standard | MIT/Apache-2.0 | Official formatter |

**Recommendation:** **rustfmt** (only option, and it's standard)

## Testing

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **built-in** | Standard | - | #[test], #[cfg(test)] |
| **mockall** | Standard | MIT/Apache-2.0 | Mock generation |
| mockito | Established | MIT | HTTP mocking |
| wiremock-rs | Modern | MIT/Apache-2.0 | HTTP mocking |

**Coverage:**
| Option | Type | License | Notes |
|--------|------|---------|-------|
| **cargo-tarpaulin** | Standard | MIT/Apache-2.0 | Best coverage tool |
| cargo-llvm-cov | Modern | MIT/Apache-2.0 | LLVM-based, accurate |
| grcov | Modern | MPL-2.0 | Mozilla, flexible |

**Benchmarking:**
| Option | Type | License | Notes |
|--------|------|---------|-------|
| **criterion** | Standard | MIT/Apache-2.0 | Statistical benchmarks |
| divan | Modern | MIT/Apache-2.0 | Simpler, faster compile |

**Recommendation:**
- Testing → Built-in + **mockall**
- Coverage → **cargo-tarpaulin** or **cargo-llvm-cov**
- Benchmarks → **criterion**

## CLI Frameworks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **clap** | Standard | MIT/Apache-2.0 | Standard choice, derive macros |
| pico-args | Modern | MIT | Zero deps, fast compile |
| argh | Modern | BSD-3 | Google, simple |
| bpaf | Modern | MIT/Apache-2.0 | Derive + combinators |

**TUI:**
| Option | Type | License | Notes |
|--------|------|---------|-------|
| **ratatui** | Modern | MIT | Active fork of tui-rs |
| crossterm | Modern | MIT | Cross-platform terminal |

**Note:** structopt is deprecated and merged into clap

**Recommendation:**
- Most CLIs → **clap** (with derive)
- Minimal deps → **pico-args**
- TUIs → **ratatui + crossterm**

## Web Frameworks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Axum** | Modern | MIT | Tokio team, ergonomic |
| **Actix-web** | Established | MIT/Apache-2.0 | Fastest, actor model |
| Rocket | Established | MIT/Apache-2.0 | Easy to use |
| warp | Modern | MIT | Filter-based |
| Poem | Modern | MIT/Apache-2.0 | OpenAPI integration |

**Recommendation:**
- Most projects → **Axum** (best DX, Tokio ecosystem)
- Max performance → **Actix-web**
- Simplicity → **Rocket**

## Async Runtime

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Tokio** | Standard | MIT | Most popular, full-featured |
| async-std | Established | MIT/Apache-2.0 | std-like API |
| smol | Modern | MIT/Apache-2.0 | Small, simple |

**Recommendation:** **Tokio** (ecosystem standard)

## Error Handling

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **thiserror** | Standard | MIT/Apache-2.0 | Derive Error trait |
| **anyhow** | Standard | MIT/Apache-2.0 | Application errors |
| eyre | Modern | MIT/Apache-2.0 | anyhow alternative |
| miette | Modern | Apache-2.0 | Fancy error reports |

**Recommendation:**
- Libraries → **thiserror**
- Applications → **anyhow** or **eyre**
- User-facing errors → **miette**

## Serialization

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **serde** | Standard | MIT/Apache-2.0 | De facto standard |
| serde_json | Standard | MIT/Apache-2.0 | JSON |
| toml | Standard | MIT/Apache-2.0 | TOML config |

**Recommendation:** **serde** (universal)

## Pre-commit & Hooks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **pre-commit** | Standard | MIT | Python-based |
| **cargo-husky** | Rust-native | MIT | Rust-specific |
| lefthook | Modern | MIT | Fast (Go) |

**Recommendation:** **pre-commit** or **cargo-husky**

## Project Structure

**Binary:**
```
project/
├── Cargo.toml
├── Cargo.lock         # Commit for binaries
├── src/
│   ├── main.rs
│   └── lib.rs         # Optional library
├── tests/             # Integration tests
│   └── integration.rs
└── benches/           # Benchmarks
    └── bench.rs
```

**Library:**
```
project/
├── Cargo.toml
├── src/
│   └── lib.rs
├── tests/
└── examples/
```

**Workspace:**
```
project/
├── Cargo.toml         # [workspace]
├── crates/
│   ├── core/
│   ├── cli/
│   └── api/
```

## Cargo.toml Example

```toml
[package]
name = "myapp"
version = "0.1.0"
edition = "2021"
rust-version = "1.75"

[dependencies]
tokio = { version = "1", features = ["full"] }
axum = "0.7"
serde = { version = "1", features = ["derive"] }
clap = { version = "4", features = ["derive"] }
thiserror = "1"
anyhow = "1"

[dev-dependencies]
mockall = "0.12"

[profile.release]
lto = true
codegen-units = 1
```
