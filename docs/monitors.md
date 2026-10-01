# Monitors — status.devora.no

Kilde for sannhet i Upptime: [`.upptimerc.yml`](../.upptimerc.yml). Denne filen er operatørreferanse for URL-er og forventet respons.

## AgePass

| Felt | Verdi |
|------|--------|
| **Komponent** | AgePass (produksjon) |
| **URL** | `GET https://agepass.devora.no/health` |
| **Forventet HTTP** | `200` |
| **Body (MVP)** | JSON med `status: healthy` når OK — **ikke** validert av Upptime i MVP; kun statuskode |
| **Ikke på offentlig status** | `agepass-test.devora.no` (test) — med vilje utelatt for å redusere støy |

## Tredjepart — Vipps

| Felt | Verdi |
|------|--------|
| **Komponent** | Vipps Login (upstream — ikke AgePass) |
| **URL** | `GET https://status.vippsmobilepay.com/api/v2/summary.json` |
| **Forventet HTTP** | `200` |
| **Tolkning** | JSON kan vise degradert komponent selv ved HTTP 200. **Rød Vipps-rad betyr ikke at AgePass er nede.** Bruk n8n/runbook for beriket Slack om innvirkning på innlogging. |

## UtilitySign

| Felt | Verdi |
|------|--------|
| **Status** | **Åpen beslutning** — ingen monitor i `.upptimerc.yml` ennå |
| **Årsak** | Prod `GET /health`-URL er ikke bekreftet i preflight |
| **Plan** | Legg til i `.upptimerc.yml` når URL er verifisert; alternativt `disabled: true` i config når Upptime støtter det for placeholder |

Eksempel (kommentert — **ikke aktiv**):

```yaml
# - name: UtilitySign (produksjon)
#   url: https://TBD.utilitysign.devora.no/health
#   expectedStatusCodes:
#     - 200
```

## Fremtidige utvidinger

- JSON body-sjekk på AgePass `/health` (når operatør godkjenner)
- Quickbutik / Azure-plattform som egne rader eller kun i hendelsestekst (preflight åpne spørsmål)
