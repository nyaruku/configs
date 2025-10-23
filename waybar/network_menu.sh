#!/bin/bash

chosen=$(nmcli -t -f active,ssid dev wifi | \
    awk -F: '$1=="yes"{print "  "$2 " (Connected)"} $1=="no"{print "  "$2}' | \
    rofi -dmenu -p "Wi-Fi")

if [[ "$chosen" == *"(Connected)"* ]]; then
    # Disconnect from current network
    ssid=$(echo "$chosen" | sed 's/ (Connected)//' | awk '{print $2}')
    nmcli con down id "$ssid"
elif [[ -n "$chosen" ]]; then
    # Try to connect (will prompt for password if needed)
    ssid=$(echo "$chosen" | awk '{print $2}')
    nmcli dev wifi connect "$ssid"
fi

