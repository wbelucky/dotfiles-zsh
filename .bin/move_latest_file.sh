#!/bin/bash

TARGET_DIR="$1"
SOURCE_NAME="$2"

if [ -z "$TARGET_DIR" ]; then
    echo "Usage: $0 <target_directory> [source_name]" >&2
    echo "  source_name defaults to 'Pictures/Screenshots'" >&2
    exit 1
fi

if [ -z "$SOURCE_NAME" ]; then
    SOURCE_NAME="Pictures/Screenshots"
fi

SOURCE_DIR=""
if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null; then
    WIN_USERPROFILE_PATH=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
    if [ -z "$WIN_USERPROFILE_PATH" ]; then
        echo "Error: Could not get Windows user profile path." >&2
        exit 1
    fi

    WIN_SOURCE_NAME=$(echo "$SOURCE_NAME" | sed 's|/|\\|g')
    WIN_SOURCE_PATH="${WIN_USERPROFILE_PATH}\\${WIN_SOURCE_NAME}"
    SOURCE_DIR=$(wslpath -u "$WIN_SOURCE_PATH" 2>/dev/null)
    if [ -z "$SOURCE_DIR" ]; then
        echo "Error: Could not convert Windows path to WSL path: $WIN_SOURCE_PATH" >&2
        exit 1
    fi
else
    SOURCE_DIR="${HOME}/${SOURCE_NAME}"
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory not found: $SOURCE_DIR" >&2
    exit 1
fi

mkdir -p "$TARGET_DIR" || { echo "Error: Could not create target directory: $TARGET_DIR" >&2; exit 1; }

LATEST_BASENAME=$(ls -t -A "$SOURCE_DIR" | head -n 1)

if [ -z "$LATEST_BASENAME" ]; then
    echo "Error: No files found in source directory: $SOURCE_DIR" >&2
    exit 1
fi

SOURCE_PATH="${SOURCE_DIR}/${LATEST_BASENAME}"
TARGET_PATH="${TARGET_DIR}/${LATEST_BASENAME}"

if [ ! -f "$SOURCE_PATH" ]; then
    echo "Error: Latest entry is not a file or does not exist: $SOURCE_PATH" >&2
    exit 1
fi

mv "$SOURCE_PATH" "$TARGET_PATH"

if [ $? -ne 0 ]; then
    echo "Error: Failed to move file from $SOURCE_PATH to $TARGET_PATH" >&2
    exit 1
fi

echo "$LATEST_BASENAME"
