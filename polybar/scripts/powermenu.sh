#!/bin/bash
# Simple power menu using rofi
options="Shutdown\nReboot\nLogout\nSuspend\nLock"

chosen=$(echo -e "$options" | rofi -dmenu -p "Power Menu" -theme-str 'window {width: 20%;}')

case $chosen in
    Shutdown)
        shutdown now
        ;;
    Reboot)
        reboot
        ;;
    Logout)
        bspc quit
        ;;
    Suspend)
        systemctl suspend
        ;;
    Lock)
        dm-tool lock
        ;;
esac
