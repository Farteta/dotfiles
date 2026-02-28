#!/usr/bin/env sh
set -eu

max_items=10

if ! command -v cliphist >/dev/null 2>&1; then
  printf '{"text":"clip n/a","tooltip":"cliphist not installed","class":"missing"}\n'
  exit 0
fi

count="$(cliphist list 2>/dev/null | awk 'NF { c++ } END { print c + 0 }')"
case "$count" in
  ''|*[!0-9]*) count=0 ;;
esac

class="ok"
tooltip="clipboard history: ${count}/${max_items}\\nleft click: open picker"

if [ "$count" -eq 0 ]; then
  class="empty"
  tooltip="clipboard history empty\\nleft click: open picker"
elif [ "$count" -gt "$max_items" ]; then
  class="overflow"
fi

printf '{"text":"clip ","tooltip":"%s","class":"%s"}\n' "$tooltip" "$class"
