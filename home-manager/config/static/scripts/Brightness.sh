#!/usr/bin/env bash
# Script for Monitor backlights (if supported) using brightnessctl

set -o pipefail

step=5 # INCREASE/DECREASE BY THIS VALUE

# Get brightness
get_backlight() {
	# 注意：在某些版本的 brightnessctl 中，百分比是第 5 个字段。
	# 如果此命令不工作，请尝试 'cut -d, -f5'
	brightnessctl -m | cut -d, -f4 | sed 's/%//'
}

# Change brightness
change_backlight() {
	local current_brightness
	current_brightness=$(get_backlight)

	# Calculate new brightness
	if [[ "$1" == "+${step}%" ]]; then
		new_brightness=$((current_brightness + step))
	elif [[ "$1" == "${step}%-" ]]; then
		new_brightness=$((current_brightness - step))
	fi

	# Ensure new brightness is within valid range
	if ((new_brightness < 5)); then
		new_brightness=5
	elif ((new_brightness > 100)); then
		new_brightness=100
	fi

	brightnessctl set "${new_brightness}%"
	# current=$new_brightness # 此变量仅用于通知，不再需要
	# notify_user           # 注释掉此行以禁用通知
}

# Execute accordingly
case "$1" in
"--get")
	get_backlight
	;;
"--inc")
	change_backlight "+${step}%"
	;;
"--dec")
	change_backlight "${step}%-"
	;;
*)
	get_backlight
	;;
esac
