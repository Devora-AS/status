#!/usr/bin/env bash
# Validates S1 Actions/cron evidence file contract — run from repo root.
# Does NOT call GitHub; only checks docs/operations/s1-actions-cron-evidence.md fields.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE="${ROOT}/docs/operations/s1-actions-cron-evidence.md"

fail() {
  echo "validate-s1-cron-evidence: FAIL — $*" >&2
  exit 1
}

pass() {
  echo "validate-s1-cron-evidence: PASS"
  exit 0
}

[[ -f "$EVIDENCE" ]] || fail "missing $EVIDENCE"

# Required sections / fields (filkontrakt)
grep -qE '^## (Observation window|Observasjonsvindu)' "$EVIDENCE" \
  || fail "missing Observation window / Observasjonsvindu section"

grep -qE 'schedule.*(PROVEN|NOT PROVEN|BLOCKED)' "$EVIDENCE" \
  || fail "missing explicit schedule status PROVEN / NOT PROVEN / BLOCKED"

# At least one Uptime CI evidence row with run ID, event, UTC time, conclusion
grep -qiE 'Uptime CI' "$EVIDENCE" || fail "missing Uptime CI reference"

# Run ID (numeric GitHub Actions run id)
grep -qE '\b[0-9]{8,}\b' "$EVIDENCE" || fail "missing run ID (numeric)"

# Event type markers
grep -qE '\b(schedule|workflow_dispatch|push|repository_dispatch)\b' "$EVIDENCE" \
  || fail "missing event type (schedule|workflow_dispatch|push|repository_dispatch)"

# UTC timestamp (ISO-8601 ...Z)
grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' "$EVIDENCE" \
  || fail "missing UTC ISO-8601 timestamp (...Z)"

# Conclusion / status for evidence rows
grep -qiE '\b(conclusion|status)\b' "$EVIDENCE" \
  || fail "missing conclusion/status field label"

# Setup CI cancel documentation
grep -qE '36841669013' "$EVIDENCE" || fail "missing Setup CI run 36841669013"
grep -qiE '(cancel|409|cancelled|not cancelable|ikke kansellerbar)' "$EVIDENCE" \
  || fail "missing cancel outcome documentation"

pass
