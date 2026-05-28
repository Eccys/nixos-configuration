#!/usr/bin/env bash

# Load environment variables from .env if it exists
if [ -f "$HOME/.config/hypr/.env" ]; then
    source "$HOME/.config/hypr/.env"
fi

INPUT_VAL="$1"

# Check if INPUT_VAL is a valid variable name that is defined in the shell
RESOLVED_TEXT=""
case "$INPUT_VAL" in
    [a-zA-Z_][a-zA-Z0-9_]*)
        eval RESOLVED_TEXT=\$$INPUT_VAL
        ;;
esac

# Fallback to literal if the variable isn't defined
if [ -z "$RESOLVED_TEXT" ]; then
    RESOLVED_TEXT="$INPUT_VAL"
fi

if [ "$2" = "cmd" ]; then
    TEXT=$(eval "$RESOLVED_TEXT")
else
    TEXT="$RESOLVED_TEXT"
fi

# Backup current clipboard
OLD_CLIP=$(wl-paste -n 2>/dev/null)

# Copy new text
echo -n "$TEXT" | wl-copy

# Paste using Hyprland's sendshortcut dispatcher targeting the active window
hyprctl dispatch sendshortcut "CTRL,v,activewindow"

# Restore old clipboard contents
if [ -n "$OLD_CLIP" ]; then
    echo -n "$OLD_CLIP" | wl-copy
fi

# Remove the temporary macro text from cliphist history to keep clipboard history clean
(cliphist delete-query "$TEXT") &
