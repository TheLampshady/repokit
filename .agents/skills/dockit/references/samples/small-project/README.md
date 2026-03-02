# json-formatter

> A CLI tool for formatting and validating JSON files.

Simple command-line utility to format, validate, and minify JSON files. Built for developers who work with JSON daily and want a fast, reliable tool that just works.

## Table of Contents

### Quick Start
- [Overview](#overview)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Usage](#usage)

### Reference
- [Architecture](#architecture)
- [Testing](#testing)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## Overview

| | |
|---|---|
| **Purpose** | Format, validate, and minify JSON files from the command line |
| **Tech Stack** | Python 3.12, Click, Rich |
| **Audience** | Developers who work with JSON files locally |

**Key Features:**
- Format JSON with configurable indentation
- Validate JSON syntax with clear error messages
- Minify JSON for production use
- Batch process multiple files

---

## Getting Started

Install and run the formatter in three commands. Requires Python 3.12+.

**Prerequisites:** Python 3.12+, pip

```bash
# 1. Install
pip install -e .

# 2. Verify installation
json-fmt --version

# 3. Format a file
json-fmt format input.json
```

---

## Configuration

The tool uses command-line flags. No config file required—everything is explicit in the command.

| Flag | Description | Default |
|------|-------------|---------|
| `--indent` | Spaces for indentation | 2 |
| `--sort-keys` | Sort object keys alphabetically | false |
| `--output` | Output file path (default: stdout) | - |

---

## Usage

All commands follow the pattern: `json-fmt <command> [options] <file>`.

| Command | Description |
|---------|-------------|
| `json-fmt format <file>` | Format JSON with indentation |
| `json-fmt validate <file>` | Check JSON syntax, exit 0 if valid |
| `json-fmt minify <file>` | Remove whitespace for compact output |
| `json-fmt batch <dir>` | Process all .json files in directory |

**Examples:**

```bash
# Format with 4-space indent
json-fmt format --indent 4 data.json

# Validate and exit silently if valid
json-fmt validate config.json && echo "Valid!"

# Minify and save to new file
json-fmt minify --output data.min.json data.json

# Process entire directory
json-fmt batch ./configs --indent 2
```

---

## Architecture

Single-module CLI tool with Click for argument parsing and Rich for terminal output.

| File | Purpose |
|------|---------|
| `json_fmt/cli.py` | Click command definitions and entry point |
| `json_fmt/formatter.py` | JSON processing logic |
| `json_fmt/validators.py` | Syntax validation and error reporting |
| `tests/` | pytest test suite |

**Why this structure:** Small tools don't need complex architectures. One module per concern keeps the codebase navigable and each file under 200 lines.

---

## Testing

Tests use pytest with sample JSON fixtures covering valid files, malformed input, and edge cases.

```bash
pytest
```

---

## Deployment

Publish to PyPI for distribution. Users install via pip.

```bash
python -m build && twine upload dist/*
```

---

## Troubleshooting

Common issues and quick fixes.

| Symptom | Fix |
|---------|-----|
| `command not found: json-fmt` | Run `pip install -e .` again |
| `Invalid JSON` error | Check file encoding is UTF-8 |
| Permission denied on output | Check write permissions on target directory |

---

## Contributing

Contributions welcome via pull request.

- Run `pytest` before submitting
- Follow existing code style
- Add tests for new features

---

## 💡 Philosophy

**Do one thing well.** This tool formats JSON. It doesn't lint, transform, query, or diff. For those tasks, use jq, jsonlint, or dedicated tools.

**No config files.** Everything is a flag. You can always see exactly what the command will do.

**Fast startup.** No heavy dependencies. The tool loads in milliseconds so you can use it in tight loops and watch scripts.
