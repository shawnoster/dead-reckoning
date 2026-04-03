.PHONY: help link-skills notebook-status

AYA ?= $(shell which aya 2>/dev/null)

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

link-skills: ## Symlink skills/*/SKILL.md into .claude/commands/ (run after adding/removing skills)
	@mkdir -p .claude/commands
	@for skill in skills/*/SKILL.md; do \
		name=$$(basename $$(dirname $$skill)); \
		target=".claude/commands/$$name.md"; \
		if [ ! -e "$$target" ] || [ -L "$$target" ]; then \
			ln -sf "../../$$skill" "$$target" && echo "  linked: $$name"; \
		else \
			echo "  skipped (non-symlink exists): $$name"; \
		fi; \
	done

notebook-status: ## Run workspace readiness check
	@if command -v aya >/dev/null 2>&1; then \
		aya status; \
	else \
		echo "aya not installed — run: uv tool install git+https://github.com/shawnoster/aya"; \
	fi
