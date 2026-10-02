# Monitors — status.devora.no

Kilde for sannhet i Upptime: [`.upptimerc.yml`](../.upptimerc.yml). Denne filen er operatørreferanse for URL-er og forventet respons.

**Aktiv på status.devora.no:** AgePass + Vipps. **UtilitySign:** deferred (se under). Ops-evidens: [S1 cron](operations/s1-actions-cron-evidence.md), [S2 drill](operations/s2-alert-drill-plan.md), [S4 UtilitySign](operations/s4-utilitysign-monitor-evidence.md); n8n: [`ops/n8n/README.md`](../ops/n8n/README.md).

### Kontinuitet: `name` vs `slug`

Upptime lager filstier under `history/` og `graphs/` fra **slug**. Uten eksplisitt `slug:` utledes slug fra `name`. **Endre aldri monitor-`name` uten å pinne `slug:` til historisk verdi, eller migrere `history/` + `graphs/` (+ `api/` om relevant).** UX/CSS-commits skal ikke slette historikk.

## AgePass

| Felt | Verdi |
|------|--------|
| **Komponent** | AgePass |
| **Slug (fast)** | `age-pass-produksjon` — pinnet i `.upptimerc.yml` slik at vennlig `name` ikke orphaner `history/` / `graphs/` |
| **URL** | `GET https://agepass.devora.no/health` |
| **Forventet HTTP** | `200` |
| **Body (MVP)** | JSON med `status: healthy` når OK — **ikke** validert av Upptime i MVP; kun statuskode |
| **Ikke på offentlig status** | `agepass-test.devora.no` (test) — med vilje utelatt for å redusere støy |

## Tredjepart — Vipps

| Felt | Verdi |
|------|--------|
| **Komponent** | Vipps Logg Inn |
| **Slug (fast)** | `vipps-login-upstream-ikke-age-pass` — historisk slug pinnet; ikke la rename til `vipps-logg-inn` orphanere historikk |
| **Ikon** | `https://status.devora.no/vipps-logg-inn.png` (`assets/vipps-logg-inn.png`) |
| **URL** | `GET https://status.vippsmobilepay.com/api/v2/summary.json` |
| **Forventet HTTP** | `200` |
| **Tolkning** | JSON kan vise degradert komponent selv ved HTTP 200. **Rød Vipps-rad betyr ikke at AgePass er nede.** Bruk n8n/runbook for beriket Slack om innvirkning på innlogging. |

## UtilitySign

| Felt | Verdi |
|------|--------|
| **Status** | **NOT PROVEN** / deferred — ingen monitor i `.upptimerc.yml` |
| **Kandidat-URL (kildekode/docs)** | `GET https://api.utilitysign.devora.no/api/health` |
| **Forventet HTTP (når aktiv)** | `200` (liveness; body `status: healthy` — ikke validert av Upptime i MVP) |
| **Årsak ikke aktiv** | Curl/DNS: custom domain CNAME finnes, men Azure-mål `devora-utilitysign-api.azurewebsites.net` har ingen offentlig A/AAAA; curl `http_code=000` / resolve-feil |
| **Plan** | [`docs/operations/s4-utilitysign-monitor-plan.md`](operations/s4-utilitysign-monitor-plan.md) + evidens [`s4-utilitysign-monitor-evidence.md`](operations/s4-utilitysign-monitor-evidence.md) |
| **Live status.devora.no** | **NOT PROVEN** — krever reachability + operator push GO |

Eksempel (kommentert i docs — **ikke** aktiv i `.upptimerc.yml`):

```yaml
# - name: UtilitySign (produksjon)
#   url: https://api.utilitysign.devora.no/api/health
#   expectedStatusCodes:
#     - 200
```

## Fremtidige utvidinger

- JSON body-sjekk på AgePass `/health` (når operatør godkjenner)
- Quickbutik / Azure-plattform som egne rader eller kun i hendelsestekst (preflight åpne spørsmål)
