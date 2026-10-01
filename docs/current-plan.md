# Execution plan — S6 final verification

**Mission:** `devora-status-ops-hardening`  
**Slice ID:** `S6-final-verify`  
**Tier:** standard  
**Preflight:** `builder_plus_verifier`

---

## Goal

Kjør sluttverifikasjon: alle lokale validators, YAML/workflows tilstede, n8n-JSON gyldig, dokumentlenker, git-diff hygiene, secret-redaction; bekreft **ingen** midlertidig DRILL-monitor i `.upptimerc.yml`; produser `docs/operations/s6-final-verification.md` med matrise mot de seks opprinnelige anbefalingene (utført / bevist / blokkert / utsatt). Forbered innhold til `docs/session-summary.md` (parent skriver final summary after verify PASS).

---

## Implementation steps

- [x] **1.** Re-run all validators: upptime-config, s1, s2, n8n, s4; `bash -n` scripts; python JSON load n8n workflow.
- [x] **2.** Confirm `.upptimerc.yml` sites = AgePass + Vipps only (no DRILL/SIMULERT/UtilitySign).
- [x] **3.** Live optional: `curl` status.devora.no size/__SAPPER__; `gh run list --event schedule` (expect still empty or note if PROVEN now).
- [x] **4.** Write `docs/operations/s6-final-verification.md` with honesty matrix + residual list.
- [x] **5.** (TDD) `scripts/validate-s6-final-verification.sh` for evidence contract — RED→GREEN.
- [x] **6.** Draft bullet list for session-summary (parent may finalize after verify).
- [x] **7.** `build-result.md` — Status PASS if local gates green even with known NOT PROVEN residuals documented; PARTIAL only if something local broken.

---

## Acceptance criteria

- [x] All listed validators exit 0.
- [x] No drill/UtilitySign active in `.upptimerc.yml`.
- [x] S6 evidence file exists with recommendation matrix + residual honesty labels.
- [x] Secret scan clean.
- [x] Live cron/Issue/Slack/n8n/UtilitySign not falsely marked PROVEN.

---

## Verification plan

Re-run same validators; spot-check s6 evidence file.

---

## Builder notes

- Do not push. Do not execute live drill or activate UtilitySign.
- Re-check schedule once for possible new evidence (update label if found).

---

## Amendments

- 2026-10-01T10:37:00Z — parent — S6 plan after S5 gate continue.
