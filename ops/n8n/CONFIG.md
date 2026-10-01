# n8n CONFIG — `devora-status-slack`

Konfigurasjonskontrakt for den portable eksporterte workflowen. **Ingen hemmelige verdier** i dette dokumentet eller i git-eksporten.

## Workflow

| Felt | Verdi |
|------|--------|
| Navn | `devora-status-slack` |
| Eksport | [`workflows/devora-status-slack.json`](./workflows/devora-status-slack.json) |
| Rolle | Supplement til Upptime — beriket Slack ved Vipps `summary.json`-degradering |
| Offentlig UI | **Ikke** n8n — bruk `https://status.devora.no` |

## Trigger

| Type | Standard | Merknad |
|------|----------|---------|
| **Schedule Trigger** | hvert **5. minutt** | Primær trigger i eksporten |
| Valgfri webhook | ikke i eksport | Kan legges til lokalt (GitHub Issue / Upptime) uten å committe webhook-URL |

Endre intervall i n8n UI etter import ved behov. Ikke hardkod cron-hemmeligheter.

## Credentials (kun navn / id-placeholder)

Opprett i n8n credential store (ikke i git):

| Credential type | Placeholder name i eksport | Bruk |
|-----------------|----------------------------|------|
| `slackApi` | **Devora Slack (n8n)** | `Post Slack Enrichment` |
| id | `PLACEHOLDER_SLACK_CRED_ID` | Bytt til lokal credential-id ved import |

Vipps HTTP-kall er **uten** auth (offentlig `summary.json`).

## Environment variables (valgfritt)

| Navn | Formål | Eksempel (ikke hemmelighet) |
|------|--------|------------------------------|
| `DEVORA_STATUS_SLACK_CHANNEL` | Slack-kanalnavn | `devora-status` |

Sett i n8n env / host — ikke i workflow JSON som hemmelighet.

## Deduplisering / idempotens

- Fingerprint: `vipps::<indicator>::<description>::<degradedComponents…>`
- Lagring: workflow `staticData` (`lastFingerprint`, `lastPostedAtMs`)
- Cooldown: **30 minutter** for samme fingerprint
- Skip når Vipps er `none`/`operational`, eller når fingerprint er duplikat innen cooldown

Utvid senere med GitHub Issue-nummer + status-fingerprint hvis webhook-trigger legges til.

## Feilhåndtering

- `Fetch Vipps Summary` og `Post Slack Enrichment`: `onError: continueErrorOutput`
- Feilgren → node **Handle Fetch Or Slack Error** (logg/strukturert payload; ingen offentlig status-side)
- Workflow starter **inactive** (`active: false`) — aktiver først etter credential-mapping og test

## Deploy / import (manuell)

Live deploy til `n8n.devora.no` krever operatørtilgang. MCP/API kan være **BLOCKED**.

1. Åpne n8n UI (operatør).
2. **Import** → velg `ops/n8n/workflows/devora-status-slack.json`.
3. Map credential **Devora Slack (n8n)** til eksisterende Slack OAuth/token credential.
4. Sett `DEVORA_STATUS_SLACK_CHANNEL` om kanalnavnet avviker.
5. **Test** manuelt (Execute workflow) med sunn Vipps-respons → forvent skip.
6. (Valgfritt) midlertidig force-alert i Code-node kun lokalt — **ikke** commit.
7. Aktiver workflow når test er OK.
8. Dokumenter deploy-utfallet i PR/commit-notat: `PROVEN` / `NOT PROVEN` / `BLOCKED`.

## Test steps (lokal / staging)

1. `bash scripts/validate-n8n-workflow-export.sh` → exit 0
2. `bash scripts/validate-upptime-config.sh` → exit 0
3. Secret scan: ingen `hooks.slack.com/services/…` i eksport
4. Etter import: manuelt kjør → skip ved operational; feilgren ved simulert HTTP-feil

## Live deploy status (S3)

| Felt | Status |
|------|--------|
| Repo-eksport | implementert |
| Live deploy `n8n.devora.no` | **NOT PROVEN** — `hard_blocker` (n8n MCP `namespaceStatus=error`; `mcp_auth` utilgjengelig for builder-subagent) + `approval_needed` for manuell import/aktivering |
