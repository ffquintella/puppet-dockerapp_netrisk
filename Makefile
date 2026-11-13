# Convenience wrapper around the `regent` CLI (see AGENTS.md).
# Do not add targets that require pdk, bundle, or a host Ruby toolchain.

.DEFAULT_GOAL := help
.PHONY: help validate test build publish clean

# Each target documents itself with a trailing `## description`.
help: ## List all available targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

validate: ## Validate the module (regent validate)
	regent validate

test: ## Run the module tests (regent test)
	regent test

build: ## Build the module package into pkg/
	regent build

# Packs the module and uploads it to the Puppet Forge.
# The API key is never stored or passed on the command line: it's read
# interactively (hidden input) and forwarded to `regent publish` via env var.
publish: build ## Build and upload the module to the Puppet Forge
	@read -s -p "Puppet Forge API key: " REGENT_FORGE_TOKEN; \
	echo ""; \
	REGENT_FORGE_TOKEN="$$REGENT_FORGE_TOKEN" regent publish

clean: ## Remove the pkg/ directory
	rm -rf pkg/
