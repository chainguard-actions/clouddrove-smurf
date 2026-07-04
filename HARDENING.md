<!-- markdownlint-disable -->

# Hardening Report: clouddrove--smurf--/v1.1.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **clouddrove--smurf--/v1.1.5** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files and the setup-smurf composite action use tag-based or version-based refs instead of pinned full 40-character SHA commit hashes. This exposes the workflow to supply-chain attacks if a tag is moved or a repository is compromised. Failing references include: actions/checkout@v7, actions/setup-go@v6, actions/setup-python@v6, actions/cache@v6, actions/upload-pages-artifact@v5, actions/deploy-pages@v5, actions/upload-artifact@v7, actions/download-artifact@v8, docker/login-action@v4, softprops/action-gh-release@v3, InsonusK/get-latest-release@v1.1.0, hashicorp/setup-terraform@v4, douglascamata/setup-docker-macos-action@v1.1.0, docker/setup-qemu-action@v4. Additionally, .github/actions/setup-smurf/action.yml uses a Docker image with a mutable tag: docker://ghcr.io/clouddrove/smurf:v0.0.5 instead of a SHA digest.

Locations:

- `.github/workflows/build.yml:17`
- `.github/workflows/build.yml:21`
- `.github/workflows/build.yml:68`
- `.github/workflows/build.yml:69`
- `.github/workflows/docs.yml:12`
- `.github/workflows/docs.yml:19`
- `.github/workflows/docs.yml:37`
- `.github/workflows/docs.yml:42`
- `.github/workflows/release.yml:21`
- `.github/workflows/release.yml:25`
- `.github/workflows/release.yml:82`
- `.github/workflows/release.yml:93`
- `.github/workflows/release.yml:107`
- `.github/workflows/release.yml:118`
- `.github/workflows/release.yml:139`
- `.github/workflows/release.yml:155`
- `.github/workflows/release.yml:163`
- `.github/workflows/test-multiplatform.yml:22`
- `.github/workflows/test-multiplatform.yml:29`
- `.github/workflows/test-multiplatform.yml:33`
- `.github/workflows/test-multiplatform.yml:37`
- `.github/workflows/test-multiplatform.yml:41`
- `.github/actions/setup-smurf/action.yml:22`

### missing-permissions (severity: medium)

build.yml has no top-level permissions key and neither the 'build' nor 'format' jobs define job-level permissions. release.yml has no top-level permissions key and the 'build' and 'docker-build' jobs have no job-level permissions (only the 'release' job has permissions: contents: write). test-multiplatform.yml has no top-level permissions key and no job-level permissions on any job. Without explicit permissions, the GITHUB_TOKEN is granted default (potentially broad) permissions.

Locations:

- `.github/workflows/build.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/test-multiplatform.yml:1`

### broad-permissions (severity: medium)

docs.yml sets top-level permissions to 'write-all', granting all available write permissions to the GITHUB_TOKEN. This is overly broad and should be replaced with specific minimal permissions (e.g., pages: write, id-token: write, contents: read).

Locations:

- `.github/workflows/docs.yml:6`

### script-injection (severity: high)

Multiple run: blocks directly interpolate ${{ }} expressions inside shell commands, violating rule (a). This allows template substitution to inject arbitrary shell metacharacters before the shell parses the command. Affected steps and offending expressions: (1) build.yml 'Build' step: ${{env.APP_PACKAGE}}, ${{steps.buildinfo.outputs.version}}, ${{steps.buildinfo.outputs.commit}}, ${{steps.buildinfo.outputs.date}} interpolated directly in go build -ldflags. (2) release.yml 'Get Build Info' step: ${{ steps.version.outputs.version }} assigned directly in shell. (3) release.yml 'Build Binary with Version Injection' step: ${{ env.BINARY_NAME }}, ${{ matrix.GOOS }}, ${{ matrix.GOARCH }}, ${{steps.buildinfo.outputs.*}} interpolated in run: block including unquoted GOOS=${{ matrix.GOOS }} GOARCH=${{ matrix.GOARCH }}. (4) release.yml 'Create Distribution Archive' step: ${{ env.BINARY_NAME }}, ${{ steps.buildinfo.outputs.version }}, ${{ matrix.GOOS }}, ${{ matrix.GOARCH }} interpolated in shell. (5) release.yml 'Build Docker Image' step: ${{ env.BINARY_NAME }}, ${{env.REPO}}, ${{ github.ref_name }} interpolated in shell. (6) release.yml 'Tag latest' and 'Push Docker Image' steps: ${{env.REPO}}, ${{ github.ref_name }} interpolated in shell. (7) release.yml 'Verify Release' step: ${{ github.repository }}, ${{ github.ref_name }} interpolated in shell.

Locations:

- `.github/workflows/build.yml:50`
- `.github/workflows/release.yml:39`
- `.github/workflows/release.yml:48`
- `.github/workflows/release.yml:67`
- `.github/workflows/release.yml:88`
- `.github/workflows/release.yml:168`
- `.github/workflows/release.yml:175`
- `.github/workflows/release.yml:179`
- `.github/workflows/release.yml:183`

### github-env-injection (severity: high)

Multiple run: blocks write values derived from untrusted or workflow-controlled sources to $GITHUB_OUTPUT without the required sanitization step (printf '%s' ... | tr -d '\n\r'). (1) action.yml 'Determine OS and Architecture' step writes $OS (derived from $RUNNER_OS, a workflow-controlled env var) and $ARCH to $GITHUB_OUTPUT without sanitization. (2) action.yml 'Get correct version format' step writes $INPUT_VERSION (from inputs.version) and $LATEST_TAG (from external curl) to $GITHUB_OUTPUT without sanitization. (3) build.yml 'Get Build Info' step writes VERSION (from curl/git), COMMIT, and DATE to $GITHUB_OUTPUT without sanitization. (4) release.yml 'Get Version from Tag' step writes ${GITHUB_REF#refs/tags/} to $GITHUB_OUTPUT without sanitization. (5) release.yml 'Get Build Info' step writes ${{ steps.version.outputs.version }} (a step output) to $GITHUB_OUTPUT without sanitization.

Locations:

- `action.yml:30`
- `action.yml:31`
- `action.yml:44`
- `action.yml:49`
- `.github/workflows/build.yml:46`
- `.github/workflows/build.yml:47`
- `.github/workflows/build.yml:48`
- `.github/workflows/release.yml:30`
- `.github/workflows/release.yml:43`
- `.github/workflows/release.yml:44`
- `.github/workflows/release.yml:45`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions, broad-permissions, script-injection, github-env-injection

**Notes:**

Fixed all 5 findings across 6 files: (1) unpinned-uses: Pinned all action refs to full SHA hashes in build.yml, docs.yml, release.yml, test-multiplatform.yml, and .github/actions/setup-smurf/action.yml. Docker image ghcr.io/clouddrove/smurf:v0.0.5 pinned to SHA digest. (2) missing-permissions: Added top-level 'permissions: {}' to build.yml, release.yml, and test-multiplatform.yml; added job-level permissions blocks to all jobs. (3) broad-permissions: Replaced 'write-all' in docs.yml with specific minimal permissions (contents: write, pages: write, id-token: write) at top-level and per-job. (4) script-injection: Moved all ${{ }} expressions from run: blocks into env: blocks in build.yml (Build step) and release.yml (Build Binary, Create Distribution Archive, Build Docker Image, Tag latest, Push Docker Image, Verify Release steps). (5) github-env-injection: Added printf '%s' ... | tr -d '\n\r' sanitization before all GITHUB_OUTPUT writes in action.yml (Determine OS/Architecture and Get correct version format steps), build.yml (Get Build Info step), and release.yml (Get Version from Tag and Get Build Info steps).

### Iteration 2

**Fixes applied:** missing-permissions, script-injection

**Notes:**

1. Added `permissions: {}` top-level block to `.github/workflows/pr-checks.yml` to prevent the workflow from inheriting broad default repository permissions. 2. Fixed the unquoted `$TF_VERSION` variable in `.github/workflows/test-multiplatform.yml` by changing `--version=$TF_VERSION` to `--version="$TF_VERSION"` in the choco install command, preventing shell metacharacter injection.

