# S2 evidence — controlled alert drill

**Slice:** `S2-alert-drill`  
**Updated (UTC):** `2026-10-01T11:45:00Z`  
**Repo:** `Devora-AS/status`

---

## Channel verdicts

| Channel | Verdict | Evidence |
|---------|---------|----------|
| GitHub Issue | **PROVEN** | Issue [#2](https://github.com/Devora-AS/status/issues/2) — `🛑 DRILL SIMULERT status-test is down` (opened ~`2026-10-01T11:40:24Z`, closed after rollback) |
| Slack | **PROVEN** | `#alerts` bot message ~`2026-10-01T11:40:25Z` (CEST 13:40:25): red square + DRILL SIMULERT status-test down + link to Issue #2 |
| Rollback | **PROVEN** | Commit `cc4f93e` removed drill site; remote `.upptimerc.yml` = AgePass + Vipps only |

---

## What worked / what failed

1. **First attempts failed** because Upptime Issue create returned **HTTP 422**: label name `drill-simulert-devora-status-varslingstest-ikke-produkt` **invalid** (GitHub labels max **50** characters). Status still flipped to `down` in history, but **no Issue** and thus weak Slack coupling until fixed.
2. **Fix:** shortened monitor name to `DRILL SIMULERT status-test` (slug `drill-simulert-status-test`, length OK).
3. After rename, Issue #2 + Slack `#alerts` fired on down.
4. Temporary monitor removed; Issue #2 closed with SIMULERT comment.

### Useful run IDs

| Run | Role |
|-----|------|
| `36856594370` | Uptime CI — up→down with long name; log shows 422 label error |
| Setup after short-name push | Created Issue #2 |
| `36857104069` / `36857242268` | Setup + Uptime after rollback |

### Test URL

`https://httpbingo.org/status/503` (curl preflight HTTP 503 OK)

---

## Production monitors after rollback

- AgePass: `https://agepass.devora.no/health`
- Vipps: `https://status.vippsmobilepay.com/api/v2/summary.json`
- No DRILL/SIMULERT site in `.upptimerc.yml`

---

## Operator note (label length)

When adding Upptime sites, keep the **generated slug** (lowercase hyphenated name) **≤ 50 characters**, or GitHub Issue creation fails with `Label name invalid` even though history updates.
