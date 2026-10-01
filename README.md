# Devora status (`Devora-AS/status`)

Offentlig selskapsstatus på **[https://status.devora.no](https://status.devora.no)** — drevet av [Upptime](https://upptime.js.org) (GitHub Actions, Issues, GitHub Pages).

**Repo:** [Devora-AS/status](https://github.com/Devora-AS/status) er **offentlig** (`PUBLIC`). Privat visibility er valgfritt policyvalg senere — ikke nåværende krav.

## Hva som overvåkes

Konfigurasjon i [`.upptimerc.yml`](./.upptimerc.yml). Detaljert URL-liste: [`docs/monitors.md`](./docs/monitors.md).

| Komponent | Status |
|-----------|--------|
| AgePass prod `/health` | Aktiv |
| Vipps Login `summary.json` | Aktiv (HTTP 200 ≠ komponent-grønn) |
| UtilitySign | **Deferred** — ikke i `.upptimerc.yml` (DNS/reachability NOT PROVEN) |

## Drift

| Dokument | Innhold |
| -------- | ------- |
| [`docs/runbook-status.md`](./docs/runbook-status.md) | Pages (`gh-pages`), secrets, DNS (Quic.cloud), hendelser, Slack, Actions-minutter, residuals |
| [`docs/monitors.md`](./docs/monitors.md) | Monitor-URL-er og forventet respons |
| [`ops/n8n/README.md`](./ops/n8n/README.md) | n8n som **supplement** (beriket Slack) — eksport klar; live deploy **NOT PROVEN** |

## Ops-evidens (S1–S4)

| Slice | Dokument | Kort status |
|-------|----------|-------------|
| S1 cron / Setup CI | [`docs/operations/s1-actions-cron-evidence.md`](./docs/operations/s1-actions-cron-evidence.md) | Uptime CI `schedule` **NOT PROVEN**; Setup CI 409 concurrency **deferred** |
| S2 alert drill | [`docs/operations/s2-alert-drill-plan.md`](./docs/operations/s2-alert-drill-plan.md) + [evidens](./docs/operations/s2-alert-drill-evidence.md) | Live Issue/Slack krever eksplisitt **push GO** |
| S3 n8n Slack | [`ops/n8n/README.md`](./ops/n8n/README.md) + [`ops/n8n/CONFIG.md`](./ops/n8n/CONFIG.md) | Workflow-eksport i repo; import til `n8n.devora.no` **NOT PROVEN** |
| S4 UtilitySign | [`docs/operations/s4-utilitysign-monitor-plan.md`](./docs/operations/s4-utilitysign-monitor-plan.md) + [evidens](./docs/operations/s4-utilitysign-monitor-evidence.md) | Monitor deferred til reachability + push GO |

## Lokal validering

```bash
bash scripts/validate-upptime-config.sh
bash scripts/validate-s1-cron-evidence.sh
bash scripts/validate-s2-alert-drill-evidence.sh
bash scripts/validate-n8n-workflow-export.sh
bash scripts/validate-s4-utilitysign-evidence.sh
```

## Offentlig nettside

Innholdet på `status.devora.no` kommer **kun** fra branch **`gh-pages`** (generert av **Setup CI** / **Static Site CI**). Pages-kilde: **Deploy from a branch → `gh-pages` → `/ (root)`**. Det finnes ingen rot-`index.html` på `main` — en slik fil kan ved feil Pages-kilde eller `pages build and deployment` på `main` overskrive Upptime-siden med en «utfaset»-stub.

## Push og GO

Ingen automatisk push fra agenter. Operatør godkjenner commit/push og DNS separat (se runbook).
