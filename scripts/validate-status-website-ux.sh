#!/usr/bin/env bash
# Validates Devora status-website UX: Digdir copy/legend, logo, Live cards (no article.graph
# filter), pinned monitor slugs, light/dark, no GitHub navbar.
# Run from repo root. TDD gate for status-website UX slices.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${ROOT}/.upptimerc.yml"
DESIGN="${ROOT}/DESIGN.md"
THEME_CSS="${ROOT}/assets/devora-status-theme.css"
LOGO_HEADER="${ROOT}/assets/logo-header.png"

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

# Digdir UX / logo / graph / light-dark documentation (slice status-digdir-ux-logo-graph-theme)
grep -qiE 'logo-header|logoUrl' "$DESIGN" || fail "DESIGN.md must document logo-header / logoUrl"
grep -qiE 'graph-filter|article\.graph|LiveStatus|Graphs CI|PNG|filter removal|no filter' "$DESIGN" || \
  fail "DESIGN.md must document LiveStatus / Graphs CI PNG policy (incl. no article.graph filter)"
grep -qiE 'prefers-color-scheme|light.?dark|data-theme' "$DESIGN" || \
  fail "DESIGN.md must document light/dark theme architecture"
grep -qiE 'Normal drift|Digdir|legend' "$DESIGN" || \
  fail "DESIGN.md must document Digdir-inspired status legend mapping"

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

# Digdir-style operational copy (AC1)
if ! grep -qE 'allSitesOperational:[[:space:]]*Alle våre systemer fungerer normalt' "$CONFIG"; then
  fail "allSitesOperational must be Digdir-style NB: Alle våre systemer fungerer normalt"
fi
if ! grep -qE 'allSystemsOperational:[[:space:]]*Alle våre systemer fungerer normalt' "$CONFIG"; then
  fail "i18n.allSystemsOperational must match Digdir-style NB: Alle våre systemer fungerer normalt"
fi
# notAllSitesOperational: NB, no English leftovers
if ! grep -qiE 'notAllSitesOperational:[[:space:]]*.*[æøåÆØÅ]' "$CONFIG"; then
  # allow NB without æøå if clearly Norwegian wording
  if ! grep -qE 'notAllSitesOperational:[[:space:]]*(En eller flere|Ikke alle|Noen tjenester|Systemene våre)' "$CONFIG"; then
    fail "notAllSitesOperational must be Norwegian Bokmål (no English leftovers)"
  fi
fi
if grep -qiE 'notAllSitesOperational:[[:space:]]*.*\b(not all|unavailable|systems? are)\b' "$CONFIG"; then
  fail "notAllSitesOperational must not contain English leftovers"
fi

# Status legend via customBodyHtml (AC2)
if ! grep -qE 'customBodyHtml:' "$CONFIG"; then
  fail "status-website.customBodyHtml required for Digdir-inspired status legend"
fi
for label in "Normal drift" "Redusert funksjonalitet" "Delvis utilgjengelig" "Utilgjengelig" "Vedlikehold"; do
  if ! grep -qF "$label" "$CONFIG"; then
    fail "customBodyHtml legend missing Digdir-inspired label: ${label}"
  fi
done
if ! grep -qE 'status-legend|devora-status-legend' "$CONFIG"; then
  fail "customBodyHtml must include a status-legend / devora-status-legend class hook"
fi
if ! grep -qE '\.status-legend|\.devora-status-legend' "$THEME_CSS"; then
  fail "theme CSS must style .status-legend or .devora-status-legend"
fi

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

# --- AC5: Chart.js graph colors (Graph.svelte reads root config.graphBorderColor / graphBackgroundColor) ---
# Defaults in @upptime/status-page are teal #1abc9c / #89e0cf — must be overridden with Devora tokens.
if ! grep -qE '^graphBorderColor:[[:space:]]*"?#3432A6"?' "$CONFIG"; then
  fail "root graphBorderColor must be Devora primary #3432A6 (Chart.js borderColor; not CSS --up-*)"
fi
if ! grep -qE '^graphBackgroundColor:[[:space:]]*"?(#968AB6|#FFFADE|#C4BFE0)"?' "$CONFIG"; then
  fail "root graphBackgroundColor must be a Devora brand fill (#968AB6 / #FFFADE / #C4BFE0)"
fi
# Reject leftover Upptime teal if explicitly set
if grep -qiE 'graphBorderColor:.*#1abc9c|graphBackgroundColor:.*#89e0cf' "$CONFIG"; then
  fail "graph colors must not use Upptime teal defaults (#1abc9c / #89e0cf)"
fi

# --- Slice status-livestatus-color-graph-slug-fix ---
# AC1: NEVER apply filter/opacity on article.graph — hue-rotate shifts entire Live cards
# (background + text) to cream/reddish. Brand sparklines via root graphBorderColor /
# graphBackgroundColor only; keep canvas { filter: none }.
if python3 - "$THEME_CSS" <<'PY'
import re, sys
css = open(sys.argv[1], encoding="utf-8").read()
# Reject any article.graph rule that sets filter: (including var(--graph-filter))
if re.search(r"article\.graph\s*\{[^}]*\bfilter\s*:", css, re.S):
    sys.exit(0)  # bad → fail below
sys.exit(1)
PY
then
  fail "theme CSS must NOT apply filter: to article.graph (hue-shifts Live status cards)"
fi
# Mirrored status-website.css must also avoid article.graph filter
if grep -qE '^[[:space:]]+css:' "$CONFIG"; then
  if python3 - "$CONFIG" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
m = re.search(r"(?m)^  css:\s*\|\s*\n((?:(?: {4}|\t).*\n)+)", text)
if not m:
    sys.exit(1)  # no block → skip (other checks cover)
css = m.group(1)
if re.search(r"article\.graph\s*\{[^}]*\bfilter\s*:", css, re.S):
    sys.exit(0)  # bad → fail below
sys.exit(1)
PY
  then
    fail "status-website.css must NOT apply filter: to article.graph"
  fi
fi
# section.live-status article must also stay unfiltered
if python3 - "$THEME_CSS" <<'PY'
import re, sys
css = open(sys.argv[1], encoding="utf-8").read()
if re.search(r"section\.live-status[^{]*\{[^}]*\bfilter\s*:", css, re.S | re.I):
    sys.exit(0)
sys.exit(1)
PY
then
  fail "section.live-status rules must NOT apply filter: (card surfaces stay unfiltered)"
fi
# canvas safety rail remains
if ! grep -qE 'canvas[[:space:]]*\{[^}]*filter:[[:space:]]*none|canvas[^{]*\{[^}]*filter:[[:space:]]*none' "$THEME_CSS" \
  && ! python3 - "$THEME_CSS" <<'PY'
import re, sys
css = open(sys.argv[1], encoding="utf-8").read()
sys.exit(0 if re.search(r"canvas[^{]*\{[^}]*filter\s*:\s*none", css, re.S) else 1)
PY
then
  fail "theme CSS must keep canvas { filter: none } safety rail"
fi

# AC2: pinned historical slugs (display names AgePass / Vipps Logg Inn must not orphan history)
if ! python3 - "$CONFIG" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
# Parse sites: list items with name + optional slug
sites = re.findall(
    r"(?m)^  - name:\s*(.+?)\s*\n((?:(?:    |\t).*\n)*)",
    text,
)
by_name = {}
for name, body in sites:
    name = name.strip().strip("\"'")
    slug_m = re.search(r"(?m)^    slug:\s*(\S+)", body)
    by_name[name] = slug_m.group(1).strip().strip("\"'") if slug_m else None
expected = {
    "AgePass": "age-pass-produksjon",
    "Vipps Logg Inn": "vipps-login-upstream-ikke-age-pass",
}
for name, slug in expected.items():
    if name not in by_name:
        sys.exit(1)
    if by_name[name] != slug:
        sys.exit(1)
sys.exit(0)
PY
then
  fail "sites AgePass / Vipps Logg Inn must pin slug: age-pass-produksjon / vipps-login-upstream-ikke-age-pass"
fi

# --- AC6: Devora favicon via documented status-website.favicon / faviconSvg + assets ---
FAVICON_PNG="${ROOT}/assets/favicon.png"
[[ -f "$FAVICON_PNG" ]] || fail "assets/favicon.png missing (Devora mark for status favicon)"
if ! grep -qE '^[[:space:]]+favicon:[[:space:]]*https://status\.devora\.no/favicon\.png' "$CONFIG"; then
  fail "status-website.favicon must be https://status.devora.no/favicon.png (assets served as-is)"
fi
# SVG optional but preferred when present
if [[ -f "${ROOT}/assets/favicon.svg" ]]; then
  if ! grep -qE '^[[:space:]]+faviconSvg:[[:space:]]*https://status\.devora\.no/favicon\.svg' "$CONFIG"; then
    fail "assets/favicon.svg exists but status-website.faviconSvg is not wired to status.devora.no/favicon.svg"
  fi
fi
grep -qiE 'favicon|graphBorderColor' "$DESIGN" || \
  fail "DESIGN.md must document favicon and graphBorderColor / graphBackgroundColor"

# Light-background header logo (AC3)
[[ -f "$LOGO_HEADER" ]] || fail "assets/logo-header.png missing (cropped light-bg header mark)"
# Reject tiny / empty / huge empty-canvas proxies: must be a real PNG with content
file "$LOGO_HEADER" | grep -qi 'PNG' || fail "assets/logo-header.png must be a PNG"
# Prefer cropped (not identical oversized empty square) — require dimensions via sips/file and size > 200 bytes
logo_bytes="$(wc -c < "$LOGO_HEADER" | tr -d ' ')"
[[ "$logo_bytes" -gt 200 ]] || fail "assets/logo-header.png looks empty (${logo_bytes} bytes)"
if ! grep -qE 'logoUrl:[[:space:]]*https://status\.devora\.no/logo-header\.png' "$CONFIG"; then
  fail "status-website.logoUrl must be https://status.devora.no/logo-header.png"
fi

# Light + dark themes (AC5)
if ! grep -qE 'prefers-color-scheme:[[:space:]]*dark|\[data-theme=["'\'']dark["'\'']\]' "$THEME_CSS"; then
  fail "theme CSS must define dark palette via @media (prefers-color-scheme: dark) and/or [data-theme=dark]"
fi
if ! grep -qiE 'color-scheme' "$CONFIG"; then
  fail "status-website.metaTags must include color-scheme (light dark)"
fi
if ! grep -qiE 'color-scheme:[[:space:]]*.*light.*dark|content:[[:space:]]*["'\'']?light dark' "$CONFIG"; then
  # Accept metaTags list form: name: color-scheme / content: light dark
  if ! python3 - "$CONFIG" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
# Look for color-scheme near light dark
if re.search(r"color-scheme[\s\S]{0,80}light\s+dark", text, re.I):
    sys.exit(0)
if re.search(r"content:\s*[\"']?light dark", text, re.I) and re.search(r"color-scheme", text, re.I):
    sys.exit(0)
sys.exit(1)
PY
  then
    fail "metaTags color-scheme must be light dark"
  fi
fi

# --- Slice status-visual-legend-logo-livestatus-bg ---
# Extract status-website.js block for legend relocate + theme logo swap hooks.
js_block="$(
  awk '
    /^status-website:/ { in_sw=1; next }
    in_sw && /^[^[:space:]#]/ { in_sw=0; in_js=0 }
    in_sw && /^  [a-zA-Z0-9_-]+:/ {
      if ($0 ~ /^  js:/) { in_js=1; next }
      if (in_js) { in_js=0 }
    }
    in_js { print }
  ' "$CONFIG"
)"
if [[ -z "$js_block" ]]; then
  fail "status-website.js block required for legend relocate + theme logo swap"
fi

# AC1: legend reposition hook — move aside after operational banner article
if ! echo "$js_block" | grep -qE 'devora-status-legend|status-legend'; then
  fail "status-website.js must reference legend selector (devora-status-legend / status-legend)"
fi
if ! echo "$js_block" | grep -qE 'article\.(up|down|degraded)|querySelector[^;]*article'; then
  fail "status-website.js must locate status summary article (article.up / .down / .degraded)"
fi
if ! echo "$js_block" | grep -qE 'insertAdjacentElement|insertBefore|after\(|nextSibling|parentNode\.insertBefore'; then
  fail "status-website.js must relocate legend DOM node after status summary article"
fi
# Sapper hydrates article.up after DOMContentLoaded — must retry (MutationObserver childList and/or interval)
if ! echo "$js_block" | grep -qE 'MutationObserver'; then
  fail "status-website.js must use MutationObserver to relocate legend after Sapper hydrates article.up"
fi
if ! echo "$js_block" | grep -qE 'childList|subtree'; then
  fail "status-website.js legend MutationObserver must watch childList/subtree (banner appears late)"
fi
if ! echo "$js_block" | grep -qE 'live-status|closest\(|:scope > article'; then
  fail "status-website.js must not treat section.live-status article.up as the operational banner"
fi

# AC2: theme-dependent header logo — dark → favicon.png; light → logo-header.png
if ! echo "$js_block" | grep -qE 'favicon\.png'; then
  fail "status-website.js must swap dark-theme header logo to favicon.png"
fi
if ! echo "$js_block" | grep -qE 'logo-header\.png'; then
  fail "status-website.js must restore light-theme header logo to logo-header.png"
fi
if ! echo "$js_block" | grep -qE 'prefers-color-scheme|matchMedia'; then
  fail "status-website.js must listen to prefers-color-scheme / matchMedia for logo swap"
fi
if ! echo "$js_block" | grep -qE 'data-theme|MutationObserver|getAttribute\([\"'\'']data-theme'; then
  fail "status-website.js must react to data-theme for logo swap"
fi
# Default logoUrl stays light asset for first paint
if ! grep -qE 'logoUrl:[[:space:]]*https://status\.devora\.no/logo-header\.png' "$CONFIG"; then
  fail "logoUrl must remain logo-header.png for SSR/first paint"
fi

# AC3: Live status card surfaces — card token, not soft-error fills
# Prefer explicit section.live-status article rule using --card-background-color
if ! grep -qE 'section\.live-status|live-status' "$THEME_CSS"; then
  fail "theme CSS must target section.live-status (Live status card surfaces)"
fi
if ! python3 - "$THEME_CSS" <<'PY'
import re, sys
css = open(sys.argv[1], encoding="utf-8").read()
# Must have a rule that styles live-status articles with card background
if not re.search(
    r"section\.live-status[^{]*\{[^}]*background(?:-color)?\s*:\s*var\(--card-background-color\)",
    css,
    re.S | re.I,
):
    sys.exit(1)
sys.exit(0)
PY
then
  fail "theme CSS must set section.live-status article background to var(--card-background-color)"
fi
# Soft-error fills must not paint Live status boxes:
# --down-background-color on Live status path must be card surface, OR live-status
# override exists (checked above). Also reject assigning FEE2E2/3F1D1D inside live-status rules.
if python3 - "$THEME_CSS" <<'PY'
import re, sys
css = open(sys.argv[1], encoding="utf-8").read()
for m in re.finditer(r"section\.live-status[^{]*\{([^}]*)\}", css, re.S | re.I):
    block = m.group(1)
    if re.search(r"#FEE2E2|#fee2e2|#3F1D1D|#3f1d1d", block):
        sys.exit(0)  # found bad fill in live-status rule → fail below
sys.exit(1)
PY
then
  fail "section.live-status rules must not use soft-error fills #FEE2E2 / #3F1D1D"
fi
# Remap --down-background-color away from soft-error for card-like surfaces:
# either equals #FFFFFF/#1B2438, or live-status override (already required) + DESIGN note.
# Still require card token #1B2438 (not #1b2432) in dark palette.
if ! grep -qiE -- '--card-background-color:[[:space:]]*#1B2438' "$THEME_CSS"; then
  fail "dark --card-background-color must be DESIGN token #1B2438 (not #1b2432)"
fi
# Mirrored status-website.css should not leave Live status on soft-error either
if grep -qE '^[[:space:]]+css:' "$CONFIG"; then
  if ! grep -qE 'section\.live-status|--card-background-color:[[:space:]]*#1B2438' "$CONFIG"; then
    fail "status-website.css mirror must include live-status card surface and/or #1B2438 card token"
  fi
  # Prefer mirrored live-status rule when css block is present
  if ! python3 - "$CONFIG" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
# Extract css: | block (YAML literal)
m = re.search(r"(?m)^  css:\s*\|\s*\n((?:(?: {4}|\t).*\n)+)", text)
if not m:
    sys.exit(1)
css = m.group(1)
if re.search(
    r"section\.live-status[^{]*\{[^}]*background(?:-color)?\s*:\s*var\(--card-background-color\)",
    css,
    re.S | re.I,
):
    sys.exit(0)
# Fallback: down-background remapped to card surfaces in both light and dark
light_ok = bool(re.search(r"--down-background-color:\s*#FFFFFF", css, re.I))
dark_ok = bool(re.search(r"--down-background-color:\s*#1B2438", css, re.I))
sys.exit(0 if (light_ok and dark_ok) else 1)
PY
  then
    fail "status-website.css must mirror Live status card surfaces (section.live-status or remapped --down-background-color)"
  fi
fi

# AC5: DESIGN.md documents legend placement, theme logo, Live status surfaces + #1B2438 vs #1b2432
grep -qiE 'legend.*(below|under|after)|article\.up|relocat' "$DESIGN" || \
  fail "DESIGN.md must document legend placement below article.up"
grep -qiE 'favicon\.png|theme.?dependent|dark.*logo|logo.*dark' "$DESIGN" || \
  fail "DESIGN.md must document theme-dependent header logo (dark → favicon.png)"
grep -qiE 'live.?status|#1B2438|#1b2432|card-background-color' "$DESIGN" || \
  fail "DESIGN.md must document Live status surfaces and #1B2438 token decision"

pass
