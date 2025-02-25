#!/bin/bash

# Define the target filename and hash
TARGET_FILE="a.exe"
TARGET_HASH="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

echo "[+] Searching for '$TARGET_FILE' using mdfind..."

# Search for the file using Spotlight (case-sensitive)
FOUND_FILES=$(mdfind "kMDItemFSName == '$TARGET_FILE'")

# If no files are found, exit early
if [ -z "$FOUND_FILES" ]; then
    echo "[-] No files named '$TARGET_FILE' found using Spotlight."
    exit 0
fi

echo "[+] Files found:"
echo "$FOUND_FILES"
echo ""

# Check hash for each found file
MATCH_FOUND=0
for FILE in $FOUND_FILES; do
    echo "[*] Calculating SHA-256 for: $FILE"
    
    # Compute SHA-256 hash of the file
    FILE_HASH=$(shasum -a 256 "$FILE" | awk '{print $1}')
    
    echo "    Computed Hash: $FILE_HASH"

    # Compare hashes
    if [[ "$FILE_HASH" == "$TARGET_HASH" ]]; then
        echo "[!!!] MATCH FOUND: $FILE"
        MATCH_FOUND=1
    fi
done

# Summary
if [[ "$MATCH_FOUND" -eq 1 ]]; then
    echo "[+] Matching file(s) found."
else
    echo "[-] No files matching the given hash were found."
fi

exit 0
