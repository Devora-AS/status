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
  surface: "#FFFFFF"
  on-surface: "#242A56"
  on-surface-muted: "#64748B"
  on-primary: "#FFFFFF"
  success: "#22C55E"
  warning: "#F59E0B"
  error: "#EF4444"
  info: "#3B82F6"
  nav-border: "#E8E6F5"
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
| primary-hover / navy | `#242A56` | Body text / on-surface |
| navy-dark | `#1B2438` | Optional deep navy |
| secondary-purple | `#968AB6` | Soft accent |
| accent-cream | `#FFFADE` | Highlight surfaces (unused by default theme vars) |
| background-page | `#F8F7FF` | Page background |
| surface | `#FFFFFF` | Cards + nav |
| muted | `#64748B` | Secondary copy (CSS may use on-surface for body) |
| success | `#22C55E` | Up |
| warning | `#F59E0B` | Degraded |
| error | `#EF4444` | Down |

## Upptime CSS variable mapping

Custom theme file: `assets/devora-status-theme.css`, published as `https://status.devora.no/devora-status-theme.css` and wired via `status-website.themeUrl` (assets are served as-is). Optional duplicate `:root` overrides via `status-website.css` for first-publish safety.

| Upptime variable | DESIGN token |
|------------------|--------------|
| `--body-background-color` | `background-page` `#F8F7FF` |
| `--body-text-color` | `on-surface` / navy `#242A56` |
| `--card-background-color` | `surface` `#FFFFFF` |
| `--nav-background-color` | `surface` `#FFFFFF` |
| `--nav-border-bottom-color` | `nav-border` `#E8E6F5` |
| `--nav-current-border-bottom-color` | `primary` `#3432A6` |
| `--card-border-color` | `nav-border` `#E8E6F5` |
| `--up-border-left-color` / `--tag-up-background-color` | `success` `#22C55E` |
| `--degraded-border-left-color` / `--tag-degraded-background-color` / `--change-background-color` | `warning` `#F59E0B` |
| `--down-border-left-color` / `--tag-down-background-color` | `error` `#EF4444` |
| `--down-background-color` | soft error `#FEE2E2` |
| `--tag-color` | `on-primary` `#FFFFFF` |
| `--error-button-*` / `--submit-button-*` | `primary` / `navy` |

Also set `metaTags` `theme-color` to `#3432A6`.

## Out of scope

- Undocumented SCSS forks or hand-editing `gh-pages` as the primary fix
- UtilitySign monitor activation on this page
- Invented logo URLs
