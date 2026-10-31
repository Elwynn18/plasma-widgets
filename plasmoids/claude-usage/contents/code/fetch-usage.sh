#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Prints the Claude plan usage (5-hour session and weekly limits) as JSON:
#   {"plan": "max", "usage": { ...response of /api/oauth/usage... }}
# or, on failure:
#   {"error": "<code>", "status": <http status or 0>}
#
# It reuses the sign-in of Claude Code (~/.claude/.credentials.json).
# The access token is never printed and is passed to curl through stdin,
# so it does not show up in the process list.
#
# Usage: fetch-usage.sh [credentials-file]

set -uo pipefail

USAGE_URL="https://api.anthropic.com/api/oauth/usage"
creds="${1:-}"
[[ -n "$creds" ]] || creds="$HOME/.claude/.credentials.json"
creds="${creds/#\~/$HOME}"

fail() {
    printf '{"error":"%s","status":%s}\n' "$1" "${2:-0}"
    exit 0
}

command -v curl >/dev/null || fail missing_curl
[[ -r "$creds" ]] || fail no_credentials

# Prints 3 lines: access token, expiry (ms since epoch), subscription type.
read_creds() {
    if command -v jq >/dev/null; then
        jq -r '.claudeAiOauth // {} | (.accessToken // ""), (.expiresAt // 0), (.subscriptionType // "")' "$creds"
    else
        python3 -c '
import json, sys
o = json.load(open(sys.argv[1])).get("claudeAiOauth") or {}
print(o.get("accessToken", "")); print(o.get("expiresAt", 0)); print(o.get("subscriptionType", ""))
' "$creds"
    fi
}
command -v jq >/dev/null || command -v python3 >/dev/null || fail missing_jq

load() { { read -r token; read -r expires_at; read -r plan; } < <(read_creds 2>/dev/null); }
token="" expires_at=0 plan=""
load
[[ -n "$token" ]] || fail no_token

# The token is refreshed by Claude Code itself. If it has expired, ask the
# claude CLI (when available) to check the sign-in, which may renew it.
now_ms=$(( $(date +%s) * 1000 ))
if (( ${expires_at%.*} > 0 && ${expires_at%.*} < now_ms + 60000 )); then
    claude_bin="$(command -v claude || echo "$HOME/.local/bin/claude")"
    if [[ -x "$claude_bin" ]]; then
        timeout 30 "$claude_bin" auth status >/dev/null 2>&1
        load
    fi
fi

response="$(printf 'Authorization: Bearer %s\n' "$token" | curl -sS --max-time 20 \
    -H @- \
    -H 'anthropic-beta: oauth-2025-04-20' \
    -H 'Accept: application/json' \
    -w '\n%{http_code}' \
    "$USAGE_URL" 2>/dev/null)" || fail network

status="${response##*$'\n'}"
body="${response%$'\n'*}"
case "$status" in
    200) ;;
    401|403) fail auth "$status" ;;
    429) fail rate_limited "$status" ;;
    *) fail http "${status:-0}" ;;
esac

printf '{"plan":"%s","usage":%s}\n' "$plan" "$body"
