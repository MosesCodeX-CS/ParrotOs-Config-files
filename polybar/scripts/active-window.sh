#!/bin/bash
# Get active window title
window_title=$(xdotool getwindowfocus getwindowname 2>/dev/null)

# Truncate if too long
if [ ${#window_title} -gt 30 ]; then
    window_title="${window_title:0:27}..."
fi

# Output the window title
echo "$window_title"
