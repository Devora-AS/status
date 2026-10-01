# Statusside for Devora (`status.devora.no`) — OSS/self-hosted

**Kilde:** [Devora status OSS landscape](c77c7fe8-43b6-442f-804d-9feb9eb42dde) · **Dato:** 2026-09-28 · Planlegging only.

**Kontekst:** Multi-produkt (AgePass, UtilitySign, …). Kritisk krav: statussiden må fortsatt være oppe og oppdaterbar når AgePass Azure er nede. **Inspirasjon:** Cursor/Digdir/Vipps = Atlassian Statuspage (offentlig `/api/v2`); DNB = egen SPA (CloudFront). **Betalt Statuspage er avvist** — se [`report.md`](report.md).

---

## Topp 3 OSS for Devora (1–3 ing.)

1. **Uptime Kuma** (MIT) på host **utenfor** AgePass-Azure — raskest MVP: multi-komponent, Slack, custom domain (Quic.cloud CNAME), HTTP/JSON Query mot Vipps `…/api/v2/summary.json` + egne `/health`.
2. **Upptime** — maks uavhengighet (GitHub Pages); svak kunde-abonnent-UX; god som supplement eller «status skal aldri dø med Azure».
3. **Gatus** — GitOps/YAML, sterkest JSONPath mot Statuspage-feeds; svakere incident-portal alene (ev. + cState).

**E-post-abonnenter MVP-kritisk?** Vurder **Statusnook** (MIT, bus factor) eller **OpenStatus** self-host (AGPL — juridisk sjekk).

**Unngå som MVP:** Cachet v3 (proprietær lisens), Statping-ng (stagnasjon), OneUptime CE (tungt).

**Unngå som MVP:** OneUptime/HertzBeat (tungt), Cachet v3 (lisens/utvikling), Grafana public dashboards (anti-pattern for kundestatus).

**Hard regel:** Status-infrastruktur ≠ AgePass Function App / samme ressursgruppe.

---

## Beslutningsramme

| Behov | Valg |
|-------|------|
| **Default (anbefalt)** | Uptime Kuma + isolert host |
| Billig + overlever Azure + minimal UX | Upptime |
| GitOps + tredjeparts-JSON | Gatus (+ ev. cState for kunde-UI) |
| Kunde-e-post + maintenance | Statusnook |
| Nesten Statuspage-UX; AGPL OK | OpenStatus self-host |
| Betalt SaaS | **Ikke i scope** (operatør) |

---

## Sammenligning (kort)

| Løsning | Overlever AgePass Azure? | Kunde-abonnenter | Maintenance | `/health` JSON | Drift 1–3 eng. |
|---------|--------------------------|------------------|-------------|----------------|----------------|
| Upptime | Ja (GitHub) | Nei | Nei | Delvis | Lav |
| Statusnook | Ja (egen VPS) | E-post | Ja | Ja (HTTP/body) | Lav–medium |
| Uptime Kuma | Ja (egen host) | RSS, ikke e-post | Ja | Ja | Lav |
| OpenStatus | Ja (egen host/SaaS) | Ja | Ja | Ja | Medium |
| Gatus | Ja (egen host) | Nei | Nei | Ja (JSONPath) | Lav — bruk bak annen side |
| cState | Ja (CDN) | RSS | Ja (manuell/git) | Nei | Lav |
| Cachet | Ja hvis egen VPS | Ja | Ja | Nei (ekstern monitor) | Medium — v3 risiko |
| OneUptime / HertzBeat | Ja hvis egen host | Delvis | Ja | Ja | Høy |

---

## Tredjeparts-ingest (Vipps, Azure, Statuspage-JSON)

| Kilde | Mønster |
|-------|---------|
| **Vipps** | `https://status.vippsmobilepay.com/api/v2/summary.json` — egen komponent «Vipps Login (tredjepart)»; merk upstream, ikke «AgePass nede» |
| **Andre Statuspage-leverandører** | Samme `/api/v2/*` på deres domene |
| **Azure (AgePass-plattform)** | Service Health → Action Group → **Slack** (internt); offentlig RSS er grov — ikke alene |
| **Egne produkter** | `GET /health` per tjeneste (AgePass API-001, UtilitySign tilsvarende) |

```
/health (AgePass, UtilitySign, …) + Vipps JSON poll
  → Kuma/Gatus/Upptime → status.devora.no + Slack #incidents
```

---

## Når egen static/CMS er dårligere enn OSS/SaaS

- Abonnentflyt (opt-in, SPF/DKIM, bounces)
- Incident-oppdateringer under stress
- Komponentstatus + historikk + vedlikeholdskalender
- Auto-kobling fra `/health` (da bygger du Gatus/Upptime uansett)

---

## Referanser

- [Upptime](https://github.com/upptime/upptime) · [Statusnook](https://statusnook.com) · [Uptime Kuma](https://github.com/louislam/uptime-kuma) · [OpenStatus](https://www.openstatus.dev) · [awesome-status-pages](https://github.com/ivbeg/awesome-status-pages)
