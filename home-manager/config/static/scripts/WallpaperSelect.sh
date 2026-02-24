#!/usr/bin/env bash
# This script for selecting wallpapers

set -o pipefail

# WALLPAPERS PATH
wallDIR="$HOME/.config/wallpapers"
wallpaper_current="$HOME/.config/background"

# swaybg config
SWAYBG_MODE="fill"  # fill, stretch, fit, center, tile

# Check if wallpaper directory exists
if [ ! -d "$wallDIR" ]; then
    echo "Error: Wallpaper directory $wallDIR does not exist!"
    exit 1
fi

# Get list of wallpapers
cd "$wallDIR" || exit 1

# Use rofi to select wallpaper
selected=$(ls -1 *.{jpg,jpeg,png,gif,bmp,webp} 2>/dev/null | rofi -dmenu -i -p "" -theme-str 'entry { placeholder: "Search Wallpaper..."; }')

# Check if user selected a wallpaper
if [ -z "$selected" ]; then
    echo "No wallpaper selected."
    exit 0
fi

# Full path to selected wallpaper
wallpaper_path="$wallDIR/$selected"

# Check if the selected file exists
if [ ! -f "$wallpaper_path" ]; then
    echo "Error: Selected wallpaper does not exist!"
    exit 1
fi

# Kill existing swaybg instance
pkill swaybg 2>/dev/null

# Set wallpaper using swaybg (run in background)
swaybg -i "$wallpaper_path" -m "$SWAYBG_MODE" &
disown

# Create/update symlink to current wallpaper
rm -f "$wallpaper_current"
ln -s "$wallpaper_path" "$wallpaper_current"

echo "Wallpaper set to: $selected"
