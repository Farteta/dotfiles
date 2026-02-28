#!/usr/bin/env sh
set -eu

print_json() {
  text=$1
  tooltip=$2
  class=$3
  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
}

if ! command -v tailscale >/dev/null 2>&1; then
  print_json "ts n/a" "tailscale not installed" "missing"
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  print_json "ts n/a" "jq is required for tailscale parsing" "missing"
  exit 0
fi

status_json="$(timeout 3 tailscale status --json 2>/dev/null || true)"
if [ -z "$status_json" ]; then
  print_json "ts off" "tailscale daemon unreachable" "offline"
  exit 0
fi

state="$(printf '%s' "$status_json" | jq -r '.BackendState // "Unknown"' 2>/dev/null || echo Unknown)"
host="$(printf '%s' "$status_json" | jq -r '.Self.HostName // .Self.DNSName // "unknown"' 2>/dev/null || echo unknown)"
ip="$(printf '%s' "$status_json" | jq -r '.Self.TailscaleIPs[0] // "n/a"' 2>/dev/null || echo n/a)"
self_online="$(printf '%s' "$status_json" | jq -r '.Self.Online // false' 2>/dev/null || echo false)"
online_peers="$(printf '%s' "$status_json" | jq -r '[ (.Peer // {}) | to_entries[] | select(.value.Online == true) ] | length' 2>/dev/null || echo 0)"
health_count="$(printf '%s' "$status_json" | jq -r '(.Health // []) | length' 2>/dev/null || echo 0)"
exit_node="$(printf '%s' "$status_json" | jq -r '.ExitNodeStatus.TailscaleIPs[0] // empty' 2>/dev/null || true)"

host_safe=$(printf '%s' "$host" | tr '"' "'")
ip_safe=$(printf '%s' "$ip" | tr '"' "'")

class="offline"
text="ts off"

if [ "$state" = "Running" ] && [ "$self_online" = "true" ]; then
  class="connected"
  text="ts ${online_peers}"
fi

if [ "$health_count" -gt 0 ] && [ "$class" = "connected" ]; then
  class="degraded"
fi

tooltip="state: ${state}\\nhost: ${host_safe}\\nip: ${ip_safe}\\nonline peers: ${online_peers}\\nhealth alerts: ${health_count}"

if [ -n "${exit_node}" ]; then
  tooltip="${tooltip}\\nexit node: ${exit_node}"
fi

print_json "$text" "$tooltip" "$class"
