#!/usr/bin/env sh
set -eu

count_lines() {
  awk 'NF { c++ } END { print c + 0 }'
}

repo_updates=""
aur_updates=""

if command -v checkupdates >/dev/null 2>&1; then
  repo_updates="$(checkupdates 2>/dev/null || true)"
else
  repo_updates="$(pacman -Qu 2>/dev/null || true)"
fi

if command -v yay >/dev/null 2>&1; then
  aur_updates="$(yay -Qua 2>/dev/null || true)"
elif command -v paru >/dev/null 2>&1; then
  aur_updates="$(paru -Qua 2>/dev/null || true)"
fi

repo_count="$(printf '%s\n' "$repo_updates" | count_lines)"
aur_count="$(printf '%s\n' "$aur_updates" | count_lines)"
total_count=$((repo_count + aur_count))

state="none"
text=""
if [ "$total_count" -gt 0 ]; then
  state="pending"
  text="<span size='125%'>󰏗</span> ${total_count}"
fi

package_preview="$(printf '%s\n%s\n' "$repo_updates" "$aur_updates" | awk '
  NF {
    count++
    if (count <= 8) print
  }
  END {
    if (count > 8) printf "… and %d more\n", count - 8
  }
')"
tooltip="$(printf '%s updates available\nRepository: %s · AUR: %s\n\n%s' \
  "$total_count" "$repo_count" "$aur_count" "$package_preview")"

jq -nc --arg text "$text" --arg tooltip "$tooltip" --arg class "$state" \
  '{text: $text, tooltip: $tooltip, class: $class}'
