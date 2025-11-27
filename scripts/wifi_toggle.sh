#!/bin/bash
if [ "$(nmcli radio wifi)" = "enabled" ]; then
    nmcli radio wifi off
    notify-send "WiFi" "Disabled"
else
    nmcli radio wifi on
    notify-send "WiFi" "Enabled"
fi
EOL

# Make the script executable
chmod +x ~/.config/scripts/wifi_toggle.sh