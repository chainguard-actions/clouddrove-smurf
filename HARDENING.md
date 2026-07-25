<!-- markdownlint-disable -->

# Hardening Report: clouddrove--smurf/v1.1.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouddrove--smurf/v1.1.5** was hardened automatically. 1 finding(s) were identified and resolved across 5 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In the 'Get correct version format' step of action.yml, the env var INPUT_VERSION is set from `${{ inputs.version }}` (an attacker-controlled input). The run block then writes `echo "tag=$INPUT_VERSION" >> "$GITHUB_OUTPUT"` without first sanitizing the value with `printf '%s' ... | tr -d '\n\r'`. A newline character in the input could inject additional key=value pairs into GITHUB_OUTPUT, poisoning subsequent steps. Additionally, LATEST_TAG is fetched from an external API and written to GITHUB_OUTPUT without sanitization. Neither write applies the required sanitization step before the write.

Locations:

- `action.yml:46`
- `action.yml:54`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed both GITHUB_OUTPUT injection vectors in the 'Get correct version format' step of action.yml:
1. LATEST_TAG (from external API, line ~46): Added `safe_tag=$(printf '%s' "$LATEST_TAG" | tr -d '\n\r')` before writing to GITHUB_OUTPUT.
2. INPUT_VERSION (attacker-controlled input, line ~54): Added `safe_tag=$(printf '%s' "$INPUT_VERSION" | tr -d '\n\r')` before writing to GITHUB_OUTPUT.
Both writes now use the sanitized `safe_tag` variable, preventing newline injection attacks that could poison subsequent steps via GITHUB_OUTPUT.

### Iteration 2

**Fixes applied:** script-injection, unpinned-uses, broad-permissions, missing-permissions, github-env-injection

**Notes:**

Fixed all findings across four workflow files:

**build.yml**: Added top-level `permissions: contents: read`. Pinned `actions/checkout@v7` → SHA `3d3c42e5...`, `actions/setup-go@v6` → SHA `924ae3a1...`. Moved all `${{ env.APP_PACKAGE }}`, `${{ steps.buildinfo.outputs.* }}` expressions out of `run:` into `env:` blocks.

**docs.yml**: Replaced `permissions: write-all` with specific minimal permissions (`contents: write`, `pages: write`, `id-token: write`). Pinned `actions/checkout@v7`, `actions/setup-python@v6`, `actions/cache@v6`, `actions/upload-pages-artifact@v5`, `actions/deploy-pages@v5` to full SHAs.

**release.yml**: Added `permissions: contents: read` to `build` job and `permissions: contents: read / packages: write` to `docker-build` job. Pinned all 11 action refs to full SHAs. Moved all `${{ }}` expressions in `run:` steps to `env:` blocks. Fixed github-env-injection in 'Get Build Info' step by moving `steps.version.outputs.version` to env and sanitizing with `printf '%s' | tr -d '\n\r'` before writing to GITHUB_OUTPUT.

**test-multiplatform.yml**: Added top-level `permissions: contents: read`. Pinned `actions/checkout@v7`, `hashicorp/setup-terraform@v4`, `douglascamata/setup-docker-macos-action@v1.1.0`, `docker/setup-qemu-action@v4`, `actions/setup-go@v6` to full SHAs. Moved `${{ env.TERRAFORM_VERSION }}` in the Windows Terraform step to an `env:` block.

### Iteration 3

**Fixes applied:** missing-permissions, script-injection

**Notes:**

1. pr-checks.yml: Added `permissions: {}` top-level block to explicitly restrict workflow permissions rather than inheriting broad repository defaults. 2. release.yml (line ~83): Double-quoted `$MATRIX_GOOS` and `$MATRIX_GOARCH` in the go build command (`GOOS="$MATRIX_GOOS" GOARCH="$MATRIX_GOARCH" go build -a ...`) to satisfy the rule that all shell expansions of env vars holding workflow-controllable context must be double-quoted.

### Iteration 4

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection vulnerability in the 'Determine OS and Architecture' step of action.yml. The $OS variable (derived from the inherited $RUNNER_OS env var) and $ARCH are now sanitized using `printf '%s' "$VAR" | tr -d '\n\r'` before being written to $GITHUB_OUTPUT. This prevents a newline-containing value from injecting additional key=value pairs into the output file. Also added proper quoting around $GITHUB_OUTPUT.

### Iteration 5

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Get Version from Tag' step in .github/workflows/release.yml (line 36). The raw `${GITHUB_REF#refs/tags/}` value was being written directly to $GITHUB_OUTPUT without sanitization. Replaced with: `safe_version=$(printf '%s' "${GITHUB_REF#refs/tags/}" | tr -d '\n\r')` followed by `echo "version=${safe_version}" >> "$GITHUB_OUTPUT"`. This prevents a specially crafted tag name containing newlines from injecting arbitrary key-value pairs into the GITHUB_OUTPUT file.

