<!-- markdownlint-disable -->

# Hardening Report: clouddrove--smurf/v1.2.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouddrove--smurf/v1.2.1** was hardened automatically. 2 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

Step 'Determine OS and Architecture' writes $OS (derived from the inherited $RUNNER_OS process env var, which is untrusted in a composite action) to $GITHUB_OUTPUT without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). The value is transformed via `tr '[:upper:]' '[:lower:]'` but never stripped of newline characters before the write. An attacker who can influence $RUNNER_OS could inject arbitrary key-value pairs into GITHUB_OUTPUT.

Locations:

- `action.yml:32`
- `action.yml:33`

### github-env-injection (severity: high)

Step 'Get correct version format' writes $INPUT_VERSION (sourced from inputs.version via the INPUT_VERSION env var) to $GITHUB_OUTPUT without the required `printf '%s' ... | tr -d '\n\r'` sanitization. A regex format check (`^v[0-9]+\.[0-9]+\.[0-9]+$`) is applied, but this is not the sanitization step required by the check — a caller supplying a crafted version string that passes the regex could still inject content. The same step also writes $LATEST_TAG (derived from a remote URL redirect) to $GITHUB_OUTPUT without sanitization.

Locations:

- `action.yml:68`
- `action.yml:76`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed all four $GITHUB_OUTPUT writes in action.yml to sanitize values before writing:
1. 'Determine OS and Architecture' step (lines 32-33): Added `safe_os=$(printf '%s' "$OS" | tr -d '\n\r')` and `safe_arch=$(printf '%s' "$ARCH" | tr -d '\n\r')` before writing `os=` and `arch=` to $GITHUB_OUTPUT.
2. 'Get correct version format' step (lines 68 and 76): Added `safe_tag=$(printf '%s' "$LATEST_TAG" | tr -d '\n\r')` before writing the resolved latest tag, and `safe_version=$(printf '%s' "$INPUT_VERSION" | tr -d '\n\r')` before writing the user-supplied version. Both values now have newline characters stripped before being written to $GITHUB_OUTPUT, preventing injection of arbitrary key-value pairs.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 21 findings across 4 workflow files:

**build.yml**: Sanitized GITHUB_OUTPUT writes in 'Get Build Info' with `tr -d '\n\r'`. Moved all ${{ }} expressions in 'Build' step to an env: block.

**release.yml**: Sanitized GITHUB_OUTPUT writes in 'Get Version from Tag' and 'Get Build Info'. Moved all ${{ }} expressions in 'Build Binary with Version Injection', 'Create Distribution Archive', 'Verify Release', 'Build Docker Image', 'Tag latest', 'Push Docker Image', and 'Push Latest Tag' steps to env: blocks.

**release-dry-run.yml**: Moved ${{ github.event.pull_request.number || 0 }} to env: block (PR_NUMBER) in 'Synthesise build info' and added sanitization before GITHUB_OUTPUT writes. Moved all ${{ matrix.* }} and ${{ steps.buildinfo.outputs.* }} expressions in 'Build with version injection', 'Create distribution archive', and 'Run the binary and confirm version injection' steps to env: blocks.

**post-release-smoke.yml**: Moved ${{ github.repository }} to env: blocks (IMAGE_REPO/GH_REPOSITORY) in 'Download every published asset', 'Pull the published image', 'Run every bundled tool from the published image', and 'Confirm the image carries the released version' steps. Moved ${{ needs.*.result }} expressions to env: block in 'Report' step and replaced inline ${{ }} comparisons with plain env var references.

### Iteration 3

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in .github/workflows/test-multiplatform.yml at the 'Set up Terraform on Windows' step. Moved `${{ env.TERRAFORM_VERSION }}` out of the `run:` shell command and into a step-level `env:` block as `TERRAFORM_VERSION: ${{ env.TERRAFORM_VERSION }}`. Updated the shell command to reference it as `$env:TERRAFORM_VERSION` (PowerShell environment variable syntax appropriate for Windows runners).

