#!/bin/bash

commands_folder="commands"

# Exit if the folder doesn't exist
if [ ! -d "$commands_folder" ]; then
    echo "Error: The folder '$commands_folder' does not exist."
    exit 1
fi

# Check if there are any files in the folder
# Use the 'find' command to search for regular files in the 'commands' folder.
#   - "$commands_folder": Specifies the folder to search in.
#   - -maxdepth 1: Limits the search to the current directory.
#   - -type f: Considers only regular files (ignores directories and other file types).
files=$(find "$commands_folder" -maxdepth 1 -type f)

# Pipe the output to 'wc -l' to count the number of files.
files_count=$(find "$commands_folder" -maxdepth 1 -type f | wc -l)

if [ "$files_count" -eq 0 ]; then
    echo "Error: No files found in folder '$commands_folder'."
    exit 1
fi

echo
echo -e "\e[4m$files_count files found:\e[0m"
echo "$files"
echo

# Prompt user to proceed
read -p "Do you want to proceed? (y/N): " proceed

if [ "${proceed,,}" != "y" ]; then  # ${proceed,,} is used to convert the input to lowercase
    echo "Exiting without further execution."
    exit 0
fi
# echo

# Iterate over each file in the folder
for file in "$commands_folder"/*; do

    # Check if it's a file
    if [ -f "$file" ]; then

        echo
        echo -e "\e[1;34m$file\e[0m"

        # Check the file extension to determine if it's a script
        if [[ "$file" == *.sh ]]; then
            
            eval "$file"   # Eval evaluates and executes a string as a command in the current shell session.

            if [ $? -eq 0 ]; then   # $? holds the exit status (return code) of the last executed command. A command returns an exit status of 0 if it executed successfully
                echo -e "\e[32msuccess.\e[0m"
                echo
            else
                echo "could not execute $file"
                echo "Exiting without further execution."
                exit 1
            fi
        else

            # Read each line (command) from the file using a while loop.
            # || is the OR operator. It executes the command on the right only if the command on the left returned an error.
            # || [ -n "$command" ] is a failsafe.
            # If the last line would be missing a newline character, the read command would return false.
            # Therefore, the loop would terminate prematurely, and the last line (command) would not be run.
            # It ensures that the last line (command) is still run as long as the line is not empty.
            while read -r command || [ -n "$command" ]; do

                # Skip processing empty lines
                [ -z "$command" ] && continue

                echo -e "\e[1;35m$command\e[0m"
                eval "$command"

                if [ $? -eq 0 ]; then   # $? holds the exit status (return code) of the last executed command. A command returns an exit status of 0 if it executed successfully
                    echo -e "\e[32msuccess.\e[0m"
                    echo
                else
                    echo "Could not execute '$command' in '$file'."
                    echo "Exiting without further execution."
                    exit 1
                fi

            done < "$file"
        fi
    fi
done

echo
echo "All files were successfully executed."

