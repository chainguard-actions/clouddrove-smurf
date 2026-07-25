<!-- markdownlint-disable -->

# Hardening Report: clouddrove--smurf/v1.1.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouddrove--smurf/v1.1.5** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In the 'Get correct version format' step of action.yml, the env var `$INPUT_VERSION` (sourced from the untrusted `inputs.version` input) is written directly to `$GITHUB_OUTPUT` without the required newline-stripping sanitization (`printf '%s' "$INPUT_VERSION" | tr -d '\n\r'`). An attacker-controlled version string containing embedded newlines could inject arbitrary key=value pairs into the GitHub output context. The offending line is: `echo "tag=$INPUT_VERSION" >> "$GITHUB_OUTPUT"`.

Locations:

- `action.yml:48`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in action.yml at line 48. The user-controlled `$INPUT_VERSION` value is now sanitized with `printf '%s' "$INPUT_VERSION" | tr -d '\n\r'` before being written to `$GITHUB_OUTPUT`. The sanitized value is stored in `safe_version` and then written as `echo "tag=$safe_version" >> "$GITHUB_OUTPUT"`, preventing newline injection attacks.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Determine OS and Architecture' step of action.yml. The $OS variable (derived from $RUNNER_OS, a workflow-controlled value) is now sanitized with `safe_os=$(printf '%s' "$OS" | tr -d '\n\r')` before being written to $GITHUB_OUTPUT as `echo "os=$safe_os" >> "$GITHUB_OUTPUT"`. This prevents newline injection attacks where a calling workflow could set RUNNER_OS to a value containing newlines to inject arbitrary key=value pairs into GITHUB_OUTPUT. The $ARCH variable was already safe (always set to a literal string) and its write was updated to use quoted "$GITHUB_OUTPUT" for consistency.

