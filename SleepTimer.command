#!/bin/bash

# Check if this is a restart with the same duration
if [ -n "$1" ]; then
    mins=$1
    isRestart=true
else
    # Prompt user for minutes (default 15)
    read -p "Sleep timer duration in minutes [default: 15]: " mins
    mins=${mins:-15}
    isRestart=false
fi

# Use bc to handle floating-point multiplication
totalDelay=$(echo "$mins * 60" | bc)
totalDelay=${totalDelay%.*}  # remove decimal portion for use in sleep

# Get current system volume
currentVol=$(osascript -e 'output volume of (get volume settings)')

# Start caffeinate to prevent system sleep and store its process ID
caffeinate -d -i -t $((totalDelay + 90)) &
caffeinate_pid=$!

# Dim screen on first run only, and do it after 3 seconds instead of 15
if [ "$isRestart" = false ]; then
    echo "Timer started for $mins minutes. Screen will dim in 3 seconds."
    sleep 3
    /usr/local/bin/brightness 0
    # Wait until final 5 seconds
    sleep $((totalDelay - 3 - 5))
else
    echo "Timer restarted for $mins minutes."
    # Already dimmed, so just wait until final 5 seconds
    sleep $((totalDelay - 5))
fi

# Fade out volume over 5 seconds
echo "Fading out volume..."
for i in {0..9}; do
    newVol=$(echo "$currentVol * (1 - $i / 10)" | bc -l)
    osascript -e "set volume output volume $(printf "%.0f" "$newVol")"
    sleep 0.5
done

# Activate Safari and pause playback
osascript -e 'tell application "Safari" to activate'
sleep 1
osascript -e 'tell application "System Events" to keystroke space'
sleep 1

# Activate Terminal to capture spacebar press
osascript -e 'tell application "Terminal" to activate'
sleep 1
osascript -e "set volume output volume $currentVol"

# Wait 60 seconds for spacebar press
echo "Paused. Press spacebar within 60 seconds to restart timer..."
python3 "$(dirname "$0")/wait_for_space.py"

if [ $? -eq 0 ]; then
    echo "Spacebar pressed, resuming playback and restarting timer with $mins minutes..."
    # Activate Safari and resume playback
    osascript -e 'tell application "Safari" to activate'
    sleep 1
    osascript -e 'tell application "System Events" to keystroke space'
    # Wait briefly before restarting the timer
    sleep 2
    # Restart the timer with the same duration
    exec "$0" "$mins"
else
    echo "Timer ended. No spacebar press. Allowing sleep..."
    kill $caffeinate_pid
fi
