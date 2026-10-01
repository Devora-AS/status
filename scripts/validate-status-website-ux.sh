#!/usr/bin/env bash
# Validates Devora status-website UX: no GitHub navbar, DESIGN.md, NB i18n, theme asset.
# Run from repo root. TDD gate for status-nb-brand-nav slice.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${ROOT}/.upptimerc.yml"
DESIGN="${ROOT}/DESIGN.md"
THEME_CSS="${ROOT}/assets/devora-status-theme.css"

fail() {
  echo "validate-status-website-ux: FAIL — $*" >&2
  exit 1
}

pass() {
  echo "validate-status-website-ux: PASS"
  exit 0
}

[[ -f "$CONFIG" ]] || fail ".upptimerc.yml not found"

# --- AC1: no GitHub navbar item linking to Devora-AS/status (or any github.com nav href) ---
# Extract navbar block (indented under status-website) and reject github.com hrefs there.
# Navbar ends at next status-website sibling key (2-space indent) or end of status-website.
navbar_block="$(
  awk '
    /^status-website:/ { in_sw=1; next }
    in_sw && /^[^[:space:]#]/ { in_sw=0; in_nav=0 }
    in_sw && /^  [a-zA-Z0-9_-]+:/ {
      if ($0 ~ /^  navbar:/) { in_nav=1; next }
      if (in_nav) { in_nav=0 }
    }
    in_nav { print }
  ' "$CONFIG"
)"
if [[ -z "$navbar_block" ]]; then
  fail "could not parse status-website.navbar block"
fi
if echo "$navbar_block" | grep -qiE 'href:.*github\.com'; then
  fail "status-website.navbar must not include GitHub href (found github.com in navbar)"
fi
if echo "$navbar_block" | grep -qiE 'title:[[:space:]]*GitHub[[:space:]]*$'; then
  fail "status-website.navbar must not include a GitHub title item"
fi

# --- Sites remain AgePass + Vipps only ---
grep -q 'agepass.devora.no/health' "$CONFIG" || fail "missing AgePass monitor URL"
grep -q 'status.vippsmobilepay.com/api/v2/summary.json' "$CONFIG" || fail "missing Vipps monitor URL"
if grep -qiE 'utilitysign|DRILL' "$CONFIG"; then
  fail "sites must remain AgePass + Vipps only (no UtilitySign/DRILL)"
fi

# --- AC2: root DESIGN.md with design.md front matter + token mapping ---
[[ -f "$DESIGN" ]] || fail "root DESIGN.md missing"
grep -qE '^---[[:space:]]*$' "$DESIGN" || fail "DESIGN.md missing YAML front matter (---)"
grep -qiE 'primary|3432A6' "$DESIGN" || fail "DESIGN.md must document primary token #3432A6"
grep -qiE 'body-background-color|nav-current-border-bottom-color' "$DESIGN" || \
  fail "DESIGN.md must map tokens to Upptime CSS variables (e.g. --body-background-color)"

# --- AC3: top-level i18n NB with placeholders + æ/ø/å ---
grep -qE '^i18n:' "$CONFIG" || fail "missing top-level i18n: block"
grep -qE 'locale:[[:space:]]*nb-NO' "$CONFIG" || fail "i18n.locale must be nb-NO"

required_i18n_keys=(
  liveStatus
  allSystemsOperational
  overallUptime
  averageResponseTime
  up
  down
  degraded
  footer
  duration24H
  duration7D
  duration30D
  duration1Y
  durationAll
  activeIncidents
  pastIncidents
  loading
)
for key in "${required_i18n_keys[@]}"; do
  grep -qE "^[[:space:]]*${key}:" "$CONFIG" || fail "i18n missing required key: ${key}"
done

# Placeholders preserved in known template strings
grep -qE 'overallUptime:.*\$UPTIME' "$CONFIG" || fail "i18n.overallUptime must preserve \$UPTIME"
grep -qE 'averageResponseTime:.*\$TIME' "$CONFIG" || fail "i18n.averageResponseTime must preserve \$TIME"
grep -qE 'footer:.*\$REPO' "$CONFIG" || fail "i18n.footer must preserve \$REPO"
grep -qE 'incidentReport:.*\$NUMBER' "$CONFIG" || fail "i18n.incidentReport must preserve \$NUMBER"

# At least one Norwegian letter in i18n / operational copy
if ! grep -E '^(i18n:|[[:space:]]+[a-zA-Z]+:|[[:space:]]+allSitesOperational:|[[:space:]]+notAllSitesOperational:|[[:space:]]+introTitle:|[[:space:]]+introMessage:)' "$CONFIG" \
  | grep -q '[æøåÆØÅ]'; then
  # broader scan of config for NB letters in user-facing keys area
  if ! python3 - "$CONFIG" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
# Prefer checking after i18n: or operational message keys
chunks = []
m = re.search(r"(?m)^i18n:\n([\s\S]*?)(?=\n[a-zA-Z0-9_-]+:|\Z)", text)
if m:
    chunks.append(m.group(1))
for key in ("allSitesOperational", "notAllSitesOperational", "introTitle", "introMessage"):
    m2 = re.search(rf"(?m)^[ \t]*{key}:[ \t]*(.*)$", text)
    if m2:
        chunks.append(m2.group(0))
blob = "\n".join(chunks)
if not re.search(r"[æøåÆØÅ]", blob):
    sys.exit(1)
sys.exit(0)
PY
  then
    fail "Norwegian Bokmål copy must include æ/ø/å in i18n or operational messages"
  fi
fi

grep -qE 'allSitesOperational:' "$CONFIG" || fail "missing status-website.allSitesOperational"
grep -qE 'notAllSitesOperational:' "$CONFIG" || fail "missing status-website.notAllSitesOperational"

# --- AC4: theme asset + themeUrl and/or css + metaTags theme-color ---
[[ -f "$THEME_CSS" ]] || fail "assets/devora-status-theme.css missing"
grep -qE -- '--body-background-color:' "$THEME_CSS" || fail "theme CSS missing --body-background-color"
grep -qE -- '--nav-current-border-bottom-color:' "$THEME_CSS" || fail "theme CSS missing --nav-current-border-bottom-color"
grep -qiE '#3432A6|#F8F7FF|#242A56' "$THEME_CSS" || \
  fail "theme CSS must use DESIGN tokens (primary/navy/page background)"

if ! grep -qE 'themeUrl:.*devora-status-theme\.css' "$CONFIG"; then
  fail "status-website.themeUrl must point at published assets/devora-status-theme.css URL"
fi
# themeUrl should be the status.devora.no asset URL (assets served as-is at site root)
if ! grep -qE 'themeUrl:[[:space:]]*https://status\.devora\.no/devora-status-theme\.css' "$CONFIG"; then
  fail "themeUrl must be https://status.devora.no/devora-status-theme.css (Upptime assets served as-is)"
fi

if ! grep -qE 'theme-color' "$CONFIG"; then
  fail "status-website.metaTags must include theme-color"
fi
if ! grep -qiE '#3432A6|#242A56' "$CONFIG"; then
  fail "theme-color / branding in config should reference primary or navy token"
fi

# Prefer documented css fallback with same vars (optional but recommended before first publish)
if grep -qE '^[[:space:]]+css:' "$CONFIG"; then
  grep -qE -- '--body-background-color' "$CONFIG" || fail "status-website.css present but missing --body-background-color"
fi

pass
