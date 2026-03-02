# Go Recommendations

> Reference for aicodeprep analysis. See main SKILL.md for usage.

## Package Management

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **go mod** | Standard | BSD-3 | Built-in since Go 1.16 |
| dep | Deprecated | BSD-3 | Pre-modules, avoid |

**Recommendation:** **go mod** (only option for modern Go)

## Linting

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **golangci-lint** | Standard | GPL-3.0 | Aggregates 50+ linters, fast |
| go vet | Built-in | BSD-3 | Basic checks |
| staticcheck | Established | MIT | High-quality checks |
| revive | Modern | MIT | Fast, configurable |

**Note:** golangci-lint is GPL-3.0 - check licensing requirements

**Recommendation:**
- Most projects → **golangci-lint** (includes staticcheck, revive, etc.)
- GPL concerns → **staticcheck** directly

## Formatting

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **gofmt** | Standard | BSD-3 | Built-in, canonical |
| goimports | Standard | BSD-3 | gofmt + import management |
| gofumpt | Modern | BSD-3 | Stricter gofmt |

**Recommendation:** **goimports** (or **gofumpt** for stricter formatting)

## Testing

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **go test** | Built-in | BSD-3 | Standard, table-driven tests |
| **testify** | Established | MIT | Better assertions, mocking |
| gomega | Established | MIT | BDD-style matchers |
| gocheck | Established | BSD-2 | Fixtures, suites |

**Mocking:**
| Option | Type | License | Notes |
|--------|------|---------|-------|
| **mockery** | Standard | BSD-3 | Interface-based, code gen |
| **gomock** | Established | Apache-2.0 | Google, official |
| moq | Modern | MIT | Minimal mocking |

**HTTP Testing:**
| Option | Type | License | Notes |
|--------|------|---------|-------|
| **httptest** | Built-in | BSD-3 | Standard library |
| gock | Modern | MIT | HTTP mocking |

**Recommendation:**
- Testing → **go test + testify**
- Mocking → **mockery** (code gen) or **gomock**
- HTTP → **httptest** (built-in)

## CLI Frameworks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Cobra** | Standard | Apache-2.0 | K8s, Hugo, GitHub CLI use it |
| urfave/cli | Established | MIT | Zero deps, simpler |
| ffcli | Modern | Apache-2.0 | Minimal, composable |
| kong | Modern | MIT | Struct-based |
| Bubble Tea | Modern | MIT | TUI framework |

**Recommendation:**
- Feature-rich CLIs → **Cobra**
- Simple CLIs → **urfave/cli** or **ffcli**
- Interactive TUIs → **Bubble Tea**

## Web Frameworks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Gin** | Established | MIT | Most popular, fast |
| **Echo** | Established | MIT | Minimalist, fast |
| **Fiber** | Modern | MIT | Express-like, fastest |
| Chi | Established | MIT | Lightweight, composable |
| net/http | Built-in | BSD-3 | Standard library |
| Gorilla Mux | Established | BSD-3 | Router (archived but stable) |

**Recommendation:**
- High performance → **Fiber** or **Gin**
- Minimal deps → **Chi** or **net/http**
- Express-like DX → **Fiber**

## Configuration

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Viper** | Standard | MIT | Full-featured, pairs with Cobra |
| envconfig | Established | MIT | Environment variables only |
| koanf | Modern | MIT | Lighter than Viper |

**Recommendation:** **Viper** (especially with Cobra)

## Logging

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **slog** | Built-in | BSD-3 | Go 1.21+, structured logging |
| **zerolog** | Modern | MIT | Zero allocation, fast |
| zap | Established | MIT | Uber, fast structured logging |
| logrus | Established | MIT | Popular but slower |

**Recommendation:**
- Go 1.21+ → **slog** (standard library)
- Performance critical → **zerolog**

## Pre-commit & Hooks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **pre-commit** | Standard | MIT | Python-based, widely used |
| **lefthook** | Modern | MIT | Fast (Go), native feel |
| golangci-lint (pre-commit hook) | - | - | Direct integration |

**Recommendation:** **lefthook** (Go-native) or **pre-commit**

## Project Structure

```
project/
├── go.mod
├── go.sum
├── main.go           # or cmd/app/main.go
├── cmd/              # CLI entry points
│   └── app/
│       └── main.go
├── internal/         # Private packages
│   └── ...
├── pkg/              # Public packages (optional)
│   └── ...
├── api/              # API definitions (OpenAPI, proto)
├── configs/
└── tests/            # Integration tests
```

## golangci-lint Config

```yaml
# .golangci.yml
linters:
  enable:
    - gofmt
    - goimports
    - govet
    - errcheck
    - staticcheck
    - unused
    - gosimple
    - ineffassign
    - revive

linters-settings:
  goimports:
    local-prefixes: github.com/yourorg/yourrepo
```
