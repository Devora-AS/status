#!/usr/bin/env bash
# Validates S6 final-verification evidence contract — run from repo root.
# File-contract only; does not mutate remotes or claim live PROVEN without evidence text.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE="${ROOT}/docs/operations/s6-final-verification.md"
CONFIG="${ROOT}/.upptimerc.yml"

fail() {
  echo "validate-s6-final-verification: FAIL — $*" >&2
  exit 1
}

pass() {
  echo "validate-s6-final-verification: PASS"
  exit 0
}

[[ -f "$EVIDENCE" ]] || fail "missing $EVIDENCE"
[[ -f "$CONFIG" ]] || fail "missing $CONFIG"

# Required sections
grep -qiE '^## (Recommendation matrix|Anbefalingsmatrise)' "$EVIDENCE" \
  || fail "missing Recommendation matrix / Anbefalingsmatrise section"
grep -qiE '^## (Residuals|Residual)' "$EVIDENCE" \
  || fail "missing Residuals section"
grep -qiE '^## (Local gates|Lokale gates|Validator)' "$EVIDENCE" \
  || fail "missing Local gates / Validator section"

# UTC timestamp
grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' "$EVIDENCE" \
  || fail "missing UTC ISO-8601 timestamp (...Z)"

# Six original recommendations must be scored (R1–R6 table rows)
for n in 1 2 3 4 5 6; do
  grep -qE "^\\| *R${n} *\\|" "$EVIDENCE" \
    || fail "missing recommendation row/marker for #${n}"
done

# Honesty labels present for live residuals that must not be falsely PROVEN
grep -qiE 'schedule.*(NOT PROVEN|BLOCKED)' "$EVIDENCE" \
  || fail "missing schedule NOT PROVEN/BLOCKED honesty"
grep -qiE '(Issue|Slack).*(NOT PROVEN|BLOCKED)' "$EVIDENCE" \
  || fail "missing Issue/Slack NOT PROVEN/BLOCKED honesty"
grep -qiE 'n8n.*(NOT PROVEN|BLOCKED)' "$EVIDENCE" \
  || fail "missing n8n NOT PROVEN/BLOCKED honesty"
grep -qiE 'UtilitySign.*(NOT PROVEN|BLOCKED|deferred|utsatt)' "$EVIDENCE" \
  || fail "missing UtilitySign NOT PROVEN/deferred honesty"
grep -qiE '(36841669013|Setup CI).*(NOT PROVEN|BLOCKED|DEFERRED|409)' "$EVIDENCE" \
  || fail "missing Setup CI cancel residual honesty"

# Guard: schedule marked PROVEN requires documented event=schedule (not dispatch alone)
if grep -qiE 'schedule[^[:space:]]{0,40}\*\*PROVEN\*\*|\*\*PROVEN\*\*[^[:space:]]{0,40}schedule' "$EVIDENCE"; then
  grep -qiE 'event[=: ].*schedule|schedule.*run' "$EVIDENCE" \
    || fail "schedule marked PROVEN without event=schedule evidence"
fi

# Production monitor hygiene mirror (AgePass+Vipps; no DRILL/SIMULERT/UtilitySign active)
if grep -qE 'name:.*(DRILL|SIMULERT)' "$CONFIG"; then
  fail "production .upptimerc.yml still contains DRILL/SIMULERT monitor"
fi
if awk '
  /^sites:/ { in_sites=1; next }
  in_sites && /^[a-zA-Z0-9_-]+:/ { in_sites=0 }
  in_sites && /^[[:space:]]*-[[:space:]]*name:[[:space:]]*.*[Uu]tility[Ss]ign/ { found=1 }
  END { exit found ? 0 : 1 }
' "$CONFIG"; then
  fail ".upptimerc.yml must not contain active UtilitySign site"
fi
grep -q 'https://agepass.devora.no/health' "$CONFIG" \
  || fail "AgePass health URL missing in .upptimerc.yml"
grep -q 'https://status.vippsmobilepay.com/api/v2/summary.json' "$CONFIG" \
  || fail "Vipps summary URL missing in .upptimerc.yml"

# Evidence should note .upptimerc hygiene (AgePass/Vipps / no drill)
grep -qiE '\.upptimerc\.yml' "$EVIDENCE" \
  || fail "evidence missing .upptimerc.yml reference"
grep -qiE 'hygiene|no (active )?(DRILL|SIMULERT)|AgePass.*Vipps|Vipps.*AgePass' "$EVIDENCE" \
  || fail "evidence missing .upptimerc.yml hygiene note"

# Pointers to prior slice evidence
for needle in s1-actions-cron-evidence s2-alert-drill-evidence s4-utilitysign-monitor-evidence; do
  grep -q "$needle" "$EVIDENCE" || fail "evidence missing pointer to $needle"
done
grep -qiE 'ops/n8n|n8n/README' "$EVIDENCE" || fail "evidence missing n8n pointer"

# Session-summary draft bullets for parent
grep -qiE '(session-summary|Session summary|draft.*summary)' "$EVIDENCE" \
  || fail "evidence missing session-summary draft section"

# Secret hygiene
if grep -qE 'hooks\.slack\.com/services/[A-Za-z0-9]' "$EVIDENCE"; then
  fail "possible Slack webhook literal in s6-final-verification.md"
fi
if grep -qiE '(password|client_secret|api[_-]?key)\s*[:=]\s*\S+' "$EVIDENCE"; then
  fail "possible secret assignment in s6-final-verification.md"
fi

pass
