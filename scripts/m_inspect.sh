#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <PID|ProcessName>"
    exit 1
fi

ARG=$1
PAGE_SIZE=$(getconf PAGESIZE)
INTERVAL=0.5  # seconds

# Determine PID
if [[ "$ARG" =~ ^[0-9]+$ ]]; then
    PID=$ARG
else
    PID=$(pgrep -n "$ARG")
    if [ -z "$PID" ]; then
        echo "No process found with name '$ARG'"
        exit 1
    fi
fi

# Initialize previous values
PREV_RES=0
PREV_SHR=0
PREV_VIRT=0

# Function to auto-scale bytes for display
scale_mem() {
    local BYTES=$1
    if (( BYTES >= 1024*1024*1024 )); then
        printf "%.2f GB" "$(awk "BEGIN {print $BYTES/1024/1024/1024}")"
    elif (( BYTES >= 1024*1024 )); then
        printf "%.2f MB" "$(awk "BEGIN {print $BYTES/1024/1024}")"
    elif (( BYTES >= 1024 )); then
        printf "%.2f KB" "$(awk "BEGIN {print $BYTES/1024}")"
    else
        printf "%d B" "$BYTES"
    fi
}

while true; do
    if [ ! -r /proc/$PID/statm ]; then
        echo "Process $PID terminated"
        exit 0
    fi

    read -a STATM < /proc/$PID/statm
    VIRT=${STATM[0]}
    RES=${STATM[1]}
    SHR=${STATM[2]}

    # Convert pages to bytes
    RES_B=$(( RES * PAGE_SIZE ))
    SHR_B=$(( SHR * PAGE_SIZE ))
    VIRT_B=$(( VIRT * PAGE_SIZE ))
    PRIV_B=$(( RES_B - SHR_B ))

    # Calculate deltas in bytes (integer arithmetic)
    if (( PREV_RES > 0 )); then
        DELTA_RES=$(( RES_B - PREV_RES ))
        DELTA_SHR=$(( SHR_B - PREV_SHR ))
        DELTA_VIRT=$(( VIRT_B - PREV_VIRT ))
        DELTA_PRIV=$(( PRIV_B - (PREV_RES - PREV_SHR) ))
    else
        DELTA_RES=0
        DELTA_SHR=0
        DELTA_VIRT=0
        DELTA_PRIV=0
    fi

    PREV_RES=$RES_B
    PREV_SHR=$SHR_B
    PREV_VIRT=$VIRT_B

    clear
    echo "Process PID: $PID"
    echo "RESIDENT: $(scale_mem $RES_B)   Δ: $(scale_mem $DELTA_RES)/sec"
    echo "SHARED:   $(scale_mem $SHR_B)   Δ: $(scale_mem $DELTA_SHR)/sec"
    echo "PRIVATE:  $(scale_mem $PRIV_B)   Δ: $(scale_mem $DELTA_PRIV)/sec"
    echo "VIRTUAL:  $(scale_mem $VIRT_B)   Δ: $(scale_mem $DELTA_VIRT)/sec"

    sleep $INTERVAL
done

