<!-- markdownlint-disable -->

# Hardening Report: clouddrove--smurf/v1.1.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **clouddrove--smurf/v1.1.2** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

Step 'Determine OS and Architecture' writes $OS (derived from the inherited env var $RUNNER_OS, which is workflow-controlled) to $GITHUB_OUTPUT without the required sanitization step (`printf '%s' "$OS" | tr -d '\n\r'`). A calling workflow could set RUNNER_OS to a value containing newlines, injecting arbitrary key=value pairs into the output context.

Offending line:
  echo "os=$OS" >> $GITHUB_OUTPUT

Locations:

- `action.yml:31`

### github-env-injection (severity: high)

Step 'Get correct version format' writes $LATEST_TAG (fetched from an external GitHub API response via curl/grep/sed, with no newline sanitization) to $GITHUB_OUTPUT. A compromised or attacker-controlled API response containing newline characters could inject arbitrary key=value pairs into the output context.

Offending line:
  echo "tag=${LATEST_TAG}" >> "$GITHUB_OUTPUT"

Locations:

- `action.yml:45`

### github-env-injection (severity: high)

Step 'Get correct version format' writes $INPUT_VERSION (sourced from inputs.version, a caller-controlled value) to $GITHUB_OUTPUT without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). Although a regex check rejects values not matching vX.Y.Z, this is not equivalent to stripping newline characters before the write. A value that passes the regex but contains embedded newlines (e.g. via ANSI escape sequences or other bypass) could inject arbitrary key=value pairs.

Offending line:
  echo "tag=$INPUT_VERSION" >> "$GITHUB_OUTPUT"

Locations:

- `action.yml:52`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed all three github-env-injection findings in action.yml:
1. 'Determine OS and Architecture' step (line 31): Sanitized $OS (derived from $RUNNER_OS) before writing to $GITHUB_OUTPUT using `safe_os=$(printf '%s' "$OS" | tr -d '\n\r')`. Also sanitized $ARCH similarly and quoted $GITHUB_OUTPUT.
2. 'Get correct version format' step (line 45): Sanitized $LATEST_TAG (from external GitHub API curl response) before writing to $GITHUB_OUTPUT using `safe_tag=$(printf '%s' "$LATEST_TAG" | tr -d '\n\r')`.
3. 'Get correct version format' step (line 52): Sanitized $INPUT_VERSION (caller-controlled input) before writing to $GITHUB_OUTPUT using `safe_version=$(printf '%s' "$INPUT_VERSION" | tr -d '\n\r')`, even though a regex check is already in place.

