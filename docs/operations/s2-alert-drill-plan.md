# S2 alert drill plan — controlled Upptime Issue + Slack

**Slice:** `S2-alert-drill`  
**Repo:** `Devora-AS/status`  
**Status page:** `https://status.devora.no`  
**Risk:** moderate — temporary failing monitor on production Upptime path; must be **SIMULERT**-marked and rolled back.

---

## Purpose

Prove that when a monitored site goes **down**, Upptime:

1. Creates / updates a **GitHub Issue** (incident) whose title includes the site name.
2. Sends a **Slack** notification via the same production secrets (`NOTIFICATION_SLACK` / `NOTIFICATION_SLACK_WEBHOOK_URL`).

Then **restore green** state: remove the drill monitor, re-run Uptime CI, close/label the Issue as drill-only. Do **not** change AgePass or Vipps monitor URLs.

---

## Preconditions

| Check | Requirement |
|-------|-------------|
| Push GO | Explicit operator **push GO** in chat before mutating remote `.upptimerc.yml` on `main` |
| Secrets (names only) | `NOTIFICATION_SLACK=true`, `NOTIFICATION_SLACK_WEBHOOK_URL` set in repo Actions secrets; optional `SLACK_WEBHOOK_URL` duplicate |
| Production monitors | AgePass + Vipps rows **unchanged** for the whole drill |
| Naming | Test site name must match `DRILL` **or** `SIMULERT` (validator enforces) |
| Local validators | `bash scripts/validate-upptime-config.sh` and `bash scripts/validate-s2-alert-drill-evidence.sh` exit 0 after evidence update |
| Concurrency | Zombie Setup CI / shared `-upptime` group may delay Uptime CI — document queued runs; do not invent Issue/Slack proof |

**If push GO is missing:** stop all remote mutate steps. Complete this plan, example patch, evidence file with Issue/Slack **NOT PROVEN** and stop reason **`approval_needed`**. Leave production `.upptimerc.yml` unchanged.

---

## Test monitor (SIMULERT)

| Field | Value |
|-------|--------|
| **Name (required)** | `DRILL SIMULERT — Devora status varslingstest (ikke produkt)` |
| **URL** | Isolated non-200 endpoint (preferred after reachability check). Candidate: `https://httpbingo.org/status/503` (or other public 503). **Never** AgePass / Vipps / UtilitySign |
| **expectedStatusCodes** | `[200]` so HTTP 503 → **down** |
| **Issue expectation** | Upptime auto-title includes site name → contains `DRILL` / `SIMULERT` |
| **Slack expectation** | Message from Upptime down template (e.g. site name + down); record channel + UTC time; **never** paste webhook URL |

### Example YAML fragment (docs only — do not leave committed on `main` without rollback path)

```yaml
  # TEMPORARY — S2 alert drill — REMOVE after drill (SIMULERT)
  - name: DRILL SIMULERT — Devora status varslingstest (ikke produkt)
    url: https://httpbingo.org/status/503
    expectedStatusCodes:
      - 200
```

Insert under `sites:` in `.upptimerc.yml` **only after push GO**, after AgePass and Vipps entries (order does not matter for correctness; keep AgePass/Vipps URLs byte-identical).

### Reachability preflight (operator / agent before push)

```bash
curl -sI --max-time 15 -o /dev/null -w "%{http_code}\n" "https://httpbingo.org/status/503"
# Expect: 503
```

If the chosen URL is unreachable, pick another public status endpoint that returns non-200 and update this plan + evidence before push. Do not fall back to product URLs.

---

## Procedure (remote — requires push GO)

### A. Prepare

1. Confirm this plan is reviewed; confirm push GO in chat.
2. Re-run reachability curl on the chosen URL.
3. Snapshot current remote monitors (AgePass + Vipps URLs) for rollback comparison.
4. Note: Upptime creates a GitHub Issue when a site transitions **up → down**, and notifies Slack via secrets in Uptime CI `SECRETS_CONTEXT` (names: `NOTIFICATION_SLACK`, `NOTIFICATION_SLACK_WEBHOOK_URL`, `SLACK_WEBHOOK_URL`).

### B. Mutate + dispatch

1. Add the temporary site block to `.upptimerc.yml` (exact name above).
2. Commit on `main` with message that includes `SIMULERT` / `DRILL` (only if commit+push GO).
3. `git push origin main` (**only with push GO**).
4. Trigger **Uptime CI** on `main`:  
   `gh workflow run "Uptime CI" --repo Devora-AS/status --ref main`
5. Wait for run completion. If stuck `queued`, check Setup CI / concurrency group; document run ID; do not claim Slack/Issue without evidence.
6. Collect:
   - Uptime CI **run ID** + conclusion + UTC times
   - GitHub Issue number/URL whose title contains `DRILL` or `SIMULERT`
   - Slack: received yes/no/unknown, channel name, UTC timestamp — **no webhook**

### C. Rollback (mandatory same session if mutate ran)

1. Remove the temporary site block from `.upptimerc.yml`.
2. Confirm AgePass URL still `https://agepass.devora.no/health` and Vipps URL still `https://status.vippsmobilepay.com/api/v2/summary.json`.
3. Commit + push rollback (same GO rules).
4. Re-run **Uptime CI** on `main`; confirm drill site gone from summary/history (or no longer failing).
5. Close the drill Issue **or** label/comment that it was **SIMULERT / DRILL** only — not a customer outage.
6. Confirm no permanent failing monitor remains in `.upptimerc.yml`.
7. Update `docs/operations/s2-alert-drill-evidence.md` to **PROVEN** / **NOT PROVEN** / **BLOCKED** per channel.

### D. Deferred remote (no push GO)

1. Do **not** edit committed `.upptimerc.yml` production monitors.
2. Keep example fragment in this plan only.
3. Evidence: Issue **NOT PROVEN**, Slack **NOT PROVEN**, stop reason **`approval_needed`**.
4. When GO arrives: execute A→C in a follow-up session; re-validate evidence file.

---

## Success criteria

| Criterion | Pass condition |
|-----------|----------------|
| Issue channel | Live Issue **PROVEN** with `DRILL`/`SIMULERT` in title, **or** remote **NOT PROVEN** + `approval_needed` with full local prep |
| Slack channel | Explicit **PROVEN** / **NOT PROVEN** / **BLOCKED** (never inferred from Issue alone) |
| Rollback | No drill monitor left in production `.upptimerc.yml`; AgePass + Vipps URLs unchanged |
| Hygiene | No secrets in git; validators exit 0 |
| Customer clarity | Drill Issue closed or clearly marked SIMULERT; status page not left red for drill after rollback |

---

## Rollback checklist (quick)

- [ ] Temporary site removed from `.upptimerc.yml`
- [ ] AgePass + Vipps URLs unchanged
- [ ] Push of rollback (if mutate was pushed)
- [ ] Uptime CI re-run after rollback
- [ ] Drill Issue closed or labeled SIMULERT
- [ ] Evidence file updated
- [ ] `bash scripts/validate-upptime-config.sh`
- [ ] `bash scripts/validate-s2-alert-drill-evidence.sh`

---

## Risks

| Risk | Mitigation |
|------|------------|
| Public status page briefly shows drill as down | Short window; obvious SIMULERT name; rollback ASAP |
| Slack noise / false alarm | Announce drill in channel beforehand if possible; SIMULERT in name |
| Uptime CI delayed by zombie Setup CI concurrency | Document; wait or use GitHub UI; do not fake evidence |
| Wrong URL / product impact | Hard forbid AgePass/Vipps/UtilitySign; curl preflight |
| Leaving failing monitor on `main` | Prefer docs-only example until GO; never leave failing monitor without rollback commit ready |

---

## Out of scope

n8n enrichment (S3), UtilitySign (S4), docs cleanup (S5), changing notification secret values.
