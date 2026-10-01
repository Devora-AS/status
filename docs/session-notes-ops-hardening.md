# Session notes — ops-hardening (pointer list)

**Mission:** `devora-status-ops-hardening`  
**Canonical state:** [`architecture/long-run-state.md`](./architecture/long-run-state.md)  
**Active slice plan:** [`current-plan.md`](./current-plan.md)

## Evidence / ops pointers

| Slice | Paths |
|-------|--------|
| S1 | `operations/s1-actions-cron-evidence.md` |
| S2 | `operations/s2-alert-drill-plan.md`, `operations/s2-alert-drill-evidence.md` |
| S3 | `../ops/n8n/README.md`, `../ops/n8n/CONFIG.md`, `../ops/n8n/workflows/devora-status-slack.json` |
| S4 | `operations/s4-utilitysign-monitor-plan.md`, `operations/s4-utilitysign-monitor-evidence.md` |
| S5 | README + `runbook-status.md` + `monitors.md` sync (this mission) |

## Residuals (mirror of long-run-state)

- S1: schedule NOT PROVEN; Setup CI 409 DEFERRED
- S2: live Issue/Slack NOT PROVEN; push GO for drill
- S3: n8n live import approval_needed / hard_blocker MCP
- S4: UtilitySign DNS/reachability + push GO before activate
