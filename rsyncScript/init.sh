#!/bin/bash

source "$SCRIPT_DIR/config"

# Check if kdialog is installed TODO: move to init script and add cronjob
if ! command -v kdialog &> /dev/null; then
    echo "Error: kdialog is not installed. Please install kdialog."
    notify-send -a "Rsync Data Backup" --urgency=critical "Error: kdialog is not installed." "Backup canceled. Please install kdialog."
    exit 1
fi

DESTINATION_CONTENTS=$(ls -A "$destination")
# Prompt action if destination directory is not empty TODO: move to init script
if [ ! -z "$DESTINATION_CONTENTS" ]; then
    kdialog --title "Rsync Data Backup" --warningcontinuecancel "Destination is not empty\nDestination: '$destination'\n\nDo you wish to continue anyway?" "Contents of the destination directory:\n\n$DESTINATION_CONTENTS"

    if [ $? == 1 ] ; then
        kdialog --title "Rsync Data Backup canceled." --passivepopup "Next Backup is schedulded in 15 Minutes." 10
        exit 1
    fi
fi