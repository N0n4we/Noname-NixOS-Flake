#!/usr/bin/env bash
set -o pipefail

save_dir="${HOME}/Pictures"
filename="Screenshot_$(date "+%d-%b_%H-%M-%S")_${RANDOM}.png"
filepath="${save_dir}/${filename}"

mkdir -p "$save_dir"

finish_shot() {
    if [[ -f "$filepath" ]]; then
        wl-copy < "$filepath"
        notify-send "Screenshot" "Saved & Copied"
        if [[ "$1" == "edit" ]]; then
            ksnip "$filepath"
        fi
        if [[ "$1" == "show" ]]; then
            pqiv "$filepath"
        fi
    else
        notify-send -u low "Screenshot" "Canceled"
    fi
}

case "$1" in
--all)
    grim "$filepath"
    finish_shot
    ;;
--alledit)
    grim "$filepath"
    finish_shot "edit"
    ;;
--area)
    grim -g "$(slurp)" "$filepath"
    finish_shot
    ;;
--edit)
    grim -g "$(slurp)" "$filepath"
    finish_shot "edit"
    ;;
--show)
    grim -g "$(slurp)" "$filepath"
    finish_shot "show"
    ;;
*)
    echo "Usage: $0 {--all|--area|--edit|--alledit}"
    exit 1
    ;;
esac

exit 0
