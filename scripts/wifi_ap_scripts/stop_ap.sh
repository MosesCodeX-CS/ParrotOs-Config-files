#!/bin/bash

# Kill the AP process
sudo pkill -f create_ap

# Bring down and remove the virtual interface
sudo ip link set wlan0_ap down
sudo iw dev wlan0_ap del

# Restart NetworkManager so WiFi works normally
sudo systemctl unmask NetworkManager
sudo systemctl start NetworkManager

