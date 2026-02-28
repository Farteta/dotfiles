#!/usr/bin/env sh
set -eu

mode="${1:-text}"
state_file="${XDG_RUNTIME_DIR:-/tmp}/kitty-copy-feedback.last"

if command -v cliphist >/dev/null 2>&1; then
    cliphist -max-items 10 store
else
    cat >/dev/null
fi

[ "$mode" = "text" ] || exit 0

command -v notify-send >/dev/null 2>&1 || exit 0
command -v hyprctl >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

active_class="$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')"
case "$active_class" in
    kitty|Kitty) ;;
    *) exit 0 ;;
esac

now="$(date +%s)"
last=0

if [ -r "$state_file" ]; then
    last="$(cat "$state_file" 2>/dev/null || printf '0')"
fi

case "$last" in
    ''|*[!0-9]*) last=0 ;;
esac

if [ $((now - last)) -lt 1 ]; then
    exit 0
fi

printf '%s\n' "$now" > "$state_file"
notify-send -a "Kitty" -u low -t 900 -h string:x-canonical-private-synchronous:kitty-copy "Copied to clipboard"
