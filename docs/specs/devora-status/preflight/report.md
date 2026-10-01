# Rapport: status.devora.no (Layer 0 preflight)

**Mottaker:** Operatør / parent  
**Dato:** 2026-09-28  
**Slug:** `devora-status`  
**Type:** Kun planlegging — ingen kode, ingen Phase B (neuroarxiv)

---

## Executive summary

Devora bør bygge **`https://status.devora.no`** som en **selskapsomfattende, gratis/OSS-basert statusside** som er **uavhengig av AgePass Azure**, med **automatiske helsesjekker**, **Slack**, **flere produkter** og synlighet for **tredjepartsavhengigheter**. **Betalt Atlassian Statuspage er ute.** Novelty-gate er **`integrate_and_extend`**: mønstrene finnes allerede (Upptime, Uptime Kuma, Statusnook m.fl.); jobben er integrasjon, DNS og driftsdisiplin — **ikke** forskningseskalering. Phase B kjøres **ikke**.

**Anbefalt primærvei (etter [Devora status OSS landscape](c77c7fe8-43b6-442f-804d-9feb9eb42dde)):** **Uptime Kuma** (MIT) på host utenfor AgePass-Azure — Slack, komponentgrupper, Quic.cloud CNAME, HTTP/JSON Query mot Vipps `…/api/v2/summary.json` + `GET /health` per produkt. **Alternativ A:** **Upptime** hvis «status skal aldri dø med Azure» er hardere enn admin-UX (GitHub SPOF). **E-post-abonnenter på MVP:** vurder Statusnook. Når `status.devora.no` er live: **301** fra `status.agepass.*`; `/health` forblir monitor-mål, ikke offentlig selskaps-UI.

---

## Krav (kort)

| # | Krav |
|---|------|
| R1 | Én merkevare: `status.devora.no` |
| R2 | Overlever AgePass / produkt-FA-outage |
| R3 | Multi-produkt komponenter (AgePass, UtilitySign, …) |
| R4 | Auto health checks (HTTP/JSON) |
| R5 | Slack-varsling |
| R6 | Tredjepart (Vipps, Quickbutik, Azure-plattform) synlig |
| R7 | Gratis / OSS — **ikke** betalt Statuspage |
| R8 | Norsk bokmål som primærspråk |
| R9 | Quic.cloud DNS + TLS for custom domain |

---

## Anbefaling vs alternativer

| Valg | Når | Kost | Risiko |
|------|-----|------|--------|
| **Uptime Kuma** (primær) | Default MVP: Slack, deps-JSON, maintenance | ~$5–12/mnd VPS | Må hostes utenfor produkt-stack |
| **Upptime** (alt.) | Maks uavhengighet av Azure | GitHub | GitHub SPOF; svakere e-post-abonnenter |
| **Statusnook** | E-post-abonnenter er MVP | VPS | Mindre community |
| **OpenStatus** | Trenger multi-region / polish; AGPL OK | Free begrenset / betalt SaaS | Free-tier tynn; AGPL ved self-host |
| **Instatus / Statuspage SaaS** | — | — | **Ekskludert** (betalt; Cursor/Digdir/Vipps er referanse-UX) |
| **Statuspage** | — | — | **Ekskludert** |
| **Utvid AgePass FA-status** | — | — | **Avvist** (ikke uavhengig) |

Detaljer: [`landscape.md`](./landscape.md), [`candidates.json`](./candidates.json), [`oss-comparison.md`](./oss-comparison.md).

---

## Novelty gate

| Felt | Verdi |
|------|--------|
| **gate** | `integrate_and_extend` |
| Phase B | **Ikke kjørt** (gate ≠ `novel_research_required`; eksplisitt operatørinstruks) |
| G2 | Ikke aktuelt |

Neste steg: **`/mat-plan`** for `devora-status` — ikke neuroarxiv.

---

## Åpne beslutninger

1. Uptime Kuma vs Upptime vs Statusnook som primærstack?  
2. Hostingsted hvis ikke GitHub Pages (må være utenfor AgePass FA/RG)?  
3. Auto-rød komponent ved monitor-feil, eller manuell bekreftelse før «Major»?  
4. Vipps/Quickbutik som egne komponenter eller kun i hendelsestekst?  
5. Skal TEST vises offentlig?  
6. Redirect eller notis for `status.agepass.*` når fellesiden er live?

---

## Handoff

- **Planleggingsdybde:** `/mat-plan` (avgrenset)  
- **Relevant:** `[existing] docs/operations/status-page-dns.md`, `[new] docs/operations/status-devora-runbook.md`, `[new]` Upptime-repo eller Kuma-hosting utenfor AgePass  
- **Ikke skriv:** `docs/current-plan.md` uten egen G6 / operatør-GO
