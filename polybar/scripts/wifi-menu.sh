#!/usr/bin/env bash
set -euo pipefail

# Function to check Wi-Fi status and enable if needed
ensure_wifi_enabled() {
    WIFI_RADIO=$(nmcli radio wifi)
    if [[ "$WIFI_RADIO" != "enabled" ]]; then
        if command -v zenity >/dev/null 2>&1 && zenity --question --text="Wi-Fi is disabled. Enable it?"; then
            if ! nmcli radio wifi on; then
                notify-send -u critical "Wi-Fi Error" "Failed to enable Wi-Fi"
                exit 1
            fi
            sleep 2
        else
            notify-send -u normal "Wi-Fi" "Wi-Fi is disabled" 2>/dev/null || true
            exit 0
        fi
    fi
}

# Function to get current connection status
get_current_connection() {
    nmcli -t -f NAME,DEVICE,TYPE connection show --active | grep -E 'wifi|wifi-p2p' | head -1 | cut -d: -f1
}

# Function to show network list
show_network_list() {
    # Check for menu programs
    if command -v rofi >/dev/null 2>&1; then
        # Check for Rofi theme in common locations
        local rofi_theme=""
        local rofi_pass_theme=""
        
        # Try to find theme in common locations
        if [ -f ~/.config/rofi/launchers/type-1/style-1.rasi ]; then
            rofi_theme="-theme ~/.config/rofi/launchers/type-1/style-1.rasi"
        elif [ -f ~/.config/rofi/config.rasi ]; then
            rofi_theme="-theme ~/.config/rofi/config.rasi"
        fi
        
        if [ -f ~/.config/rofi/menus/password.rasi ]; then
            rofi_pass_theme="-theme ~/.config/rofi/menus/password.rasi"
        fi
        
        DMENU_CMD="rofi -dmenu -i -p 'Wi-Fi' $rofi_theme"
        PASS_CMD="rofi -dmenu -password -p 'Password' $rofi_pass_theme"
    elif command -v dmenu >/dev/null 2>&1; then
        DMENU_CMD="dmenu -i -p 'Wi-Fi'"
        PASS_CMD="dmenu -p 'Password'"
    else
        echo "Error: rofi or dmenu required" >&2
        exit 1
    fi

    # Rest of the function remains the same...
    echo "Scanning for Wi-Fi networks..."
    NETWORKS=$(nmcli -f "SSID,SECURITY,SIGNAL" device wifi list --rescan yes 2>&1) || {
        notify-send -u critical "Wi-Fi Error" "Failed to scan for networks"
        exit 1
    }

    # Process network list
    OPTIONS=$(echo "$NETWORKS" | tail -n +2 | while IFS= read -r line; do
        [ -z "$line" ] && continue
        if [[ "$line" =~ ^([^[:space:]]+([[:space:]]+[^[:space:]]+)*)[[:space:]]+([^[:space:]]+)[[:space:]]+([0-9]+)%?[[:space:]]*$ ]]; then
            ssid="${BASH_REMATCH[1]}"
            security="${BASH_REMATCH[3]}"
            signal="${BASH_REMATCH[4]}"
            printf "%-35s | %-12s | %3s%%\n" "$ssid" "$security" "$signal"
        else
            # Fallback parsing
            ssid=$(echo "$line" | awk '{print $1}')
            security=$(echo "$line" | awk '{print $(NF-1)}')
            signal=$(echo "$line" | awk '{print $NF}' | sed 's/%//g')
            printf "%-35s | %-12s | %3s%%\n" "$ssid" "$security" "$signal"
        fi
    done | sort -k3,3nr)

    # Show network selection
    SELECTED=$(echo -e "$OPTIONS" | eval "$DMENU_CMD") || exit 0
    [ -z "$SELECTED" ] && exit 0

    # Extract SSID and SECURITY from selection
    SSID=$(echo "$SELECTED" | awk -F'|' '{print $1}' | sed 's/[[:space:]]*$//' | xargs)
    SECURITY=$(echo "$SELECTED" | awk -F'|' '{print $2}' | xargs)

    # Connect to selected network
    if [[ "$SECURITY" == "WPA"* || "$SECURITY" == "WEP"* || "$SECURITY" == "802.1X"* ]]; then
        PASSWORD=$(echo -e "" | eval "$PASS_CMD") || exit 0
        if [ -n "$PASSWORD" ]; then
            if ! nmcli device wifi connect "$SSID" password "$PASSWORD"; then
                notify-send -u critical "Wi-Fi Error" "Failed to connect to $SSID"
                exit 1
            fi
        else
            notify-send -u normal "Wi-Fi" "Connection cancelled - no password provided"
            exit 0
        fi
    else
        if ! nmcli device wifi connect "$SSID"; then
            notify-send -u critical "Wi-Fi Error" "Failed to connect to $SSID"
            exit 1
        fi
    fi

    notify-send "Wi-Fi" "Successfully connected to $SSID" 2>/dev/null || true
}

# Check for right-click event (button 3)
if [[ "${1:-}" == "--right-click" ]]; then
    ensure_wifi_enabled
    
    # Check if Wi-Fi device exists and is available
    if ! nmcli -t -f DEVICE,TYPE dev | grep -q ":wifi"; then
        notify-send -u critical "Wi-Fi Error" "No Wi-Fi device found"
        exit 1
    fi
    
    # Get Wi-Fi interface name
    WIFI_DEVICE=$(nmcli -t -f DEVICE,TYPE dev | grep ":wifi" | cut -d: -f1 | head -1)
    
    # Check if interface is in a usable state
    WIFI_STATE=$(nmcli -t -f DEVICE,STATE dev | grep "^$WIFI_DEVICE:" | cut -d: -f2)
    case "$WIFI_STATE" in
        "connected"|"disconnected"|"unavailable"|"unmanaged")
            # These states are acceptable for scanning
            ;;
        *)
            notify-send -u critical "Wi-Fi Error" "Wi-Fi interface is not ready (state: $WIFI_STATE)"
            exit 1
            ;;
    esac
    
    # Try to rescan networks
    if nmcli device wifi rescan 2>/dev/null; then
        sleep 1
    fi
    
    # Get list of networks
    NETWORKS=$(nmcli -f "SSID,SECURITY,SIGNAL" device wifi list --rescan no 2>&1 || true)
    NETWORK_COUNT=$(echo "$NETWORKS" | tail -n +2 | grep -c . || true)
    
    if [ "$NETWORK_COUNT" -gt 0 ]; then
        CURRENT_CONN=$(get_current_connection)
        if [ -n "$CURRENT_CONN" ]; then
            notify-send -t 3000 "Wi-Fi" "Connected to: $CURRENT_CONN\nFound $NETWORK_COUNT available networks"
        else
            notify-send -t 3000 "Wi-Fi" "Found $NETWORK_COUNT available networks"
        fi
    else
        notify-send -u normal "Wi-Fi" "No networks found"
    fi
    exit 0
fi

# Main execution
ensure_wifi_enabled

# Check if Wi-Fi device exists
if ! nmcli -t -f DEVICE,TYPE dev | grep -q ":wifi"; then
    notify-send -u critical "Wi-Fi Error" "No Wi-Fi device found"
    exit 1
fi

# Get Wi-Fi interface name
WIFI_DEVICE=$(nmcli -t -f DEVICE,TYPE dev | grep ":wifi" | cut -d: -f1 | head -n 1)

# Check if interface is in a usable state
WIFI_STATE=$(nmcli -t -f DEVICE,STATE dev | grep "^$WIFI_DEVICE:" | cut -d: -f2)
case "$WIFI_STATE" in
    "connected"|"disconnected"|"unavailable"|"unmanaged")
        # These states are acceptable
        ;;
    *)
        notify-send -u critical "Wi-Fi Error" "Wi-Fi interface is not ready (state: $WIFI_STATE)"
        exit 1
        ;;
esac

# Show network list
show_network_list