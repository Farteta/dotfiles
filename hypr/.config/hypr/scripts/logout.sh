#!/usr/bin/env sh

set -eu

confirm() {
    prompt="$1"
    message="$2"

    choice="$({ printf 'No\nYes\n'; } | rofi -dmenu -i -p "$prompt" -mesg "$message" -selected-row 0)" || exit 0
    [ "$choice" = "Yes" ]
}

action="$({ printf '  Lock\n󰤄  Suspend\n󰍃  Logout\n󰜉  Reboot\n  Shutdown\n'; } | rofi -dmenu -i -p 'Power' -mesg 'Choose an action' -selected-row 0)" || exit 0

case "$action" in
    '  Lock')
        exec loginctl lock-session
        ;;
    '󰤄  Suspend')
        confirm 'Suspend?' 'Lock and suspend this session?' || exit 0
        loginctl lock-session
        exec systemctl suspend
        ;;
    '󰍃  Logout')
        if command -v hyprshutdown >/dev/null 2>&1; then
            exec hyprshutdown
        fi
        confirm 'Logout?' 'End your Hyprland session?' || exit 0
        exec hyprctl dispatch exit
        ;;
    '󰜉  Reboot')
        confirm 'Reboot?' 'Restart this machine now?' || exit 0
        exec systemctl reboot
        ;;
    '  Shutdown')
        confirm 'Shutdown?' 'Power off this machine now?' || exit 0
        exec systemctl poweroff
        ;;
esac
