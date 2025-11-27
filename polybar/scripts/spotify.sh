#!/usr/bin/env bash

set -euo pipefail

if ! command -v playerctl >/dev/null 2>&1; then
  echo "No playerctl"
  exit 0
fi

PLAYER="playerctld"

if ! playerctl -p "$PLAYER" status >/dev/null 2>&1; then
  PLAYER="spotify"
fi

STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null || echo "Stopped")

if [[ "$STATUS" == "Stopped" ]]; then
  echo "No music"
  exit 0
fi

ARTIST=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null || echo "")
TITLE=$(playerctl -p "$PLAYER" metadata title 2>/dev/null || echo "")

if [ -n "$ARTIST" ] && [ -n "$TITLE" ]; then
  echo "$ARTIST - $TITLE"
elif [ -n "$TITLE" ]; then
  echo "$TITLE"
else
  echo "Playing"
fi

