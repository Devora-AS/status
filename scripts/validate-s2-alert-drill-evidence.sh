#!/usr/bin/env bash
# Validates S2 alert-drill plan + evidence contract — run from repo root.
# Does NOT call GitHub/Slack; checks local files and production monitor hygiene.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAN="${ROOT}/docs/operations/s2-alert-drill-plan.md"
EVIDENCE="${ROOT}/docs/operations/s2-alert-drill-evidence.md"
CONFIG="${ROOT}/.upptimerc.yml"

fail() {
  echo "validate-s2-alert-drill-evidence: FAIL — $*" >&2
  exit 1
}

pass() {
  echo "validate-s2-alert-drill-evidence: PASS"
  exit 0
}

[[ -f "$PLAN" ]] || fail "missing $PLAN"
[[ -f "$EVIDENCE" ]] || fail "missing $EVIDENCE"
[[ -f "$CONFIG" ]] || fail "missing $CONFIG"

# Plan: rollback + success criteria + SIMULERT naming
grep -qiE 'rollback' "$PLAN" || fail "plan missing rollback"
grep -qiE 'success criteria|suksesskriter' "$PLAN" || fail "plan missing success criteria"
grep -qE 'DRILL|SIMULERT' "$PLAN" || fail "plan missing DRILL|SIMULERT naming"

# Evidence: explicit Issue and Slack channel verdicts (independent)
grep -qiE 'Issue.*(PROVEN|NOT PROVEN|BLOCKED)' "$EVIDENCE" \
  || fail "missing explicit Issue status PROVEN / NOT PROVEN / BLOCKED"
grep -qiE 'Slack.*(PROVEN|NOT PROVEN|BLOCKED)' "$EVIDENCE" \
  || fail "missing explicit Slack status PROVEN / NOT PROVEN / BLOCKED"

# Drill monitor naming marker
grep -qE 'DRILL|SIMULERT' "$EVIDENCE" || fail "evidence missing DRILL|SIMULERT marker"

# When remote Issue not live-proven, approval_needed must be documented
if grep -qiE 'Issue.*(NOT PROVEN|BLOCKED)' "$EVIDENCE"; then
  grep -qiE 'approval_needed' "$EVIDENCE" \
    || fail "Issue NOT PROVEN/BLOCKED requires approval_needed stop reason"
fi

# UTC timestamp somewhere in evidence
grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' "$EVIDENCE" \
  || fail "missing UTC ISO-8601 timestamp (...Z)"

# Production .upptimerc.yml must not retain a permanent drill/failing test monitor
if grep -qE 'name:.*(DRILL|SIMULERT)' "$CONFIG"; then
  fail "production .upptimerc.yml still contains DRILL/SIMULERT monitor — rollback required"
fi

# AgePass + Vipps URLs must remain the production targets
grep -q 'https://agepass.devora.no/health' "$CONFIG" \
  || fail "AgePass health URL missing or changed in .upptimerc.yml"
grep -q 'https://status.vippsmobilepay.com/api/v2/summary.json' "$CONFIG" \
  || fail "Vipps summary URL missing or changed in .upptimerc.yml"

# Secret hygiene: no Slack webhook path literals in evidence/plan
for f in "$PLAN" "$EVIDENCE"; do
  if grep -qE 'hooks\.slack\.com/services/[A-Za-z0-9]' "$f"; then
    fail "possible Slack webhook literal in $(basename "$f")"
  fi
done

pass
