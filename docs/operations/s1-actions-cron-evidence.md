# S1 evidence — Actions cron + Setup CI cancel

**Slice:** `S1-actions-cron`  
**Repo:** `Devora-AS/status`  
**Collected (UTC):** `2026-10-01T10:17:13Z`  
**Collector:** `gh` as `Christian-Devora` (scopes observed: `gist`, `read:org`, `repo`, `user`, `workflow` — token value not recorded)

---

## Observation window

| Field | Value (UTC) |
|-------|-------------|
| Window start | `2026-10-01T08:36:06Z` (bootstrap commit with workflows) |
| Window end | `2026-10-01T10:17:13Z` (this collection) |
| Uptime CI cron on `main` | `*/5 * * * *` (every 5 minutes) |
| Approx. expected schedule ticks since workflow last updated (`2026-10-01T09:32:08Z`) | ~9 five-minute slots by collection time |
| Default branch | `main` |
| Repo Actions enabled | `true` (`allowed_actions=all`) |

---

## Schedule status (Uptime CI)

**Verdict: NOT PROVEN**

No workflow run with `event=schedule` was found for **Uptime CI** (or any workflow) in the observation window.

| Run ID | Workflow | Event | Created (UTC) | Updated (UTC) | Status | Conclusion | Branch |
|--------|----------|-------|---------------|---------------|--------|------------|--------|
| `36844676061` | Uptime CI | `workflow_dispatch` | `2026-10-01T09:44:28Z` | `2026-10-01T09:44:44Z` | completed | success | `main` |

- `gh run list --workflow 'Uptime CI' --event schedule` → empty `[]`
- `gh run list --event schedule --limit 5` → empty `[]`
- Push-triggered Uptime CI runs: none observed
- Manual/dispatch path works: run `36844676061` proves Uptime CI can complete on `main`

Do **not** treat `workflow_dispatch` success as schedule proof.

---

## Diagnosis (why schedule may be missing)

Honest assessment — **no invented schedule runs**:

1. **Cron YAML on default branch** — Present and valid on remote `main`:
   - `on.schedule: - cron: "*/5 * * * *"`
   - Also: `repository_dispatch` / `workflow_dispatch`
2. **Concurrency group** — Setup CI and Uptime CI share:
   - `group: ${{ github.repository }}-${{ github.head_ref || github.ref_name }}-upptime`
   - `cancel-in-progress: false`
   - Stuck Setup CI run `36841669013` remains `status=queued` (~59+ min) and **may** interfere with other `-upptime` group members; however a later Uptime CI `workflow_dispatch` (`36844676061`) **did** complete while Setup stayed queued — so concurrency is a **suspect**, not a sole proof of blockage.
3. **Stuck / zombie queued Setup CI** — See cancel section; API reports `queued` but cancel returns HTTP **409** with message that the re-run has not yet queued. Jobs list empty. This is an anomalous GitHub Actions state.
4. **GitHub schedule delay** — Schedules on newly added/updated workflows can lag (often tens of minutes; occasionally longer under platform load). Workflow file last changed `2026-10-01T09:32:08Z`; by `10:17:13Z` still **zero** schedule events.
5. **Actions permissions** — Repo-level Actions enabled. Org-level permissions API returned **403** (needs `admin:org`) — org policy not fully inspectable from this token; not claimed as cause.
6. **Not started manually for fake schedule proof** — Per slice constraint, no artificial `workflow_dispatch` was used to “fill” schedule evidence.

**Likely next operator actions (outside S1 mutate-unless-GO):** wait for genuine `schedule` event; if still empty after several hours, open GitHub support / check org Actions policies; consider GitHub UI cancel/delete of zombie run `36841669013` if it persists.

---

## Setup CI run `36841669013` (cancel attempt)

| Field | Value |
|-------|-------|
| Repo | `Devora-AS/status` |
| Workflow | Setup CI |
| Event | `workflow_dispatch` |
| Created (UTC) | `2026-10-01T09:16:42Z` |
| Updated (UTC) | `2026-10-01T09:21:22Z` |
| `run_started_at` (UTC) | `2026-10-01T09:21:22Z` |
| Status (before/after cancel attempt) | `queued` |
| Conclusion | empty / `null` |
| Jobs | none returned |
| URL | https://github.com/Devora-AS/status/actions/runs/36841669013 |

### Cancel attempts (no blind retry loop)

1. **CLI:** `gh run cancel 36841669013 --repo Devora-AS/status`  
   - Result: failure message *Cannot cancel a workflow run that is completed* (exit ≠ 0)  
   - Fresh view still: `status=queued`, conclusion empty
2. **REST:** `POST .../actions/runs/36841669013/cancel`  
   - **HTTP 409 Conflict**  
   - Body message: `Cannot cancel a workflow re-run that has not yet queued.`  
   - Fresh status unchanged: `queued` / `conclusion=null`

**Cancel outcome: NOT CANCELABLE via API (HTTP 409).** Documented; stopped further cancel retries per slice rules. Run remains zombie-`queued` as of `2026-10-01T10:17:13Z`.

---

## Auth / target confirmation

| Check | Result |
|-------|--------|
| `gh auth status` | Logged in as `Christian-Devora`; scopes include `repo`, `workflow` |
| Target repo | `Devora-AS/status` (`default_branch=main`, public) |
| Secrets printed | **None** (webhook/PAT values not recorded) |

---

## Commands used (high level)

- `gh auth status`
- `gh repo view Devora-AS/status`
- `gh workflow list --repo Devora-AS/status`
- `gh run list` (Uptime CI; filters `schedule` / `workflow_dispatch` / `push`; repo-wide schedule)
- `gh run view 36841669013`
- `gh run cancel 36841669013` (failed)
- `gh api` cancel endpoint (HTTP 409)
- `gh api repos/.../actions/permissions` (enabled)
- Local: `bash scripts/validate-s1-cron-evidence.sh`, `bash scripts/validate-upptime-config.sh`

---

## Conclusions

| Claim | Status |
|-------|--------|
| Uptime CI can run on `main` (manual) | **PROVEN** (`36844676061`, `workflow_dispatch`, success) |
| Uptime CI has run on `schedule` | **NOT PROVEN** |
| Cron YAML present on default branch | **PROVEN** (remote `uptime.yml`) |
| Setup CI `36841669013` cancelled | **NOT PROVEN** — **BLOCKED** by API HTTP 409; run left in zombie `queued` |
