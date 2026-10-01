# n8n — supplement til Upptime (ikke offentlig status)

Upptime på `status.devora.no` er **kanonisk offentlig UI** og primær uptime/hendelseslogg (GitHub Issues). n8n brukes kun som **supplement** for beriket Slack og intern logikk — ikke som erstatning for statussiden.

## Eksisterende vs ny workflow

| Workflow | Rolle | Anbefaling |
|----------|--------|------------|
| **Downtime Monitor** (inaktiv i prod?) | Generisk nedetidsvarsling | Vurder **deaktiverert** eller avviklet for Devora-selskapsstatus — overlapp med Upptime |
| **`devora-status-slack`** (ny / planlagt) | Beriket varsling | F.eks. Vipps `summary.json` degradert → Slack med kontekst «mulig innvirkning på AgePass-innlogging» |

## Grenser

- **Ikke** eksponer n8n-URL eller workflow som offentlig status.
- **Ikke** lagre webhook-URL, API-nøkler eller credentials i dette git-repoet.
- Roter hemmeligheter i n8n credential store; dokumenter kun **navn** og **flyt** her.

## Typisk flyt (skisse)

1. Upptime oppretter/oppdaterer GitHub Issue ved nedetid (AgePass eller Vipps HTTP-sjekk).
2. Valgfritt: n8n lytter på Slack, GitHub webhook, eller periodisk poll av Vipps JSON for **innhold** (ikke bare HTTP 200).
3. n8n poster beriket melding til Devora Slack-kanal — uten å endre Upptime-status-UI.

## Eksport

Ved implementering: eksporter workflow JSON **uten** credentials til `ops/n8n/workflows/` (egen commit, operatør-GO). Denne syklusen inneholder kun README.
