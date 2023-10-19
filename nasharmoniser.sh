#!/bin/bash
 
# Get the current date and time for the log file name
current_datetime=$(date +"%Y%m%d_%H%M%S")
log_file="rename_operation_${current_datetime}.log"
 
# Capture both stdout and stderr in the log file
exec &> >(tee -a "$log_file")
 
continue_all=false  # Global variable to keep track of user choice
 
# Function to handle errors
handle_error() {
    local error_message=$1
    echo "$error_message"
    echo "Do you want to (Y) continue, (N) abort, or (A) continue ignoring all future errors? Y/N/A: "
    read -r user_choice
 
    case $user_choice in
        [Yy]* ) echo "Continuing..." ;;
        [Nn]* ) echo "Aborting..."; exit 1 ;;
        [Aa]* ) echo "Continuing and ignoring all future errors..."; continue_all=true ;;
        * ) echo "Please answer with Y, N, or A." ;;
    esac
}
 
# Ensure a directory is provided as an argument
if [ "$#" -ne 1 ]; then
    handle_error "Usage: $0 DIRECTORY"
    exit 1
fi
 
# Convert the relative path to an absolute path
cd "$1" || handle_error "Failed to change directory to $1"
DIRECTORY=$(pwd)
cd - || handle_error "Failed to revert to original directory"
 
# Function to sanitize the names of files
sanitize_file_names() {
    local dir=$1
    find "$dir" -type f -print0 | while IFS= read -r -d '' item; do
        local dirpath=$(dirname "$item")
        local basename=$(basename "$item")
        local new_basename=$(echo "$basename" | sed -E 's/^[[:space:]]+/_/g; s/[\\/:*?"<>|]/_/g' | sed 's/ \./_./g')
        if [[ "$basename" != "$new_basename" ]]; then
            local final_basename=$new_basename
            local counter=1
            while [[ -e "$dirpath/$final_basename" ]]; do
                final_basename="${new_basename%.*}_$counter.${new_basename##*.}"
                counter=$((counter + 1))
            done
            echo "Renaming file: $item to $dirpath/$final_basename"
            mv "$item" "$dirpath/$final_basename" || handle_error "Failed to rename $item to $dirpath/$final_basename"
        fi
    done
}
 
# Function to sanitize the names of directories
sanitize_dir_names() {
    local dir=$1
    find "$dir" -type d -print0 | sort -z -r | while IFS= read -r -d '' item; do
        local dirpath=$(dirname "$item")
        local basename=$(basename "$item")
        local new_basename=$(echo "$basename" | sed -E 's/^[[:space:]]+/_/g; s/[\\/:*?"<>|]/_/g' | sed 's/ \+/ /g' | awk '{gsub(/ +$/,"_"); print}')
        if [[ "$basename" != "$new_basename" ]]; then
            local final_basename=$new_basename
            local counter=1
            while [[ -e "$dirpath/$final_basename" ]]; do
                final_basename="${new_basename}_$counter"
                counter=$((counter + 1))
            done
            echo "Renaming directory: $item to $dirpath/$final_basename"
            mv "$item" "$dirpath/$final_basename" || handle_error "Failed to rename $item to $dirpath/$final_basename"
        fi
    done
}
 
# Call the functions
sanitize_file_names "$DIRECTORY"
sanitize_dir_names "$DIRECTORY"
