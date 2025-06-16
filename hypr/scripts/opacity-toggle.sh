#!/bin/bash

# Default values
NORMAL_OPACITY=1.0
LOW_OPACITY=0.7

# Get the current active window
active_win=$(hyprctl activewindow -j | jq -r '.address')

# Get the current opacity
current_opacity=$(hyprctl getoption animations:opacity -j | jq -r '.floatVal')

# Store current opacity in XDG_RUNTIME_DIR (ephemeral per session)
state_file="${XDG_RUNTIME_DIR}/.hypr_opacity_toggle"

if [[ -f $state_file ]]; then
    state=$(cat "$state_file")
else
    state="normal"
fi

if [[ "$state" == "normal" ]]; then
    hyprctl dispatch opacity "$active_win $LOW_OPACITY"
    echo "dim" > "$state_file"
else
    hyprctl dispatch opacity "$active_win $NORMAL_OPACITY"
    echo "normal" > "$state_file"
fi