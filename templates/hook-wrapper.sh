#!/usr/bin/env bash
# 実運用で使った hook ラッパーの型。
# 時計プログラム（ここでは Python）は1行 JSON を出す：
#   {"decision": "silent"|"wake", "reason": "...", "payload": {...}}
# ラッパーはそれを hook ランタイムの silent / wake へ振り分けるだけにする。
set -euo pipefail
source "$HATCH_HOOK_RUNTIME"

ARGS=()
if [ "${HATCH_HOOK_DRY_RUN:-0}" = "1" ]; then
  ARGS+=(--dry-run)
fi

OUT=$(python3 /path/to/clock.py "${ARGS[@]}")
DECISION=$(printf '%s' "$OUT" | python3 -c 'import json,sys; print(json.load(sys.stdin)["decision"])')
REASON=$(printf '%s' "$OUT" | python3 -c 'import json,sys; print(json.load(sys.stdin)["reason"])')
PAYLOAD=$(printf '%s' "$OUT" | python3 -c 'import json,sys; print(json.dumps(json.load(sys.stdin)["payload"], ensure_ascii=False))')

log "clock tick" "$OUT"

if [ "$DECISION" = "wake" ]; then
  wake "$REASON" "$PAYLOAD"
else
  silent "$REASON" "$PAYLOAD"
fi
