#!/usr/bin/env sh
set -eu

panel="${1:-}"

case "$panel" in
  volume)
    class_pattern="^(pavucontrol|org\\.pulseaudio\\.pavucontrol)$"
    process_pattern="pavucontrol"
    launch_cmd="pavucontrol"
    ;;
  network)
    class_pattern="^(nm-connection-editor|nm-connection-ed|nm-connection)$"
    process_pattern="nm-connection-editor"
    launch_cmd="nm-connection-editor"
    ;;
  bluetooth)
    class_pattern="^(blueman-manager|blueman)$"
    process_pattern="blueman-manager"
    launch_cmd="blueman-manager"
    ;;
  *)
    printf 'Usage: %s {volume|network|bluetooth}\n' "$0" >&2
    exit 2
    ;;
esac

addresses="$(hyprctl clients | awk -v pattern="$class_pattern" '
/^Window / {
  addr = $2
  sub(/:$/, "", addr)
  next
}
/^[[:space:]]*class:/ {
  cls = $2
  if (tolower(cls) ~ pattern) {
    print addr
  }
}
')"

if [ -n "$addresses" ]; then
  printf '%s\n' "$addresses" | while IFS= read -r addr; do
    [ -n "$addr" ] && hyprctl dispatch closewindow "address:$addr" >/dev/null
  done
  exit 0
fi

# Fallback: if process exists but no mapped client matched, close it.
if pgrep -f "$process_pattern" >/dev/null 2>&1; then
  pkill -f "$process_pattern" >/dev/null 2>&1 || true
  exit 0
fi

nohup sh -c "$launch_cmd" >/dev/null 2>&1 &
