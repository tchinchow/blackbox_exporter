#!/usr/bin/env bash
# Post-create script for the Blackbox Exporter devcontainer.
# Installs the CLI tools that the project's Makefile expects.
# Versions are pinned to match Makefile.common so that local builds are
# identical to CI.

set -euo pipefail

# ── Constants (kept in sync with Makefile.common) ────────────────────────────
GOLANGCI_LINT_VERSION="v2.11.4"   # GOLANGCI_LINT_VERSION in Makefile.common
PROMU_VERSION="0.20.0"             # PROMU_VERSION in Makefile.common

GOOS="$(go env GOOS)"
GOARCH="$(go env GOARCH)"

echo "==> [1/5] Installing golangci-lint ${GOLANGCI_LINT_VERSION}"
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
    | sudo sh -s -- -b /usr/local/bin "${GOLANGCI_LINT_VERSION}"

echo "==> [2/5] Installing promu ${PROMU_VERSION}"
PROMU_TMP="$(mktemp -d)"
curl -sSfL \
    "https://github.com/prometheus/promu/releases/download/v${PROMU_VERSION}/promu-${PROMU_VERSION}.${GOOS}-${GOARCH}.tar.gz" \
    | tar -xz -C "${PROMU_TMP}"
sudo mv "${PROMU_TMP}/promu-${PROMU_VERSION}.${GOOS}-${GOARCH}/promu" /usr/local/bin/promu
rm -rf "${PROMU_TMP}"

echo "==> [3/5] Installing govulncheck (used in govulncheck.yml CI workflow)"
go install golang.org/x/vuln/cmd/govulncheck@latest

echo "==> [4/5] Installing yamllint (used in 'make yamllint')"
# yamllint ships in the Debian package repository; avoids Python dependency
# management in the container.
sudo apt-get update -qq
sudo apt-get install -y -qq --no-install-recommends yamllint

echo "==> [5/5] Pre-downloading Go module dependencies"
go mod download

echo "==> Done. Run 'make build test' to verify the setup."
