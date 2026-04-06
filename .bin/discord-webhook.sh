#!/usr/bin/env bash

PAYLOAD=$(cat)

SESSION_ID=$(echo "$PAYLOAD" | jq -r '.session_id // empty')
HOOK_EVENT=$(echo "$PAYLOAD" | jq -r '.hook_event_name // empty')
TITLE=$(echo "$PAYLOAD" | jq -r '.title // empty')
MESSAGE=$(echo "$PAYLOAD" | jq -r '.message // empty')
CWD=$(echo "$PAYLOAD" | jq -r '.cwd // empty')
PROJECT_NAME=$(basename "${CWD:-$(pwd)}")
SHORT_ID="${SESSION_ID:0:8}"

# イベントに応じたプレフィックス
case "$HOOK_EVENT" in
  Notification) PREFIX="🔔" ;;
  Stop)         PREFIX="✅" ;;
  *)            PREFIX="ℹ️" ;;
esac

# メッセージ組み立て
CONTENT="${PREFIX} **${PROJECT_NAME}** (${SHORT_ID})"
if [ -n "$TITLE" ]; then
  CONTENT="${CONTENT}\n${TITLE}"
fi
if [ -n "$MESSAGE" ]; then
  CONTENT="${CONTENT}\n${MESSAGE}"
fi

# JSON安全にエスケープしてPOST
JSON_CONTENT=$(jq -n --arg c "$CONTENT" '{content: $c}')
curl -s -H "Content-Type: application/json" \
  -d "$JSON_CONTENT" \
  "$DISCORD_WEBHOOK_URL"
