#!/usr/bin/env sh
set -eu

width="${1:-44}"
delay="${2:-0.12}"
poll_every="${3:-4}"
pause_frames="${4:-6}"
gap='     '

case "$width" in
  ''|*[!0-9]*) width=44 ;;
esac

case "$poll_every" in
  ''|*[!0-9]*) poll_every=4 ;;
esac

case "$pause_frames" in
  ''|*[!0-9]*) pause_frames=6 ;;
esac

if [ "$width" -lt 1 ]; then
  width=44
fi

if [ "$poll_every" -lt 1 ]; then
  poll_every=1
fi

sanitize() {
  printf '%s' "$1" | tr '\r\n' '  ' | sed 's/\\/\\\\/g; s/"/\\"/g'
}

pick_metadata_line() {
  lines="$(playerctl -a metadata --format '{{status}}|{{playerName}}|{{artist}}|{{title}}' 2>/dev/null || true)"
  [ -n "$lines" ] || return 1

  playing_line="$(printf '%s\n' "$lines" | awk -F '|' '$1 == "Playing" { print; exit }')"
  if [ -n "$playing_line" ]; then
    printf '%s\n' "$playing_line"
    return 0
  fi

  paused_line="$(printf '%s\n' "$lines" | awk -F '|' '$1 == "Paused" { print; exit }')"
  if [ -n "$paused_line" ]; then
    printf '%s\n' "$paused_line"
    return 0
  fi

  return 1
}

player_icon() {
  case "$1" in
    firefox) printf '󰈹' ;;
    spotify) printf '' ;;
    mpv) printf '' ;;
    *) printf '󰎈' ;;
  esac
}

status_icon() {
  case "$1" in
    Playing) printf '󰏤' ;;
    Paused) printf '󰐊' ;;
    *) printf '󰓛' ;;
  esac
}

scroll_text() {
  text=$1
  pos=$2
  max=$3

  printf '%s' "$text" | awk -v p="$pos" -v w="$max" '
  {
    n = length($0)
    if (n <= w) {
      print $0
      next
    }

    start = (p % n) + 1
    out = substr($0, start, w)
    if (length(out) < w) {
      out = out substr($0, 1, w - length(out))
    }
    print out
  }'
}

if ! command -v playerctl >/dev/null 2>&1; then
  printf '{"text":"mpris n/a","tooltip":"playerctl not installed","class":"stopped"}\n'
  exit 0
fi

offset=0
pause_left=0
poll_left=0
cached_line=''
last_key=''

while :; do
  if [ "$poll_left" -le 0 ]; then
    cached_line="$(pick_metadata_line || true)"
    poll_left="$poll_every"
  fi
  poll_left=$((poll_left - 1))

  line="$cached_line"

  if [ -z "$line" ]; then
    printf '{"text":"","tooltip":"No active media player","class":"stopped"}\n'
    offset=0
    pause_left=0
    last_key=''
    sleep "$delay"
    continue
  fi

  status="$(printf '%s' "$line" | cut -d '|' -f 1)"
  player="$(printf '%s' "$line" | cut -d '|' -f 2)"
  artist="$(printf '%s' "$line" | cut -d '|' -f 3)"
  title="$(printf '%s' "$line" | cut -d '|' -f 4-)"

  [ -n "$title" ] || title='unknown title'

  dynamic="$title"
  if [ -n "$artist" ]; then
    dynamic="$dynamic — $artist"
  fi

  key="$status|$player|$dynamic"
  if [ "$key" != "$last_key" ]; then
    offset=0
    pause_left="$pause_frames"
    last_key="$key"
  fi

  full="$(status_icon "$status") $(player_icon "$player") $dynamic"
  scroll_source="$full$gap"
  full_len="$(printf '%s' "$full" | awk '{ print length }')"

  if [ "$full_len" -gt "$width" ]; then
    display="$(scroll_text "$scroll_source" "$offset" "$width")"
    scroll_len="$(printf '%s' "$scroll_source" | awk '{ print length }')"

    if [ "$pause_left" -gt 0 ]; then
      pause_left=$((pause_left - 1))
    else
      offset=$((offset + 1))
      if [ "$offset" -ge "$scroll_len" ]; then
        offset=0
        pause_left="$pause_frames"
      fi
    fi
  else
    offset=0
    pause_left=0
    display="$full"
  fi

  class='stopped'
  case "$status" in
    Playing) class='playing' ;;
    Paused) class='paused' ;;
  esac

  player_safe="$(sanitize "$player")"
  status_safe="$(sanitize "$status")"
  title_safe="$(sanitize "$title")"
  artist_safe="$(sanitize "$artist")"
  text_safe="$(sanitize "$display")"

  tooltip="$player_safe ($status_safe)\\n$title_safe"
  if [ -n "$artist_safe" ]; then
    tooltip="$tooltip\\n$artist_safe"
  fi

  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text_safe" "$tooltip" "$class"
  sleep "$delay"
done
