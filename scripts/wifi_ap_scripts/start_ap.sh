#!/bin/bash

# Stop NetworkManager to avoid conflicts
sudo systemctl stop NetworkManager
sudo rfkill unblock all

# Create the virtual AP interface
sudo iw phy phy0 interface add wlan0_ap type __ap
sudo ip link set wlan0_ap up

# Start the access point
sudo create_ap --no-virt --driver nl80211 wlan0_ap enp0s31f6 @its-Moses 123456789

