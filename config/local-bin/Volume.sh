#!/usr/bin/env bash
#
# ===================================================================
# Scripts for volume and mic controls with optional sound feedback.
#
# Combines volume control logic with a sound player.
# Depends on: pamixer, pipewire-media-session (pw-play) or pulseaudio (pa-play)
# ===================================================================

set -o pipefail

# --- Sound Configuration ---
# Master switch to enable or disable sound feedback for this script.
play_sounds=true

# Set the theme for the system sounds (e.g., "freedesktop", "sound-theme-freedesktop").
sound_theme="freedesktop"

# Toggle sound for specific actions.
play_volume_sound=true     # Sound for volume change and mute toggle.
play_mic_toggle_sound=true # Sound for microphone mute toggle.

# --- Sound Player Function (Integrated from Sound.sh) ---
play_sound() {
    # Exit if master sound switch is off.
    if [[ "$play_sounds" != true ]]; then
        return 0
    fi

    local sound_type="$1"
    local sound_option=""

    # Determine which sound to play based on the argument.
    case "$sound_type" in
    "volume")
        if [[ "$play_volume_sound" != true ]]; then return 0; fi
        sound_option="audio-volume-change.*"
        ;;
    "mic_toggle")
        if [[ "$play_mic_toggle_sound" != true ]]; then return 0; fi
        # We can use the same sound as volume change, or choose another.
        sound_option="audio-volume-change.*"
        ;;
    *)
        # Silently ignore unknown sound types.
        return 1
        ;;
    esac

    # --- Sound File Lookup Logic ---
    # Set directory defaults for system sounds.
    local systemDIR
    if [ -d "/run/current-system/sw/share/sounds" ]; then
        systemDIR="/run/current-system/sw/share/sounds" # NixOS
    else
        systemDIR="/usr/share/sounds" # Standard Linux
    fi
    local userDIR="$HOME/.local/share/sounds"
    local defaultTheme="freedesktop"

    # Prefer user's theme, then system's theme, finally fall back to freedesktop default.
    local sDIR="$systemDIR/$defaultTheme" # Fallback directory
    if [ -d "$userDIR/$sound_theme" ]; then
        sDIR="$userDIR/$sound_theme"
    elif [ -d "$systemDIR/$sound_theme" ]; then
        sDIR="$systemDIR/$sound_theme"
    fi

    # Find the sound file in the chosen theme directory or its inherited theme.
    local sound_file
    sound_file=$(find -L "$sDIR/stereo" -name "$sound_option" -print -quit 2>/dev/null)

    # If not found, check the inherited theme.
    if ! test -f "$sound_file"; then
        local iTheme
        iTheme=$(grep -i "Inherits" "$sDIR/index.theme" | cut -d "=" -f 2 | tr -d '[:space:]')
        if [[ -n "$iTheme" ]] && [ -d "$sDIR/../$iTheme" ]; then
            local iDIR="$sDIR/../$iTheme"
            sound_file=$(find -L "$iDIR/stereo" -name "$sound_option" -print -quit 2>/dev/null)
        fi
    fi

    # If still not found, search in the ultimate default directories as a last resort.
    if ! test -f "$sound_file"; then
        sound_file=$(find -L "$userDIR/$defaultTheme/stereo" -name "$sound_option" -print -quit 2>/dev/null)
    fi
    if ! test -f "$sound_file"; then
        sound_file=$(find -L "$systemDIR/$defaultTheme/stereo" -name "$sound_option" -print -quit 2>/dev/null)
    fi

    # Play the sound if the file was found.
    if test -f "$sound_file"; then
        # Use pw-play (PipeWire) if available, otherwise fall back to pa-play (PulseAudio).
        # The & makes it run in the background to not block the script.
        (pw-play "$sound_file" || pa-play "$sound_file") &>/dev/null &
    else
        # Optional: uncomment to debug if sounds are not found.
        # echo "Debug: Sound file for '$sound_option' not found." >&2
        return 1
    fi
}

# --- Volume and Mic Control Functions ---

# Get Volume
get_volume() {
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        echo "Muted"
    else
        echo "$(pamixer --get-volume) %"
    fi
}

# Increase Volume
inc_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        pamixer -u # Unmute first
    fi
    pamixer -i 5 --allow-boost --set-limit 150
    play_sound "volume"
}

# Decrease Volume
dec_volume() {
    pamixer -d 5
    play_sound "volume"
}

# Toggle Mute
toggle_mute() {
    pamixer -t
    play_sound "volume"
}

# Toggle Mic Mute
toggle_mic() {
    pamixer --default-source -t
    play_sound "mic_toggle"
}

# Get Microphone Volume
get_mic_volume() {
    if [[ "$(pamixer --default-source --get-mute)" == "true" ]]; then
        echo "Muted"
    else
        echo "$(pamixer --default-source --get-volume) %"
    fi
}

# Increase MIC Volume
inc_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        pamixer --default-source -u # Unmute first
    fi
    pamixer --default-source -i 5
    # No sound for mic volume change to avoid being too noisy, but you can add it:
    # play_sound "mic_toggle"
}

# Decrease MIC Volume
dec_mic_volume() {
    pamixer --default-source -d 5
    # No sound for mic volume change to avoid being too noisy, but you can add it:
    # play_sound "mic_toggle"
}

# --- Main Execution Block ---
# Execute the corresponding function based on the first argument.
case "$1" in
--get)
    get_volume
    ;;
--inc)
    inc_volume
    ;;
--dec)
    dec_volume
    ;;
--toggle)
    toggle_mute
    ;;
--toggle-mic)
    toggle_mic
    ;;
--mic-get)
    get_mic_volume
    ;;
--mic-inc)
    inc_mic_volume
    ;;
--mic-dec)
    dec_mic_volume
    ;;
*)
    # Default action: show current volume.
    get_volume
    ;;
esac
