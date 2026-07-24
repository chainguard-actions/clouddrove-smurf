<!-- markdownlint-disable -->

# Hardening Report: clouddrove--smurf/v1.1.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouddrove--smurf/v1.1.8** was hardened automatically. 2 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

Step 'Determine OS and Architecture' writes the variable $OS (derived from the inherited process env var $RUNNER_OS, which is not set within the same run block) to $GITHUB_OUTPUT without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). In a composite action, inherited env vars must be treated as untrusted. The `tr '[:upper:]' '[:lower:]'` transformation does not strip newlines, so a crafted value could inject additional key=value pairs into GITHUB_OUTPUT.

Locations:

- `action.yml:32`

### github-env-injection (severity: high)

Step 'Get correct version format' writes $INPUT_VERSION (sourced from `inputs.version`, an attacker-controllable input) to $GITHUB_OUTPUT without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). Although a regex validation (`^v[0-9]+\.[0-9]+\.[0-9]+$`) is applied in the else-branch, this is not the prescribed sanitization method and does not cover the case where the validation is bypassed or the value contains embedded newlines that could inject additional output entries.

Locations:

- `action.yml:54`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:

1. 'Determine OS and Architecture' step (line 32): Added env block to capture runner.os as RUNNER_OS_INPUT, applied printf '%s' ... | tr -d '\n\r' sanitization when computing OS from the env var, and added safe_os/safe_arch variables with newline stripping before writing to $GITHUB_OUTPUT.

2. 'Get correct version format' step (line 54): Added safe_tag and safe_version variables using printf '%s' ... | tr -d '\n\r' sanitization in both branches (latest tag from API and validated user-supplied version) before writing to $GITHUB_OUTPUT.

Both fixes use the prescribed sanitization method to prevent newline injection into GITHUB_OUTPUT.

### Iteration 2

**Fixes applied:** script-injection, missing-permissions, broad-permissions, unpinned-uses

**Notes:**

Fixed all findings across 5 workflow files:

1. build.yml: Pinned actions/checkout@v7→SHA and actions/setup-go@v6→SHA. Added top-level and job-level permissions: contents: read. Fixed script injection in 'Build' step by moving APP_PACKAGE, buildinfo.outputs.version/commit/date into step env: block and referencing as plain shell vars.

2. release.yml: Added permissions: contents: read, packages: write to docker-build job. Fixed script injection in 'Build Docker Image', 'Tag latest', 'Push Docker Image', 'Push Latest Tag' steps by moving env.REPO and github.ref_name into step env: blocks (REPO_NAME, REF_NAME).

3. test-multiplatform.yml: Pinned all 5 unpinned actions to full SHAs. Added top-level and job-level permissions: contents: read. Fixed script injection in 'Set up Terraform on Windows' step by moving TERRAFORM_VERSION into step env: block (TF_VERSION).

4. docs.yml: Replaced permissions: write-all with specific minimal permissions (contents: write, pages: write, id-token: write) at top level and scoped per-job. Pinned all 5 unpinned actions to full SHAs.

5. pr-checks.yml: Added top-level permissions: contents: read, pull-requests: read.

### Iteration 3

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in hardened/action/.github/workflows/release.yml by quoting all shell variable expansions of ${REPO_NAME} and ${REF_NAME} in the four affected run: commands (lines 61, 67, 73, 78). The variables were already correctly placed in the env: block to avoid direct ${{ }} expression injection, but the shell expansions were unquoted, allowing shell metacharacters in the values to be interpreted. Added double quotes around all expansions: IMAGE="ghcr.io/${REPO_NAME}:${REF_NAME}", VERSION="${REF_NAME}", docker tag arguments, and docker push arguments.

