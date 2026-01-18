#!/usr/bin/env bash

time=$(date "+%d-%b_%H-%M-%S")
dir="${HOME}/Videos/ScreenRecord"

notify_cmd_base="notify-send -t 10000"
notify_cmd_NOT="notify-send -u low"

notify_view() {
    local file_path="$1"
    local message="$2"

    if [[ -e "$file_path" ]]; then
        resp=$(timeout 5 ${notify_cmd_base} "ScreenRecord" "${message} Saved.")
        case "$resp" in
        action1)
            xdg-open "$file_path" &
            ;;
        action2)
            rm "$file_path" &
            ;;
        esac
    else
        ${notify_cmd_NOT} "ScreenRecord" "${message} NOT Saved."
    fi
}

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

recordall() {
    stop_recording
    local ret=$?
    if [[ $ret -eq 0 ]]; then
        exit 0
    fi

    local file_path="${dir}/ScreenRecord_${time}_${RANDOM}.mp4"

    if wf-recorder -f "$file_path" --audio & then
        echo $! >/tmp/wf-recorder.pid
        ${notify_cmd_NOT} "ScreenRecord" "Fullscreen recording started"
    else
        ${notify_cmd_NOT} "ScreenRecord" "Failed to start fullscreen recording"
    fi
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

    if wf-recorder -g "$geometry" -f "$file_path" --audio & then
        echo $! >/tmp/wf-recorder.pid
        ${notify_cmd_NOT} "ScreenRecord" "Area recording started"
    else
        ${notify_cmd_NOT} "ScreenRecord" "Failed to start area recording"
    fi
}

recordcut() {
    stop_recording
    local ret=$?
    if [[ $ret -eq 0 ]]; then
        exit 0
    fi

    local file_path="${dir}/ScreenRecord_${time}_cut.mp4"
    local geometry

    geometry=$(slurp)
    if [ -z "$geometry" ]; then
        ${notify_cmd_NOT} "ScreenRecord" "Cut selection cancelled"
        return 1
    fi

    if wf-recorder -g "$geometry" -f "$file_path" --audio & then
        local pid=$!
        echo $pid >/tmp/wf-recorder.pid
        ${notify_cmd_NOT} "ScreenRecord" "Cut recording started"
        wait $pid
        if [[ -e "$file_path" ]]; then
            losslesscut -- "$file_path"
            notify_view "$file_path" "Cut screen record"
        else
            ${notify_cmd_NOT} "ScreenRecord" "Recording failed, no file to trim"
        fi
    else
        ${notify_cmd_NOT} "ScreenRecord" "Failed to start cut recording"
    fi
}

if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
fi

case "$1" in
--all) recordall ;;
--area) recordarea ;;
--cut) recordcut ;;
*) echo "Available Options: --all, --area, --cut" ;;
esac

exit 0
