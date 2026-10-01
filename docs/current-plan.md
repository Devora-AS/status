# Execution plan — Status page NB + brand + remove GitHub nav

**Mission:** `devora-status-public-ux`  
**Slice ID:** `status-nb-brand-nav`  
**Tier:** standard  
**Preflight / execution_mode:** `builder_plus_verifier`  
**execution_rationale:** Config + DESIGN.md + validators + browser checks need independent build/verify; single writer (builder).  
**Prompt source:** MCP `user-prompt-optimizer` → `optimize-user-prompt` (template `user-prompt-planning`); optimized brief is authoritative for this slice.

---

## Goal

Fix Devora public status page (`https://status.devora.no`, Upptime on `Devora-AS/status`):

1. Remove the GitHub **navbar** item linking to `https://github.com/Devora-AS/status`.
2. Localize user-facing copy to Norwegian Bokmål (æ/ø/å); keep code/paths/IDs/URLs/monitor technical names unchanged unless a user-facing label must change.
3. Create root `DESIGN.md` (Google Labs `design.md` format; inspired by AgePass `DESIGN.md` + Admin IA v2 tokens), then apply **only verified** Upptime theming so the generated site matches those tokens.

**Out of scope:** push/commit (no GO); UtilitySign monitor; product Azure; speculative custom CSS outside documented Upptime hooks.

---

## Root-cause notes (preflight evidence — parent)

| Issue | Source of truth | Fix surface |
|-------|-----------------|-------------|
| GitHub nav link | `.upptimerc.yml` → `status-website.navbar` entry `title: GitHub` / `href: https://github.com/Devora-AS/status` (also live HTML `<nav>`) | Remove that navbar item only |
| English UI strings | Live page still shows `Live Status`, duration labels, footer English; Upptime supports top-level `i18n:` keys from `upptime/status-page/i18n.yml` | Add complete `i18n:` block in `.upptimerc.yml` (NB); also `introTitle`/`introMessage`/`allSitesOperational`/`notAllSitesOperational` as needed |
| Branding | Default Upptime light theme CSS vars (`--nav-current-border-bottom-color: #1abc9c`, teal body bg); Context7 + upptime.js.org docs | Documented: `theme` / `themeUrl` + `assets/*.css` CSS variables, and/or `status-website.css`, `metaTags` `theme-color`, optional `logoUrl` |

**Verified Upptime capabilities (Context7 `/upptime/upptime` + upptime.js.org configuration):**

- `status-website.navbar`, `introTitle`, `introMessage`, `name`, `cname`, `logoUrl`, `faviconSvgPath`
- `status-website.css` (inline), `links` stylesheets, `metaTags`
- `theme`: `light` \| `dark` \| `night` \| `ocean`; custom via `assets/<name>.css` + `themeUrl`
- Theme CSS variables (from status-page `themes/*.css`): `--body-background-color`, `--body-text-color`, `--card-background-color`, `--nav-background-color`, `--nav-border-bottom-color`, `--nav-current-border-bottom-color`, `--card-border-color`, up/down/degraded colors, button colors, etc.
- Top-level `i18n:` for all status-page strings
- `allSitesOperational` / `notAllSitesOperational` under `status-website`

**Do not invent:** undocumented SCSS build paths, forked status-page templates, or hand-editing `gh-pages` output as the primary fix.

**AgePass brand tokens to map (gh `Devora-AS/agepass` DESIGN.md):** primary `#3432A6`, primary-hover/navy `#242A56`, navy-dark `#1B2438`, secondary-purple `#968AB6`, accent-cream `#FFFADE`, background-page `#F8F7FF`, surface `#FFFFFF`, on-surface `#242A56`, muted `#64748B`, success/warning/error semantic colors.

---

## Implementation steps

- [x] **0.** Re-confirm Upptime docs (Context7) and AgePass tokens; do not invent CSS hooks.
- [x] **1. TDD (failing first):** Add/extend validators under `scripts/` that fail on current tree for: (a) GitHub navbar href present, (b) missing root `DESIGN.md`, (c) missing/incomplete NB `i18n` (spot-check required keys + æ/ø/å in at least one string), (d) missing Devora theme asset or documented `css`/`themeUrl` mapping to DESIGN tokens. Prefer extending `scripts/validate-upptime-config.sh` and/or new `scripts/validate-status-website-ux.sh`. Run RED before product edits.
- [x] **2. DESIGN.md:** Create repo-root `DESIGN.md` per https://github.com/google-labs-code/design.md (YAML front matter + prose). Scope: public status page. Tokens from AgePass/Devora; status-page component mapping (nav, cards, up/down tags). Optionally lint with `npx @google/design.md lint DESIGN.md` if network allows; document result.
- [x] **3. Remove GitHub navbar item** from `.upptimerc.yml` only. Keep `Status` + `devora.no`. Do not remove monitor scope. Soften/rephrase `introMessage` GitHub markdown link if it remains the primary “GitHub promo” (navbar is mandatory; intro link is optional cleanup for UX consistency — prefer NB wording without requiring users to open the repo).
- [x] **4. Localize:** Add top-level `i18n:` with Norwegian Bokmål for all keys from `upptime/status-page/i18n.yml` (or full set needed by Upptime). Set `locale` appropriately (e.g. `nb-NO`). Translate `allSitesOperational` / `notAllSitesOperational`. Preserve placeholders (`$NUMBER`, `$DATE`, `$UPTIME`, `$REPO`, etc.). Monitor `sites[].name` may stay as product names (AgePass / Vipps) — user-facing descriptive Norwegian already partly in names is OK; do not break slug/history filenames.
- [x] **5. Branding (verified only):** Create `assets/devora-status-theme.css` (or equivalent under `assets/`) setting `:root` CSS variables to DESIGN.md tokens (light theme primary). Wire via `status-website.themeUrl` pointing at the **published** asset URL pattern Upptime documents (`https://status.devora.no/<file>` after assets copy — verify exact URL convention from docs: assets served as-is). Additionally or alternatively set `status-website.css` with the same `:root` vars if `themeUrl` alone is insufficient before first publish. Set `metaTags` `theme-color` to primary/navy. Optional: `logoUrl` only if a stable public Devora logo URL is already known — do not invent.
- [x] **6. Re-run validators → GREEN.** Keep AgePass + Vipps only; no UtilitySign/DRILL.
- [x] **7. Browser validation:** Use playwright-cli and/or Playwright MCP. Against **local config evidence** always; against `https://status.devora.no` for baseline (GitHub nav still present until deploy) and document that live site will lag until operator push + Upptime site workflow. If a local preview of generated site is feasible without push, use it; otherwise validate YAML/asset content + scripts as deploy-ready proof.
- [x] **8. Write `build-result.md`** per workflow-artifact-contract (Status, Acceptance Criteria rows, Linting/Type-Check, Closeout). No commit/push.

---

## Acceptance criteria

- [x] **AC1:** `.upptimerc.yml` `status-website.navbar` has **no** item with `href` containing `github.com/Devora-AS/status` (or any GitHub repo nav link).
- [x] **AC2:** Root `DESIGN.md` exists, uses design.md front-matter + prose, and documents Devora tokens mapped to status-page CSS variables.
- [x] **AC3:** User-facing Upptime strings are configured in Norwegian Bokmål via `i18n:` (and intro/operational messages) with correct æ/ø/å; placeholders preserved; code/paths/IDs unchanged.
- [x] **AC4:** Branding uses only documented Upptime hooks (`themeUrl`/`assets` CSS vars and/or `css`/`metaTags`); CSS variables align with `DESIGN.md` (primary/navy/page background at minimum).
- [x] **AC5:** Validators under `scripts/` cover AC1–AC4 (TDD: RED then GREEN); `sites` remain AgePass + Vipps only.
- [x] **AC6:** Browser/check evidence recorded (live vs local/config distinguished); no push/commit performed.
- [x] **AC7:** No speculative undocumented theme paths; no UtilitySign activation.

---

## Verification plan

### Phase 1 — Config / design unit gates (loop until pass)

```bash
bash scripts/validate-upptime-config.sh
bash scripts/validate-status-website-ux.sh   # or whatever name builder adds
# optional: npx @google/design.md lint DESIGN.md
```

Loop until exit 0 after RED→GREEN.

### Phase 2 — Diff hygiene (loop until pass)

```bash
# Confirm no secrets; sites only AgePass+Vipps; no commit of .cursor/
rg -n 'github.com/Devora-AS/status' .upptimerc.yml || true
# navbar must not match; intro may still mention repo only if intentionally kept — prefer absence in navbar
```

### Phase 3 — Browser / visual (loop until pass or documented deploy lag)

```bash
# playwright-cli or Playwright MCP against https://status.devora.no
# Assert current live state OR local preview; document deploy dependency for live AC1–AC4
```

### Global before handoff

1. Phase 1 scripts exit 0  
2. `build-result.md` complete with PASS/PARTIAL honesty about live vs config  
3. No push/commit  

---

## Expected artifacts

- `DESIGN.md` (root)
- `.upptimerc.yml` (navbar, i18n, theme/css/meta)
- `assets/devora-status-theme.css` (or equivalent documented asset)
- `scripts/validate-status-website-ux.sh` (and/or extended validate-upptime-config)
- `build-result.md`
- Parent: `verify-result.md`, updated `docs/session-summary.md`

---

## Builder constraints

- Single writer for all product files.
- TDD for script/config checks.
- Context7 / Upptime docs before any CSS approach.
- Do **not** push. Do **not** commit (no GO this slice).
- Exclude `.cursor/` from any staging if commit were ever requested later.
- Do not activate UtilitySign or DRILL monitors.

---

## Amendments

- 2026-10-01T12:55:49Z — parent — Slice seeded from optimized prompt (`user-prompt-optimizer` / `user-prompt-planning`); preflight rooted GitHub nav in `.upptimerc.yml`; verified Upptime `i18n`, `themeUrl`/`assets` CSS vars, and `css` via Context7 + upptime.js.org; AgePass tokens captured for DESIGN.md.
