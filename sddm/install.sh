#!/usr/bin/env bash
# Copy the hypr-dark SDDM theme into the system theme directory,
# prepare a system-readable wallpaper copy, optionally install the Nerd
# Font for the sddm user, and write the SDDM config drop-in that activates
# the theme.
# Run with: sudo ./sddm/install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="hypr-dark"
THEME_SRC="${SCRIPT_DIR}/themes/${THEME_NAME}"
THEME_DST="/usr/share/sddm/themes/${THEME_NAME}"
SDDM_CONF="/etc/sddm.conf.d/zz-${THEME_NAME}.conf"
SDDM_WALLPAPER_DIR="/var/lib/hypr"
SDDM_WALLPAPER="${SDDM_WALLPAPER_DIR}/current-wallpaper"
SDDM_BLURRED_WALLPAPER="${SDDM_WALLPAPER_DIR}/current-wallpaper-blurred.jpg"
USER_HOME="$(eval echo ~${SUDO_USER:-$USER})"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)."
    exit 1
fi

# ── 1. Copy theme into SDDM themes directory ──────────────────
echo "[1/4] Installing theme: ${THEME_SRC} -> ${THEME_DST}"
rm -rf "${THEME_DST}"
cp -r "${THEME_SRC}" "${THEME_DST}"

# ── 2. Prepare system-readable wallpaper path ───────────────────
echo "[2/4] Preparing SDDM wallpaper path: ${SDDM_WALLPAPER}"
mkdir -p "${SDDM_WALLPAPER_DIR}"
chmod 755 "${SDDM_WALLPAPER_DIR}"

if [[ -n "${SUDO_UID:-}" && -n "${SUDO_GID:-}" ]]; then
    chown "${SUDO_UID}:${SUDO_GID}" "${SDDM_WALLPAPER_DIR}"
fi

USER_CURRENT_WALLPAPER="${USER_HOME}/.config/hypr/current-wallpaper"

if [[ -e "${USER_CURRENT_WALLPAPER}" ]]; then
    cp -fL "${USER_CURRENT_WALLPAPER}" "${SDDM_WALLPAPER}"
    chmod 644 "${SDDM_WALLPAPER}"
    if command -v magick >/dev/null 2>&1; then
        magick "${SDDM_WALLPAPER}" -auto-orient -blur 0x10 -quality 92 "${SDDM_BLURRED_WALLPAPER}"
    else
        cp -f "${SDDM_WALLPAPER}" "${SDDM_BLURRED_WALLPAPER}"
    fi
    chmod 644 "${SDDM_BLURRED_WALLPAPER}"
    if [[ -n "${SUDO_UID:-}" && -n "${SUDO_GID:-}" ]]; then
        chown "${SUDO_UID}:${SUDO_GID}" "${SDDM_WALLPAPER}"
        chown "${SUDO_UID}:${SUDO_GID}" "${SDDM_BLURRED_WALLPAPER}"
    fi
else
    echo "      No current wallpaper found at ${USER_CURRENT_WALLPAPER}; run set-wallpaper.sh after install"
fi

# ── 3. Install font system-wide so the sddm user can access it ──
FONT_DIR="/usr/local/share/fonts/JetBrainsMonoNerdFont"
USER_FONT_DIR="${USER_HOME}/.local/share/fonts"

if [[ -d "${USER_FONT_DIR}" ]]; then
    echo "[3/4] Installing JetBrainsMono Nerd Font system-wide"
    mkdir -p "${FONT_DIR}"
    cp -u "${USER_FONT_DIR}"/JetBrainsMonoNerd*.ttf "${FONT_DIR}/" 2>/dev/null || true
    fc-cache -f "${FONT_DIR}"
else
    echo "[3/4] No user font dir found at ${USER_FONT_DIR}; skipping font install"
fi

# ── 4. Write SDDM config drop-in ────────────────────────────────
echo "[4/4] Writing SDDM config: ${SDDM_CONF}"
cat > "${SDDM_CONF}" << 'EOF'
[Theme]
Current=hypr-dark
CursorTheme=capitaine-cursors
Font=JetBrainsMono Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

[Users]
MaximumUid=60000
MinimumUid=1000
EOF

echo "Done. Restart SDDM to see changes (or reboot)."
