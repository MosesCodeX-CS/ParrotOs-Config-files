#!/bin/bash
# Simple weather display without emojis
city="Nairobi"  # Change to your city
weather=$(curl -s "wttr.in/$city?format=%t" 2>/dev/null | tr -d '\n')
if [ -n "$weather" ]; then
    echo "$weather"
else
    echo "N/A"
fi
