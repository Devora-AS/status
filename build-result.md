# Build Result

## Task
Fix Live status card hue-shift (remove article.graph filter) and restore graph/history continuity via pinned monitor slugs.

## Status
PASS

## Changes Made
- `scripts/validate-status-website-ux.sh`: TDD — replaced required `article.graph` filter checks with ban on `filter:` for `article.graph` / live-status; added pinned-slug asserts for AgePass / Vipps Logg Inn; kept canvas `filter: none` and soft-error fill bans.
- `assets/devora-status-theme.css`: Removed `--graph-filter` / `--graph-opacity` and `article.graph { filter; opacity }`; kept `section.live-status article { background-color: var(--card-background-color) }` and canvas `filter: none`.
- `.upptimerc.yml`: Pinned `slug: age-pass-produksjon` and `slug: vipps-login-upstream-ikke-age-pass`; removed mirror `--graph-filter` / `--graph-opacity`; added canvas `filter: none` in `status-website.css`; restored `$REPO` in `i18n.footer` (pre-existing validator gate).
- `DESIGN.md`: Documented filter removal (why hue-rotate broke cards) + slug continuity operator rule.
- `docs/monitors.md`: Listed pinned slugs + rename/slug continuity warning.
- `docs/current-plan.md`: In-plan checklist markers mutated to `[x]`.

## Acceptance Criteria
- AC-1: PASS — No `filter:` on `article.graph` / `section.live-status`; card surface remains `var(--card-background-color)`; no `#3F1D1D` / `#FEE2E2` in live-status rules; canvas `filter: none` kept.
- AC-2: PASS — Names stay `AgePass` / `Vipps Logg Inn` with `slug: age-pass-produksjon` / `slug: vipps-login-upstream-ikke-age-pass`.
- AC-3: PASS — `history/age-pass-produksjon.yml` and `history/vipps-login-upstream-ikke-age-pass.yml` exist; graph dirs present; docs state continuity policy; no history/graphs deletes.
- AC-4: PASS — Fail-first confirmed (filter present + missing slugs before fix); `bash scripts/validate-status-website-ux.sh` exits 0 after fix; `bash scripts/validate-upptime-config.sh` exits 0.
- AC-5: PASS — `DESIGN.md` documents filter removal; `docs/monitors.md` lists slugs + continuity rule.

## Linting / Type-Check
PASS
- `bash scripts/validate-status-website-ux.sh` → PASS (exit 0)
- `bash scripts/validate-upptime-config.sh` → PASS (exit 0)

## Issues / Blockers
None. Live site may lag until Static Site / Graphs CI republish binds sparklines to pinned slugs again.

## Notes for Verifier
- TDD evidence: before CSS/slug fix, isolated asserts showed `article.graph filter present: True` and pinned slugs missing; full script also hit pre-existing `i18n.footer` `$REPO` gate (footer restored to `[Upptime]($REPO)`).
- Confirm mirror css block has no `article.graph { filter` and theme CSS comment documents ban.
- Do not expect `history/` or `graphs/` deletions in the diff.
- No commit / no push by builder.

## Closeout (2026-10-02)
Slice `status-livestatus-color-graph-slug-fix` implemented with TDD validator, filter removal, slug pins, and docs; both validators green.
