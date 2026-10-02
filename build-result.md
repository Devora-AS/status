# Build Result

## Task
Three visual adjustments — legend below `article.up`, theme-dependent header logo, Live status card surfaces (`status-visual-legend-logo-livestatus-bg`)

## Status
PASS

## Changes Made
- `scripts/validate-status-website-ux.sh`: Fail-first asserts for legend relocate JS, dark→favicon logo swap, `section.live-status` card surfaces, DESIGN.md docs (AC4).
- `.upptimerc.yml`: Extended `js` — relocate `aside.devora-status-legend` after `main article.up|down|degraded`; sync nav logo (`logo-header.png` light / `favicon.png` dark) via `data-theme` + `matchMedia('(prefers-color-scheme: dark)')`; mirrored `css` with `section.live-status article` + remapped `--down-background-color` to `#FFFFFF` / `#1B2438` (removed `#FEE2E2` / `#3F1D1D` from card fills). `logoUrl` remains light asset for first paint.
- `assets/devora-status-theme.css`: Same Live status surface rule; remapped `--down-background-color`; legend placement comment.
- `DESIGN.md`: Legend placement below `article.up`; theme-dependent logo; Live status surfaces + `#1B2438` vs `#1b2432` token decision.
- `docs/current-plan.md`: Implementation steps `[x]`; Amendments append-only note.

## Acceptance Criteria
- AC1: PASS — `status-website.js` relocates `aside.devora-status-legend` via `insertAdjacentElement('afterend', …)` after first `main article.up|down|degraded`; Norwegian legend labels unchanged in `customBodyHtml`.
- AC2: PASS — Light logo `logo-header.png`; dark logo `favicon.png`; listens to `data-theme` (MutationObserver) + `prefers-color-scheme` (`matchMedia`); `logoUrl` still `https://status.devora.no/logo-header.png`; favicon hooks unchanged.
- AC3: PASS — `section.live-status article { background-color: var(--card-background-color) }`; card token light `#FFFFFF` / dark `#1B2438`; soft-error `#FEE2E2` / `#3F1D1D` removed from `--down-background-color` (theme + css mirror). **Token decision:** use DESIGN `#1B2438` (not `#1b2432`); live `article.up` already computed `rgb(27, 36, 56)` = `#1B2438`.
- AC4: PASS — Validator extended fail-first (pre-impl FAIL on missing legend JS); post-impl `bash scripts/validate-status-website-ux.sh` → PASS (exit 0).
- AC5: PASS — `DESIGN.md` documents legend placement, theme logo swap, Live status surfaces, and `#1B2438` vs `#1b2432`.
- AC6: PASS — Sites AgePass + Vipps only; NB i18n preserved; no commit/push by builder.

## Linting / Type-Check
PASS

```text
$ bash scripts/validate-status-website-ux.sh
validate-status-website-ux: PASS
```

## Issues / Blockers
None. Live site will lag until Static Site CI publishes — repo artifacts are authoritative for this slice.

## Notes for Verifier
- Prefer playwright-cli on live `https://status.devora.no` **after** publish; until then, verify repo `.upptimerc.yml` `js`/`css`, `assets/devora-status-theme.css`, and validator exit 0.
- Pre-publish live check (2026-10-02): legend still top orphan; logo always `logo-header.png` in dark — expected until CI.
- After publish: legend `previousElementSibling` should be `article.up`; dark nav logo `src` ends with `favicon.png`; Live status `backgroundColor` light `rgb(255,255,255)` / dark `rgb(27,36,56)`.
- Emulate dark: Playwright `emulateMedia({ colorScheme: 'dark' })` and/or click `#devora-theme-toggle`.

## Closeout (2026-10-02T12:35:00Z)
Builder slice complete: TDD validator green; three visual adjustments implemented in config/theme/DESIGN; no commit/push. Parent owns `[mao:build]` → completed after build→validate transition check.

## Trace Correlation
- run_id: status-visual-legend-logo-livestatus-bg-20261002T1228Z
