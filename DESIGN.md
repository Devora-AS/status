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
  down-soft: "#FEE2E2"
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

**Status legend** is injected via documented `status-website.customBodyHtml` (classes `.devora-status-legend` / `.status-legend`) and styled in `assets/devora-status-theme.css`. Upptime only has **up / degraded / down** + scheduled maintenance — the five Digdir-inspired rows are labels for visitors, not five live Upptime states:

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
| `--down-background-color` | soft error `#FEE2E2` (dark: `#3F1D1D`) |
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

### B) Live status card sparklines (Graphs CI PNGs)

`LiveStatus.svelte` paints **PNG backgrounds** from Graphs CI on `article.graph`. `@upptime/graphs` hardcodes teal `#1abc9c` / `#89e0cf` — root Chart.js keys do **not** recolor those PNGs.

Stock Upptime `global.css` uses selector `article .graph` (descendant), which does **not** match LiveStatus’s `article.graph`. Theme CSS therefore must:

```css
:root {
  --graph-filter: hue-rotate(72deg) saturate(0.95) brightness(0.92);
  --graph-opacity: 0.95;
}
article.graph {
  filter: var(--graph-filter);
  opacity: var(--graph-opacity);
}
```

Scope the filter to `article.graph` only so Vipps/site icons and Chart.js canvases are not hue-shifted. Theme CSS also forces `canvas { filter: none }` as a safety rail.

## Favicon / header logo

| Asset | Role |
|-------|------|
| `assets/logo-header.png` | Light-background cropped Devora mark for nav (`logoUrl`) |
| `assets/Logo_symbol_-_Lyse_bakgrunner-source.png` | Source light-bg symbol (uncropped) |
| `assets/favicon.png` | Tab icon — **dark-bg** mark (kept for contrast on browser chrome) |
| `assets/favicon.svg` | Crisp SVG sibling for `rel=icon type=image/svg` |
| `assets/logo-192.png` / `assets/logo-512.png` | PWA / fallback PNG sizes |

Wire via documented Upptime hooks:

```yaml
status-website:
  favicon: https://status.devora.no/favicon.png
  faviconSvg: https://status.devora.no/favicon.svg
  logoUrl: https://status.devora.no/logo-header.png
```

Do not leave favicon unset — the status page falls back to the Upptime icon SVG. Header logo and favicon may intentionally differ (light vs dark mark).

## Out of scope

- Undocumented SCSS forks or hand-editing `gh-pages` as the primary fix
- Regenerating Graphs CI PNGs inside `@upptime/graphs` (CSS filter is the supported path)
- UtilitySign monitor activation on this page
- Invented logo URLs outside `assets/` + `status.devora.no`
- Paid Statuspage / Digdir Atlassian subscribe features
