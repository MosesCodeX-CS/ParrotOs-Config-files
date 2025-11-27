#!/bin/bash
case $1 in
    up) 
        vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n1)
        [ "$vol" -lt 100 ] && pactl set-sink-volume @DEFAULT_SINK@ +5%
        notify-send "Volume" "$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n1)%" -h int:value:$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n1)
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        notify-send "Volume" "$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n1)%" -h int:value:$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n1)
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        if [ "$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')" = "yes" ]; then
            notify-send "Volume" "Muted"
        else
            notify-send "Volume" "Unmuted: $(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n1)%" -h int:value:$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n1)
        fi
        ;;
esac
