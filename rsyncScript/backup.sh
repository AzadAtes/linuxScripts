#!/bin/bash

{
    trap 'kdialog --title "Rsync Data Backup FAILED" --error "Backup failed."; exit 1' ERR 

    # define directories and files
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) #TODO: RESEARCH
    
    source "$SCRIPT_DIR/config"

    RSYNC_COMMAND="rsync -a $SOURCE_DIR $DESTINATION_DIR"
    RSYNC_COMMAND_WITH_DELETE="$RSYNC_COMMAND --delete"
    RSYNC_COMMAND_WITH_DELETE_DRY_RUN="$RSYNC_COMMAND_WITH_DELETE -n"

    LOGS_DIR="$SCRIPT_DIR/rsyncLogs"
    FILES_TO_DELETE_FILE="$SCRIPT_DIR/filesToDelete.txt"

    # ensure source and destination directories exist
    for DIR in "$SOURCE_DIR" "$DESTINATION_DIR"; do
        if [ ! -d "$DIR" ]; then
            kdialog --title "Rsync Data Backup" --sorry "Directory does not exist:\n$DIR\n\nExiting."
            exit 1
        fi
    done

    # create directories and files if they don't exist
    mkdir -p "$LOGS_DIR"
    touch "$FILES_TO_DELETE_FILE"

    # make a dry run
    DRY_RUN_OUTPUT=$($RSYNC_COMMAND_WITH_DELETE_DRY_RUN) 
    PREV_FILES_TO_DELETE=$(cat "$FILES_TO_DELETE_FILE") # load files that would be deleted by --delete option from previous run
    FILES_TO_DELETE=$(echo "$DRY_RUN_OUTPUT" | grep deleting)  # extract the files that would be deleted from the dry run output
    echo "$FILES_TO_DELETE" > $FILES_TO_DELETE_FILE # override files to delete from previous run
}

runRsyncCommand () {
    COMMAND_OUTPUT=$($1 2>&1) # 2>&1 redirects stderr to stdout so we can store it in our variable
    if [ $? == 0 ] ; then
        kdialog --title "Rsync Data Backup Successful" --passivepopup "$1" 10
    else
        kdialog --title "Rsync Data Backup FAILED" --error "Command failed:\n$1\n\nCheck the Details or Logs for more Details.\nLog directory: $LOGS_DIR" "$COMMAND_OUTPUT"
    fi
    echo "$1" > $LOGS_DIR/rsyncLog_$(date +"%Y-%m-%d_%H:%M:%S").txt # save rsync command output to a log file
}

{
    trap '' ERR

    # if FILES_TO_DELETE is empty or has not changed since previous run, don't ask for user interaction and run the rsync command without the --delete option.
    if [ -z "$FILES_TO_DELETE" ] || [ "$FILES_TO_DELETE" = "$PREV_FILES_TO_DELETE" ]; then
        runRsyncCommand "$RSYNC_COMMAND"
    else
        while : ; do
        
            # ask for user interaction
            kdialog --title "Rsync Data Backup" \
            --warningyesnocancel "There are files present in the Destination which are missing in the Source\nDo you want to DELETE these files only present in the Destination?\n\nSource = $SOURCE_DIR          Destination = $DESTINATION_DIR" \
            "$FILES_TO_DELETE" \
            --yes-label "Yes - DELETE files" \
            --no-label "No - Keep files"

            case $? in

            0) # Yes
                input=$(kdialog --title "Rsync Data Backup" --inputbox "Type 'Delete' and press ok if you want to continue.\n -Files in the Source will be synced with Destination.\n -Files that are only present in the Destination will be DELETED." "")

                if [ $? == 0 ] ; then
                    if [ "$input" = "Delete" ] ; then
                        runRsyncCommand "$RSYNC_COMMAND_WITH_DELETE"
                        break
                    else
                        kdialog --title "Rsync Data Backup" --sorry "Invalid input."
                    fi
                fi
                ;;

            1) # No
                kdialog --title "Rsync Data Backup" --warningcontinuecancel "Are you sure you want to continue?\n -Files in the Source will be synced with Destination.\n -Files that are only present in the Destination will NOT be deleted.\n -You will not be prompted to delete these files until the list of files only present in the Destination changes."

                if [ $? == 0 ] ; then
                    runRsyncCommand "$RSYNC_COMMAND"
                    break
                fi
                ;;


            2) # Cancel TODO: implement the actual next schedule interval.
                kdialog --title "Rsync Data Backup Canceled." --passivepopup "Next Backup is schedulded in 15 Minutes." 10 
                break
                ;;

            *)
                kdialog --title "Rsync Data Backup" --passivepopup "Unknown Error." 99
                break
                ;;
            esac
        done
    fi
}