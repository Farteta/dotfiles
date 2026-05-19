#!/usr/bin/env bash
# Copy the hypr-dark SDDM theme into the system theme directory,
# optionally install the Nerd Font for the sddm user, and write the
# SDDM config drop-in that activates the theme.
# Run with: sudo ./sddm/install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="hypr-dark"
THEME_SRC="${SCRIPT_DIR}/themes/${THEME_NAME}"
THEME_DST="/usr/share/sddm/themes/${THEME_NAME}"
SDDM_CONF="/etc/sddm.conf.d/zz-${THEME_NAME}.conf"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)."
    exit 1
fi

# ── 1. Copy theme into SDDM themes directory ──────────────────
echo "[1/3] Installing theme: ${THEME_SRC} -> ${THEME_DST}"
rm -rf "${THEME_DST}"
cp -r "${THEME_SRC}" "${THEME_DST}"

# ── 2. Install font system-wide so the sddm user can access it ──
FONT_DIR="/usr/local/share/fonts/JetBrainsMonoNerdFont"
USER_FONT_DIR="$(eval echo ~${SUDO_USER:-$USER})/.local/share/fonts"

if [[ -d "${USER_FONT_DIR}" ]]; then
    echo "[2/3] Installing JetBrainsMono Nerd Font system-wide"
    mkdir -p "${FONT_DIR}"
    cp -u "${USER_FONT_DIR}"/JetBrainsMonoNerd*.ttf "${FONT_DIR}/" 2>/dev/null || true
    fc-cache -f "${FONT_DIR}"
else
    echo "[2/3] No user font dir found at ${USER_FONT_DIR}; skipping font install"
fi

# ── 3. Write SDDM config drop-in ────────────────────────────────
echo "[3/3] Writing SDDM config: ${SDDM_CONF}"
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
