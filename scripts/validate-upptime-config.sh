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
# Docs contract (S5): Pages branch model + visibility not private-only
grep -q 'gh-pages' "$RUNBOOK" || fail "runbook must document Pages branch gh-pages"
grep -qiE 'offentlig|public' "$RUNBOOK" || fail "runbook must note public/offentlig visibility (not private-only)"
grep -qiE 'privat|private' "$RUNBOOK" || fail "runbook must still document private as optional/policy path"

README="${ROOT}/README.md"
[[ -f "$README" ]] || fail "README.md not found"
grep -q 'gh-pages' "$README" || fail "README must document Pages branch gh-pages"
grep -qiE 'offentlig|public' "$README" || fail "README must note public/offentlig repo"

pass
