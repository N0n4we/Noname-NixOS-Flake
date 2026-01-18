#!/usr/bin/env bash

time=$(date "+%d-%b_%H-%M-%S")
dir="${HOME}/Music/AudioRecord"

notify_cmd_base="notify-send -t 10000"
notify_cmd_NOT="notify-send -u low"

notify_view() {
    local file_path="$1"
    local message="$2"

    if [[ -e "$file_path" ]]; then
        resp=$(timeout 5 ${notify_cmd_base} "AudioRecord" "${message} Saved.")
        case "$resp" in
        action1)
            xdg-open "$file_path" &
            ;;
        action2)
            rm "$file_path" &
            ;;
        esac
    else
        ${notify_cmd_NOT} "AudioRecord" "${message} NOT Saved."
    fi
}

notify_stop() {
    local message="$1"
    ${notify_cmd_NOT} "AudioRecord" "$message"
}

recordall() {
    stop_recording
    [[ $? -eq 0 ]] && exit 0

    local file_path="${dir}/AudioRecord_${time}_${RANDOM}.wav"

    # 使用 @DEFAULT_MONITOR@ 捕获系统声音
    if parec --device=@DEFAULT_MONITOR@ --file-format=wav "$file_path" & then
        echo $! >/tmp/pw-record.pid
        ${notify_cmd_NOT} "AudioRecord" "System audio recording started"
    else
        ${notify_cmd_NOT} "AudioRecord" "Failed to start recording"
    fi
}

stop_recording() {
    if [[ -f /tmp/pw-record.pid ]]; then
        local pid=$(cat /tmp/pw-record.pid)
        if kill -TERM "$pid" 2>/dev/null; then
            rm /tmp/pw-record.pid
            return 0
        fi
    fi
    pkill -TERM parec && return 0
    return 1
}

recordcut() {
    stop_recording
    local ret=$?
    if [[ $ret -eq 0 ]]; then
        exit 0
    fi

    local file_path="${dir}/AudioRecord_${time}_cut.wav"

    if parec --device=@DEFAULT_MONITOR@ --file-format=wav "$file_path" & then
        local pid=$!
        echo $pid >/tmp/pw-record.pid
        ${notify_cmd_NOT} "AudioRecord" "Cut recording started"
        wait $pid
        if [[ -e "$file_path" ]]; then
            losslesscut -- "$file_path"
            notify_view "$file_path" "Cut audio record"
        else
            ${notify_cmd_NOT} "AudioRecord" "Recording failed, no file to cut"
        fi
    else
        ${notify_cmd_NOT} "AudioRecord" "Failed to start cut recording"
    fi
}

if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
fi

case "$1" in
--all) recordall ;;
--cut) recordcut ;;
*) echo "Available Options: --all, --cut" ;;
esac

exit 0
