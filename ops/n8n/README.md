# n8n — supplement til Upptime (ikke offentlig status)

Upptime på `status.devora.no` er **kanonisk offentlig UI** og primær uptime/hendelseslogg (GitHub Issues). n8n brukes kun som **supplement** for beriket Slack og intern logikk — ikke som erstatning for statussiden.

## Status: eksport vs deploy

| Lag | Status |
|-----|--------|
| **Repo-eksport** | **Implementert** — [`workflows/devora-status-slack.json`](./workflows/devora-status-slack.json) + [`CONFIG.md`](./CONFIG.md) |
| **Live deploy** (`n8n.devora.no`) | **NOT PROVEN** — se CONFIG (MCP error → `hard_blocker` / `approval_needed` for manuell import) |

Validator: `bash scripts/validate-n8n-workflow-export.sh`

## Eksisterende vs ny workflow

| Workflow | Rolle | Anbefaling |
|----------|--------|------------|
| **Downtime Monitor** (inaktiv i prod?) | Generisk nedetidsvarsling | Vurder **deaktiverert** eller avviklet for Devora-selskapsstatus — overlapp med Upptime |
| **`devora-status-slack`** (eksport i repo) | Beriket varsling | Vipps `summary.json` degradert → Slack med kontekst «mulig innvirkning på AgePass-innlogging» |

## Grenser

- **Ikke** eksponer n8n-URL eller workflow som offentlig status.
- **Ikke** lagre webhook-URL, API-nøkler eller credentials i dette git-repoet.
- Roter hemmeligheter i n8n credential store; dokumenter kun **navn** og **flyt** her (se CONFIG).

## Typisk flyt

1. Upptime oppretter/oppdaterer GitHub Issue ved nedetid (AgePass eller Vipps HTTP-sjekk).
2. n8n **Schedule Trigger** (5 min) henter Vipps `summary.json` for **innhold** (ikke bare HTTP 200).
3. Code-node bygger fingerprint, deduplisering (staticData + 30 min cooldown), og AgePass-innloggingshint.
4. Ved ny degradering: Slack-melding til Devora-kanal — uten å endre Upptime-status-UI.
5. HTTP/Slack-feil går til error-path node (`onError: continueErrorOutput`).

## Eksport

Portable workflow JSON **uten** credentials (kun `id`/`name`-placeholders):

- [`workflows/devora-status-slack.json`](./workflows/devora-status-slack.json)
- Import/deploy-steg: [`CONFIG.md`](./CONFIG.md)

Aktiver ikke i prod før credential-mapping og manuell test. Live deploy er operatørstyrt når MCP/API ikke er tilgjengelig.
