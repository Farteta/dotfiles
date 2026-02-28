#!/usr/bin/env sh
set -eu

awk '
function memory_class(pct) {
  if (pct >= 90) return "critical"
  if (pct >= 80) return "hot"
  if (pct >= 70) return "warm"
  return "cool"
}

$1 == "MemTotal:" { mem_total = $2 }
$1 == "MemAvailable:" { mem_avail = $2 }
$1 == "MemFree:" { mem_free = $2 }
$1 == "Buffers:" { buffers = $2 }
$1 == "Cached:" { cached = $2 }
$1 == "SwapTotal:" { swap_total = $2 }
$1 == "SwapFree:" { swap_free = $2 }

END {
  if (!mem_total) {
    print "{\"text\":\"ram n/a\",\"tooltip\":\"memory stats unavailable\",\"class\":\"offline\"}"
    exit 0
  }

  if (!mem_avail) {
    mem_avail = mem_free + buffers + cached
  }

  mem_used = mem_total - mem_avail
  mem_pct = int((100 * mem_used + mem_total / 2) / mem_total)

  swap_used = swap_total - swap_free
  if (swap_total > 0) {
    swap_pct = int((100 * swap_used + swap_total / 2) / swap_total)
  } else {
    swap_pct = 0
  }

  printf("{\"text\":\"ram  %d%%\",\"tooltip\":\"RAM\\nUsed: %.1f GiB / %.1f GiB (%d%%)\\nAvail: %.1f GiB\\nSwap: %.1f GiB / %.1f GiB (%d%%)\",\"class\":\"%s\"}\n",
    mem_pct,
    mem_used / 1048576,
    mem_total / 1048576,
    mem_pct,
    mem_avail / 1048576,
    swap_used / 1048576,
    swap_total / 1048576,
    swap_pct,
    memory_class(mem_pct))
}
' /proc/meminfo
