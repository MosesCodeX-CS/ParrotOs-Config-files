#!/usr/bin/env bash

set -euo pipefail

if command -v rofi >/dev/null 2>&1; then
  MENU_CMD="rofi -dmenu -i -p 'Power'"
elif command -v dmenu >/dev/null 2>&1; then
  MENU_CMD="dmenu -i -p 'Power'"
else
  echo "rofi or dmenu required" >&2
  exit 1
fi

declare -A ACTIONS=(
  [" Lock"]="loginctl lock-session"
  [" Suspend"]="systemctl suspend"
  ["󰍃 Logout"]="loginctl terminate-session ${XDG_SESSION_ID:-}"
  [" Reboot"]="systemctl reboot"
  [" Shutdown"]="systemctl poweroff"
  [" Cancel"]="echo cancel"
)

CHOICE=$(printf "%s\n" "${!ACTIONS[@]}" | sort | eval "$MENU_CMD") || exit 0

CMD=${ACTIONS[$CHOICE]:-}

if [ -z "$CMD" ] || [[ "$CMD" == "echo cancel" ]]; then
  exit 0
fi

eval "$CMD"

