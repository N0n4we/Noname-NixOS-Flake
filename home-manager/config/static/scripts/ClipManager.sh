#!/usr/bin/env bash

set -o pipefail

if pidof rofi >/dev/null; then
    pkill rofi
fi

while true; do
    result=$(
        rofi -i -dmenu -p "" \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            < <(cliphist list)
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
