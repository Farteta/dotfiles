#!/usr/bin/env sh

selection="$(cliphist list | rofi -dmenu -i -p 'clipboard')"
[ -z "$selection" ] && exit 0

printf '%s' "$selection" | cliphist decode | wl-copy
