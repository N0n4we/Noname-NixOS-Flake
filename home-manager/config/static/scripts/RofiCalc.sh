#!/usr/bin/env bash

# /* Calculator (using qalculate) and rofi */

set -o pipefail

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
fi

# main function

while true; do
    result=$(
        rofi -i -dmenu -p "" \
            -mesg "$result = $calc_result" \
            -location 2 -font "Noto Sans Mono CJK SC 32" -theme-str 'window { width: 60%; height: 170px; } entry { placeholder: "Rofi Calc"; horizontal-align: 0.5; } textbox { horizontal-align: 0.5; }'

    )

    if [ $? -ne 0 ]; then
        exit
    fi

    if [ -n "$result" ]; then
        calc_result=$(qalc -t "$result")
        echo "$calc_result" | wl-copy
    fi
done
