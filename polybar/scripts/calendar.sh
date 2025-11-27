#!/usr/bin/env bash

set -euo pipefail

# Try gsimplecal first (lightweight calendar)
if command -v gsimplecal >/dev/null 2>&1; then
  pkill gsimplecal 2>/dev/null || true
  gsimplecal &
  exit 0
fi

# Try yad calendar
if command -v yad >/dev/null 2>&1; then
  yad --calendar --title="Calendar" --undecorated --skip-taskbar --close-on-unfocus &
  exit 0
fi

# Try zenity calendar
if command -v zenity >/dev/null 2>&1; then
  zenity --calendar --title="Calendar" &
  exit 0
fi

# Fallback: show calendar in notification
CAL_OUTPUT=$(cal -3)

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Calendar" "$CAL_OUTPUT" -t 5000
else
  # Last resort: open in terminal
  TERMINAL="${TERMINAL:-alacritty}"
  if command -v "$TERMINAL" >/dev/null 2>&1; then
    $TERMINAL -e bash -c "cal -3; read -n 1" &
  else
    xterm -e bash -c "cal -3; read -n 1" &
  fi
fi

