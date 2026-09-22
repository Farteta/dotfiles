#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    printf 'Usage: %s /path/to/wallpaper\n' "${0##*/}" >&2
    exit 2
fi

wallpaper="$(realpath -e "$1")"
current_link="${HOME}/.config/hypr/current-wallpaper"
sddm_wallpaper_dir="/var/lib/hypr"
sddm_wallpaper="${sddm_wallpaper_dir}/current-wallpaper"
sddm_blurred_wallpaper="${sddm_wallpaper_dir}/current-wallpaper-blurred.jpg"

mkdir -p "$(dirname "$current_link")"
ln -sfn "$wallpaper" "$current_link"

if [[ -d "$sddm_wallpaper_dir" && -w "$sddm_wallpaper_dir" ]]; then
    install -m 0644 "$wallpaper" "$sddm_wallpaper"
    if command -v magick >/dev/null 2>&1; then
        magick "$sddm_wallpaper" -auto-orient -blur 0x10 -quality 92 "$sddm_blurred_wallpaper"
    else
        install -m 0644 "$wallpaper" "$sddm_blurred_wallpaper"
    fi
    chmod 0644 "$sddm_blurred_wallpaper"
else
    printf 'SDDM wallpaper not updated; run sudo bash sddm/install.sh once to prepare %s\n' "$sddm_wallpaper_dir" >&2
fi

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl hyprpaper unload all >/dev/null 2>&1 || true
    hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true
    hyprctl hyprpaper wallpaper ",$wallpaper,cover" >/dev/null 2>&1 || true
fi

printf 'Current wallpaper: %s\n' "$wallpaper"
