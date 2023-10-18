#!/bin/bash

# Get the current date and time for the log file name
current_datetime=$(date +"%Y%m%d_%H%M%S")
log_file="rename_operation_${current_datetime}.log"
continue_all=false  # Global variable to keep track of user choice

# Function to handle errors
handle_error() {
    local error_message=$1
    if $continue_all; then
        echo "$error_message - Continuing as per user choice" | tee -a $log_file
        return
    fi
    
    while true; do
        echo "$error_message"
        echo "Do you want to (Y)es to continue, (N)o to abort or (A)ll to continue for all future errors? Y/N/A: " | tee -a $log_file
        read -r user_choice
        case $user_choice in
            [Yy]* ) echo "Continuing..." | tee -a $log_file; break;;
            [Nn]* ) echo "Aborting..." | tee -a $log_file; exit 1;;
            [Aa]* ) echo "Continuing for all future errors..." | tee -a $log_file; continue_all=true; break;;
            * ) echo "Please answer with Y, N, or A.";;
        esac
    done
}

# Ensure a directory is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 DIRECTORY" | tee -a $log_file  # Append the error message to the log file
    exit 1
fi

# Convert the relative path to an absolute path
cd "$1" || handle_error "Failed to change directory to $1"  # New error handling call

DIRECTORY=$(pwd)
cd - || handle_error "Failed to revert to original directory"  # New error handling call

# Function to sanitize the names of files
sanitize_file_names() {
    local dir=$1
    find "$dir" -type f | while read -r item; do
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
            echo "Renaming file: $item to $dirpath/$final_basename" | tee -a $log_file  # Append info to log file
            mv "$item" "$dirpath/$final_basename"
        fi
    done
}

# Function to sanitize the names of directories
sanitize_dir_names() {
    local dir=$1
    find "$dir" -type d | sort -r | while IFS= read -r item; do
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
            echo "Renaming directory: $item to $dirpath/$final_basename" | tee -a $log_file  # Append info to log file
            mv "$item" "$dirpath/$final_basename"
        fi
    done
}

# Call the functions
sanitize_file_names "$DIRECTORY"
sanitize_dir_names "$DIRECTORY"
