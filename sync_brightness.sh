#!/bin/bash

# Get the brightness of the first monitor (display 1)
brightness=$(ddcutil getvcp 10 --display 2 | grep -oP 'current value =\s*\K\d+')

# Set the brightness of the second monitor (display 2) to the same value
ddcutil setvcp 10 $brightness --display 1

echo "Brightness of display 2 set to $brightness"

