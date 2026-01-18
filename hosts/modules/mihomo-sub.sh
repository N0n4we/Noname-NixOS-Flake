#!/usr/bin/env bash
# ============================================================================
#  Mihomo 多订阅源自动更新守护脚本（持久化时间戳版）
#     • 开机由 systemd 启动，先 sleep 10 分钟，再每 LOOP_SLEEP_SEC 秒轮询
#     • 仅在「上次成功下载时间 ≥ MIN_INTERVAL_SEC」或「stamp 不存在」时抓取
#     • 抓取失败 ≠ 退出；记录日志以后进入下一轮
#     • last-success 时间写入 <output>.stamp（纯数字 epoch 秒）
# ============================================================================

set -euo pipefail

### ===== 配 置 区 ============================================================
SUBS="$SUBSCRIPTION"

CURL_GLOBAL_OPTS=(
  -L
  -H "User-Agent: mihomo/1.19.17"
  --retry 3
  --connect-timeout 10
)

# 订阅最小刷新间隔，秒
MIN_INTERVAL_SEC=7200
# 守护循环休眠，秒
LOOP_SLEEP_SEC=600
# 启动后第一次延迟，秒
INITIAL_DELAY_SEC=600
# 锁文件
LOCK_FILE="/var/lib/private/mihomo/providers/mihomo-sub.lock"
### ==========================================================================

# ---------- 工具函数 ---------------------------------------------------------
stamp_path() { printf "%s.stamp" "$1"; }

last_success() {                    # $1=output -> echo epoch | 返回1=无stamp
  local sfile; sfile=$(stamp_path "$1")
  [[ -f $sfile ]] && cat "$sfile" || return 1
}

mark_success() {                    # $1=output
  local sfile; sfile=$(stamp_path "$1")
  printf "%s\n" "$(date +%s)" > "$sfile"
}

should_update() {                   # $1=output 0=需更新
  local out="$1" last now
  if ! last=$(last_success "$out" 2>/dev/null); then
    return 0             # stamp 不存在 → 需要更新
  fi
  now=$(date +%s)
  (( now - last >= MIN_INTERVAL_SEC )) && return 0 || return 1
}

fetch_one() {
  local url="$1" out="$2" tmp
  echo "[$(date -Is)] Fetch   $url -> $out"
  tmp=$(mktemp)
  if curl "${CURL_GLOBAL_OPTS[@]}" "$url" -o "$tmp"; then
    if [[ -s "$tmp" ]]; then
      mkdir -p "$(dirname "$out")"
      mv "$tmp" "$out"
      mark_success "$out"
      echo "[$(date -Is)] Saved   $out   (stamp updated)"
    else
      echo "[$(date -Is)] ERROR   $url returned empty file, keeping old one" >&2
      rm -f "$tmp"
    fi
  else
    echo "[$(date -Is)] ERROR   curl failed ($url)" >&2
    rm -f "$tmp"
  fi
}

process_all() {
  echo "$SUBS" | tr ';' '\n' | while read -r url out || [[ -n $url ]]; do
    [[ -z $url || $url =~ ^# ]] && continue
    if should_update "$out"; then
      fetch_one "$url" "$out"
    else
      echo "[`date -Is`] Skip    $out fresh"
    fi
  done
}

# ---------- 主循环 -----------------------------------------------------------
LOCK_DIR=$(dirname "$LOCK_FILE")
mkdir -p "$LOCK_DIR"
chown -R nobody:nogroup /var/lib/private/mihomo

exec 200>"$LOCK_FILE"
flock -n 200 || { echo "[`date -Is`] Another instance running, exit"; exit 0; }

echo "[`date -Is`] Mihomo-sub started; first run after ${INITIAL_DELAY_SEC}s"
trap 'echo "[`date -Is`] SIGTERM caught, exit"; exit 0' TERM INT

sleep "$INITIAL_DELAY_SEC"

while :; do
  process_all
  chown -R nobody:nogroup /var/lib/private/mihomo
  sleep "$LOOP_SLEEP_SEC" &
  wait $!
done
