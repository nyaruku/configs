#!/bin/bash

ZOOM_FILE="$HOME/.config/hyprmag_zoom_level"
[ ! -f $ZOOM_FILE ] && echo 1.5 > $ZOOM_FILE   # default zoom

zoom=$(cat $ZOOM_FILE)

if [ "$1" == "in" ]; then
    zoom=$(echo "$zoom + 0.1" | bc)
elif [ "$1" == "out" ]; then
    zoom=$(echo "$zoom - 0.1" | bc)
    (( $(echo "$zoom < 1.0" | bc) )) && zoom=1.0
fi

echo $zoom > $ZOOM_FILE
killall hyprmag 2>/dev/null
hyprmag -r 300 -s $zoom &

