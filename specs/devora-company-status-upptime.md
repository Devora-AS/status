# Devora selskapsstatus — Upptime på status.devora.no

**Preflight classification:** `ready_for_execution_handoff`  
**Task type:** `feature`  
**Complexity:** `medium`  
**Operatør-beslutning (2026-09-28):** Upptime + GitHub Pages; repo `Devora-AS/status`; n8n som supplement; ingen produktkode-endringer i denne syklusen.

---

## Task Description

Implementere selskapsomfattende offentlig driftsstatus på **https://status.devora.no** med **Upptime** (GitHub Actions, Issues, GitHub Pages) i repoet **Devora-AS/status**. Erstatte/integrere dagens statiske `index.html` med Upptime-struktur. Dokumentere DNS (Quic.cloud → Pages), secrets, monitorliste og n8n-supplement for beriket Slack — uten at n8n erstatter offentlig status-UI.

---

## Objective

Kunder og partnere får én uavhengig statusflate (ikke hostet på AgePass Function Apps) med automatiske HTTP-sjekker mot produkt-`/health` og tredjepartsstatus (Vipps), norsk bokmål, og operatør-runbook for hendelser, secrets og oppfølging.

---

## Scope

**In scope (denne syklusen):**

- `.upptimerc.yml` med `owner: Devora-AS`, `repo: status`, `status-website.cname: status.devora.no`, norsk intro, komponentnavn gruppert logisk (AgePass, UtilitySign, Tredjepart).
- GitHub Actions workflows fra Upptime-mal (generert/vedlikeholdt via `update-template`; ikke manuelt redigere workflow-innhold utover første bootstrap).
- Dokumentasjon: `docs/runbook-status.md`, `docs/monitors.md`, `ops/n8n/README.md` (grense mot Upptime).
- Fjerne eller erstatte placeholder `index.html` i tråd med Upptime Pages-deploy.
- Validering lokalt (YAML, ingen secrets i git, workflow-filer tilstede).

**Operator manual (dokumentert, ikke automatisk i slice):**

- Quic.cloud DNS for `status.devora.no` (CNAME/A per GitHub Pages + ev. TXT for domenebekreftelse).
- GitHub repo visibility → **private** (merk: `gh repo view` kan vise annen tilstand — synk med operatør).
- GitHub Secrets: `SLACK_WEBHOOK_URL`, ev. `GH_PAT` for Pages/workflow-skriving.
- GitHub Pages aktivert for repo + custom domain.

**n8n (dokumentasjon + ev. eksportert workflow-skjelett uten hemmeligheter):**

- Vurdere «Downtime Monitor» (inaktiv) vs nytt `devora-status-slack`.
- Beriket varsling (f.eks. Vipps degradert → mulig innvirkning på AgePass-innlogging).

---

## Assumptions

- Devora GitHub-org har eller vil skaffe plan som støtter **GitHub Pages på private repos** og tilstrekkelig **Actions-minutter** (se Risks).
- `GET https://agepass.devora.no/health` returnerer HTTP 200 med JSON der `status` er `healthy` når OK (body-validering er nice-to-have; HTTP 200 er MVP).
- Vipps status-URL `https://status.vippsmobilepay.com/api/v2/summary.json` er offentlig og returnerer 200 når tjenesten er nåbar.
- UtilitySign prod-`/health`-URL er **ukjent** i preflight — placeholder i `docs/monitors.md` til URL er bekreftet.
- AgePass **test** (`agepass-test.devora.no`) vises **ikke** på offentlig status i MVP (reduserer støy og eksponering).
- Quic.cloud DNS API (`QC_API_EMAIL` / `QC_API_KEY`) er tilgjengelig for operatør; ingen prod DNS-endring uten eksplisitt GO.

---

## Non-Goals

- Endre AgePass, UtilitySign eller Azure Function Apps.
- Betalt Statuspage/Instatus eller Uptime Kuma som primærstack i denne syklusen.
- 301 fra `status.agepass.*` (kun follow-up i runbook).
- Prod n8n credential-rotasjon.
- E-post-abonnenter som MVP-krav (Upptime-svakhet — dokumenter alternativ senere).

---

## Problem Statement

Produktkoblede statussider på samme Azure-stack som AgePass oppfyller ikke kravet om uavhengig selskapsstatus. Devora trenger lavkost, OSS-basert overvåking med offentlig side, Slack-varsling og synlighet for tredjepartsavhengigheter — uten å hoste status på produkt-RG.

---

## Solution Approach

1. **Bootstrap Upptime** i `Devora-AS/status`: `.upptimerc.yml` som eneste konfigurasjonskilde; workflows fra Upptime `update-template` (push til `.upptimerc.yml` trigger Setup CI).
2. **Monitors (MVP):**
   - AgePass prod: `https://agepass.devora.no/health` (GET, `expectedStatusCode: 200`).
   - Vipps: `https://status.vippsmobilepay.com/api/v2/summary.json` — komponent «Vipps Login (upstream)»; nedetid her betyr **ik** automatisk «AgePass nede».
   - UtilitySign: `disabled: true` eller kommentert placeholder til URL finnes.
3. **Status-UI:** Norsk bokmål via `status-website.introTitle` / `introMessage` / `name`.
4. **Varsling:** `notifications` med Slack og `$SLACK_WEBHOOK_URL` (secret); n8n dokumentert som supplement for kontekst.
5. **Private repo:** Dokumenter GH_PAT, Pages-innstillinger, minuttforbruk og mitigering.
6. **DNS-runbook:** GitHub Pages CNAME `status.devora.no` → `<org>.github.io` eller apex A-records per GitHub-dok; Quic.cloud steg med record-forslag (uten å kjøre write uten GO).

---

## Relevant Files / Areas

- [existing] `index.html` — erstattes av Upptime-generert site etter første Pages-deploy
- [new] `.upptimerc.yml` — hovedkonfigurasjon
- [new] `.github/workflows/*.yml` — Upptime-genererte workflows
- [new] `.gitignore` — utelukk genererte artefakter/secrets-mønstre
- [new] `docs/runbook-status.md` — DNS, secrets, hendelser, Slack
- [new] `docs/monitors.md` — URL-liste og forventet respons
- [new] `ops/n8n/README.md` — supplement og «Downtime Monitor»
- [new] `docs/current-plan.md` — projisert execution plan
- [existing] `docs/specs/devora-status/preflight/report.md` — kravbakgrunn
- [existing] `docs/specs/devora-status/preflight/landscape.md` — Upptime vs Kuma

---

## Task Traceability

| Oppgave | Krav / beslutning |
|--------|-------------------|
| `.upptimerc.yml` + AgePass/Vipps monitors | R4 auto health; R3 multi-produkt; operatør låst Upptime |
| Norsk status-website tekst | R8 bokmål |
| Slack via notifications + secret | R5 Slack |
| Vipps summary JSON monitor | R6 tredjepart |
| Runbook DNS Quic.cloud + Pages | R9 DNS; operator manual step |
| n8n README | Supplement; ikke offentlig UI |
| Private repo + Actions-dok | Obligatoriske planpunkter 1–3 |
| GitHub SPOF i Risks | Obligatorisk punkt 4 |
| Ingen produkt-repo endringer | Operatør non-goal |

---

## Testing Strategy

Manuelt etter push: GitHub Actions enabled, første workflow-kjøring, Pages custom domain (operatør). Automatisert i repo: YAML-lint/validering, script som sjekker at påkrevde filer finnes og at ingen webhook-URLer ligger i tracked files.

Edge cases: Vipps JSON 200 men degraded innhold (kun n8n/operatør-tolkning); AgePass health 200 med feil body (dokumenter fremtidig JSON-sjekk); private repo uten Pages-plan (fail ved deploy — dokumentert).

TDD for denne slice: **begrenset** — infrastruktur/YAML; builder skriver **først** en liten valideringsscript/test (f.eks. `scripts/validate-upptime-config.sh`) som feiler før config finnes, deretter implementerer config til grønt.

### Per-phase validation loops (loop until pass)

| Phase | Command | Loop until pass |
|-------|---------|-----------------|
| Config | `bash scripts/validate-upptime-config.sh` | Re-run after `.upptimerc.yml` edits until exit 0 |
| Secrets hygiene | `rg -n 'hooks\.slack\.com\|xox[baprs]-' --glob '!*.md' . && exit 1 \|\| true` | Re-run until no matches in non-doc files |
| Workflows present | `test -f .github/workflows/uptime.yml && test -f .github/workflows/setup.yml` | Re-run until both exist |

### Global validation commands (before handoff)

1. `bash scripts/validate-upptime-config.sh`
2. `git grep -E 'SLACK_WEBHOOK|xox[baprs]-' -- ':!docs/**' ':!ops/**'` (forvent ingen treff med faktiske verdier)

Hard orchestration gates remain `build-result.md` / `verify-result.md`; in-plan loops are SOP for builders.

---

## Acceptance Criteria

- [ ] `.upptimerc.yml` er gyldig YAML med `owner: Devora-AS`, `repo: status`, `status-website.cname: status.devora.no`, og `sites` inkluderer AgePass prod `/health` og Vipps summary JSON.
- [ ] `.github/workflows/` inneholder Upptime uptime/setup (og relaterte) workflows kompatible med standard Upptime-mal.
- [ ] `docs/runbook-status.md` beskriver Pages, custom domain, secrets, manuelle hendelser, Slack og n8n-grense.
- [ ] `docs/monitors.md` lister URL-er og forventet respons; UtilitySign merket som åpen beslutning.
- [ ] Ingen hemmeligheter i git; Slack referert som `$SLACK_WEBHOOK_URL` / GitHub Secret.
- [ ] `scripts/validate-upptime-config.sh` finnes og passerer på repo-tilstand.

---

## Risks and Open Questions

| Risk / spørsmål | Mitigering / notat |
|-----------------|-------------------|
| **GitHub Actions-minutter (private repo)** | Upptime ~5 min cron ≈ **~8 640** uptime-kjøringer/mnd + øvrige workflows (graphs, response time, setup). Free org **2 000 min/mnd** er sannsynlig **ikke nok**. Mitigering: GitHub **Team**/høyere kvote, org-billing, workflow-optimalisering kun med operatør-GO, ev. self-hosted runner — **ikke** senke sjekkfrekvens uten GO. |
| **Pages på private repo** | Krever GitHub-plan som støtter private Pages; custom domain + HTTPS i repo-innstillinger. |
| **GitHub SPOF** | Akseptert av operatør; dokumenter at Actions/Issues/Pages-utfall blokkerer oppdateringer. |
| **Repo visibility** | Operatør ønsker private; verifiser mot GitHub. |
| **UtilitySign URL** | Open Decision — monitor disabled til URL bekreftes. |
| **AgePass TEST offentlig** | MVP: **nei** (dokumentert). |
| **JSON body på /health** | MVP HTTP 200; utvid med Gatus-lignende sjekk senere hvis Upptime tillater. |
| **GH_PAT** | Kan være nødvendig for workflow commits og Pages fra private repo — secret, ikke i git. |

---

## Amendments

- 2026-09-28T10:05:00Z — parent-orchestrator — Initial plan fra operatør-GO via `/mat-plan-team`; stack låst til Upptime.
- 2026-10-01T10:34:00Z — builder (S5-docs-cleanup) — Living ops claim: `Devora-AS/status` er **offentlig** (`PUBLIC`); privat visibility er valgfritt senere, ikke nåværende krav. Pages-kilde forblir branch **`gh-pages`**. Aktive monitorer: AgePass + Vipps; UtilitySign deferred. n8n: eksport klar / live deploy NOT PROVEN. S1 cron NOT PROVEN; Setup CI 409 deferred; S2 drill krever push GO. Se README, `docs/runbook-status.md`, `docs/monitors.md`.

---

## Recommended Next Command

Projiser denne planen til `docs/current-plan.md` (standard execution template), fullfør `[mao:plan]`, deretter builder med eksplisitte filstier.

```txt
/mat-plan-team (fortsett) — Task subagent_type=builder med docs/current-plan.md
```
