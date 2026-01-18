#!/usr/bin/env bash
# Clipboard Manager. This script uses cliphist, rofi, and wl-copy.

set -o pipefail

# Variables
msg='CTRL DEL - del | ALT DEL - wipe'

# Check if rofi is already running
if pidof rofi >/dev/null; then
    pkill rofi
fi

while true; do
    result=$(
        rofi -i -dmenu -p "" \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            -mesg "$msg" < <(cliphist list)
    )

    case "$?" in
    1)
        exit
        ;;
    0)
        case "$result" in
        "")
            continue
            ;;
        *)
            cliphist decode <<<"$result" | wl-copy
            exit
            ;;
        esac
        ;;
    10)
        cliphist delete <<<"$result"
        ;;
    11)
        cliphist wipe
        ;;
    esac
done
