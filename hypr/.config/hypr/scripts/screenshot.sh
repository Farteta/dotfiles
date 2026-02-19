#!/usr/bin/env sh

set -eu

mode="${1:-}"
dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
file="$dir/${timestamp}.png"

mkdir -p "$dir"

take_area() {
    region="$(slurp)" || exit 0
    [ -n "$region" ] || exit 0
    grim -g "$region" "$file"
}

take_full() {
    grim "$file"
}

take_active() {
    geometry="$(hyprctl activewindow -j | jq -r 'if (.at|length)==2 and (.size|length)==2 then "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])" else empty end')"
    [ -n "$geometry" ] || exit 1
    grim -g "$geometry" "$file"
}

case "$mode" in
    area) take_area ;;
    full) take_full ;;
    active) take_active ;;
    *)
        echo "usage: $0 {area|full|active}" >&2
        exit 2
        ;;
esac

if command -v wl-copy >/dev/null 2>&1; then
    wl-copy --type image/png < "$file"
fi

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Screenshot saved" "$(basename "$file") copied to clipboard"
fi
