#!/usr/bin/env bash

time=$(date "+%d-%b_%H-%M-%S")
dir="${HOME}/Videos/ScreenRecord"

notify_cmd_base="notify-send -t 10000"
notify_cmd_NOT="notify-send -u low"

notify_stop() {
    local message="$1"
    ${notify_cmd_NOT} "ScreenRecord" "$message"
}

stop_recording() {
    if [[ -f /tmp/wf-recorder.pid ]]; then
        local pid
        pid=$(cat /tmp/wf-recorder.pid)
        if kill -TERM "$pid" 2>/dev/null; then
            rm /tmp/wf-recorder.pid
            notify_stop "Previous recording stopped and saved"
            return 0
        else
            rm /tmp/wf-recorder.pid
            return 1
        fi
    else
        if pkill -TERM wf-recorder; then
            notify_stop "Previous recording stopped"
            return 0
        fi
    fi
    return 1
}

recordarea() {
    stop_recording
    local ret=$?
    if [[ $ret -eq 0 ]]; then
        exit 0
    fi

    local file_path="${dir}/ScreenRecord_${time}_area.mp4"
    local geometry

    geometry=$(slurp)
    if [ -z "$geometry" ]; then
        ${notify_cmd_NOT} "ScreenRecord" "Area selection cancelled"
        return 1
    fi

    if wf-recorder --fps 30 -g "$geometry" -f "$file_path" --audio & then
        echo $! >/tmp/wf-recorder.pid
        ${notify_cmd_NOT} "ScreenRecord" "Area recording started"
    else
        ${notify_cmd_NOT} "ScreenRecord" "Failed to start area recording"
    fi
}

if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
fi

case "$1" in
--area) recordarea ;;
*) echo "Available Options: --area" ;;
esac

exit 0
