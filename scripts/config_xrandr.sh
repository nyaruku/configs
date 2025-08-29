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

# Function to generate modeline using a given tool
generate_modeline() {
    local tool=$1
    local args=$2
    MODELINE=$( $tool $args 2>/dev/null | grep Modeline | cut -d' ' -f2- )
    echo $MODELINE
}

# Try cvt
MODELINE=$(generate_modeline cvt "$WIDTH $HEIGHT $HZ")

# If cvt fails, try cvt -r
if [ -z "$MODELINE" ]; then
    echo "cvt failed, trying reduced blanking..."
    MODELINE=$(generate_modeline cvt "-r $WIDTH $HEIGHT $HZ")
fi

# If still fails, try gtf
if [ -z "$MODELINE" ]; then
    echo "cvt -r failed, trying gtf..."
    MODELINE=$(generate_modeline gtf "$WIDTH $HEIGHT $HZ")
fi

# If still empty, exit
if [ -z "$MODELINE" ]; then
    echo "❌ Failed to generate modeline. Cannot continue."
    exit 1
fi

# Extract mode name
MODENAME=$(echo $MODELINE | awk '{print $1}' | tr -d '"')

echo "Adding mode: $MODENAME for monitor $MONITOR"

# Add mode
xrandr --newmode $MODELINE 2>/dev/null
if ! xrandr | grep -q "$MODENAME"; then
    echo "❌ Failed to add mode $MODENAME. Your GPU/monitor may not support it."
    exit 1
fi

xrandr --addmode $MONITOR $MODENAME

# Apply mode
xrandr --output $MONITOR --mode $MODENAME

