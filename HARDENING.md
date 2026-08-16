<!-- markdownlint-disable -->

# Hardening Report: clouddrove--smurf/v1.1.9

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouddrove--smurf/v1.1.9** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In the 'Get correct version format' step of action.yml, the shell variable $INPUT_VERSION (sourced from inputs.version via the env: block) is written to $GITHUB_OUTPUT without the required sanitization pipeline (`printf '%s' ... | tr -d '\n\r'`). The line `echo "tag=$INPUT_VERSION" >> "$GITHUB_OUTPUT"` writes an untrusted input-derived value directly to the special environment file. Although a regex validation (`^v[0-9]+\.[0-9]+\.[0-9]+$`) is applied before the write and would reject values containing newlines, the prescribed sanitization step is absent. An attacker controlling the `version` input could attempt to inject environment variable assignments if the regex were ever relaxed.

Locations:

- `action.yml:54`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Get correct version format' step of action.yml (line 54). Added the required sanitization pipeline: `safe_version=$(printf '%s' "$INPUT_VERSION" | tr -d '\n\r')` before writing to $GITHUB_OUTPUT. The sanitized value `safe_version` is now used in the echo statement instead of the raw `$INPUT_VERSION`. This ensures newline/carriage-return characters are stripped even if the regex validation were ever relaxed.

### Iteration 2

**Fixes applied:** script-injection, unpinned-uses, permissions

**Notes:**

Fixed all findings across 4 workflow files:

**build.yml**: Added `permissions: contents: read` at top level. Pinned `actions/checkout@v7` and `actions/setup-go@v6` (×2) to full SHAs. Moved all `${{env.APP_PACKAGE}}` and `${{steps.buildinfo.outputs.*}}` expressions from the Build step's `run:` block into a step-level `env:` block.

**docs.yml**: Replaced `permissions: write-all` with minimal `contents: write`, `pages: write`, `id-token: write`. Pinned all 5 actions (`actions/checkout`, `actions/setup-python`, `actions/cache`, `actions/upload-pages-artifact`, `actions/deploy-pages`) to full commit SHAs.

**test-multiplatform.yml**: Added `permissions: contents: read` at top level. Pinned all 5 actions (`actions/checkout`, `hashicorp/setup-terraform`, `douglascamata/setup-docker-macos-action`, `docker/setup-qemu-action`, `actions/setup-go`) to full commit SHAs. Moved `${{ env.TERRAFORM_VERSION }}` from the `choco install` run command into a step-level `env:` block.

**release.yml**: Added `permissions: contents: read` to the `build` job and `permissions: contents: read, packages: write` to the `docker-build` job. Moved all `${{ matrix.GOOS }}`, `${{ matrix.GOARCH }}`, `${{ env.BINARY_NAME }}`, `${{ env.APP_PACKAGE }}`, `${{ steps.buildinfo.outputs.* }}`, `${{ steps.version.outputs.version }}`, `${{ env.REPO }}`, `${{ github.ref_name }}` expressions from `run:` blocks into step-level `env:` blocks across all affected steps.

