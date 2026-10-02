# Plan: Three visual adjustments — status.devora.no

**Slice id:** `status-visual-legend-logo-livestatus-bg`  
**Execution mode:** `builder_plus_verifier`  
**Rationale:** Targeted Svelte/CSS/Upptime theme + config changes with independent verify (incl. light/dark visual checks).  
**Slice class:** `feature`  
**No commit / no push** unless operator explicitly asks.

## Task description

Implement and verify three visual adjustments on the Devora public status page (`status.devora.no`), preserving Norwegian Bokmål UI copy and avoiding unrelated scope:

1. **Legend placement** — Move `aside.devora-status-legend.status-legend` («Forklaring av driftsstatus») from its current top/left injection into main content **directly below** `article.up` («Alle våre systemer fungerer normalt»).
2. **Theme-dependent header logo** — Light theme: keep `logo-header.png` via `logoUrl`. Dark theme: use favicon asset `favicon.png` (`https://status.devora.no/favicon.png`) for visibility on dark nav/backgrounds.
3. **Live status box backgrounds** — Match `article.up` / «Tidligere hendelser» card surfaces:
   - Light: `#ffffff` (token `--card-background-color` / surface)
   - Dark: prefer existing DESIGN token `#1B2438` (`--card-background-color`) over operator shorthand `#1b243` / `#1b2432` unless live page proves a different computed color is required — document decision in `build-result.md` / `DESIGN.md`
   - Remove/replace incorrect soft-error fills `#3F1D1D` and `#FEE2E2` / `#fee2e2` where they paint Live status boxes (do not leave Live status reading as error-tinted soft red)

Out of scope: commit/push, UtilitySign monitors, Digdir subscribe features, Graphs CI PNG regeneration, unrelated navbar/i18n edits.

## Acceptance criteria

- [x] **AC1 — Legend below `article.up`:** After page load (and after theme toggle if present), `aside.devora-status-legend` (or `.status-legend`) is a sibling/following node directly under the operational banner `article.up` in main content — not stuck as a top/left orphan above the banner. Norwegian legend copy unchanged (Normal drift, Redusert funksjonalitet, Delvis utilgjengelig, Utilgjengelig, Vedlikehold).
- [x] **AC2 — Theme logo swap:** In light mode, header logo `src` resolves to `logo-header.png`. In dark mode (`prefers-color-scheme: dark` and/or `data-theme="dark"`), header logo `src` resolves to `favicon.png`. Favicon tab icon remains `favicon.png` / `faviconSvg`. Default `logoUrl` in `.upptimerc.yml` stays light asset for first paint.
- [x] **AC3 — Live status surfaces:** Live status boxes use the same surface as `article.up` / past-incident cards: light `#FFFFFF`, dark card token (preferred `#1B2438`). Theme CSS / mirrored `status-website.css` must not leave Live status boxes on `#FEE2E2` / `#3F1D1D`. Document token choice if `#1b2432` ≠ `#1B2438`.
- [x] **AC4 — Validator / TDD:** `scripts/validate-status-website-ux.sh` extended (failing checks first) for legend reposition hook, dark-logo swap hook, and Live status bg constraints; script exits 0 after implementation.
- [x] **AC5 — Docs:** `DESIGN.md` documents legend placement, theme-dependent logo, and Live status surface tokens (incl. `#1B2438` vs `#1b2432` note).
- [x] **AC6 — No unrelated churn:** Sites remain AgePass + Vipps; NB i18n preserved; no commit/push.

## Implementation steps

- [x] **0. TDD fail-first:** Extend `scripts/validate-status-website-ux.sh` with new asserts that fail on current tree (legend placement JS/CSS hook, dark logo → favicon, Live status not using `#FEE2E2`/`#3F1D1D` for card surfaces). Run once → expect FAIL.
- [x] **1. Legend relocation:** Keep legend HTML in `customBodyHtml`. Add CSS/JS so after DOM ready the aside is moved to immediately follow `article.up` (or `article.down` / degraded banner if not all systems operational — prefer `main article.up, main article.down, main article.degraded` first status summary article). Preserve accessibility (`aria-label`). Use Context7 for any Svelte/DOM patterns only if touching generated page JS patterns; Upptime injection is config+CSS+`status-website.js`.
- [x] **2. Theme logo:** Extend `status-website.js` to select nav logo `<img>` (Upptime header) and set `src` to `logo-header.png` (light) or `favicon.png` (dark); listen to `data-theme` changes + `matchMedia('(prefers-color-scheme: dark)')`. Keep `logoUrl` pointing at light asset for SSR/first paint.
- [x] **3. Live status backgrounds:** Align Live status card/`article` backgrounds with `--card-background-color` (`#FFFFFF` / `#1B2438`). Replace incorrect uses of `--down-background-color: #FEE2E2` / `#3F1D1D` for Live status surfaces (update theme CSS + mirrored `status-website.css`; update DESIGN.md mapping). Prefer token `#1B2438` over inventing `#1b2432` unless evidence requires otherwise.
- [x] **4. Docs + validator green:** Update `DESIGN.md`; re-run validator → PASS; note any Playwright visual check commands for verifier.
- [x] **5. Write `build-result.md`** per `docs/reference/workflow-artifact-contract.md` (or repo equivalent) with Status, Acceptance Criteria rows, Linting/Type-Check, Closeout.

## Validation steps (verifier)

- [x] Read-only: confirm AC1–AC6 against files + validator output.
- [x] Prefer **playwright-cli** against live `https://status.devora.no` **and/or** local evidence of config/CSS/JS that will publish — note that live site may lag until Static Site CI; if live still shows old layout, verify **repo artifacts** prove the three changes and document live lag as non-blocking for this slice.
- [x] Light + dark: logo src and Live status computed/background intent; legend position relative to `article.up`.
- [x] Return structured verify payload (parent serializes `verify-result.md`).

## Expected output artifacts

| Artifact | Owner |
|----------|--------|
| `docs/current-plan.md` | Parent (this file) |
| `build-result.md` | Builder |
| `verify-result.md` | Parent (from verifier payload) |
| Touched: `.upptimerc.yml`, `assets/devora-status-theme.css`, `scripts/validate-status-website-ux.sh`, `DESIGN.md` | Builder |

## Token decision (plan default)

| Operator note | Repo DESIGN today | Plan default |
|---------------|-------------------|--------------|
| Dark Live status `#1b243` / `#1b2432` | `--card-background-color: #1B2438` | **Use `#1B2438`** (existing token); document if visual QA wants `#1b2432` instead |
| Remove `#3F1D1D`, `#fee2e2` from Live status boxes | `--down-background-color` soft error | Live status / card surfaces must not use those; adjust down soft fill mapping so Live status matches `article.up` / past incidents |

## Rollback

Revert `.upptimerc.yml` `js`/`css`/`customBodyHtml`, `assets/devora-status-theme.css`, validator extensions, and DESIGN.md notes for this slice.

## Amendments

- 2026-10-02T12:27:00Z — parent-orchestrator — Seeded substantive plan for three visual adjustments (legend below article.up, theme logo swap, Live status card surfaces); default dark token `#1B2438`; execution_mode builder_plus_verifier; no commit/push.
- 2026-10-02T12:35:00Z — builder — Implemented slice: fail-first validator → PASS; legend relocate + theme logo JS in `.upptimerc.yml`; Live status `section.live-status article` + remapped `--down-background-color` to card surfaces (`#FFFFFF` / `#1B2438`); DESIGN.md docs; no commit/push.
- 2026-10-02T12:40:00Z — parent-orchestrator — Verifier PASS AC1–AC6; serialized `verify-result.md`; synced plan AC/validation markers to `[x]`; live CI lag remains open advisory only.
- 2026-10-02T12:45:00Z — parent (mat-sprint) — Replaced AgePass-focused `introTitle`/`introMessage` with company-wide driftsstatus copy; no other status-website fields; fold into same commit as visual slice.
