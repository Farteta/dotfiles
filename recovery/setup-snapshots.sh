#!/usr/bin/env bash
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
  echo "Run this script as root: sudo ./recovery/setup-snapshots.sh" >&2
  exit 1
fi

if [[ $(findmnt -n -o FSTYPE /) != btrfs ]]; then
  echo "The root filesystem is not Btrfs; no changes were made." >&2
  exit 1
fi

if ! command -v snapper >/dev/null 2>&1; then
  echo "Snapper is not installed; no changes were made." >&2
  exit 1
fi

if [[ -e /etc/snapper/configs/root ]]; then
  echo "A root Snapper configuration already exists; leaving it unchanged."
  snapper -c root list
  exit 0
fi

if [[ -e /.snapshots ]]; then
  echo "/.snapshots already exists without a root Snapper configuration." >&2
  echo "Inspect it before creating a configuration; no changes were made." >&2
  exit 1
fi

snapper -c root create-config /
snapper -c root set-config \
  'TIMELINE_CREATE=yes' \
  'TIMELINE_CLEANUP=yes' \
  'TIMELINE_LIMIT_HOURLY=2' \
  'TIMELINE_LIMIT_DAILY=5' \
  'TIMELINE_LIMIT_WEEKLY=1' \
  'TIMELINE_LIMIT_MONTHLY=0' \
  'TIMELINE_LIMIT_QUARTERLY=0' \
  'TIMELINE_LIMIT_YEARLY=0' \
  'NUMBER_CLEANUP=yes' \
  'NUMBER_LIMIT=10' \
  'NUMBER_LIMIT_IMPORTANT=10'

snapper -c root create --read-only --cleanup-algorithm number \
  --description 'Initial system recovery point'
systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

echo "Root snapshots are configured and the timeline/cleanup timers are active."
echo "Note: /home and /boot are separate filesystems and are NOT in root snapshots."
snapper -c root list
