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
if [ "$total_count" -gt 0 ]; then
  state="pending"
fi

tooltip="repo: ${repo_count}\\naur: ${aur_count}\\ntotal: ${total_count}"

printf '{"text":"󰏗 %s","tooltip":"%s","class":"%s"}\n' "$total_count" "$tooltip" "$state"
