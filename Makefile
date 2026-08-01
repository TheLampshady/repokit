.DEFAULT_GOAL := help

# ── Help ──────────────────────────────────────────────────────────────────────

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		| sort

# ── Setup ─────────────────────────────────────────────────────────────────────

.PHONY: setup
setup: hooks antigravity claude ## First-time dev setup: install hooks, link Antigravity plugin, install Claude plugin

.PHONY: hooks
hooks: ## Install pre-commit hooks
	@command -v uv >/dev/null 2>&1 \
		&& uv tool install pre-commit --quiet \
		|| pip install --quiet pre-commit
	pre-commit install --config .config/.pre-commit-config.yaml
	@git config --local commit.template .config/.commit-message-template
	@echo "✓ pre-commit hooks installed"


# ── ANTIGRAVITY ────────────────────────────────────────────────────────────────
# Two separate products, same plugin contents, different install surface:
#   IDE (v2.x)      — folder placement, no command. Symlink for live reload.
#   CLI (agy, v1.x) — `agy plugin install`, own dir under ~/.gemini/antigravity-cli/
# `make antigravity` does both when available.

ANTIGRAVITY_PLUGINS ?= $(HOME)/.gemini/config/plugins

.PHONY: antigravity
antigravity: antigravity-ide antigravity-cli ## Install for Antigravity IDE + CLI (whichever are present)

.PHONY: antigravity-ide
antigravity-ide: ## Symlink into the Antigravity IDE global plugin dir (live reloads on changes)
	@mkdir -p $(ANTIGRAVITY_PLUGINS)
	@ln -sfn $(PWD) $(ANTIGRAVITY_PLUGINS)/repokit
	@echo "✓ Antigravity IDE plugin linked: $(ANTIGRAVITY_PLUGINS)/repokit -> $(PWD)"
	@echo "  Restart the IDE, then mention 'dockit' or 'repokit' to confirm skills load."

.PHONY: antigravity-cli
antigravity-cli: ## Install into Antigravity CLI via `agy plugin install`
	@command -v agy >/dev/null 2>&1 \
		&& { agy plugin install $(PWD) && echo "✓ Antigravity CLI plugin installed (agy plugin list to verify)"; } \
		|| echo "⊘ agy not found — skipping CLI install (https://antigravity.google/cli/install.sh)"

.PHONY: antigravity-workspace
antigravity-workspace: ## Symlink into a workspace's .agents/plugins/ (set DIR=/path/to/workspace)
	@test -n "$(DIR)" || { echo "Usage: make antigravity-workspace DIR=/path/to/workspace"; exit 1; }
	@mkdir -p $(DIR)/.agents/plugins
	@ln -sfn $(PWD) $(DIR)/.agents/plugins/repokit
	@echo "✓ Antigravity plugin linked: $(DIR)/.agents/plugins/repokit -> $(PWD)"

.PHONY: un-antigravity
un-antigravity: ## Remove the Antigravity IDE symlink and uninstall from the CLI
	@rm -f $(ANTIGRAVITY_PLUGINS)/repokit
	@echo "✓ Antigravity IDE plugin unlinked"
	@command -v agy >/dev/null 2>&1 \
		&& { agy plugin uninstall repokit && echo "✓ Antigravity CLI plugin uninstalled"; } \
		|| echo "⊘ agy not found — nothing to uninstall"

# ── GEMINI CLI (legacy) ────────────────────────────────────────────────────────
# Gemini CLI stopped serving Pro/Ultra/free tiers on 2026-06-18.
# Retained for Code Assist Standard/Enterprise license holders.

.PHONY: gemini
gemini: ## [legacy] Link this repo as a Gemini CLI extension
	gemini extensions link $(PWD)
	@echo "✓ Gemini extension linked at $(PWD)"

.PHONY: un-gemini
un-gemini: ## [legacy] Uninstall the Gemini CLI extension
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


# ── Cross-Platform ───────────────────────────────────────────────────────────

.PHONY: cursorrules
cursorrules: ## Generate .cursorrules from SKILL.md descriptions
	@echo "# Repokit — Codebase Maintenance Toolkit" > .cursorrules
	@echo "# Auto-generated from skills/*/SKILL.md" >> .cursorrules
	@echo "" >> .cursorrules
	@for skill in skills/*/SKILL.md; do \
		name=$$(grep '^name:' "$$skill" | head -1 | sed "s/name: *'\\{0,1\\}//;s/'$$//"); \
		desc=$$(grep '^description:' "$$skill" | head -1 | sed "s/description: *'\\{0,1\\}//;s/'$$//"); \
		echo "## $$name"; \
		echo "$$desc"; \
		echo ""; \
	done >> .cursorrules
	@echo "✓ .cursorrules generated from $$(ls skills/*/SKILL.md | wc -l) skills"

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
	@open=$$(grep -c '\- \[ \]' .backlog/backlog.md 2>/dev/null || echo 0); \
		[ "$$open" -gt 0 ] \
		&& grep '\- \[ \]' .backlog/backlog.md \
		|| echo "  No open items"
	@echo ""
	@echo "── Antigravity IDE Plugin ───────────────────────────────"
	@test -L $(ANTIGRAVITY_PLUGINS)/repokit \
		&& echo "  linked -> $$(readlink $(ANTIGRAVITY_PLUGINS)/repokit)" \
		|| echo "  repokit not linked (run: make antigravity-ide)"
	@echo ""
	@echo "── Antigravity CLI Plugin ───────────────────────────────"
	@command -v agy >/dev/null 2>&1 \
		&& { agy plugin list 2>/dev/null | grep -i repokit || echo "  repokit not installed (run: make antigravity-cli)"; } \
		|| echo "  agy not installed"
	@echo ""
	@echo "── Claude Plugin ────────────────────────────────────────"
	@claude plugin list 2>/dev/null | grep -i repokit || echo "  repokit not installed (run: make claude)"
	@echo ""
	@echo "── Gemini CLI Extension (legacy) ────────────────────────"
	@command -v gemini >/dev/null 2>&1 \
		&& { gemini extensions list 2>/dev/null | grep -i repokit || echo "  repokit not linked (run: make gemini)"; } \
		|| echo "  gemini CLI not installed (retired 2026-06-18)"
	@echo ""

# ── Cleanup ───────────────────────────────────────────────────────────────────

.PHONY: clean
clean: ## Remove pre-commit cache
	pre-commit clean --config .config/.pre-commit-config.yaml
	@echo "✓ pre-commit cache cleared"
