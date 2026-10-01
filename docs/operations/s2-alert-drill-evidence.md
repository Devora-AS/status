# S2 evidence — controlled alert drill (Issue + Slack)

**Slice:** `S2-alert-drill`  
**Repo:** `Devora-AS/status`  
**Collected (UTC):** `2026-10-01T10:23:00Z`  
**Collector:** local builder session (no remote mutate)

---

## Push / remote mutate gate

| Field | Value |
|-------|--------|
| Explicit push GO in builder prompt / chat | **No** |
| Remote `.upptimerc.yml` mutate | **Not executed** |
| Uptime CI dispatch for drill | **Not executed** |
| Stop reason for remote steps | **`approval_needed`** |

Production monitors were left unchanged. Drill site exists only as a documented example in [`s2-alert-drill-plan.md`](./s2-alert-drill-plan.md).

---

## Test design (prepared locally)

| Field | Value |
|-------|--------|
| Monitor name | `DRILL SIMULERT — Devora status varslingstest (ikke produkt)` |
| Test URL (preferred) | `https://httpbingo.org/status/503` |
| Reachability (UTC) | `2026-10-01T10:22:09Z` — `curl -sI` → **HTTP 503** (ok) |
| Alternates also 503 | `https://httpbin.org/status/503`, `https://postman-echo.com/status/503` |
| Rejected candidate | `https://httpstat.us/503` — unreachable in this session (`curl` code `000`) |
| expectedStatusCodes | `[200]` (503 → down) |
| AgePass / Vipps | **Unchanged** in `.upptimerc.yml` |

---

## Channel verdicts

### GitHub Issue

**Issue: NOT PROVEN**

- No temporary drill monitor was pushed to `origin/main`.
- No Uptime CI run was triggered for this drill.
- No drill Issue number/URL collected.
- Stop reason: **`approval_needed`** (push GO required before remote mutate).

### Slack

**Slack: NOT PROVEN**

- Slack was **not** observed for this drill (no down event generated on production path).
- Do **not** infer Slack from Issue (Issue also not proven).
- Webhook URL / secret values: **not printed**.
- When live drill runs after GO: record channel name + UTC receive time only.

---

## Production config hygiene (post-deferred remote)

| Check | Result |
|-------|--------|
| Drill/SIMULERT site in `.upptimerc.yml` | **Absent** (correct for deferred remote) |
| AgePass URL | `https://agepass.devora.no/health` — present, unchanged |
| Vipps URL | `https://status.vippsmobilepay.com/api/v2/summary.json` — present, unchanged |
| Secrets in evidence | None (names only: `NOTIFICATION_SLACK`, `NOTIFICATION_SLACK_WEBHOOK_URL`, `SLACK_WEBHOOK_URL`) |

---

## Rollback status

| Step | Status |
|------|--------|
| Remove drill monitor from remote | **N/A** — never added remotely |
| Re-run Uptime CI after rollback | **N/A** |
| Close/label drill Issue | **N/A** |

When push GO is granted, execute mutate → evidence → rollback per [`s2-alert-drill-plan.md`](./s2-alert-drill-plan.md), then update this file to Issue/Slack **PROVEN** or **BLOCKED** with run IDs.

---

## Local artifacts ready for live drill

| Artifact | Path |
|----------|------|
| Full procedure + rollback | `docs/operations/s2-alert-drill-plan.md` |
| This evidence | `docs/operations/s2-alert-drill-evidence.md` |
| Evidence validator | `scripts/validate-s2-alert-drill-evidence.sh` |
| Runbook pointer | `docs/runbook-status.md` § alert drill |

---

## Commands used (high level)

- Context7 `/upptime/upptime` — downtime Issues + Slack/`NOTIFICATION_*` secrets
- `curl -sI` reachability on candidate 503 URLs
- Inspect `.upptimerc.yml` sites (AgePass + Vipps only)
- `bash scripts/validate-s2-alert-drill-evidence.sh` (RED then GREEN)
- `bash scripts/validate-upptime-config.sh`
- Secret scan pattern for `hooks.slack.com/services/…` (no literals)

---

## Conclusions

| Claim | Status |
|-------|--------|
| Local drill plan + rollback documented | **PROVEN** (plan file) |
| Live GitHub Issue for SIMULERT downtime | **NOT PROVEN** — **`approval_needed`** |
| Live Slack notification for drill | **NOT PROVEN** |
| Production `.upptimerc.yml` free of drill monitor | **PROVEN** |
| AgePass + Vipps URLs unchanged | **PROVEN** |
