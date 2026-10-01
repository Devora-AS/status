# Execution plan — Devora status (Upptime)

**Tier:** standard (projisert fra `specs/devora-company-status-upptime.md`)  
**Preflight (execution):** `builder_plus_verifier`  
**Slice:** Bootstrap Upptime + dokumentasjon i `Devora-AS/status` (lokal working tree)

---

## Goal

Offentlig selskapsstatus på `status.devora.no` via Upptime (GitHub Actions + Pages), med monitors for AgePass prod og Vipps upstream, norsk UI-tekst, runbooks og n8n-supplement dokumentert — uten produktkode-endringer eller prod DNS i denne syklusen.

---

## Implementation steps

- [x] **1.** Opprett `scripts/validate-upptime-config.sh` (RED først: skal feile til `.upptimerc.yml` er komplett).
- [x] **2.** Legg til `.upptimerc.yml` (`Devora-AS` / `status`, CNAME, norsk `status-website`, sites: AgePass prod health, Vipps summary, UtilitySign disabled/placeholder).
- [x] **3.** Bootstrap `.github/workflows/` fra Upptime-mal (setup, uptime, response-time, graphs, summary, updates — versjon align med `upptime/uptime-monitor` i upstream setup.yml).
- [x] **4.** Legg til `.gitignore` (node/site/cache, `.env`, secrets-mønstre).
- [x] **5.** Fjern eller deprecate rot-`index.html` (README peker til Upptime Pages).
- [x] **6.** Skriv `docs/runbook-status.md` (Pages, private repo, secrets, Quic.cloud DNS-forslag, hendelser via Issues, Slack, follow-up 301 agepass).
- [x] **7.** Skriv `docs/monitors.md` og `ops/n8n/README.md`.
- [x] **8.** Oppdater `README.md` med kort driftsoversikt og lenker.
- [x] **9.** Kjør global validering til grønt; skriv `build-result.md`.

---

## Acceptance criteria (verifier)

- [x] `.upptimerc.yml` valid; sites inkluderer AgePass `/health` + Vipps status JSON.
- [x] Workflows finnes og matcher Upptime private-repo-mønster (GH_PAT dokumentert i runbook).
- [x] Pages + custom domain dokumentert (operatør-trinn selv om DNS ikke er skrudd).
- [x] Ingen secrets i git.
- [x] Runbook beskriver n8n-supplement og grense mot Upptime.
- [x] `build-result.md` Status PASS eller PARTIAL med forklaring.

---

## Verification plan

### Per-phase validation loops (loop until pass)

| Phase | Command | Loop until pass |
|-------|---------|-----------------|
| Config | `bash scripts/validate-upptime-config.sh` | Re-run after config edits until exit 0 |
| Workflows | `test -f .github/workflows/uptime.yml && test -f .github/workflows/setup.yml` | Re-run until both exist |
| Secret scan | `git grep -E 'hooks\.slack\.com/services/[A-Za-z0-9]' -- . ':!docs/**' ':!specs/**' && exit 1 \|\| exit 0` | Re-run until no webhook literals |

### Global validation commands (before handoff)

1. `bash scripts/validate-upptime-config.sh`
2. `git grep -E 'SLACK_WEBHOOK' -- . ':!docs/**' ':!specs/**' ':!ops/**'` (kun `$SLACK_WEBHOOK_URL` referanser, ikke verdier)

Hard gates: `build-result.md` / `verify-result.md`.

---

## Builder notes

- **Ikke** `git push` uten operatør-GO.
- Bruk Context7/Upptime-dok for workflow-versjoner ved bootstrap.
- n8n MCP: kun dokumentasjon/eksport-skjelett; ingen credentials i git.

---

## Amendments

- 2026-09-28T10:06:00Z — parent-orchestrator — Projisert fra `specs/devora-company-status-upptime.md` etter operatør-GO.
