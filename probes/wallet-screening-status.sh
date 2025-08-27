#!/usr/bin/env bash
#
# Minimal Cloudflare D1 probe → Influx Line Protocol (integer field)
# Requires: curl, jq
# Env (required): CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_API_KEY
# Positional arguments: ENVIRONMENT, CLOUDFLARE_DATABASE_ID

set -euo pipefail

: "${CLOUDFLARE_ACCOUNT_ID:?Missing CLOUDFLARE_ACCOUNT_ID}"
: "${CLOUDFLARE_API_KEY:?Missing CLOUDFLARE_API_KEY}"

ENVIRONMENT="${1:?Missing ENVIRONMENT argument}"
CLOUDFLARE_DATABASE_ID="${2:?Missing CLOUDFLARE_DATABASE_ID}"

# --- D1 query: oldest last_screened_at in SECONDS ---
# COALESCE ensures we always get an integer (0 means "missing/none")
SQL='
  SELECT COALESCE(UNIXEPOCH(last_screened_at), 0) AS last_screened_at
  FROM wallet_details
  ORDER BY last_screened_at ASC
  LIMIT 1;
'

URL="https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/d1/database/${CLOUDFLARE_DATABASE_ID}/query"
DATA=$(jq -nc --arg sql "$SQL" '{sql: $sql}')

# echo URL: "$URL" >&2
# echo DATA: "$DATA" >&2

tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT

# Query Cloudflare D1
curl -sS -o "$tmp" \
  -X POST "$URL" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
  --data "$DATA"

# echo "Response:" >&2
# cat "$tmp" >&2 # for debugging

# Extract first row's epoch seconds; default to 0 if empty or bad
LAST_SCREENED_AT_SEC="$(jq -r '.result[0].results[0].last_screened_at // 0' "$tmp" || echo 0)"

MEASUREMENT="wallet-screening"
FIELDS="oldest_last_screened_at=${LAST_SCREENED_AT_SEC}i"
TAGS="environment=${ENVIRONMENT}"

# Emit one line; timestamp omitted (Telegraf will add _time)
printf '%s,%s %s\n' "$MEASUREMENT" "$TAGS" "$FIELDS"
