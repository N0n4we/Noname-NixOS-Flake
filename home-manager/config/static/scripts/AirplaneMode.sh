#!/usr/bin/env bash
# Airplane Mode. Turning on or off all wifi using rfkill.

set -o pipefail

# Check if any wireless device is blocked
wifi_blocked=$(rfkill list wifi | grep -o "Soft blocked: yes")

if [ -n "$wifi_blocked" ]; then
    rfkill unblock wifi
    notify-send -u low " Airplane" " mode: OFF"
else
    rfkill block wifi
    notify-send -u low " Airplane" " mode: ON"
fi
