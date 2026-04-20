#!/usr/bin/env bash

set -euo pipefail

REPOSITORY="${1:-UnBArqDsw2026-1-Turma01/2026.1-T01-_G7_MonitoreSeuTreino_Entrega_02}"

main_sha="$(gh api "repos/${REPOSITORY}/git/ref/heads/main" --jq '.object.sha')"

if ! gh api "repos/${REPOSITORY}/git/ref/heads/dev" >/dev/null 2>&1; then
  gh api --method POST "repos/${REPOSITORY}/git/refs" \
    -f ref='refs/heads/dev' \
    -f sha="$main_sha" >/dev/null
fi

tmp_main="$(mktemp)"
tmp_dev="$(mktemp)"
trap 'rm -f "$tmp_main" "$tmp_dev"' EXIT

cat >"$tmp_main" <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Main PR source policy",
      "Version history check"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": false,
  "lock_branch": false,
  "allow_fork_syncing": true
}
EOF

cat >"$tmp_dev" <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Version history check"
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": false,
  "lock_branch": false,
  "allow_fork_syncing": true
}
EOF

gh api --method PUT \
  -H "Accept: application/vnd.github+json" \
  "repos/${REPOSITORY}/branches/main/protection" \
  --input "$tmp_main" >/dev/null

gh api --method PUT \
  -H "Accept: application/vnd.github+json" \
  "repos/${REPOSITORY}/branches/dev/protection" \
  --input "$tmp_dev" >/dev/null

echo "Protecoes aplicadas em main e dev para ${REPOSITORY}."
