# Current plan — Digdir UX + logo light + graph brand + light/dark

**Depth tier:** standard (execution projection)  
**Preflight / execution_mode:** `builder_plus_verifier`  
**Slice id:** `status-digdir-ux-logo-graph-theme`  
**Repo:** Devora-AS/status (local: `devora-status`)  
**Public URL:** https://status.devora.no  

## Goal

Improve Devora’s Upptime status page with Digdir-inspired UX copy/legend, a visible light-background header logo (cropped), brand-aligned live response graphs, and dual light/dark theming — all via documented Upptime hooks (`.upptimerc.yml`, `assets/`, `DESIGN.md`). Norwegian Bokmål for visitor-facing copy. No paid Statuspage SaaS.

## Preflight evidence (parent)

| Topic | Finding | Implication |
|-------|---------|-------------|
| Digdir headline | Live `status.digdir.no` shows **«Alle våre systemer fungerer normalt»** + horizontal legend (Normal drift / Redusert funksjonalitet / Delvis utilgjengelig / Utilgjengelig / Vedlikehold) | Map copy via `allSitesOperational` / `notAllSitesOperational` + inject a static legend (Upptime has no native 5-state legend) |
| Digdir vs Upptime states | Digdir/Statuspage: 5 states. Upptime: **up / degraded / down** + scheduled maintenance | Legend must be honest: Digdir-inspired labels mapped to Upptime semantics; do not invent a fifth live state |
| Header logo | Live `logoUrl` → `favicon.png` (dark-bg mark) — low contrast on white nav | Use uploaded light-bg mark; crop excess padding; set `logoUrl` to dedicated header asset (keep favicon separate if needed) |
| Live graphs still teal | `LiveStatus.svelte` paints PNG backgrounds from Graphs CI (`#1abc9c` / `#89e0cf` hardcoded in `@upptime/graphs`). Root `graphBorderColor`/`graphBackgroundColor` **are** already `#3432A6`/`#968AB6` in the live JS bundle — they only affect Chart.js `Graph.svelte` detail charts | Fix live cards with CSS `--graph-filter` **and** an explicit `article.graph { filter: … }` rule (stock `global.css` selector `article .graph` does **not** match `article.graph`) |
| Light/dark | Upptime docs: `theme: light\|dark\|night\|ocean` **or** custom `themeUrl`. With `themeUrl` alone, built-in dual `prefers-color-scheme` light+dark link pair is skipped | Keep one `themeUrl` CSS that defines light `:root` **and** `@media (prefers-color-scheme: dark)`; optional manual toggle via documented `js` / `customHeadHtml` + `data-theme` |
| Context7 / docs | `/upptime/upptime` + [configuration](https://upptime.js.org/docs/configuration/): `allSitesOperational`, `logoUrl`, `theme`/`themeUrl`, `css`, `js`, `customBodyHtml`, `metaTags` `color-scheme` | Config-first only |

### Digdir UX recommendations (implement vs defer)

**Implement in this slice**
1. Digdir-like overall status strings (`allSitesOperational` / `notAllSitesOperational` + matching `i18n.allSystemsOperational`).
2. Static status legend (Digdir-inspired NB labels + color swatches) via `customBodyHtml` and/or styled block in theme CSS — placed near the overall status / intro.
3. Restyle overall status banner for higher prominence (Digdir card-like: clear surface, padding, border) using theme CSS targeting Upptime’s operational status container (inspect live DOM; do not fork Sapper).
4. Light-bg cropped header logo via `logoUrl`.
5. Live PNG graph recolor via `--graph-filter` + `article.graph` CSS; keep Chart.js keys.
6. Light + dark token sets in `assets/devora-status-theme.css` (+ duplicate critical vars in `status-website.css`); `metaTags` `color-scheme: light dark`.

**Recommend / defer (document in DESIGN.md, do not block slice)**
- Subscribe / email / Teams (Statuspage feature) — out of Upptime scope; Slack webhook already configured.
- Service grouping / icons per product cluster — only 2 monitors; low value now.
- Separate test-env status URL — future if TEST monitors are added.
- Accessibility statement footer link — optional follow-up.

### Digdir → Upptime legend mapping (canonical)

| Digdir label | Upptime meaning | Token / visual |
|--------------|-----------------|----------------|
| Normal drift | `up` | success `#22C55E` |
| Redusert funksjonalitet | `degraded` | warning `#F59E0B` |
| Delvis utilgjengelig | *not a distinct Upptime state* — show in legend as explanatory (maps closest to degraded / partial impact) | warning / muted note |
| Utilgjengelig | `down` | error `#EF4444` |
| Vedlikehold | scheduled maintenance | info `#3B82F6` |

## Acceptance criteria

- [x] **AC1:** `allSitesOperational` (and `i18n.allSystemsOperational`) = Digdir-style NB, e.g. «Alle våre systemer fungerer normalt»; `notAllSitesOperational` updated to matching NB (no English leftovers for these keys).
- [x] **AC2:** A visible status-legend block exists (NB labels for the five Digdir-inspired rows above) injected via documented Upptime HTML/CSS hooks; styled with DESIGN tokens; works in light and dark.
- [x] **AC3:** Header `logoUrl` points at a light-background Devora mark under `assets/` (cropped — minimal empty padding), published as `https://status.devora.no/<asset>`; favicon remains correct Devora mark (may stay dark-bg or match — document choice).
- [x] **AC4:** Live status card graph backgrounds no longer read as Upptime teal; `--graph-filter` + `article.graph` (and any needed specificity) apply Devora-brand recolor; root `graphBorderColor`/`graphBackgroundColor` remain `#3432A6` / `#968AB6`.
- [x] **AC5:** Theme CSS provides coherent **light** and **dark** palettes (Devora tokens); dark via `@media (prefers-color-scheme: dark)` and/or `data-theme="dark"`; `color-scheme` meta present; optional toggle OK if low-risk via `js`.
- [x] **AC6:** `DESIGN.md` updated (logo assets, graph PNG vs Chart.js, legend mapping, light/dark architecture, Digdir UX notes).
- [x] **AC7:** `scripts/validate-status-website-ux.sh` extended for new AC checks and passes locally.
- [x] **AC8:** Sites remain AgePass + Vipps only; no GitHub navbar; no UtilitySign activation; no commit/push in builder (parent/operator owns push).

## Implementation steps

- [x] **1. TDD:** Extend `scripts/validate-status-website-ux.sh` (RED first) for: Digdir-style operational copy; legend presence (config HTML and/or theme CSS class); light logo asset + `logoUrl`; `--graph-filter` not `none` **or** explicit `article.graph` filter rule with non-teal intent; dark `@media` / `data-theme` block in theme CSS; `color-scheme` meta.
- [x] **2. Logo:** From uploaded light-bg PNG (`Logo_symbol_-_Lyse_bakgrunner-…png`), crop tight bounding box (ImageMagick/`sips`/Python), write `assets/logo-header.png` (+ optional tight SVG sibling). Point `status-website.logoUrl` at `https://status.devora.no/logo-header.png`. Keep `favicon.png`/`favicon.svg` for tab icon (document).
- [x] **3. Copy + legend:** Update `allSitesOperational` / `notAllSitesOperational` / `i18n.allSystemsOperational`. Add Digdir-inspired legend via `customBodyHtml` (preferred) or equivalent documented hook; style with classes in `devora-status-theme.css` (light+dark).
- [x] **4. Graph brand:** Set `--graph-filter` to a documented hue-rotate/saturate (or equivalent) that shifts teal PNGs toward primary/secondary purple; add `article.graph { filter: var(--graph-filter); opacity: var(--graph-opacity); }` because stock `article .graph` misses LiveStatus. Keep Chart.js root colors. Tune so detail Chart.js pages are not double-shifted if both apply — prefer scoping filter to live-status PNG cards only if Chart.js canvases would be distorted.
- [x] **5. Light/dark:** Expand `assets/devora-status-theme.css` with dark tokens (navy surfaces, readable text, semantic status colors preserved). Mirror critical vars in `status-website.css`. Add `metaTags` `color-scheme: light dark`. Optional: small toggle button via `js` + `localStorage` + `data-theme` (nice-to-have; do not block AC5 if prefers-color-scheme alone is solid).
- [x] **6. DESIGN.md:** Document all of the above + Digdir mapping + deferred UX ideas.
- [x] **7. Validate:** Loop `scripts/validate-status-website-ux.sh` until green; write `build-result.md` per workflow-artifact-contract.

## Verification plan

### Per-phase validation loops (loop until pass)

| Phase | Command / check | Pass condition |
|-------|-----------------|----------------|
| TDD gate | `bash scripts/validate-status-website-ux.sh` | Exit 0 after product edits (expect fail before) |
| YAML sanity | `python3 -c "import yaml; yaml.safe_load(open('.upptimerc.yml'))"` if PyYAML present, else visual/yq | Config parses |
| Asset presence | `test -f assets/logo-header.png && test -f assets/devora-status-theme.css` | Files exist; logo not huge empty canvas |
| Theme dual mode | `rg -n 'prefers-color-scheme:\\s*dark|data-theme' assets/devora-status-theme.css` | Dark rules present |
| Graph filter | `rg -n 'article\\.graph|--graph-filter' assets/devora-status-theme.css .upptimerc.yml` | Filter wired for LiveStatus |
| Legend / copy | `rg -n 'Alle våre systemer fungerer normalt|Normal drift|customBodyHtml' .upptimerc.yml` | Copy + legend present |

### Global validation commands (before handoff)

1. `bash scripts/validate-status-website-ux.sh`
2. Confirm `.upptimerc.yml` has no GitHub navbar href and sites = AgePass + Vipps only.
3. Confirm `DESIGN.md` documents logo-header, graph PNG filter vs Chart.js keys, light/dark, Digdir legend mapping.
4. Write `build-result.md` with Status PASS/PARTIAL, Acceptance Criteria rows, Linting/Type-Check PASS (script gate).

## Expected artifacts

- Updated: `.upptimerc.yml`, `DESIGN.md`, `assets/devora-status-theme.css`, `scripts/validate-status-website-ux.sh`
- New: `assets/logo-header.png` (and optional SVG)
- Handoffs: `build-result.md`, then verifier `verify-result.md`

## Out of scope

- Commit / push / CI monitor (operator GO in a later turn)
- UtilitySign monitor activation
- Paid Statuspage / Digdir Atlassian subscribe features
- Forking `@upptime/status-page` or hand-editing `gh-pages` as primary fix
- Regenerating Graphs CI PNGs with custom Chart.js colors inside `@upptime/graphs` (not configurable today — CSS filter is the supported path)

## Risk / rollback

- Aggressive `--graph-filter` may hue-shift icons inside the same `article` — scope CSS carefully; verify icon (Vipps logo) still looks correct.
- Dark mode must keep status semantics (green/amber/red) recognizable.
- Rollback: revert theme CSS filter and logoUrl to previous favicon.png.

## Amendments

- 2026-10-02T11:22:00Z — parent — Slice seeded from optimized prompt + Digdir browser inspect + Context7/Upptime docs; root-caused live teal graphs as Graphs CI PNGs + `article .graph` selector miss; dual theme via single themeUrl + prefers-color-scheme.
- 2026-10-02T11:35:00Z — builder — Implemented Digdir copy/legend, cropped `logo-header.png` (87×81 from light source), `article.graph` + `--graph-filter`, light/dark theme + optional js toggle; optional SVG sibling deferred (PNG sufficient). Validator PASS. No commit/push.
