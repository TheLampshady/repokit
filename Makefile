.DEFAULT_GOAL := help

# ── Help ──────────────────────────────────────────────────────────────────────

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		| sort

# ── Setup ─────────────────────────────────────────────────────────────────────

.PHONY: setup
setup: hooks gemini claude ## First-time dev setup: install hooks, link Gemini extension, install Claude plugin

.PHONY: hooks
hooks: ## Install pre-commit hooks
	@command -v uv >/dev/null 2>&1 \
		&& uv tool install pre-commit --quiet \
		|| pip install --quiet pre-commit
	pre-commit install --config .config/.pre-commit-config.yaml
	@git config --local commit.template .config/.commit-message-template
	@echo "✓ pre-commit hooks installed"


# ── GEMINI ─────────────────────────────────────────────────────────────────────

.PHONY: gemini
gemini: ## Link this repo as a Gemini extension (live reloads on changes)
	gemini extensions link $(PWD)
	@echo "✓ Gemini extension linked at $(PWD)"

.PHONY: un-gemini
un-gemini: ## Uninstall the Gemini extension
	gemini extensions uninstall repokit
	@echo "✓ Gemini extension uninstalled"

# ── CLAUDE ─────────────────────────────────────────────────────────────────────

.PHONY: claude
claude: ## Install this repo as a Claude plugin (local scope, this machine only)
	claude plugin marketplace add $(PWD) --scope local
	claude plugin install repokit@repokit-marketplace --scope local
	@echo "✓ Claude plugin installed (local scope)"

.PHONY: claude-project
claude-project: ## Install this repo as a Claude plugin (project scope, shared via .claude/settings.json)
	claude plugin marketplace add $(PWD) --scope project
	claude plugin install repokit@repokit-marketplace --scope project
	@echo "✓ Claude plugin installed (project scope)"

.PHONY: un-claude
un-claude: ## Uninstall the local Claude plugin
	claude plugin uninstall repokit --scope local
	@echo "✓ Claude plugin uninstalled (local scope)"


# ── Commands ──────────────────────────────────────────────────────────────────

.PHONY: toml-to-md
toml-to-md: ## Convert commands/*.toml → *.md (Claude format)
	uv run python scripts/toml_to_md.py commands/
	@echo "✓ TOML commands converted to Markdown"

.PHONY: md-to-toml
md-to-toml: ## Convert commands/*.md → *.toml (Gemini format)
	uv run python scripts/md_to_toml.py commands/
	@echo "✓ Markdown commands converted to TOML"

# ── Cross-Platform ───────────────────────────────────────────────────────────

.PHONY: cursorrules
cursorrules: ## Generate .cursorrules from SKILL.md descriptions
	@echo "# Repokit — Codebase Maintenance Toolkit" > .cursorrules
	@echo "# Auto-generated from .agents/skills/*/SKILL.md" >> .cursorrules
	@echo "" >> .cursorrules
	@for skill in .agents/skills/*/SKILL.md; do \
		name=$$(grep '^name:' "$$skill" | head -1 | sed "s/name: *'\\{0,1\\}//;s/'$$//"); \
		desc=$$(grep '^description:' "$$skill" | head -1 | sed "s/description: *'\\{0,1\\}//;s/'$$//"); \
		echo "## $$name"; \
		echo "$$desc"; \
		echo ""; \
	done >> .cursorrules
	@echo "✓ .cursorrules generated from $$(ls .agents/skills/*/SKILL.md | wc -l) skills"

# ── Validation ────────────────────────────────────────────────────────────────

.PHONY: check
check: ## Run pre-commit checks on all files
	pre-commit run --all-files --config .config/.pre-commit-config.yaml

.PHONY: check-json
check-json: ## Validate all JSON files (hooks, plugin manifests)
	pre-commit run check-json --all-files --config .config/.pre-commit-config.yaml

.PHONY: check-toml
check-toml: ## Validate all TOML files (policies, commands)
	pre-commit run check-toml --all-files --config .config/.pre-commit-config.yaml

.PHONY: check-yaml
check-yaml: ## Validate all YAML files (pre-commit config, frontmatter)
	pre-commit run check-yaml --all-files --config .config/.pre-commit-config.yaml

# ── Status ────────────────────────────────────────────────────────────────────

.PHONY: status
status: ## Show open backlog items and installed extension status
	@echo ""
	@echo "── Backlog ──────────────────────────────────────────────"
	@open=$$(grep -c '\- \[ \]' spec/backlog.md 2>/dev/null || echo 0); \
		[ "$$open" -gt 0 ] \
		&& grep '\- \[ \]' spec/backlog.md \
		|| echo "  No open items"
	@echo ""
	@echo "── Gemini Extension ─────────────────────────────────────"
	@gemini extensions list 2>/dev/null | grep -i repokit || echo "  repokit not linked (run: make gemini)"
	@echo ""
	@echo "── Claude Plugin ────────────────────────────────────────"
	@claude plugin list 2>/dev/null | grep -i repokit || echo "  repokit not installed (run: make claude)"
	@echo ""

# ── Cleanup ───────────────────────────────────────────────────────────────────

.PHONY: clean
clean: ## Remove pre-commit cache
	pre-commit clean --config .config/.pre-commit-config.yaml
	@echo "✓ pre-commit cache cleared"
