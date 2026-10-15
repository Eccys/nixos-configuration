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
        RESOLVED_TEXT="${!INPUT_VAL}"
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

# Copy new text safely (printf avoids echo flag parsing on strings starting with -n/-e)
printf '%s' "$TEXT" | wl-copy

# Paste using Hyprland's sendshortcut dispatcher targeting the active window
hyprctl dispatch sendshortcut "CTRL,v,activewindow"

# Allow the active Wayland client to read the pasted buffer before restoring clipboard
sleep 0.05

# Restore old clipboard contents (or clear if clipboard was previously empty)
if [ -n "$OLD_CLIP" ]; then
    printf '%s' "$OLD_CLIP" | wl-copy
else
    wl-copy --clear 2>/dev/null || true
fi

# Remove the temporary macro text from cliphist history to keep clipboard history clean
(cliphist delete-query "$TEXT") &