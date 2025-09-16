#!/bin/bash
# Kill only GUI instances, ignoring other processes
for pid in $(pgrep -x flameshot); do
    kill -9 $pid
done

# Start new GUI
flameshot gui

