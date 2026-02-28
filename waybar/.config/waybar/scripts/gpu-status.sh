#!/usr/bin/env sh
set -eu

trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

gpu_temp_class() {
  t=$1
  if [ "$t" -ge 85 ]; then
    echo critical
  elif [ "$t" -ge 75 ]; then
    echo hot
  elif [ "$t" -ge 65 ]; then
    echo warm
  else
    echo cool
  fi
}

print_offline() {
  printf '{"text":"gpu 󰢮 n/a","tooltip":"GPU stats unavailable","class":"offline"}\n'
}

emit_stats() {
  gpu_name=$(printf '%s' "$1" | tr '"' "'")
  usage=$2
  temp=$3
  class="$(gpu_temp_class "$temp")"

  printf '{"text":"gpu 󰢮 %s%%  %s°C","tooltip":"%s\\nUsage: %s%%\\nTemp: %s°C","class":"%s"}\n' \
    "$usage" "$temp" "$gpu_name" "$usage" "$temp" "$class"
}

stats_from_nvidia() {
  command -v nvidia-smi >/dev/null 2>&1 || return 1
  line="$(nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1 || true)"
  [ -n "$line" ] || return 1

  name="$(trim "$(printf '%s' "$line" | cut -d ',' -f 1)")"
  usage="$(trim "$(printf '%s' "$line" | cut -d ',' -f 2)")"
  temp="$(trim "$(printf '%s' "$line" | cut -d ',' -f 3)")"

  case "$usage" in
    ''|*[!0-9]*) return 1 ;;
  esac
  case "$temp" in
    ''|*[!0-9]*) return 1 ;;
  esac

  printf '%s|%s|%s\n' "$name" "$usage" "$temp"
}

temp_from_hwmon() {
  card="$1"
  for tf in "$card"/device/hwmon/hwmon*/temp1_input; do
    [ -f "$tf" ] || continue
    milli="$(cat "$tf" 2>/dev/null || true)"
    case "$milli" in
      ''|*[!0-9]*) continue ;;
    esac
    echo $(( (milli + 500) / 1000 ))
    return 0
  done
  return 1
}

name_from_hwmon() {
  card="$1"
  for nf in "$card"/device/hwmon/hwmon*/name; do
    [ -f "$nf" ] || continue
    name="$(cat "$nf" 2>/dev/null || true)"
    [ -n "$name" ] || continue
    printf '%s\n' "$name"
    return 0
  done
  return 1
}

temp_from_sensors_edge() {
  command -v sensors >/dev/null 2>&1 || return 1

  sensors 2>/dev/null | awk '
  function grab_temp(line,   v) {
    if (match(line, /\+[0-9]+(\.[0-9]+)?/)) {
      v = substr(line, RSTART + 1, RLENGTH - 1) + 0
      return int(v + 0.5)
    }
    return -1
  }
  {
    if (gpu < 0 && $1 ~ /^edge:/) {
      gpu = grab_temp($0)
    }
  }
  END {
    if (gpu >= 0) print gpu
  }' gpu=-1
}

stats_from_amdgpu_sysfs() {
  for bf in /sys/class/drm/card[0-9]/device/gpu_busy_percent; do
    [ -f "$bf" ] || continue
    usage="$(cat "$bf" 2>/dev/null || true)"
    case "$usage" in
      ''|*[!0-9]*) continue ;;
    esac

    card="$(dirname "$(dirname "$bf")")"
    name="$(name_from_hwmon "$card" || true)"
    [ -n "$name" ] || name="amdgpu"

    temp="$(temp_from_hwmon "$card" || true)"
    if [ -z "$temp" ]; then
      temp="$(temp_from_sensors_edge || true)"
    fi

    case "$temp" in
      ''|*[!0-9]*) continue ;;
    esac

    printf '%s|%s|%s\n' "$name" "$usage" "$temp"
    return 0
  done
  return 1
}

stats="$(stats_from_nvidia || true)"
if [ -z "$stats" ]; then
  stats="$(stats_from_amdgpu_sysfs || true)"
fi

if [ -z "$stats" ]; then
  print_offline
  exit 0
fi

name="$(printf '%s' "$stats" | cut -d '|' -f 1)"
usage="$(printf '%s' "$stats" | cut -d '|' -f 2)"
temp="$(printf '%s' "$stats" | cut -d '|' -f 3)"

emit_stats "$name" "$usage" "$temp"
