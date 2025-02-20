#!/bin/bash

# Define the filename to search for
FILENAME="a.dmg"
# Define the SHA-256 hash to search for
HASH="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

# Initialize an empty variable to store filename matches
FILENAME_RESULTS=""
# Initialize an empty variable to store hash matches
HASH_RESULTS=""

# Search for files with the specified filename
echo "Searching for files named: $FILENAME..."
# Use find command to locate files matching the specified filename, suppressing permission errors
FILENAME_RESULTS=$(find / -type f -name "$FILENAME" 2>/dev/null)

# Search for files matching the specified hash
echo "Searching for files matching hash: $HASH..."
# Initialize an empty variable to store hash match results
HASH_RESULTS=""
# Use find to list all files and compute their SHA-256 hash, checking for a match
while IFS= read -r file; do
    # Compute the SHA-256 hash of the current file
    FILE_HASH=$(shasum -a 256 "$file" 2>/dev/null | awk '{print $1}')
    # Check if the computed hash matches the target hash
    if [[ "$FILE_HASH" == "$HASH" ]]; then
        # Store the matching file path and hash
        HASH_RESULTS+="$file: $FILE_HASH"$'\n'
    fi
done < <(find / -type f 2>/dev/null)

# Display results of filename search
echo -e "\nFilename Matches:"
echo "===================="
# Check if any files matched the specified filename
if [[ -n "$FILENAME_RESULTS" ]]; then
    while IFS= read -r file; do
        # Compute the SHA-256 hash of the matched file
        FILE_HASH=$(shasum -a 256 "$file" 2>/dev/null | awk '{print $1}')
        # Print the file path and its computed hash
        echo "$file: $FILE_HASH"
    done <<< "$FILENAME_RESULTS"
else
    # If no files matched, display a message
    echo "No matches found."
fi

# Display results of hash search
echo -e "\nHash Matches:"
echo "===================="
# Check if any files matched the specified hash
if [[ -n "$HASH_RESULTS" ]]; then
    # Print all files that matched the hash
    echo "$HASH_RESULTS"
else
    # If no files matched, display a message
    echo "No matches found."
fi
