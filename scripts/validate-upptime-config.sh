#!/usr/bin/env bash
# Validates Devora Upptime bootstrap (.upptimerc.yml) — run from repo root.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${ROOT}/.upptimerc.yml"

fail() {
  echo "validate-upptime-config: FAIL — $*" >&2
  exit 1
}

pass() {
  echo "validate-upptime-config: PASS"
  exit 0
}

[[ -f "$CONFIG" ]] || fail ".upptimerc.yml not found"

grep -qE '^owner:\s*Devora-AS\s*$' "$CONFIG" || fail "missing or wrong owner (expected Devora-AS)"
grep -qE '^repo:\s*status\s*$' "$CONFIG" || fail "missing or wrong repo (expected status)"

grep -q 'status.devora.no' "$CONFIG" || fail "missing CNAME status.devora.no in status-website"

grep -q 'agepass.devora.no/health' "$CONFIG" || fail "missing AgePass prod health URL"
grep -q 'status.vippsmobilepay.com/api/v2/summary.json' "$CONFIG" || fail "missing Vipps summary JSON URL"

grep -q 'SLACK_WEBHOOK_URL' "$CONFIG" || fail "missing Slack notification reference (SLACK_WEBHOOK_URL)"

RUNBOOK="${ROOT}/docs/runbook-status.md"
[[ -f "$RUNBOOK" ]] || fail "docs/runbook-status.md not found"
grep -q '`workflow`' "$RUNBOOK" || fail "runbook must document GH_PAT workflow scope (Setup CI push)"

pass
