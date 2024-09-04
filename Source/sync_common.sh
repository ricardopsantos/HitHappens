#!/bin/bash

clear

# Define constants for source and destination paths
SOURCE_DIR="./Common"
DEST_DIR="../../RJPS_Common"
BACKUPS_DIR="$DEST_DIR/backups"

# Define a list of files and directories to be preserved
SAFE_FILES=("backups" ".git" ".gitignore" ".swiftpm")

# Function to check if directories exist
check_directories() {
    if [ -d "$SOURCE_DIR" ] && [ -d "$DEST_DIR" ]; then
        return 0  # Success, can continue
    else
        echo "Either the source folder $SOURCE_DIR or the destination folder $DEST_DIR does not exist."
        return 1  # Failure, cannot continue
    fi
}

# Function to create a string of safe files for use in the find command
create_exclude_string() {
    EXCLUDE_STRING=""
    for item in "${SAFE_FILES[@]}"; do
        EXCLUDE_STRING+="! -name '$item' "
    done
}

# Function to synchronize content from SOURCE_DIR to DEST_DIR
sync_out() {
    # Create the backups directory if it doesn't exist
    mkdir -p "$BACKUPS_DIR"

    # Generate a timestamp for the backup file
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="$BACKUPS_DIR/backup_$TIMESTAMP.zip"

    # Create a zip backup of the DEST_DIR content, excluding the backups directory, suppressing the log output
    echo "Creating backup of $DEST_DIR..."
    zip -rq "$BACKUP_FILE" "$DEST_DIR" -x "$BACKUPS_DIR/*" > /dev/null

    if [ $? -eq 0 ]; then
        echo "Backup created successfully at $BACKUP_FILE."
    else
        echo "Failed to create backup. Aborting sync operation."
        return 1
    fi

    # Create exclude string for the find command
    create_exclude_string

    # Remove existing content in the DEST_DIR except the specified safe files and directories
    echo "Removing existing content from $DEST_DIR, except safe files and directories..."
    eval "find '$DEST_DIR' -mindepth 1 -maxdepth 1 $EXCLUDE_STRING -exec rm -rf {} +"

    # Perform the copy operation
    cp -R "$SOURCE_DIR"/* "$DEST_DIR"/
    echo "Content from $SOURCE_DIR has been copied to $DEST_DIR."
}

# Function to synchronize content from DEST_DIR to SOURCE_DIR (reverse operation)
sync_in() {
    # Create exclude string for the find command
    create_exclude_string

    # Remove existing content in the SOURCE_DIR except the specified safe files and directories
    echo "Removing existing content from $SOURCE_DIR, except safe files and directories..."
    eval "find '$SOURCE_DIR' -mindepth 1 -maxdepth 1 $EXCLUDE_STRING -exec rm -rf {} +"

    # Perform the copy operation, excluding safe files and directories
    echo "Copying content from $DEST_DIR to $SOURCE_DIR, excluding safe files and directories..."
    for item in "$DEST_DIR"/*; do
        # Extract the base name of the item
        base_item=$(basename "$item")
        # Check if the item is not in the safe list
        if [[ ! " ${SAFE_FILES[@]} " =~ " ${base_item} " ]]; then
            cp -R "$item" "$SOURCE_DIR"/
        else
            echo "Skipping $base_item as it is a safe file or directory."
        fi
    done
    echo "Content from $DEST_DIR has been copied to $SOURCE_DIR, excluding safe files and directories."
}

# Main execution
if check_directories; then
    # Prompt the user for confirmation
    echo "### Choose an operation:"
    echo " [1] : Sync out (from $SOURCE_DIR to $DEST_DIR)"
    echo " [2] : Sync in (from $DEST_DIR to $SOURCE_DIR)"
    echo " [3] : Cancel the operation"
    echo -n "Option? "
    read option
    case $option in
        [1] ) sync_out ;;
        [2] ) sync_in ;;
        [3] ) echo "Sync operation canceled." ;;
        * ) echo "Invalid option. Operation canceled." ;;
    esac
else
    echo "Sync operation aborted."
fi
