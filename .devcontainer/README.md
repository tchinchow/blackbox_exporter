# Development Container

This directory holds the VS Code Dev Container configuration for the
Blackbox Exporter project.  It lets you build, test and extend the project
without installing any Go toolchain on your host machine.

## Quick start

1. Open this repository in VS Code.
2. Install the **Dev Containers** extension
   (`ms-vscode-remote.remote-containers`).
3. Run **"Dev Containers: Reopen in Container"** from the command palette
   (`Ctrl+Shift+P`).
4. Wait for the post-create script to finish (check the terminal for
   `==> Done`).
5. `make build test` — first end-to-end sanity check.

---

## What is inside

### Base image

`mcr.microsoft.com/devcontainers/go:1.26-bookworm`

The official Microsoft Go devcontainer image based on Debian Bookworm.  It
ships with the correct Go toolchain version (matching `.promu.yml` and the CI
`golang-builder` image), a non-root `vscode` user, `git`, `make`, `curl` and
the VS Code Server pre-configured.

> **Why not reuse the project's `Dockerfile`?**  The production images set a
> binary `ENTRYPOINT` and have no shell.  They cannot serve as a dev
> environment.

Reference: <https://github.com/devcontainers/images/tree/main/src/go>

---

### Dev Container Features

| Feature | Purpose |
|---------|---------|
| `docker-in-docker:2` | Lets `make docker` build container images from inside the devcontainer without exposing the host socket. |
| `github-cli:1` | `gh` CLI for creating pull requests against upstream once your patch is ready. |

Reference: <https://containers.dev/features>

---

### CLI tools (installed by `post-create.sh`)

| Tool | Version | Purpose |
|------|---------|---------|
| **golangci-lint** | v2.11.4 | Aggregated linter — `make lint`.  Version pinned to `GOLANGCI_LINT_VERSION` in `Makefile.common`. |
| **promu** | 0.20.0 | Prometheus build tool — `make build`.  Injects version/branch/date ldflags into the binary.  Version pinned to `PROMU_VERSION` in `Makefile.common`. |
| **govulncheck** | latest | Static vulnerability scanner — mirrors the `govulncheck.yml` CI workflow. |
| **yamllint** | distro | YAML style and syntax checker — `make yamllint`. |
| **gopls** | (Go ext) | Go language server, installed automatically by the `golang.go` extension. |
| **dlv** | (Go ext) | Delve debugger, installed automatically by the `golang.go` extension. |

References:
- golangci-lint: <https://golangci-lint.run>
- promu: <https://github.com/prometheus/promu>
- govulncheck: <https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck>
- yamllint: <https://yamllint.readthedocs.io>
- Delve: <https://github.com/go-delve/delve>

---

### VS Code extensions

| Extension | Purpose |
|-----------|---------|
| **golang.go** | Full Go IDE: completion, navigation, inline diagnostics, test runner, debugger integration. |
| **github.copilot** | AI inline code completion — suggests whole functions as you type. |
| **github.copilot-chat** | AI chat — ask questions about the codebase, request explanations or refactors. |
| **prometheus-community.vscode-promql** | Syntax highlighting for PromQL queries and Prometheus rule files. |
| **grafana.vscode-jsonnet** | Jsonnet support for writing Grafana dashboards as code. |
| **redhat.vscode-yaml** | Schema validation and auto-complete for `blackbox.yml`, `example.yml` and CI workflow files. |
| **davidanson.vscode-markdownlint** | Lint `README.md`, `CHANGELOG.md`, `CONFIGURATION.md` etc. |
| **streetsidesoftware.code-spell-checker** | Catches typos in identifiers, comments and docs. |
| **ms-azuretools.vscode-docker** | Browse images/containers, Dockerfile syntax highlighting. |
| **eamodio.gitlens** | Inline blame, rich history, interactive rebase — essential when preparing a patch for upstream. |
| **mhutchie.git-graph** | Visual branch and commit graph. |

---

### Runtime capabilities

| Flag | Why it is needed |
|------|-----------------|
| `--cap-add=NET_RAW` | The ICMP prober sends raw packets; without this capability the `prober` tests that exercise ICMP will fail. |
| `--cap-add=SYS_PTRACE` | Required by the Delve debugger (`dlv`) to attach to or launch Go processes. |
| `--security-opt seccomp=unconfined` | Removes the seccomp filter that would otherwise block the `ptrace` syscall used by Delve. |

---

### Persistent volume mounts

Two named Docker volumes are attached so that the Go module cache and build
cache survive container rebuilds.  This avoids re-downloading all dependencies
every time the container is recreated.

| Volume | Mount path | Content |
|--------|------------|---------|
| `blackbox-gomodcache` | `/home/vscode/go/pkg/mod` | Downloaded module sources (`go mod download`). |
| `blackbox-gobuildcache` | `/home/vscode/.cache/go-build` | Compiled object files (`go build` cache). |

---

## Useful make targets

```bash
make build          # compile with promu (sets version ldflags)
make test           # run the full test suite (includes -race on amd64)
make lint           # run golangci-lint
make style          # check gofmt formatting
make check_license  # verify licence headers
make unused         # check go.mod / go.sum are tidy
make yamllint       # lint YAML files
make all            # all of the above
```

Run `./blackbox_exporter --config.file=blackbox.yml` after building to start
the exporter locally.  VS Code will forward port **9115** and show a
notification.
