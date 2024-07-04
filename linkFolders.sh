#!/bin/bash

trap 'echo "An error occurred. Exiting.." && exit 1' ERR # exit the script if any command returns with an error

source_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) # Get the directory of the script
target_dir="$HOME"
blacklist=("lost+found") # Add blacklisted folder names here like this: blacklist=("lost+found" "other")

echo "Source Dir: $source_dir"
echo "Target Dir: $target_dir"
echo "Blacklisted Folders: $blacklist"

read -p "Do you want to continue? (y/N): " CHOICE

# Exit if the choice, converted to lowercase, is not "y" or "yes"
if [[ "${CHOICE,,}" != "y" && "${CHOICE,,}" != "yes" ]]; then
    echo "exiting.."
    exit 1
fi

cd "$target_dir" || { echo "Error: Failed to change directory to $target_dir"; exit $?; }

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
DARKGREEN='\033[0;36m'
NC='\033[0m' # No Color

for dir in "$source_dir"/*; do
    if [ -d "$dir" ]; then

        dir_name=$(basename "$dir")

        # Check if directory is blacklisted. Skip if it is.
        if [[ " ${blacklist[@]} " =~ " ${dir_name} " ]]; then
            echo -e "${BLUE}Skipping blacklisted directory '$dir_name'${NC}"
            continue
        fi

        # Check if dir_name does exist as a symlink. Skip If it does.
        if [ -L "$dir_name" ]; then 
            echo -e "${YELLOW}Symlink '$dir_name' already exists in target${NC}"
            continue
        fi

        # At this point we know that dir_name does not exist as a symlink. Create a symlink, if it also does not exist as a directory.
        if [ ! -e "$dir_name" ]; then 
            ln -s "$dir" .
            echo -e "${GREEN}Created symlink for $dir_name${NC}"
            continue
        fi

        # At this point we know that dir_name exists as a directory. Delete it and create a symlink, if it is empty.
        if [ -z "$(ls -A "$dir_name")" ]; then 
            #rm -rf "$dir_name"
            rmdir "$dir_name"
            ln -s "$dir" .
            echo -e "${DARKGREEN}Deleted existing empty directory '$dir_name' in target directory and created symlink for $dir_name${NC}"
            continue
        fi

        # if directory dir_name exists and is NOT empty, do nothing.
        echo -e "${RED}Directory '$dir_name' already exists in target directory and is not empty${NC}"
    fi
done

