#!/bin/bash

# 1. Check if 'entr' is installed
if ! command -v entr &> /dev/null; then
    echo "❌ Error: 'entr' is not installed."
    echo "Please install it first: brew install entr"
    exit 1
fi

# 2. Check if a filename was provided
if [ "$#" -ne 1 ]; then
    echo "📋 Usage: $0 <filename>"
    exit 1
fi

TARGET_FILE="$1"

# 3. Ensure the file actually exists
if [ ! -f "$TARGET_FILE" ]; then
    echo "❌ Error: File '$TARGET_FILE' does not exist."
    exit 1
fi

# 4. Resolve the absolute path of the file
if [[ "$TARGET_FILE" = /* ]]; then
    ABS_PATH="$TARGET_FILE"
else
    ABS_PATH="$(pwd)/$TARGET_FILE"
fi

FILE_URL="file://${ABS_PATH}"

# 5. Open/Set the file to the FIRST tab of the FIRST window in Chrome
echo "🚀 Launching Chrome and loading '$TARGET_FILE' into Tab 1..."
osascript -e 'on run argv
    tell application "Google Chrome"
        activate
        if not (exists window 1) then
            make new window
        end if
        set URL of tab 1 of window 1 to (item 1 of argv)
    end tell
end run' "$FILE_URL"

# 6. Watch the file and trigger a reload only on Tab 1 when it changes
echo "👀 Watching '$TARGET_FILE' for changes. Edit and save to see updates! (Ctrl+C to stop)"
echo "$ABS_PATH" | entr osascript -e '
    tell application "Google Chrome"
        tell tab 1 of window 1 to reload
    end tell
'
