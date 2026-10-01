# Runbook — Devora status (Upptime)

**Domene:** `https://status.devora.no`  
**Repo:** `Devora-AS/status` — **offentlig** (`PUBLIC`). Privat er valgfritt senere; Pages på private repo krever betalt plan.  
**Stack:** Upptime → GitHub Actions + Issues + GitHub Pages (`gh-pages`)

---

## 0. Driftstatus (ops residuals)

| Tema | Status | Evidens / neste steg |
|------|--------|----------------------|
| Repo visibility | **Offentlig** OK | Ikke private-only som krav |
| Pages | Branch **`gh-pages`** (root) | Setup CI / Static Site CI |
| Monitors | AgePass + Vipps aktiv; UtilitySign **deferred** | [`monitors.md`](./monitors.md) |
| Uptime CI cron (`schedule`) | **NOT PROVEN** | [`operations/s1-actions-cron-evidence.md`](./operations/s1-actions-cron-evidence.md) |
| Setup CI concurrency 409 | **Deferred** | Samme S1-evidens; ikke blind retry |
| Alert drill (Issue + Slack) | Krever **push GO** | [`operations/s2-alert-drill-plan.md`](./operations/s2-alert-drill-plan.md) |
| n8n Slack | Eksport klar; live deploy **NOT PROVEN** | [`ops/n8n/README.md`](../ops/n8n/README.md) |
| UtilitySign monitor | Deferred (reachability NOT PROVEN) | [`operations/s4-utilitysign-monitor-evidence.md`](./operations/s4-utilitysign-monitor-evidence.md) |

---

## 1. Første gangs oppsett (operatør)

1. **Repo** — opprett eller bruk `Devora-AS/status`, push bootstrap fra denne working tree (agent push **ikke** uten GO).
2. **Visibility** — **nåværende:** offentlig. Sett til **Private** kun hvis policy krever det senere; da må org-plan støtte **GitHub Pages på private repos**.
3. **Actions** — aktiver GitHub Actions for repoet.
4. **Secrets** (Settings → Secrets and variables → Actions):

   | Secret | Verdi |
   |--------|--------|
   | `GH_PAT` | **Classic PAT** (anbefalt for Upptime): scopes **`repo`** + **`workflow`** (obligatorisk for Setup CI — uten `workflow` avviser GitHub push av `.github/workflows/*.yml`). **Fine-grained:** Contents *Read and write*, Actions *Read and write*, Workflows *Read and write* på dette repoet. **SSO:** Authorize token for org **Devora-AS**. Roter token ved lekkasje. |
   | `NOTIFICATION_SLACK` | `true` |
   | `NOTIFICATION_SLACK_WEBHOOK_URL` | Incoming Slack webhook URL |
   | `SLACK_WEBHOOK_URL` | *(valgfritt duplikat)* Samme webhook — listet i `.upptimerc.yml` `secrets` for dokumentasjon; Upptime leser primært `NOTIFICATION_*` |

   **Ingen** webhook-URL i git. Roter webhook i Slack ved lekkasje.

5. **Pages** — Settings → Pages: kilde **Deploy from a branch** → branch **`gh-pages`** → mappe **`/ (root)`**. Upptime (peaceiris/actions-gh-pages) publiserer til `gh-pages`, **ikke** via «GitHub Actions»-kilde (da får du «There isn't a GitHub Pages site here» selv med grønn DNS). Etter Setup CI / Static Site CI: verifiser at `gh-pages` har `index.html` + `CNAME`.
6. **Custom domain** — `status.devora.no` i Pages-innstillinger; vent på DNS + HTTPS (se §3).
7. **Første kjøring** — push `.upptimerc.yml` trigger **Setup CI**; deretter **Uptime CI** på cron.

---

## 2. GitHub Actions-minutter

Upptime **Uptime CI** kjører typisk hvert **5. minutt** per monitor ≈ **~8 640** kjøringer/mnd for én workflow, pluss response-time, graphs, summary, updates, setup.

På **offentlig** repo telles ikke Actions-minutter mot private-kvoten på samme måte som private workflows — følg likevel Settings → Billing. Hvis repo senere blir privat:

| Scenario | Konsekvens |
|----------|------------|
| Free org (~2 000 min/mnd) | Sannsynlig **ikke nok** for standard Upptime-frekvens |
| Mitigering | GitHub **Team** / betalt kvote, org billing, ev. self-hosted runner — **ikke** senk sjekkfrekvens eller disable workflows uten eksplisitt operatør-GO |

Dokumenter faktisk forbruk i Settings → Billing etter første uke.

---

## 3. DNS — Quic.cloud (manuelt, ingen API i denne syklusen)

**Mål:** Pek `status.devora.no` til GitHub Pages for `Devora-AS/status`.

1. Logg inn på Quic.cloud (eller der `devora.no` DNS styres).
2. Opprett/oppdater for **status.devora.no**:
   - **CNAME** → `<org>.github.io` **eller** apex A-records per [GitHub Pages custom domain-dok](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site).
3. Hvis GitHub ber om **TXT** for domenebekreftelse — legg til i Quic.cloud.
4. Vent på propagering; verifiser HTTPS i GitHub Pages UI.
5. **Ingen** prod DNS-skriv via agent/API uten eksplisitt GO.

---

## 4. Hendelser og kommunikasjon

| Aktivitet | Hvor |
|-----------|------|
| Automatisk nedetid / gjenoppretting | Upptime oppretter/oppdaterer **GitHub Issues** |
| Offentlig historikk | Status-UI + Issues |
| Manuell hendelse (planlagt vedlikehold, feil utenfor monitor) | Opprett Issue i repo med label/konvensjon operatør velger; oppdater evt. Upptime maintenance via Issues/API per Upptime-dok |
| Slack | Via `NOTIFICATION_SLACK_WEBHOOK_URL` ved statusendring |
| **Alert drill (SIMULERT)** | Kontrollert midlertidig feilmonitor → bevis Issue + Slack → rollback. Se [`operations/s2-alert-drill-plan.md`](./operations/s2-alert-drill-plan.md). Krever eksplisitt **push GO**. Evidens: [`operations/s2-alert-drill-evidence.md`](./operations/s2-alert-drill-evidence.md). Aldri endre AgePass/Vipps-URLer. |

**n8n:** Se [`ops/n8n/README.md`](../ops/n8n/README.md) — workflow-eksport i repo er klar; live import til `n8n.devora.no` er **NOT PROVEN** (`approval_needed` / MCP hard blocker). Beriket Slack (f.eks. Vipps JSON degradert) er **ikke** erstatning for offentlig side.

---

## 5. Monitors

Se [`monitors.md`](./monitors.md). Endre kun [`.upptimerc.yml`](../.upptimerc.yml); Setup CI regenererer workflows ved behov.

- **Aktiv:** AgePass prod `/health`, Vipps `summary.json`
- **Deferred:** UtilitySign — se [`operations/s4-utilitysign-monitor-plan.md`](./operations/s4-utilitysign-monitor-plan.md)

---

## 6. Oppfølging — `status.agepass.*`

Når `status.devora.no` er stabil:

- Planlegg **301 redirect** fra `status.agepass.devora.no` (og evt. andre produkt-subdomener) til `https://status.devora.no`.
- `/health` på produkt-URL-er forblir **monitor-mål**, ikke offentlig selskaps-UI.

---

## 7. Feilsøking (kort)

| Symptom | Sjekk |
|---------|--------|
| Setup CI: `refusing to allow a Personal Access Token to create or update workflow ... without workflow scope` | `GH_PAT` mangler **`workflow`** (classic) eller Workflows *write* (fine-grained). Opprett nytt token, oppdater secret, **Re-run Setup CI**. Se [run #36842751538](https://github.com/Devora-AS/status/actions/runs/36842751538). |
| Setup CI: `Permission denied to github-actions[bot]` | Repo/org **Workflow permissions** var read-only; krever **Read and write** eller gyldig `GH_PAT` på push. |
| Setup CI: `ENOENT ... scandir 'api'|'graphs'|'history'` | **Ikke fatal** før første vellykkede setup; mapper opprettes ved push. Valgfritt: tomme mapper med `.gitkeep` i repo. |
| `There isn't a GitHub Pages site here` på custom domain | Pages-kilde er sannsynlig **GitHub Actions** — bytt til **branch `gh-pages`** (root). DNS kan være grønn uten at workflow-deploy finnes. |
| Pages tom / 404 | Har Setup/Static Site CI deployet til **`gh-pages`**? Sjekk branch i repo. |
| Upptime Issue 422 `Label`/`name`/`invalid` | Site-navn genererer label-slug **> 50 tegn**. Forkort `name` i `.upptimerc.yml` (slug ≤50). Bevist under S2 drill med for langt SIMULERT-navn.
| S2 alert drill (Issue+Slack) | Prosedyre: `docs/operations/s2-alert-drill-plan.md`. Evidens **PROVEN**: `docs/operations/s2-alert-drill-evidence.md` (Issue #2 + Slack `#alerts`).
| «Denne filen er **utfaset**…» / 739-byte `index.html` | GitHub Pages har bygget fra **`main`** (rot-`index.html` skal **ikke** finnes på `main`). Bekreft Pages-kilde = **`gh-pages`** (root). Kjør **Static Site CI** på `main`, vent til **pages build and deployment** (`gh-pages`) er **built**, hard refresh. Sjekk: `curl -sL https://status.devora.no/ \| wc -c` ≈ **7500** (Upptime), ikke **739**. |
| Hvilken branch for manuelle workflows? | **Uptime CI**, **Graphs CI**, **Static Site CI** osv. kjøres på **`main`** — de deployer ikke feil branch; kun **Static Site CI** / **Setup CI** oppdaterer `gh-pages`. |
| Workflows feiler på push | `GH_PAT` scope (`repo` + **`workflow`**); branch protection; SSO authorize |
| Ingen Slack | `NOTIFICATION_SLACK=true` (secret), webhook secret, Issue opprettet? |
| Vipps grønn men innlogging feiler | Forventet — les Vipps JSON; bruk n8n supplement |
| Uptime CI cron (`schedule`) synes død | Bekreft default branch `main`, cron i `.github/workflows/uptime.yml`, Actions enabled. Skill `schedule` vs `workflow_dispatch` i Actions UI/`gh run list --event schedule`. Se [`operations/s1-actions-cron-evidence.md`](./operations/s1-actions-cron-evidence.md). GitHub kan forsinke nye scheduler; manuell dispatch ≠ cron-bevis. Status: **NOT PROVEN**. |
| Setup CI henger i `queued` / cancel HTTP 409 | Delt concurrency-gruppe `…-upptime` (`cancel-in-progress: false`). Ved *Cannot cancel…* / 409: ikke blind retry — hent fersk status; dokumenter. Zombie-queued kan kreve GitHub UI/support. Evidens: run `36841669013` (S1). **Deferred** i ops-hardening. |

---

## 8. Validering lokalt

```bash
bash scripts/validate-upptime-config.sh
bash scripts/validate-s1-cron-evidence.sh
bash scripts/validate-s2-alert-drill-evidence.sh
bash scripts/validate-n8n-workflow-export.sh
bash scripts/validate-s4-utilitysign-evidence.sh
```

Secret-scan (ingen webhook-literal i tracked kode uten docs):

```bash
git grep -E 'hooks\.slack\.com/services/[A-Za-z0-9]' -- . ':!docs/**' ':!specs/**' && exit 1 || exit 0
```
