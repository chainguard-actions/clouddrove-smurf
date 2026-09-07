<!-- markdownlint-disable -->

# Hardening Report: clouddrove--smurf/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouddrove--smurf/v1.2.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings in the 'Build' step. Offending lines include: `echo "Package: ${{env.APP_PACKAGE}}"`, `echo "Version: ${{steps.buildinfo.outputs.version}}"`, `-X '${{env.APP_PACKAGE}}.version=${{steps.buildinfo.outputs.version}}'`, etc. These expressions are expanded by the Actions template engine before the shell sees them, allowing any value containing shell metacharacters to inject arbitrary commands.

Locations:

- `.github/workflows/build.yml:52`

### script-injection (severity: high)

Sub-rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings in multiple steps. The 'Build Binary with Version Injection' step uses `${{ matrix.GOOS }}`, `${{ matrix.GOARCH }}`, `${{ env.BINARY_NAME }}`, `${{env.APP_PACKAGE}}`, `${{steps.buildinfo.outputs.version}}`, `${{steps.buildinfo.outputs.commit}}`, `${{steps.buildinfo.outputs.date}}` directly in shell. The 'Build Docker Image' step uses `${{env.REPO}}` and `${{ github.ref_name }}` directly in shell (`make image IMAGE=ghcr.io/${{env.REPO}}:${{ github.ref_name }}`). The 'Tag latest' and 'Push Docker Image' steps also use `${{env.REPO}}` and `${{ github.ref_name }}` directly in shell.

Locations:

- `.github/workflows/release.yml:47`
- `.github/workflows/release.yml:120`
- `.github/workflows/release.yml:126`
- `.github/workflows/release.yml:129`

### script-injection (severity: high)

Sub-rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings. The 'Build with version injection' step uses `${{ matrix.GOOS }}`, `${{ matrix.GOARCH }}`, `${{ steps.buildinfo.outputs.version }}`, `${{ steps.buildinfo.outputs.commit }}`, `${{ steps.buildinfo.outputs.date }}` directly in shell. The 'Create distribution archive' step also uses `${{ matrix.GOOS }}`, `${{ matrix.GOARCH }}`, `${{ steps.buildinfo.outputs.version }}` directly in shell. The 'Run the binary and confirm version injection' step uses `${{ steps.buildinfo.outputs.version }}` directly in shell.

Locations:

- `.github/workflows/release-dry-run.yml:62`
- `.github/workflows/release-dry-run.yml:80`
- `.github/workflows/release-dry-run.yml:107`

### script-injection (severity: high)

Sub-rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings in the 'Report' step of the summary job. Offending lines include: `echo "assets: ${{ needs.release-assets.result }}"`, `echo "image: ${{ needs.published-image.result }}"`, `echo "action: ${{ needs.published-action.result }}"`, and the if-condition comparisons using these same expressions. If any of these values contained shell metacharacters they would be interpreted by the shell.

Locations:

- `.github/workflows/post-release-smoke.yml:175`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in four workflow files by moving all ${{ }} expressions out of run: shell strings and into step-level env: blocks:

1. build.yml (line 52): The 'Build' step now has an env: block with BUILD_APP_PACKAGE, BUILD_VERSION, BUILD_COMMIT, BUILD_DATE. The run: script references these as plain shell variables.

2. release.yml (lines 47, 120, 126, 129): 
   - 'Build Binary with Version Injection' step: moved MATRIX_GOOS, MATRIX_GOARCH, BUILD_BINARY_NAME, BUILD_APP_PACKAGE, BUILD_VERSION, BUILD_COMMIT, BUILD_DATE to env: block.
   - 'Create Distribution Archive' step: moved MATRIX_GOOS, MATRIX_GOARCH, BUILD_BINARY_NAME, BUILD_VERSION to env: block.
   - 'Build Docker Image' step: moved BUILD_BINARY_NAME, IMAGE_REPO, IMAGE_TAG to env: block.
   - 'Tag latest' step: moved IMAGE_REPO, IMAGE_TAG to env: block.
   - 'Push Docker Image' step: moved IMAGE_REPO, IMAGE_TAG to env: block.
   - 'Push Latest Tag' step: moved IMAGE_REPO to env: block.
   - 'Verify Release' step: moved GH_REPOSITORY, GH_REF_NAME to env: block.

3. release-dry-run.yml (lines 62, 80, 107):
   - 'Synthesise build info' step: moved PR_NUMBER to env: block.
   - 'Build with version injection' step: moved MATRIX_GOOS, MATRIX_GOARCH, BUILD_VERSION, BUILD_COMMIT, BUILD_DATE to env: block.
   - 'Create distribution archive' step: moved MATRIX_GOOS, MATRIX_GOARCH, BUILD_VERSION to env: block.
   - 'Run the binary and confirm version injection' step: moved BUILD_VERSION to env: block.

4. post-release-smoke.yml (line 175): The 'Report' step now has an env: block with RESULT_ASSETS, RESULT_IMAGE, RESULT_ACTION. The run: script references these as plain shell variables instead of ${{ needs.*.result }} expressions.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all four findings:
1. test-multiplatform.yml: Moved `${{ env.TERRAFORM_VERSION }}` into a step env block as `TERRAFORM_VERSION` and referenced it as `$env:TERRAFORM_VERSION` in the PowerShell run script.
2. post-release-smoke.yml: Moved `${{ github.repository }}` into step-level env blocks as `GH_REPOSITORY` for all five affected run steps (Download assets, Pull image, Run tools, Confirm version).
3. action.yml: Added `safe_version=$(printf '%s' "$INPUT_VERSION" | tr -d '\n\r')` before writing to GITHUB_OUTPUT to prevent newline injection.
4. release-dry-run.yml: Added `safe_pr=$(printf '%s' "$PR_NUMBER" | tr -d '\n\r')` before writing to GITHUB_OUTPUT to prevent newline injection.

