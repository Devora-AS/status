---
version: alpha
name: Devora Status
description: >-
  Visual identity for Devora’s public company status page (status.devora.no),
  powered by Upptime. Tokens align with AgePass / Devora Admin; applied only via
  documented Upptime hooks (themeUrl + assets CSS variables, optional css, metaTags).
colors:
  primary: "#3432A6"
  primary-hover: "#242A56"
  navy: "#242A56"
  navy-dark: "#1B2438"
  secondary-purple: "#968AB6"
  accent-cream: "#FFFADE"
  background-page: "#F8F7FF"
  background-page-dark: "#12182A"
  surface: "#FFFFFF"
  surface-dark: "#1B2438"
  on-surface: "#242A56"
  on-surface-dark: "#E8E6F5"
  on-surface-muted: "#64748B"
  on-primary: "#FFFFFF"
  success: "#22C55E"
  warning: "#F59E0B"
  error: "#EF4444"
  info: "#3B82F6"
  nav-border: "#E8E6F5"
  nav-border-dark: "#2F3A5C"
typography:
  body-md:
    fontFamily: system-ui
    fontSize: 1rem
    fontWeight: 400
    lineHeight: 1.5
  heading-md:
    fontFamily: system-ui
    fontSize: 1.25rem
    fontWeight: 700
    lineHeight: 1.3
rounded:
  sm: 8px
  md: 12px
spacing:
  sm: 16px
  md: 24px
components:
  status-nav:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    borderBottomColor: "{colors.nav-border}"
    activeBorderColor: "{colors.primary}"
  status-page:
    backgroundColor: "{colors.background-page}"
    textColor: "{colors.on-surface}"
  status-card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    borderColor: "{colors.nav-border}"
  tag-up:
    backgroundColor: "{colors.success}"
    textColor: "{colors.on-primary}"
  tag-degraded:
    backgroundColor: "{colors.warning}"
    textColor: "{colors.on-surface}"
  tag-down:
    backgroundColor: "{colors.error}"
    textColor: "{colors.on-primary}"
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    borderColor: "{colors.navy}"
---

# Devora Status — design contract

Public status at `https://status.devora.no` (Upptime). This file is the token source of truth for branding; do not invent undocumented theme hooks.

## Brand tokens (AgePass / Devora)

| Token | Hex | Role |
|-------|-----|------|
| primary | `#3432A6` | Active nav underline, primary buttons, `theme-color` |
| primary-hover / navy | `#242A56` | Body text / on-surface (light) |
| navy-dark | `#1B2438` | Dark surfaces / cards |
| secondary-purple | `#968AB6` | Soft accent, Chart.js fill, dark active nav |
| accent-cream | `#FFFADE` | Highlight surfaces (unused by default theme vars) |
| background-page | `#F8F7FF` | Page background (light) |
| background-page-dark | `#12182A` | Page background (dark) |
| surface | `#FFFFFF` | Cards + nav (light) |
| surface-dark | `#1B2438` | Cards + nav (dark) |
| muted | `#64748B` | Secondary copy / legend notes |
| success | `#22C55E` | Up / Normal drift |
| warning | `#F59E0B` | Degraded / Redusert funksjonalitet |
| error | `#EF4444` | Down / Utilgjengelig |
| info | `#3B82F6` | Vedlikehold |

## Digdir-inspired UX (honest mapping)

Visitor-facing operational copy mirrors Digdir’s status.digdir.no tone (Norwegian Bokmål):

| Config key | Copy |
|------------|------|
| `allSitesOperational` / `i18n.allSystemsOperational` | Alle våre systemer fungerer normalt |
| `notAllSitesOperational` | Ikke alle systemer fungerer normalt |

**Status legend** is injected via documented `status-website.customBodyHtml` (classes `.devora-status-legend` / `.status-legend`) and styled in `assets/devora-status-theme.css`. Upptime only has **up / degraded / down** + scheduled maintenance — the five Digdir-inspired rows are labels for visitors, not five live Upptime states.

**Placement:** `customBodyHtml` injects the aside early in `#sapper` (above nav). `status-website.js` relocates it **after Sapper hydrates** the operational banner (`main.container > article.up|down|degraded`, never `section.live-status article`) via `MutationObserver` (`childList`/`subtree`) + interval retry — a single `DOMContentLoaded` call is too early because `article.up` is client-rendered. Target order: banner → **12px gap** (`article.up + .devora-status-legend { margin-top }`) → legend → «Live status».

**Public copy:** Visitor-facing HTML must say **Devora driftsstatus** (not third-party product names). Do not mention Digdir or other external status products in legend or body copy. **Upptime** is named only in `i18n.footer` (`drevet av Upptime`).

| Digdir-inspired label | Upptime meaning | Token |
|-----------------------|-----------------|-------|
| Normal drift | `up` | success `#22C55E` |
| Redusert funksjonalitet | `degraded` | warning `#F59E0B` |
| Delvis utilgjengelig | *not distinct* — explanatory; closest to degraded / partial impact | warning (muted swatch) |
| Utilgjengelig | `down` | error `#EF4444` |
| Vedlikehold | scheduled maintenance | info `#3B82F6` |

### Deferred Digdir/Statuspage ideas (do not block)

- Subscribe / email / Teams notifications (Slack webhook already configured)
- Service grouping / product-cluster icons (only AgePass + Vipps today)
- Separate TEST-env status URL
- Accessibility statement footer link

## Upptime CSS variable mapping

Custom theme file: `assets/devora-status-theme.css`, published as `https://status.devora.no/devora-status-theme.css` and wired via `status-website.themeUrl` (assets are served as-is). Optional duplicate `:root` overrides via `status-website.css` for first-publish safety (includes dark `@media` + `data-theme` mirrors).

| Upptime variable | DESIGN token |
|------------------|--------------|
| `--body-background-color` | `background-page` `#F8F7FF` (dark: `#12182A`) |
| `--body-text-color` | `on-surface` / navy `#242A56` (dark: `#E8E6F5`) |
| `--card-background-color` | `surface` `#FFFFFF` (dark: `#1B2438`) |
| `--nav-background-color` | `surface` `#FFFFFF` (dark: `#1B2438`) |
| `--nav-border-bottom-color` | `nav-border` `#E8E6F5` (dark: `#2F3A5C`) |
| `--nav-current-border-bottom-color` | `primary` `#3432A6` (dark: secondary-purple) |
| `--card-border-color` | `nav-border` `#E8E6F5` (dark: `#2F3A5C`) |
| `--up-border-left-color` / `--tag-up-background-color` | `success` `#22C55E` |
| `--degraded-border-left-color` / `--tag-degraded-background-color` / `--change-background-color` | `warning` `#F59E0B` |
| `--down-border-left-color` / `--tag-down-background-color` | `error` `#EF4444` |
| `--down-background-color` | **card surface** `#FFFFFF` (dark: `#1B2438`) — never soft-error red fills; down state via border-left + tags only |
| `--tag-color` | `on-primary` `#FFFFFF` |
| `--error-button-*` / `--submit-button-*` | `primary` / `navy` |

Also set `metaTags` `theme-color` to `#3432A6` and `color-scheme` to `light dark`.

## Light / dark architecture

With a custom `themeUrl`, Upptime **does not** auto-load the built-in light.css + dark.css pair. Dual themes are therefore implemented **inside** `assets/devora-status-theme.css`:

1. **Light** tokens on `:root`
2. **Dark** tokens under `@media (prefers-color-scheme: dark)` (respecting `:not([data-theme="light"])`)
3. **Manual override** via `[data-theme="dark"]` / `[data-theme="light"]` (optional `status-website.js` toggle + `localStorage`)

Semantic status colors (green / amber / red / blue) stay the same in both modes so uptime meaning stays recognizable.

## Response-time charts — two pipelines

### A) Chart.js detail charts (`Graph.svelte`)

Live canvas charts are **not** driven by `--up-*` / `--tag-up-*` CSS variables. `@upptime/status-page` `Graph.svelte` reads **root** `.upptimerc.yml` keys (copied into `config.json`):

| Config key | DESIGN token | Purpose |
|------------|--------------|---------|
| `graphBorderColor` | `primary` `#3432A6` | Line stroke (replaces Upptime default `#1abc9c`) |
| `graphBackgroundColor` | `secondary-purple` `#968AB6` | Area fill (replaces `#89e0cf`) |

### B) Live status card sparklines (Graphs CI PNGs) — **no CSS filter**

`LiveStatus.svelte` paints **PNG backgrounds** from Graphs CI on `<article class="graph">`. That element is the **entire Live status card** (background + text + sparkline), not a nested sparkline node.

**Do not** apply `filter:` / `opacity` on `article.graph` (or `section.live-status article`). A hue-rotate meant to recolor teal PNGs toward Devora purple also hue-shifts card surfaces → light cream / dark reddish cards instead of `--card-background-color` (`#FFFFFF` / `#1B2438`).

Brand colors for charts:

| Path | Mechanism |
|------|-----------|
| Chart.js detail graphs | Root `graphBorderColor` / `graphBackgroundColor` (`#3432A6` / `#968AB6`) |
| Graphs CI PNG teal | Accept stock teal on Live cards, **or** regenerate PNGs upstream — **not** via `article.graph { filter }` |

Theme CSS keeps `canvas { filter: none }` so Chart.js canvases are never hue-shifted.

### C) Monitor slug continuity (history / graphs)

Upptime derives site slugs from `sites[].name` unless `slug` is set. Renaming a display name **orphans** `history/<old-slug>.yml` and `graphs/<old-slug>/` and can leave Summary/Graphs with a single sample (diagonal sparkline fill).

**Operator rule:** Never change `sites[].name` without either:

1. Pinning `slug:` to the **historical** slug (preferred for friendly titles), **or**
2. Migrating `history/`, `graphs/`, and any `api/` paths to the new slug.

Do not delete historical assets during UX/CSS commits. Pinned today:

| Display name | Pinned `slug` |
|--------------|---------------|
| AgePass | `age-pass-produksjon` |
| Vipps Logg Inn | `vipps-login-upstream-ikke-age-pass` |

## Favicon / header logo

| Asset | Role |
|-------|------|
| `assets/logo-header.png` | Light-theme nav mark (`logoUrl` + JS light swap) |
| `assets/Logo_symbol_-_Lyse_bakgrunner-source.png` | Source light-bg symbol (uncropped) |
| `assets/favicon.png` | Tab icon **and** dark-theme nav mark (visible on dark nav) |
| `assets/favicon.svg` | Crisp SVG sibling for `rel=icon type=image/svg` |
| `assets/logo-192.png` / `assets/logo-512.png` | PWA / fallback PNG sizes |
| `assets/vipps-logg-inn.png` | Live status icon for **Vipps Logg Inn** (`sites[].icon`) |

Wire via documented Upptime hooks:

```yaml
status-website:
  favicon: https://status.devora.no/favicon.png
  faviconSvg: https://status.devora.no/favicon.svg
  logoUrl: https://status.devora.no/logo-header.png  # light first-paint

sites:
  - name: AgePass
    slug: age-pass-produksjon
  - name: Vipps Logg Inn
    slug: vipps-login-upstream-ikke-age-pass
    icon: https://status.devora.no/vipps-logg-inn.png
```

**Per-site icons:** Upptime `sites[].icon` overrides the DuckDuckGo favicon fallback. Vipps Logg Inn uses the hosted Vipps Login mark in `assets/vipps-logg-inn.png` (copied to site root by Static Site CI).
**Slug pins:** Keep friendly `name` values while pinning `slug` to historical paths (see §C above). Never rename without a pin or migration.
**Theme-dependent nav logo:** Default `logoUrl` stays `logo-header.png` for SSR/first paint. `status-website.js` swaps the header `<img>` to `favicon.png` when dark (`data-theme="dark"` or `prefers-color-scheme: dark` without light override), and back to `logo-header.png` in light. Tab favicon remains `favicon.png` / `faviconSvg` regardless of theme.

Do not leave favicon unset — the status page falls back to the Upptime icon SVG.

## Live status card surfaces

Live status monitor boxes (`section.live-status article`) use the same surface as `article.up` and past-incident cards:

| Mode | Background | Token |
|------|------------|-------|
| Light | `#FFFFFF` | `--card-background-color` / `surface` |
| Dark | `#1B2438` | `--card-background-color` / `surface-dark` / `navy-dark` |

**Token decision:** Operator shorthand `#1b243` / `#1b2432` is **not** used. Dark Live status uses existing DESIGN token `#1B2438` (matches live computed `rgb(27, 36, 56)` for `article.up`). `--down-background-color` is remapped to the card surface, with down indicated by `--down-border-left-color` / tags only.

### Banned fills (not Devora brand)

These hex values must **never** appear in status-page CSS, theme tokens, or Live status / card surfaces — they are **not** part of Devora’s graphical profile:

| Hex | Why banned |
|-----|------------|
| `#3F1D1D` | Non-brand dark soft-error fill (never use) |
| `#FEE2E2` / `#fee2e2` | Non-brand light soft-error fill (never use for status boxes) |

Use `surface` / `surface-dark` (`#FFFFFF` / `#1B2438`) for box backgrounds; communicate down via `error` border/tag tokens only.

Theme CSS:

```css
section.live-status article {
  background-color: var(--card-background-color);
}
```

Mirrored in `status-website.css` for first-publish safety.

## Out of scope

- Undocumented SCSS forks or hand-editing `gh-pages` as the primary fix
- Regenerating Graphs CI PNGs inside `@upptime/graphs` as a required MVP step (prefer root Chart.js keys; never hue-filter whole Live cards)
- UtilitySign monitor activation on this page
- Invented logo URLs outside `assets/` + `status.devora.no`
- Paid Statuspage / Digdir Atlassian subscribe features
