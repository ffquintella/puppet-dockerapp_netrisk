# Convenience wrapper around the `regent` CLI (see AGENTS.md).
# Do not add targets that require pdk, bundle, or a host Ruby toolchain.

.PHONY: validate test build publish clean

validate:
	regent validate

test:
	regent test

build:
	regent build

# Packs the module and uploads it to the Puppet Forge.
# The API key is never stored or passed on the command line: it's read
# interactively (hidden input) and forwarded to `regent publish` via env var.
publish: build
	@read -s -p "Puppet Forge API key: " REGENT_FORGE_TOKEN; \
	echo ""; \
	REGENT_FORGE_TOKEN="$$REGENT_FORGE_TOKEN" regent publish

clean:
	rm -rf pkg/
