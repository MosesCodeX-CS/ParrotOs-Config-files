
#!/bin/bash

THRESHOLD=20          # Alert when battery is below or equal to this %
CHECK_INTERVAL=60     # Seconds between notifications
ALERTED_FILE="/tmp/battery_alert_active"

while true; do
    BATTERY=$(acpi -b | grep -P -o '[0-9]+(?=%)')
    STATUS=$(acpi -b | grep -o 'Discharging')

    if [[ "$STATUS" == "Discharging" ]] && [[ "$BATTERY" -le "$THRESHOLD" ]]; then
        
        # Continuous notifications while below threshold
        DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus \
        notify-send "⚠️ Battery Critically Low" "Battery is at ${BATTERY}%. Plug in your charger!"
        
        touch "$ALERTED_FILE"  # Mark that alerts are active

    else
        # Stop alerting when charging or battery above threshold
        [ -f "$ALERTED_FILE" ] && rm "$ALERTED_FILE"
    fi

    sleep $CHECK_INTERVAL
done
