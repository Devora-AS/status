#!/usr/bin/env bash
# Validates S4 UtilitySign monitor decision evidence + deferred plan contract.
# Does NOT call GitHub or mutate .upptimerc.yml; file-contract only.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE="${ROOT}/docs/operations/s4-utilitysign-monitor-evidence.md"
PLAN="${ROOT}/docs/operations/s4-utilitysign-monitor-plan.md"
MONITORS="${ROOT}/docs/monitors.md"
CONFIG="${ROOT}/.upptimerc.yml"

fail() {
  echo "validate-s4-utilitysign-evidence: FAIL — $*" >&2
  exit 1
}

pass() {
  echo "validate-s4-utilitysign-evidence: PASS"
  exit 0
}

[[ -f "$EVIDENCE" ]] || fail "missing $EVIDENCE"
[[ -f "$PLAN" ]] || fail "missing $PLAN"
[[ -f "$MONITORS" ]] || fail "missing $MONITORS"
[[ -f "$CONFIG" ]] || fail "missing $CONFIG"

# Evidence: search method + explicit decision
grep -qiE 'search method|søkemetode|gh (api|search)' "$EVIDENCE" \
  || fail "evidence missing search method documentation"
grep -qE '(PROVEN activate|NOT PROVEN)' "$EVIDENCE" \
  || fail "evidence missing decision PROVEN activate or NOT PROVEN"

# UTC timestamp
grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' "$EVIDENCE" \
  || fail "evidence missing UTC ISO-8601 timestamp (...Z)"

# Candidate path from UtilitySign source (docs/code) must be named even if deferred
grep -qE 'api\.utilitysign\.devora\.no' "$EVIDENCE" \
  || fail "evidence missing documented candidate host api.utilitysign.devora.no"

# Curl / DNS reachability evidence required for either branch
grep -qiE 'curl|DNS|NXDOMAIN|http_code|Could not resolve' "$EVIDENCE" \
  || fail "evidence missing curl/DNS reachability observation"

# When NOT PROVEN: deferred plan + monitors + no speculative active URL in config
if grep -qE 'NOT PROVEN' "$EVIDENCE"; then
  grep -qiE 'missing|mangler|required|påkrev' "$PLAN" \
    || fail "NOT PROVEN requires plan to list missing fields"
  grep -qE 'api\.utilitysign\.devora\.no/api/health' "$PLAN" \
    || fail "deferred plan missing candidate URL https://api.utilitysign.devora.no/api/health"
  grep -qiE 'NOT PROVEN|deferred|utsatt|ikke aktiv' "$MONITORS" \
    || fail "docs/monitors.md must reflect NOT PROVEN / deferred UtilitySign"
  # Active (uncommented) UtilitySign site url must not appear under sites
  if awk '
    /^sites:/ { in_sites=1; next }
    in_sites && /^[a-zA-Z0-9_-]+:/ { in_sites=0 }
    in_sites && /^[[:space:]]*-[[:space:]]*name:[[:space:]]*.*[Uu]tility[Ss]ign/ { found=1 }
    END { exit found ? 0 : 1 }
  ' "$CONFIG"; then
    fail ".upptimerc.yml must not contain active UtilitySign site when NOT PROVEN"
  fi
  if grep -qE '^[[:space:]]+url:[[:space:]]*https://api\.utilitysign\.devora\.no' "$CONFIG"; then
    fail ".upptimerc.yml must not contain active UtilitySign url when NOT PROVEN"
  fi
fi

# When PROVEN activate: config + monitors must include verified URL
if grep -qE 'PROVEN activate' "$EVIDENCE"; then
  grep -qE 'api\.utilitysign\.devora\.no' "$CONFIG" \
    || fail "PROVEN activate requires UtilitySign URL in .upptimerc.yml"
  grep -qE 'api\.utilitysign\.devora\.no' "$MONITORS" \
    || fail "PROVEN activate requires UtilitySign URL in docs/monitors.md"
fi

# Secret hygiene
for f in "$EVIDENCE" "$PLAN" "$MONITORS"; do
  if grep -qE 'hooks\.slack\.com/services/[A-Za-z0-9]' "$f"; then
    fail "possible Slack webhook literal in $(basename "$f")"
  fi
  if grep -qiE '(password|client_secret|api[_-]?key)\s*[:=]\s*\S+' "$f"; then
    fail "possible secret assignment in $(basename "$f")"
  fi
done

pass
