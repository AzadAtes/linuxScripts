#!/bin/bash

# Get the list of windows sorted by most recently used
window_list=$(xdotool search --onlyvisible --class firefox)

if [ -z "$window_list" ]; then
    # If no Firefox windows are found, start a new instance
    firefox &
else
    # Get the last window from the list
    last_window=$(echo "$window_list" | tail -n 1)
    
    # Activate the last used window
#    wmctrl -ia "$last_window"
    wmctrl -i -r "$last_window" -e 0,1920,0,-1,-1
    wmctrl -i -r "$last_window" -b add,maximized_vert,maximized_horz
    wmctrl -ia "$last_window"
fi

