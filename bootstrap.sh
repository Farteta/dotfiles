#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"

INSTALL_PACKAGES=1
ENABLE_SERVICES=1

for arg in "$@"; do
  case "$arg" in
    --no-packages) INSTALL_PACKAGES=0 ;;
    --no-services) ENABLE_SERVICES=0 ;;
    *)
      echo "Unknown flag: $arg"
      echo "Usage: $0 [--no-packages] [--no-services]"
      exit 2
      ;;
  esac
done

PACKAGES=(
  stow
  hyprland
  hyprpaper
  hyprlock
  hypridle
  mako
  wl-clipboard
  cliphist
  waybar
  grim
  slurp
  brightnessctl
  pavucontrol
  wireplumber
  rofi
  kitty
  dolphin
  ark
  gwenview
  micro
  yazi
  btop
  networkmanager
  nm-connection-editor
  blueman
  polkit-kde-agent
  xdg-desktop-portal
  xdg-desktop-portal-hyprland
  syncthing
)

STOW_PACKAGES=(
  desktop
  hypr
  kitty
  waybar
  zsh
)

echo "[1/4] Installing packages"
if [[ "$INSTALL_PACKAGES" -eq 1 ]]; then
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed "${PACKAGES[@]}"
  else
    echo "pacman not found; skipping package installation"
  fi
else
  echo "Skipping package installation (--no-packages)"
fi

echo "[2/4] Stowing dotfiles into ${TARGET_HOME}"
if ! command -v stow >/dev/null 2>&1; then
  echo "GNU stow is required. Install it first."
  exit 1
fi
stow -d "${REPO_DIR}" -t "${TARGET_HOME}" "${STOW_PACKAGES[@]}"

echo "[3/4] Ensuring Hyprland host override file exists"
HOST_TEMPLATE="${REPO_DIR}/hypr/.config/hypr/host.local.conf.example"
HOST_LOCAL="${TARGET_HOME}/.config/hypr/host.local.conf"
if [[ ! -f "${HOST_LOCAL}" ]]; then
  install -Dm644 "${HOST_TEMPLATE}" "${HOST_LOCAL}"
  {
    echo
    echo "# Hostname: $(hostname -s)"
  } >> "${HOST_LOCAL}"
  echo "Created ${HOST_LOCAL}"
fi

echo "[4/4] Enabling services"
if [[ "$ENABLE_SERVICES" -eq 1 ]]; then
  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable --now NetworkManager.service || true
    sudo systemctl enable --now bluetooth.service || true
    systemctl --user enable --now syncthing.service || true
  else
    echo "systemctl not found; skipping service enable"
  fi
else
  echo "Skipping service enable (--no-services)"
fi

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 || true
fi

echo "Done."
