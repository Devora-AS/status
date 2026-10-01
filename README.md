# Devora status (`Devora-AS/status`)

Offentlig selskapsstatus på **[https://status.devora.no](https://status.devora.no)** — drevet av [Upptime](https://upptime.js.org) (GitHub Actions, Issues, GitHub Pages).

## Hva som overvåkes

Konfigurasjon i [`.upptimerc.yml`](./.upptimerc.yml). Detaljert URL-liste: [`docs/monitors.md`](./docs/monitors.md).

## Drift

| Dokument | Innhold |
|----------|---------|
| [`docs/runbook-status.md`](./docs/runbook-status.md) | Pages, private repo, secrets, DNS (Quic.cloud), hendelser, Slack, Actions-minutter |
| [`ops/n8n/README.md`](./ops/n8n/README.md) | n8n som **supplement** (beriket Slack) — ikke offentlig status-UI |

## Lokal validering

```bash
bash scripts/validate-upptime-config.sh
```

## Merk om `index.html`

Rot-`index.html` er en **utfaset placeholder**. Etter første vellykkede GitHub Pages-deploy erstatter Upptime-generert innhold under `site/` den offentlige siden på `status.devora.no`.

## Push og GO

Ingen automatisk push fra agenter. Operatør godkjenner commit/push og DNS separat (se runbook).
