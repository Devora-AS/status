# Preflight landscape — devora-status

**Generated:** 2026-09-28 · **Mode:** Pre-build strategy (company-wide surface; AgePass has product-local `/health` + `/status-page` only) · **Phase B:** not run (gate only)

## Evidence status

| Source | What was inspected | Limits |
|--------|-------------------|--------|
| Local | `docs/operations/status-page-dns.md`, prior verify notes for `GET /health` + `GET /status-page`, existing drafts under `specs/devora-status/preflight/` | No dependency install, no deploy, no live DNS changes |
| External (official / primary) | Upptime README (GitHub), Uptime Kuma README, OpenStatus product/pricing page, Statusnook site, Instatus `pricing.md`, Cachet v3 docs (license/maturity), Microsoft Learn (Functions health check / Service Health) | Pricing and plan limits observed 2026-09-28; confirm before commit |
| UX references | [status.cursor.com](https://status.cursor.com/), [status.digdir.no](https://status.digdir.no/), [www.dnbstatus.no](https://www.dnbstatus.no/) | Pattern inspiration only — not stack selection |
| G3 community | **Off** (default) — no X/Reddit/YouTube | — |
| Research cache | `specs/_research-cache/` — no hit for this topic | `cache_hit: false` |

## Project frame

| Field | Value |
|-------|-------|
| **Goal** | Company-wide public status at `https://status.devora.no` covering multiple Devora products |
| **Users** | Customers, partners, internal on-call; Norwegian bokmål primary |
| **Must** | Multi-product components; automated health checks against product `/health` (and peers); Slack alerts; third-party dependency visibility (Vipps, Quickbutik, Azure platform); **no paid Atlassian Statuspage** |
| **Prefer** | Free / OSS (or free SaaS tier) over paid status SaaS |
| **Hard constraint** | Status surface must stay up and updatable when AgePass Azure / product Function Apps are down |
| **Out of scope (MVP)** | Per-merchant components; replacing Azure Service Health for Microsoft’s own platform; paid Statuspage |
| **Operating mode** | Pre-build for company page; mid-build awareness that AgePass already ships product-coupled status HTML on the same Function App |

## Comparables and references

Not ranked by stars. Fit against independence, free/OSS, auto-checks, Slack, multi-product, custom domain.

### Direct / free–OSS

| Comparable | Relevance | Transfers | Do not copy |
|------------|-----------|-----------|-------------|
| **Upptime** ([github.com/upptime/upptime](https://github.com/upptime/upptime), MIT) | direct | Zero product-Azure dependency (GitHub Actions + Pages); HTTP checks; auto Issues as incidents; Slack webhooks; custom domain via Pages/CNAME | GitHub as SPOF; weak e-mail subscriber UX; 5‑min min interval; Issue-centric incident UX for non-engineers |
| **Uptime Kuma** ([github.com/louislam/uptime-kuma](https://github.com/louislam/uptime-kuma), MIT) | direct | Docker self-host; rich monitors (HTTP/JSON/body); 90+ notifications incl. Slack; public status page; maintenance windows; groups/tags for multi-product | Must host **outside** AgePass Azure; e-mail subscribers not first-class (RSS/status URL more common); single-region probe unless multi-instance |
| **OpenStatus** ([openstatus.dev](https://www.openstatus.dev/), AGPL-3.0 + managed) | adjacent | Monitor → status auto-update; subscribers; Slack; Terraform/API; multi-region SaaS **or** self-host | Free SaaS tier is thin (1 monitor / 10m / limited components — confirm live pricing); AGPL if self-hosting; paid cloud from ~$30/mo if free insufficient |
| **Statusnook** ([statusnook.com](https://statusnook.com), MIT) | adjacent | Self-host with monitors + incidents + maintenance + e-mail subscribers; Docker/install scripts; custom domain + auto HTTPS | Smaller community / bus factor; ops on a non-Azure VPS still required |
| **Gatus** ([github.com/TwiN/gatus](https://github.com/TwiN/gatus), Apache-2.0) | lighter | Excellent JSONPath `/health` checks; YAML-as-code; Slack | Not a full customer incident/comms product alone — pair with a status front if needed |
| **cState** | lighter | Static Hugo status site on CDN — max independence | No auto-health; manual/git incident workflow |

### Heavier / avoid for MVP

| Comparable | Why not primary |
|------------|-----------------|
| **OneUptime** | Full observability stack; high ops burden |
| **Cachet v3** | Still in development; custom/source-available license friction ([docs.cachethq.io](https://docs.cachethq.io/v3.x/introduction)) — not a clean “just ship” OSS MVP |
| **Statping-ng** | Maintenance risk (stale pushes / open issues reported in 2026 roundups) |

### Paid SaaS (baseline / contrast — **Statuspage out**)

| Comparable | Role in this preflight |
|------------|------------------------|
| **Atlassian Statuspage** | Explicitly **excluded** (operator: no paid Statuspage). Free tier lacks custom domain — unfit for `status.devora.no` anyway |
| **Instatus** | Free Starter: page + monitors + Slack, **no custom domain**; Pro ~$20/mo unlocks domain ([instatus.com/pricing.md](https://instatus.com/pricing.md), observed 2026-09-28). Only escalate if OSS path fails G6 readiness |
| **Better Stack** | Uptime + status bundle; costs escalate with responders — not free-first |

### Local anti-pattern (inspect)

AgePass `status.agepass*.devora.no` CNAMEs to the **same** Function Apps as the product (`docs/operations/status-page-dns.md`). `/health` JSON is an excellent **monitor target**; the HTML status host is **not** an independent company status plane.

## Cost and vendor reality

| Scenario | Likely cost | Notes |
|----------|-------------|-------|
| **Prototype** | $0 software + existing GitHub Org **or** ~$5–12/mo small VPS (Hetzner/DigitalOcean/etc.) outside Azure product RG | Upptime ≈ $0; Kuma/Statusnook ≈ VPS only |
| **Launch** | Same + Quic.cloud CNAME for `status.devora.no` + TLS (Pages ACME or Caddy/Traefik on VPS) | Custom domain is free on GitHub Pages / self-host; Instatus free **cannot** attach `status.devora.no` |
| **Growth** | Ops time (patching, incident discipline) >> license; optional OpenStatus paid or Instatus Pro if subscriber e-mail + polish become blockers | Watch GitHub Actions minutes; VPS disk/backups; Slack webhook hygiene |

**Buckets to verify before commit:** GitHub Actions minutes; VPS backup; e-mail deliverability (SPF/DKIM) if Statusnook subscribers; AGPL counsel if OpenStatus self-host; DPA only if choosing EU SaaS later.

## Recommendation summary

**Primary path — integrate & extend known OSS:**

1. **Default A (max Azure independence, min ops):** **Upptime** on a dedicated GitHub repo → Pages at `status.devora.no`; monitors for AgePass/UtilitySign `/health` + critical third-party HTTP surfaces; Slack via Upptime notifications; component groups via Upptime site config.
2. **Default B (richer admin + maintenance + JSON checks):** **Uptime Kuma** on a **non-Azure / non-product** VPS (or SWA-adjacent only if truly failure-isolated — prefer other cloud/VPS); public status page; Slack; groups per product; optional Statusnook if e-mail subscribers are MVP-critical.

**Credible alternative:** OpenStatus self-host (AGPL) or OpenStatus free→paid only if multi-region probes + subscriber polish outweigh free constraint. **Do not** adopt paid Statuspage. **Do not** host company status on `fa-agepass*`.

**Failure conditions:**

- Status host shares fate with AgePass FA / same RG → constraint violated.
- Auto-red without human gate floods false positives to customers.
- Upptime-only and stakeholders need polished e-mail subscriber + maintenance calendar → escalate to Kuma/Statusnook or low-cost non-Statuspage SaaS.
- Treating Azure Service Health / App Insights dashboards as the public page.

**Ordered next actions:**

1. Operator picks Upptime vs Kuma(+optional Statusnook) in Open Decisions.
2. `/mat-plan` for slug `devora-status` with component taxonomy + DNS runbook + Slack wiring (no neuroarxiv).
3. Keep AgePass `/health` as probe target; plan redirect/notice for `status.agepass.*` after company page is live.

## Handoff to /mat-plan

- **Suggested depth:** `/mat-plan` (bounded greenfield for company status; not full onboarding package unless multi-repo).
- **Novelty gate:** `integrate_and_extend` — see `novelty-gate.json`. **Phase B / neuroarxiv: do not run.**
- **Open Decisions:** listed in `report.md` and gate file.
- **Relevant Files (hints):**
  - `[existing] docs/operations/status-page-dns.md`
  - `[existing] specs/devora-status/preflight/*` (this package)
  - `[new] docs/operations/status-devora-runbook.md` (incident + DNS for company page)
  - `[new]` Upptime repo **or** compose/hosting manifest for Kuma/Statusnook (outside AgePass FA)
  - `[existing]` AgePass `/health` / status-page handlers (monitor targets only — do not extend as company plane)
