# Plan: Fix Live status card colors + restore graph/history continuity

**Slice id:** `status-livestatus-color-graph-slug-fix`  
**Execution mode:** `builder_plus_verifier`  
**Rationale:** Two coupled production regressions after rename + CSS filter; needs TDD + independent verify.  
**Slice class:** `bugfix`  
**No commit / no push** unless operator explicitly asks.

## Root cause (investigated)

### 1. Wrong Live status card colors (light cream / dark reddish)
Live status rows are Upptime `<article class="graph">`. Theme CSS applies:

```css
article.graph { filter: var(--graph-filter); } /* hue-rotate(72deg) … */
```

That filter was meant to recolor teal PNG sparklines toward Devora purple, but it **hue-shifts the entire card** (background + text). Result: light cream/beige cards and dark reddish-brown cards — not `--card-background-color` `#FFFFFF` / `#1B2438`. Soft-error hex `#3F1D1D` is not the fill source here; the filter is.

### 2. Graphs show a diagonal “triangle” / missing history
Monitor **display names** were changed to `AgePass` / `Vipps Logg Inn`. Upptime derives **slugs from names** unless `slug` is set:

| Display name (now) | Current slug | Historical assets still on disk |
|--------------------|--------------|----------------------------------|
| AgePass | `age-pass` | `history/age-pass-produksjon.yml`, `graphs/age-pass-produksjon/*` |
| Vipps Logg Inn | `vipps-logg-inn` | `history/vipps-login-upstream-ikke-age-pass.yml`, `graphs/vipps-login-upstream-ikke-age-pass/*` |

`history/summary.json` now points at the **new** slugs with essentially a single response-time sample → Chart.js / sparklines render as a diagonal fill. Historical data was **not deleted** by push; it was **orphaned** by slug change. UX updates must never rename sites without pinning `slug` or migrating history/graphs/api paths.

Upptime supports explicit `sites[].slug` (documented custom slug) — use it to keep friendly names while preserving history paths.

## Task description

1. **Stop hue-shifting Live status cards** — remove `filter`/`opacity` from `article.graph` (and mirrored `status-website.css`). Keep sparklines readable; rely on root `graphBorderColor` / `graphBackgroundColor` (`#3432A6` / `#968AB6`) for Graphs CI / Chart.js brand colors. Do not reintroduce banned fills `#3F1D1D` / `#FEE2E2`.
2. **Restore history continuity** — keep display names `AgePass` and `Vipps Logg Inn`; set explicit:
   - AgePass → `slug: age-pass-produksjon`
   - Vipps Logg Inn → `slug: vipps-login-upstream-ikke-age-pass`
3. **Document operator rule** in `DESIGN.md` and/or `docs/monitors.md`: never change monitor `name` without pinning `slug` or migrating `history/` + `graphs/` (+ `api/` if present); UX/CSS commits must not wipe history.
4. **TDD** extend `scripts/validate-status-website-ux.sh` (fail first) for: no `filter:` on `article.graph`; both sites declare the pinned slugs; no banned fills.

Out of scope: UtilitySign, renaming display titles again, force-push, deleting old history files.

## Acceptance criteria

- [x] **AC1 — Card surfaces unfiltered:** Light/dark Live status cards use `--card-background-color` (`#FFFFFF` / `#1B2438`) without `filter` on `article.graph` / `section.live-status article`. No cream/reddish hue-shift; no `#3F1D1D` / `#FEE2E2`.
- [x] **AC2 — Slug continuity:** `.upptimerc.yml` keeps names `AgePass` / `Vipps Logg Inn` and pins `slug: age-pass-produksjon` / `slug: vipps-login-upstream-ikke-age-pass`. Existing `history/*.yml` and `graphs/*` paths remain the canonical continuity keys.
- [x] **AC3 — History not wiped:** No deletion of `history/` or `graphs/` historical assets; docs state the rename/slug policy.
- [x] **AC4 — Validator TDD:** Fail-first asserts in `scripts/validate-status-website-ux.sh` for filter ban + pinned slugs; script exits 0 after fix.
- [x] **AC5 — Docs:** `DESIGN.md` notes filter removal; `docs/monitors.md` lists slug + continuity warning.

## Implementation steps

- [x] **0. TDD fail-first:** Add validator checks that fail on current tree (article.graph filter present; missing pinned slugs).
- [x] **1. CSS:** Remove `article.graph { filter; opacity }` from `assets/devora-status-theme.css` and mirrored `.upptimerc.yml` `status-website.css`. Keep `section.live-status article { background-color: var(--card-background-color) }` and canvas `filter: none`.
- [x] **2. Config:** Add `slug:` pins under both sites; keep icon/URLs/names.
- [x] **3. Docs:** Update DESIGN.md + monitors.md with slug continuity rule.
- [x] **4. Validator green + `build-result.md`.**

## Verification plan

### Per-phase validation loops (loop until pass)

| Phase | Command | Pass rule |
|-------|---------|-----------|
| Validator | `bash scripts/validate-status-website-ux.sh` | exit 0 |
| Config | `bash scripts/validate-upptime-config.sh` | exit 0 |
| History presence | `test -f history/age-pass-produksjon.yml && test -f history/vipps-login-upstream-ikke-age-pass.yml` | files exist |
| Graphs presence | `test -d graphs/age-pass-produksjon && test -d graphs/vipps-login-upstream-ikke-age-pass` | dirs exist |

### Global validation commands (before handoff)

1. `bash scripts/validate-status-website-ux.sh`
2. `bash scripts/validate-upptime-config.sh`
3. Confirm `.upptimerc.yml` has both `slug:` pins and no `article.graph` filter in theme CSS / css mirror
4. Prefer playwright-cli or curl evidence notes for verifier (live may lag until CI)

## Validation steps (verifier)

- [] Confirm AC1–AC5 against files + validator
- [] Confirm history/graphs paths untouched (not deleted)
- [] Note: after publish, Summary/Graphs CI should bind sparklines to pinned slugs again

## Expected output artifacts

| Artifact | Owner |
|----------|--------|
| `docs/current-plan.md` | Parent |
| `build-result.md` | Builder |
| `verify-result.md` | Verifier / parent serialize |
| Touched: `.upptimerc.yml`, `assets/devora-status-theme.css`, `scripts/validate-status-website-ux.sh`, `DESIGN.md`, `docs/monitors.md` | Builder |

## Rollback

Revert CSS filter removal and slug pins; history files remain as before.

## Amendments

- 2026-10-02T13:15:00Z — parent-orchestrator — New slice: Live status color bug from article.graph hue-rotate; graph orphan from name→slug rename; fix via remove filter + pin historical slugs; TDD validator; no commit/push.
- 2026-10-02T13:25:00Z — builder — Removed article.graph filter; pinned historical slugs; docs + validator green; build-result PASS.
- 2026-10-02T13:30:00Z — parent-orchestrator — Verifier PASS AC1–AC5; serialized verify-result.md; awaiting operator commit/push for live republish.
