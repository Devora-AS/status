# Runbook — Devora status (Upptime)

**Domene:** `https://status.devora.no`  
**Repo:** `Devora-AS/status` (forventet **private**)  
**Stack:** Upptime → GitHub Actions + Issues + GitHub Pages

---

## 1. Første gangs oppsett (operatør)

1. **Repo** — opprett eller bruk `Devora-AS/status`, push bootstrap fra denne working tree (agent push **ikke** uten GO).
2. **Visibility** — sett repo til **Private** hvis policy krever det; verifiser at org-plan støtter **GitHub Pages på private repos**.
3. **Actions** — aktiver GitHub Actions for repoet.
4. **Secrets** (Settings → Secrets and variables → Actions):

   | Secret | Verdi |
   |--------|--------|
   | `GH_PAT` | Personal Access Token med `repo`, `workflow`, og Pages-skrivetilgang (nødvendig for workflow-commits og noen private-repo-mønstre) |
   | `NOTIFICATION_SLACK` | `true` |
   | `NOTIFICATION_SLACK_WEBHOOK_URL` | Incoming Slack webhook URL |
   | `SLACK_WEBHOOK_URL` | *(valgfritt duplikat)* Samme webhook — listet i `.upptimerc.yml` `secrets` for dokumentasjon; Upptime leser primært `NOTIFICATION_*` |

   **Ingen** webhook-URL i git. Roter webhook i Slack ved lekkasje.

5. **Pages** — Settings → Pages: kilde **GitHub Actions** (etter første `site.yml`-kjøring) eller branch/`site` per Upptime-dok etter Setup CI.
6. **Custom domain** — `status.devora.no` i Pages-innstillinger; vent på DNS + HTTPS (se §3).
7. **Første kjøring** — push `.upptimerc.yml` trigger **Setup CI**; deretter **Uptime CI** på cron.

---

## 2. GitHub Actions-minutter (private repo)

Upptime **Uptime CI** kjører typisk hvert **5. minutt** per monitor ≈ **~8 640** kjøringer/mnd for én workflow, pluss response-time, graphs, summary, updates, setup.

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

**n8n:** Se [`ops/n8n/README.md`](../ops/n8n/README.md) — beriket Slack (f.eks. Vipps JSON degradert), **ikke** erstatning for offentlig side.

---

## 5. Monitors

Se [`monitors.md`](./monitors.md). Endre kun [`.upptimerc.yml`](../.upptimerc.yml); Setup CI regenererer workflows ved behov.

---

## 6. Oppfølging — `status.agepass.*`

Når `status.devora.no` er stabil:

- Planlegg **301 redirect** fra `status.agepass.devora.no` (og evt. andre produkt-subdomener) til `https://status.devora.no`.
- `/health` på produkt-URL-er forblir **monitor-mål**, ikke offentlig selskaps-UI.

---

## 7. Feilsøking (kort)

| Symptom | Sjekk |
|---------|--------|
| Pages tom / 404 | Har `Site CI` kjørt? Er `site/` committet av Actions? |
| Workflows feiler på push | `GH_PAT` scope; branch protection |
| Ingen Slack | `NOTIFICATION_SLACK=true`, webhook secret, Issue opprettet? |
| Vipps grønn men innlogging feiler | Forventet — les Vipps JSON; bruk n8n supplement |

---

## 8. Validering lokalt

```bash
bash scripts/validate-upptime-config.sh
```

Secret-scan (ingen webhook-literal i tracked kode uten docs):

```bash
git grep -E 'hooks\.slack\.com/services/[A-Za-z0-9]' -- . ':!docs/**' ':!specs/**' && exit 1 || exit 0
```
