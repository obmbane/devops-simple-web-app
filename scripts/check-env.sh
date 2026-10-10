#!/usr/bin/env bash
#
# check-env.sh - check that this machine is ready to deploy the project.
#
# Checks:
#   1. Required tools are installed
#   2. Docker is running
#   3. The Kubernetes API is reachable
#   4. Every cluster node is Ready
#
# Every check runs, and each failure is reported.
# Exits 0 if all checks pass, 1 if any fail.
#
# Usage: ./scripts/check-env.sh [--context <kube-context>]

set -uo pipefail

REQUIRED_TOOLS=(docker kind kubectl terraform)
TIMEOUT=5s

# ---- Arguments ----
KUBE_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c | --context)
      KUBE_ARGS=(--context "${2:?--context needs a value}")
      shift 2
      ;;
    -h | --help)
      sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown option: $1 (try --help)" >&2
      exit 2
      ;;
  esac
done

# ---- Output helpers ----
if [[ -t 1 ]]; then
  GREEN=$'\e[32m' RED=$'\e[31m' YELLOW=$'\e[33m' BOLD=$'\e[1m' RESET=$'\e[0m'
else
  GREEN="" RED="" YELLOW="" BOLD="" RESET=""
fi

FAILURES=()

pass() { echo "  ${GREEN}✔${RESET} $1"; }
fail() {
  echo "  ${RED}✘${RESET} $1"
  FAILURES+=("$1")
}
section() { echo; echo "${BOLD}$1${RESET}"; }

# kubectl with the chosen context and a timeout, so a dead cluster can't hang the script
kube() { kubectl "${KUBE_ARGS[@]}" --request-timeout="$TIMEOUT" "$@"; }

# ---- 1. Required tools ----
section "1. Required tools"
for tool in "${REQUIRED_TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    pass "$tool installed ($(command -v "$tool"))"
  else
    fail "$tool is not installed"
  fi
done

# ---- 2. Docker daemon ----
section "2. Docker"
if ! command -v docker >/dev/null 2>&1; then
  fail "Docker not checked: docker is not installed"
elif version=$(docker info --format '{{.ServerVersion}}' 2>/dev/null); then
  pass "Docker is running (server $version)"
else
  fail "Docker is not running (start Docker Desktop or the docker service)"
fi

# ---- 3. Kubernetes API ----
section "3. Kubernetes API"
api_ok=false
if ! command -v kubectl >/dev/null 2>&1; then
  fail "Kubernetes API not checked: kubectl is not installed"
elif ! context=$(kubectl "${KUBE_ARGS[@]}" config current-context 2>/dev/null) || [[ -z "$context" ]]; then
  fail "No kubectl context is set (create a cluster or pass --context)"
else
  # With --context, current-context still prints the default, so show the one in use
  [[ ${#KUBE_ARGS[@]} -gt 0 ]] && context="${KUBE_ARGS[1]}"
  if kube get --raw='/readyz' >/dev/null 2>&1; then
    pass "API server is reachable (context: $context)"
    api_ok=true
  else
    fail "API server is not reachable (context: $context)"
  fi
fi

# ---- 4. Node readiness ----
section "4. Cluster nodes"
if [[ "$api_ok" != true ]]; then
  fail "Nodes not checked: the API server is not reachable"
else
  # One line per node: "<name> <Ready condition status>"
  nodes=$(kube get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' 2>/dev/null)
  if [[ -z "$nodes" ]]; then
    fail "No nodes found in the cluster"
  else
    while read -r name ready; do
      if [[ "$ready" == "True" ]]; then
        pass "$name is Ready"
      else
        fail "$name is NotReady (Ready=${ready:-Unknown})"
      fi
    done <<<"$nodes"
  fi
fi

# ---- Summary ----
echo
if [[ ${#FAILURES[@]} -eq 0 ]]; then
  echo "${GREEN}${BOLD}Environment is ready.${RESET}"
  exit 0
fi

echo "${RED}${BOLD}Environment is NOT ready: ${#FAILURES[@]} check(s) failed:${RESET}"
for failure in "${FAILURES[@]}"; do
  echo "  ${YELLOW}-${RESET} $failure"
done
exit 1
