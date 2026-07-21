<!-- markdownlint-disable -->

# Hardening Report: clouddrove--smurf/v1.1.7-beta

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouddrove--smurf/v1.1.7-beta** was hardened automatically. 12 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in the Build step of build.yml. Specifically: `echo "Package: ${{env.APP_PACKAGE}}"`, `echo "Version: ${{steps.buildinfo.outputs.version}}"`, `echo "Commit: ${{steps.buildinfo.outputs.commit}}"`, `echo "Date: ${{steps.buildinfo.outputs.date}}"`, and the go build -ldflags lines all embed ${{env.APP_PACKAGE}}, ${{steps.buildinfo.outputs.version}}, ${{steps.buildinfo.outputs.commit}}, ${{steps.buildinfo.outputs.date}} directly in the shell script. These values flow through YAML template substitution before the shell sees them, enabling shell metacharacter injection.

Locations:

- `.github/workflows/build.yml:54`

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in the docker-build job of release.yml. Offending lines: `make image IMAGE=ghcr.io/${{env.REPO}}:${{ github.ref_name }} VERSION=${{ github.ref_name }}`, `docker tag ghcr.io/${{env.REPO}}:${{ github.ref_name }} ghcr.io/${{env.REPO}}:latest`, `docker push ghcr.io/${{env.REPO}}:${{ github.ref_name }}`, and `docker push ghcr.io/${{env.REPO}}:latest`. The `github.ref_name` and `env.REPO` contexts are substituted directly into shell commands without quoting or env-var indirection.

Locations:

- `.github/workflows/release.yml:47`
- `.github/workflows/release.yml:50`
- `.github/workflows/release.yml:53`
- `.github/workflows/release.yml:56`

### script-injection (severity: high)

Sub-rule (a): A ${{ }} expression is interpolated directly inside a run: shell command string in test-multiplatform.yml. Offending line: `choco install terraform --version=${{ env.TERRAFORM_VERSION }} -y`. The env.TERRAFORM_VERSION context is substituted directly into the shell command via YAML template expansion before the shell processes it.

Locations:

- `.github/workflows/test-multiplatform.yml:28`

### github-env-injection (severity: high)

In action.yml, the 'Get correct version format' step writes the value of inputs.version (routed via the INPUT_VERSION env var) directly to $GITHUB_OUTPUT without sanitization: `echo "tag=$INPUT_VERSION" >> "$GITHUB_OUTPUT"`. No `printf '%s' ... | tr -d '\n\r'` sanitization step is applied before the write. A caller can supply a version string containing newline characters to inject arbitrary key=value pairs into GITHUB_OUTPUT, potentially overwriting subsequent step outputs.

Locations:

- `action.yml:55`

### missing-permissions (severity: medium)

build.yml has no top-level permissions: key and neither the 'build' job nor the 'format' job defines a job-level permissions: block. This means the workflow runs with the default (potentially write) token permissions.

Locations:

- `.github/workflows/build.yml:1`

### broad-permissions (severity: medium)

docs.yml sets `permissions: write-all` at the top level, granting overly broad write access to all GitHub API scopes for every job in the workflow. This should be replaced with specific minimal permissions (e.g., contents: write, pages: write, id-token: write).

Locations:

- `.github/workflows/docs.yml:7`

### missing-permissions (severity: medium)

pr-checks.yml has no top-level permissions: key and the single job 'pr-validation' (which calls a reusable workflow) has no job-level permissions: block. The workflow runs with default token permissions.

Locations:

- `.github/workflows/pr-checks.yml:1`

### missing-permissions (severity: medium)

release.yml has no top-level permissions: key. While the 'goreleaser' job defines `permissions: contents: write`, the 'docker-build' job has no permissions: block at all. Since not every job defines its own permissions, the file fails the check — the docker-build job inherits default (potentially broad) token permissions.

Locations:

- `.github/workflows/release.yml:1`

### missing-permissions (severity: medium)

test-multiplatform.yml has no top-level permissions: key and the single 'test' job has no job-level permissions: block. The workflow runs with default token permissions.

Locations:

- `.github/workflows/test-multiplatform.yml:1`

### unpinned-uses (severity: high)

build.yml references multiple actions by mutable tag rather than a full 40-character commit SHA: `actions/checkout@v7` (build job line 17, format job line 76) and `actions/setup-go@v6` (build job line 21, format job line 77). These tags can be moved to point to different commits, enabling supply-chain attacks.

Locations:

- `.github/workflows/build.yml:17`
- `.github/workflows/build.yml:21`
- `.github/workflows/build.yml:76`
- `.github/workflows/build.yml:77`

### unpinned-uses (severity: high)

docs.yml references multiple actions by mutable tag rather than a full 40-character commit SHA: `actions/checkout@v7`, `actions/setup-python@v6`, `actions/cache@v6`, `actions/upload-pages-artifact@v5`, and `actions/deploy-pages@v5`. These tags can be moved to point to different commits, enabling supply-chain attacks.

Locations:

- `.github/workflows/docs.yml:12`
- `.github/workflows/docs.yml:17`
- `.github/workflows/docs.yml:19`
- `.github/workflows/docs.yml:40`
- `.github/workflows/docs.yml:44`
- `.github/workflows/docs.yml:49`

### unpinned-uses (severity: high)

test-multiplatform.yml references multiple actions by mutable tag rather than a full 40-character commit SHA: `actions/checkout@v7`, `hashicorp/setup-terraform@v4`, `douglascamata/setup-docker-macos-action@v1.1.0`, `docker/setup-qemu-action@v4`, and `actions/setup-go@v6`. These tags can be moved to point to different commits, enabling supply-chain attacks.

Locations:

- `.github/workflows/test-multiplatform.yml:22`
- `.github/workflows/test-multiplatform.yml:32`
- `.github/workflows/test-multiplatform.yml:36`
- `.github/workflows/test-multiplatform.yml:40`
- `.github/workflows/test-multiplatform.yml:44`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, missing-permissions, broad-permissions, unpinned-uses

**Notes:**

Fixed all 10 findings across 5 files:

1. build.yml: Pinned actions/checkout@v7 and actions/setup-go@v6 to full SHAs; added top-level and job-level permissions: contents: read; moved all ${{ }} expressions in the Build step into the step env: block (BUILD_APP_PACKAGE, BUILD_VERSION, BUILD_COMMIT, BUILD_DATE).

2. release.yml: Added top-level permissions: contents: read; added permissions: contents: read, packages: write to docker-build job; moved ${{ env.REPO }} and ${{ github.ref_name }} into step-level env: blocks (DOCKER_REPO, REF_NAME) for all four docker steps.

3. test-multiplatform.yml: Pinned actions/checkout@v7, hashicorp/setup-terraform@v4, douglascamata/setup-docker-macos-action@v1.1.0, docker/setup-qemu-action@v4, actions/setup-go@v6 to full SHAs; added top-level and job-level permissions: contents: read; moved ${{ env.TERRAFORM_VERSION }} into step env: block as TF_VERSION.

4. docs.yml: Replaced permissions: write-all with specific minimal permissions (contents: write, pages: write, id-token: write) at top level with job-level scoping; pinned all 5 actions to full SHAs.

5. pr-checks.yml: Added top-level permissions: contents: read and job-level permissions: contents: read, pull-requests: read.

6. action.yml: Added printf '%s' ... | tr -d '\n\r' sanitization before writing to $GITHUB_OUTPUT in both branches of the version check step.

