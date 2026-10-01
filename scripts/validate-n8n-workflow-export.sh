#!/usr/bin/env bash
# Validates portable n8n workflow export for S3 (devora-status-slack).
# Run from repo root. No network; no credential values expected in git.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOW="${N8N_WORKFLOW_JSON:-${ROOT}/ops/n8n/workflows/devora-status-slack.json}"
CONFIG_MD="${ROOT}/ops/n8n/CONFIG.md"
README_MD="${ROOT}/ops/n8n/README.md"

fail() {
  echo "validate-n8n-workflow-export: FAIL — $*" >&2
  exit 1
}

pass() {
  echo "validate-n8n-workflow-export: PASS"
  exit 0
}

[[ -f "$WORKFLOW" ]] || fail "missing workflow JSON: $WORKFLOW"
[[ -f "$CONFIG_MD" ]] || fail "missing ops/n8n/CONFIG.md"
[[ -f "$README_MD" ]] || fail "missing ops/n8n/README.md"

# Valid JSON object
if ! python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert isinstance(d, dict)' "$WORKFLOW" 2>/dev/null; then
  fail "workflow is not valid JSON object: $WORKFLOW"
fi

# Required top-level export fields
python3 - "$WORKFLOW" <<'PY' || fail "workflow missing required export fields (name, nodes, connections)"
import json, sys
path = sys.argv[1]
d = json.load(open(path))
for key in ("name", "nodes", "connections"):
    if key not in d:
        raise SystemExit(1)
if not isinstance(d["nodes"], list) or len(d["nodes"]) < 1:
    raise SystemExit(1)
if not isinstance(d["connections"], dict):
    raise SystemExit(1)
if "devora-status-slack" not in str(d.get("name", "")):
    raise SystemExit(1)
PY

# Secret / credential-literal hygiene (no live secrets in git export)
if grep -qE 'hooks\.slack\.com/services/[A-Za-z0-9]' "$WORKFLOW"; then
  fail "possible Slack webhook URL literal in workflow JSON"
fi
if grep -qiE 'github_pat_[A-Za-z0-9_]+|ghp_[A-Za-z0-9]+|gho_[A-Za-z0-9]+' "$WORKFLOW"; then
  fail "possible GitHub PAT literal in workflow JSON"
fi
if grep -qE 'xox[bpas]-[A-Za-z0-9-]+' "$WORKFLOW"; then
  fail "possible Slack bot/user token literal in workflow JSON"
fi
if grep -qiE 'Authorization["'\'']?\s*:\s*["'\'']?Bearer\s+[A-Za-z0-9._\-]{20,}' "$WORKFLOW"; then
  fail "possible Bearer token literal in workflow JSON"
fi
# credentials entries must be id/name placeholders only (no data/password/accessToken values)
python3 - "$WORKFLOW" <<'PY' || fail "credentials must be id/name placeholders only (no secret data fields)"
import json, sys

ALLOWED_CRED_KEYS = {"id", "name"}

def walk(obj, path="$"):
    if isinstance(obj, dict):
        if "credentials" in obj and isinstance(obj["credentials"], dict):
            for ctype, cref in obj["credentials"].items():
                if isinstance(cref, dict):
                    extra = set(cref.keys()) - ALLOWED_CRED_KEYS
                    if extra:
                        raise SystemExit(f"credentials.{ctype} has non-placeholder keys: {sorted(extra)}")
                    if "data" in cref or "password" in cref or "accessToken" in cref:
                        raise SystemExit(f"credentials.{ctype} contains secret-bearing fields")
                elif not isinstance(cref, str):
                    raise SystemExit(f"credentials.{ctype} must be object {{id,name}} or string name")
        for k, v in obj.items():
            walk(v, f"{path}.{k}")
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            walk(v, f"{path}[{i}]")

d = json.load(open(sys.argv[1]))
walk(d)
PY

# Contract: enrichment + dedup + error handling markers in export or companion docs
CONTENT="$(cat "$WORKFLOW" "$CONFIG_MD" "$README_MD")"
echo "$CONTENT" | grep -qiE 'vipps|summary\.json' \
  || fail "missing Vipps/summary enrichment narrative in workflow or docs"
echo "$CONTENT" | grep -qiE 'dedup|fingerprint|idempot' \
  || fail "missing dedup/idempotency contract in workflow or docs"
echo "$CONTENT" | grep -qiE 'error|onError|Error Trigger|catch' \
  || fail "missing failure/error handling contract in workflow or docs"

# CONFIG must document trigger + deploy without secrets
grep -qiE 'trigger|schedule|webhook|cron' "$CONFIG_MD" \
  || fail "CONFIG.md missing trigger documentation"
grep -qiE 'deploy|import' "$CONFIG_MD" \
  || fail "CONFIG.md missing deploy/import steps"
if grep -qE 'hooks\.slack\.com/services/[A-Za-z0-9]' "$CONFIG_MD" "$README_MD"; then
  fail "possible Slack webhook literal in CONFIG.md or README.md"
fi

# README must distinguish export vs deploy status
grep -qiE 'implementert|export|eksport' "$README_MD" \
  || fail "README.md missing export/implementert status"
grep -qiE 'deploy|NOT PROVEN|PROVEN|BLOCKED|approval_needed|hard_blocker' "$README_MD" \
  || fail "README.md missing deploy status wording"

pass
