#!/usr/bin/env sh
set -eu

read_cpu_totals() {
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  total=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle_total=$((idle + iowait))
  printf '%s %s\n' "$total" "$idle_total"
}

cpu_usage_percent() {
  set -- $(read_cpu_totals)
  total1=$1
  idle1=$2

  sleep 0.2

  set -- $(read_cpu_totals)
  total2=$1
  idle2=$2

  delta_total=$((total2 - total1))
  delta_idle=$((idle2 - idle1))

  if [ "$delta_total" -le 0 ]; then
    echo 0
    return
  fi

  echo $(( (100 * (delta_total - delta_idle)) / delta_total ))
}

cpu_temp_c() {
  if ! command -v sensors >/dev/null 2>&1; then
    echo 0
    return
  fi

  sensors 2>/dev/null | awk '
  function grab_temp(line,   v) {
    if (match(line, /\+[0-9]+(\.[0-9]+)?/)) {
      v = substr(line, RSTART + 1, RLENGTH - 1) + 0
      return int(v + 0.5)
    }
    return -1
  }
  {
    if (tctl < 0 && $1 ~ /^Tctl:/) {
      tctl = grab_temp($0)
    }
    if (pkg < 0 && $1 == "Package" && $2 == "id" && $3 == "0:") {
      pkg = grab_temp($0)
    }
    if (cpu < 0 && $1 == "CPU:") {
      cpu = grab_temp($0)
    }
  }
  END {
    if (tctl >= 0) print tctl
    else if (pkg >= 0) print pkg
    else if (cpu >= 0) print cpu
    else print 0
  }' tctl=-1 pkg=-1 cpu=-1
}

temp_class() {
  t=$1
  if [ "$t" -ge 85 ]; then
    echo critical
  elif [ "$t" -ge 75 ]; then
    echo hot
  elif [ "$t" -ge 60 ]; then
    echo warm
  else
    echo cool
  fi
}

usage="$(cpu_usage_percent)"
temp="$(cpu_temp_c)"
class="$(temp_class "$temp")"

printf '{"text":"cpu  %s%%  %s°C","tooltip":"CPU\\nUsage: %s%%\\nTemp: %s°C","class":"%s"}\n' \
  "$usage" "$temp" "$usage" "$temp" "$class"
