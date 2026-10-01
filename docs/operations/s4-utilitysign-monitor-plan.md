# S4 plan — UtilitySign monitor (deferred / not operative)

**Slice:** `S4-utilitysign`  
**Status:** **NOT PROVEN** — do not activate until missing fields below are satisfied  
**Evidence:** [`s4-utilitysign-monitor-evidence.md`](s4-utilitysign-monitor-evidence.md)  
**Status page:** `https://status.devora.no`

---

## Purpose

Activate a production UtilitySign row in Upptime (same pattern as AgePass) **only** when an authoritative prod health URL is curl-proven reachable. Until then keep `.upptimerc.yml` free of speculative URLs (no invalid `disabled:` placeholder syntax).

---

## Exact missing information (required before activate)

| # | Missing field | Why required | How to obtain |
|---|---------------|--------------|---------------|
| 1 | **Reachable prod health URL** | Upptime needs HTTP 200 (or agreed codes) from a stable public endpoint | Operator/infra: restore Azure App Service DNS for `devora-utilitysign-api.azurewebsites.net` **or** update CNAME for `api.utilitysign.devora.no` to a live target; then prove with curl |
| 2 | **HTTP proof** | Slice gate: curl `-sI`/`-sf` must show expected status (200 for liveness) | `curl -sI --max-time 15 -o /dev/null -w "%{http_code}\n" "https://api.utilitysign.devora.no/api/health"` → expect `200` |
| 3 | **Operator push GO** | Remote `.upptimerc.yml` + Setup CI / Uptime path mutates production status | Explicit GO in chat after local config change |
| 4 | **Confirm liveness vs readiness** | Prefer simple liveness (`/api/health`) like AgePass; avoid `/health/ready` unless operator wants dependency-aware public reds | Product/ops confirmation if readiness preferred |

**Candidate URL (documented in UtilitySign — not live-proven):**  
`https://api.utilitysign.devora.no/api/health`

Do **not** guess alternate hosts. Do **not** monitor staging (`api-staging.utilitysign.devora.no`).

---

## Preconditions (when unblocking)

| Check | Requirement |
|-------|-------------|
| Evidence refresh | Re-run curl; update `s4-utilitysign-monitor-evidence.md` to **PROVEN activate** with UTC timestamp |
| Validators | `bash scripts/validate-upptime-config.sh` and `bash scripts/validate-s4-utilitysign-evidence.sh` exit 0 |
| Config | Add site below to `.upptimerc.yml` under `sites:` (after AgePass/Vipps) |
| validate-upptime-config | Extend script to require UtilitySign URL **only after** activate |
| Push | Operator **push GO**; then Setup CI / Uptime as per runbook — live monitor **NOT PROVEN** until then |

---

## Minimal future YAML (docs only — not in `.upptimerc.yml` until proven)

```yaml
# FUTURE — S4 UtilitySign — activate only after curl 200 on this URL + push GO
# - name: UtilitySign (produksjon)
#   url: https://api.utilitysign.devora.no/api/health
#   expectedStatusCodes:
#     - 200
```

---

## Rollback / hygiene

- If a speculative URL was ever added without proof: remove the UtilitySign site block; re-run `validate-upptime-config.sh`.
- Never leave a permanent failing UtilitySign row to “discover” DNS — that creates false public incidents.
- No secrets in plan/evidence; webhook names only if referenced elsewhere.

---

## Out of scope (this deferred plan)

S2 live drill, S3 n8n import, S5 docs cleanup, inventing hosts, monitoring admin SPA (`admin.utilitysign.devora.no`) as API health.
