# Build Result

## Task
status-nb-brand-nav — remove GitHub navbar, NB i18n, DESIGN.md + verified Upptime theme

## Status
PASS

## Changes Made
- `scripts/validate-status-website-ux.sh`: new TDD gate (GitHub navbar absent, DESIGN.md, NB `i18n`, theme asset/`themeUrl`/`theme-color`, AgePass+Vipps only)
- `DESIGN.md`: root design.md front matter + prose; AgePass/Devora tokens mapped to Upptime CSS vars
- `.upptimerc.yml`: removed GitHub navbar item; full NB `i18n` (`locale: nb-NO`); `allSitesOperational`/`notAllSitesOperational`; `themeUrl` + inline `css` `:root` vars; `metaTags` `theme-color`; intro without GitHub promo link
- `assets/devora-status-theme.css`: light-theme CSS variables from DESIGN.md
- `docs/current-plan.md`: step/AC markers `[]`→`[x]`

## Acceptance Criteria
- AC1: PASS — navbar is Status + devora.no only; no `github.com` href in `status-website.navbar`
- AC2: PASS — root `DESIGN.md` with YAML front matter; maps primary/navy/page bg to `--nav-current-border-bottom-color` / `--body-*`; `npx @google/design.md lint DESIGN.md` → 0 errors (warnings only)
- AC3: PASS — top-level `i18n:` complete from status-page `i18n.yml`, `locale: nb-NO`, æ/ø/å present; `$UPTIME`/`$TIME`/`$REPO`/`$NUMBER` preserved; sites/paths unchanged
- AC4: PASS — `themeUrl: https://status.devora.no/devora-status-theme.css` + `assets/devora-status-theme.css` + duplicate `css` `:root` + `theme-color: #3432A6` (documented Upptime hooks only)
- AC5: PASS — RED then GREEN on `validate-status-website-ux.sh`; `validate-upptime-config.sh` PASS; sites AgePass + Vipps only
- AC6: PASS — playwright-cli vs live `https://status.devora.no` recorded (GitHub nav + English + teal `#1abc9c` still live); local config proof GREEN; **no commit/push**
- AC7: PASS — no custom SCSS fork / gh-pages edits; no UtilitySign/DRILL

## Linting / Type-Check
PASS
```text
validate-status-website-ux: PASS
validate-upptime-config: PASS
bash -n scripts/validate-status-website-ux.sh: PASS
npx @google/design.md lint DESIGN.md: 0 errors (orphaned-token warnings OK)
playwright-cli open https://status.devora.no/: OK (baseline lag documented)
```

## Issues / Blockers
None for local/config scope. Live site will lag until operator push + Upptime static-site workflow publishes `assets/` and regenerates the status page.

## Notes for Verifier
- TDD: first RED was GitHub navbar present (`validate-status-website-ux` FAIL); fixed awk edge so `--css-var` greps use `grep --` on macOS
- Live baseline (2026-10-01): nav still has GitHub → `https://github.com/Devora-AS/status`; UI English (`Live Status`, `All systems are operational`); `--nav-current-border-bottom-color` = `#1abc9c`
- Local ready: navbar titles `['Status', 'devora.no']`; theme file + `themeUrl` + NB i18n in tree
- Context7 `/upptime/upptime` + upptime.js.org confirmed `themeUrl`/`assets/*.css`, `i18n`, navbar, `css`, `metaTags`
- Snapshots under `.playwright-cli/` are local evidence only (not for commit)
- Parent owns build→validate transition / `[mao:build]` completed

## Closeout (2026-10-01)
Deploy-ready config for NB + brand + no GitHub nav; validators green; live lag documented; no commit/push.
