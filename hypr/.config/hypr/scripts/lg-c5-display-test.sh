#!/usr/bin/env bash
set -euo pipefail

# Test one color change at a time. A normal Hyprland reload restores the
# everyday 8-bit SDR profile in config/monitors/lg_c5.lua.
profile=${1:-}
duration=${2:-20}

case "$profile" in
  10bit)
    color_options='bitdepth = 10, cm = "srgb"'
    ;;
  hdr)
    color_options='bitdepth = 10, cm = "hdr"'
    ;;
  *)
    printf 'Usage: %s {10bit|hdr} [seconds, 5-120]\n' "$0" >&2
    exit 2
    ;;
esac

if [[ ! "$duration" =~ ^[0-9]+$ ]] || (( duration < 5 || duration > 120 )); then
  printf 'Duration must be between 5 and 120 seconds.\n' >&2
  exit 2
fi

monitor_rule="hl.monitor({ output = \"HDMI-A-1\", mode = \"3840x2160@143.99\", position = \"0x0\", scale = 2.0, vrr = 2, $color_options })"

restore() {
  hyprctl reload >/dev/null || printf 'Automatic restore failed. Run: hyprctl reload\n' >&2
}
trap restore EXIT

printf 'Testing %s for %s seconds; the normal display profile will restore automatically.\n' "$profile" "$duration"
hyprctl eval "$monitor_rule"
sleep "$duration"
