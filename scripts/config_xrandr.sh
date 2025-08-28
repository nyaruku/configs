#!/bin/bash
# Usage: ./setmode.sh <width> <height> <hz> <monitor>
# Example: ./setmode.sh 1920 1440 165 DP-4

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <width> <height> <hz> <monitor>"
    exit 1
fi

WIDTH=$1
HEIGHT=$2
HZ=$3
MONITOR=$4

# Generate modeline using cvt
MODELINE=$(cvt $WIDTH $HEIGHT $HZ | grep Modeline | cut -d' ' -f2-)

# Extract the mode name (first quoted string after 'Modeline')
MODENAME=$(echo $MODELINE | awk '{print $1}' | tr -d '"')

echo "Adding mode: $MODENAME for monitor $MONITOR"

# Add the new mode
xrandr --newmode $MODELINE
xrandr --addmode $MONITOR $MODENAME

# Apply the mode
xrandr --output $MONITOR --mode $MODENAME

