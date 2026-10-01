# S4 evidence — UtilitySign monitor decision

**Slice:** `S4-utilitysign`  
**Repo (status):** `Devora-AS/status`  
**Source repo:** `Devora-AS/Devora-UtilitySign` (default branch `main`)  
**Collected (UTC):** `2026-10-01T10:32:00Z`  
**Collector:** `gh` + local `curl`/`dig` (no secrets recorded)

---

## Decision

**Verdict: NOT PROVEN** (deferred plan — do **not** activate monitor)

Documented candidate exists in UtilitySign source, but authoritative prod GET health was **not** proven reachable with curl. `.upptimerc.yml` left without UtilitySign URL. Live monitor on `status.devora.no`: **NOT PROVEN** / stop reason **`approval_needed`** until reachability + push GO.

---

## Search method

| Step | Tool / command | Result |
|------|----------------|--------|
| 1 | `gh api repos/Devora-AS/Devora-UtilitySign` | `default_branch=main`, homepage null |
| 2 | `gh search code --repo Devora-AS/Devora-UtilitySign "health"` | Controllers, AGENTS, monitoring docs |
| 3 | `gh api …/HealthController.cs` | Routes `/api/health`, `/api/health/health`, `/api/health/startup`, `/api/health/version` |
| 4 | `gh api …/backend/AGENTS.md` + `docs/monitoring/README.md` | Prod host `api.utilitysign.devora.no`; Azure probe `/health/ready` |
| 5 | `gh search code … "utilitysign.devora"` / `"devora.no"` | Prod API + admin hosts documented |
| 6 | Optional org/other-repo search | **Skipped** — UtilitySign repo had sufficient path/host evidence |

Org docs outside UtilitySign were not required for candidate discovery (step 2 of plan).

---

## Documented candidate (code + docs — not live-proven)

| Field | Value | Source |
|-------|--------|--------|
| Prod API host | `api.utilitysign.devora.no` | `docs/monitoring/README.md`, DNS docs, `frontend` apiConfig |
| Preferred Upptime liveness URL | `GET https://api.utilitysign.devora.no/api/health` | `HealthController.HealthDirect` → `{ status: "healthy" }` HTTP 200 |
| Compat liveness | `GET …/api/health/health` | Same controller |
| Azure readiness (heavier) | `GET …/health/ready` | AGENTS.md / monitoring README — dependency checks; **not** chosen for MVP Upptime (prefer simple 200 like AgePass) |
| Azure App Service CNAME target | `devora-utilitysign-api.azurewebsites.net` | DNS docs / dig CNAME |

Do **not** invent alternate hosts. Staging (`api-staging…`) is out of scope for public status.

---

## Curl / DNS reachability observation

| Check | Observation |
|-------|-------------|
| `curl` `https://api.utilitysign.devora.no/api/health` | `http_code=000`, curl exit **6** — Could not resolve host |
| `curl` `…/api/health/health`, `…/health/ready`, `…/health/live`, `…/health` | Same resolve failure (`http_code=000`) |
| `dig @8.8.8.8 api.utilitysign.devora.no A` | **CNAME** → `devora-utilitysign-api.azurewebsites.net.` (no A at apex of query) |
| `dig @8.8.8.8 devora-utilitysign-api.azurewebsites.net A/AAAA` | **Empty answer** — Azure hostname has no public A/AAAA |
| Local resolver (`nslookup` / system DNS) | **NXDOMAIN** for both custom domain and azurewebsites target |
| Control: `curl` AgePass `/health` from same host | Also `http_code=000` (local DNS/network degraded) — **does not** override empty Azure A/AAAA from public resolvers |

**Conclusion:** Prod health URL is documented but **not** curl-proven reachable. Activating Upptime would risk a permanent red/false incident. Deferred per slice rules.

---

## Config / docs outcome

| Artifact | Action |
|----------|--------|
| `.upptimerc.yml` | **Unchanged** — no speculative UtilitySign `url` |
| `docs/monitors.md` | Updated to **NOT PROVEN** / deferred |
| `docs/operations/s4-utilitysign-monitor-plan.md` | Deferred activation plan + missing fields + future YAML (docs comments only) |
| `scripts/validate-s4-utilitysign-evidence.sh` | Evidence contract validator |
| Live `status.devora.no` UtilitySign row | **NOT PROVEN** — requires reachability proof + operator **push GO** + Setup/Uptime path |

---

## Stop reasons

- Reachability: **NOT PROVEN**
- Remote activate / push: **`approval_needed`**
