#!/usr/bin/env bash

set -euo pipefail

BAT="${BATTERY:-BAT1}"
BASE="/sys/class/power_supply/${BAT}"
CAP_FILE="$BASE/capacity"
STATUS_FILE="$BASE/status"

if [ ! -r "$CAP_FILE" ] || [ ! -r "$STATUS_FILE" ]; then
  exit 0
fi

CAP=$(cat "$CAP_FILE")
STATUS=$(cat "$STATUS_FILE")

if [[ "$STATUS" == "Charging" || "$STATUS" == "Full" ]]; then
  exit 0
fi

if [ "$CAP" -le 10 ]; then
  MSG="⚠ Battery critical: ${CAP}%"
elif [ "$CAP" -le 20 ]; then
  MSG="Battery low: ${CAP}%"
else
  exit 0
fi

echo "$MSG"

