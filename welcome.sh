#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

print_version() {
  AVAIL=$(glast $2/$3 | sed -e 's/^.*v//')
  ALIAS=${5:-$3}
  [ "${AVAIL}" == "$4" ] && printf "%-20s %15s ✅\n" "$1" "$4" # ✔️ not working
  [ "$4" == "n/a" ] && printf "%-20s %15s ❌ run 'instool ${ALIAS} ${AVAIL}' to install latest version\n" "$1" "$4" && return 0
  [ "${AVAIL}" != "$4" ] && printf "%-20s %15s 🆕 run 'instool ${ALIAS} ${AVAIL}' to update to latest version\n" "$1" "$4" && return 0
  return 0
}

get_githubcli_version() {
  gh --version 2>/dev/null | head -1 | cut -d' ' -f3 || echo -n "n/a" && return 0
}

get_neon_version() {
  neon --version 2>/dev/null || echo -n "n/a" && return 0
}

get_golangci_lint_version() {
  golangci-lint --version 2>/dev/null | cut -d' ' -f4 || echo -n "n/a" && return 0
}

get_goreleaser_version() {
  goreleaser --version 2>/dev/null | head -1 | cut -d' ' -f3 || echo -n "n/a" && return 0
}

get_svu_version() {
  svu --version 2>&1 | cut -d' ' -f3 || echo -n "n/a" && return 0
}

get_venom_version() {
  venom version 2>/dev/null | cut -d' ' -f3 | sed -e 's/^v//' || echo -n "n/a" && return 0
}

get_gopls_version() {
  gopls version 2>/dev/null | head -1 | cut -d' ' -f2 | sed -e 's/^v//' || echo -n "n/a" && return 0
}

get_delve_version() {
  dlv version 2>/dev/null | head -2 | tail -1 | cut -d' ' -f2 | sed -e 's/^v//' || echo -n "n/a" && return 0
}

get_changie_version() {
  changie -v 2>/dev/null | cut -d' ' -f3 | sed -e 's/^v//' || echo -n "n/a" && return 0
}

figlet -c Go Devcontainer

(
  source /etc/os-release
  echo -n "${NAME} v${VERSION_ID} "
  LATEST_ALPINE_VERSION=$(dlast alpine)
  [[ "${LATEST_ALPINE_VERSION}" == "${VERSION_ID}" ]] && echo "✅" || echo "🆕 new alpine version available v${LATEST_ALPINE_VERSION}"
)

DOCKER_CLI_VERSION=$(docker version -f '{{.Client.Version}}' 2>/dev/null || :)
echo "├── Docker Client v${DOCKER_CLI_VERSION} ✅"

GIT_VERSION=$(git --version | cut -d' ' -f3 || :)
echo "├── Git Client v${GIT_VERSION} ✅"

ZSH_VERSION=$(zsh --version | cut -d' ' -f2 || :)
echo "├── Zsh v${ZSH_VERSION} ✅"

GO_VERSION=$(go version | cut -d' ' -f3 || :)
echo -n "├── Go v${GO_VERSION#go} "
LATEST_GO_VERSION=$(dlast golang)
[[ "${LATEST_GO_VERSION}" == "${GO_VERSION#go}" ]] && echo "✅" || echo "🆕 new golang version available v${LATEST_GO_VERSION}"

echo
echo "Installed tools"
echo "============================================================================="
# VSCode Go Extension requirements (https://github.com/golang/vscode-go/blob/master/docs/tools.md)
print_version "Gopls" "golang" "tools" "$(get_gopls_version)" "gopls"
print_version "Delve" "go-delve" "delve" "$(get_delve_version)"
# Linters
print_version "GolangCI Lint" "golangci" "golangci-lint" "$(get_golangci_lint_version)"
# Test helpers
print_version "Venom" "ovh" "venom" "$(get_venom_version)"
# Documentation helpers
print_version "Changie" "miniscruff" "changie" "$(get_changie_version)"
# Build helpers
print_version "Github CLI" "cli" "cli" "$(get_githubcli_version)"
print_version "Neon" "c4s4" "neon" "$(get_neon_version)"
print_version "GoReleaser" "goreleaser" "goreleaser" "$(get_goreleaser_version)"
print_version "SVU" "caarlos0" "svu" "$(get_svu_version)"
echo "============================================================================="
echo
