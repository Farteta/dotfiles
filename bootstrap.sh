#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"

INSTALL_PACKAGES=1
ENABLE_SERVICES=1
DEPLOY_SDDM=1
INSTALL_HYPR_PLUGINS=1

for arg in "$@"; do
  case "$arg" in
    --no-packages) INSTALL_PACKAGES=0 ;;
    --no-services) ENABLE_SERVICES=0 ;;
    --no-sddm) DEPLOY_SDDM=0 ;;
    --no-hypr-plugins) INSTALL_HYPR_PLUGINS=0 ;;
    *)
      echo "Unknown flag: $arg"
      echo "Usage: $0 [--no-packages] [--no-services] [--no-sddm] [--no-hypr-plugins]"
      exit 2
      ;;
  esac
done

BACKUP_ROOT="${XDG_STATE_HOME:-${HOME}/.local/state}/dotfiles-backups/bootstrap-$(date +%Y%m%d-%H%M%S)"
BACKUP_CREATED=0

target_exists() {
  [[ -e "$1" || -L "$1" ]]
}

backup_target() {
  local target="$1"
  local rel="${target#${TARGET_HOME}/}"
  local backup_path="${BACKUP_ROOT}/${rel}"

  mkdir -p "$(dirname "${backup_path}")"
  mv "${target}" "${backup_path}"
  BACKUP_CREATED=1
  echo "Backed up ${target} -> ${backup_path}"
}

install_hypr_edgehover() {
  local plugin_name="hypr-edgehover"
  local plugin_repo="https://github.com/gfhdhytghd/hypr-edgehover"
  local needs_add=1

  if ! command -v hyprpm >/dev/null 2>&1; then
    echo "hyprpm not found; skipping ${plugin_name} install"
    return
  fi

  hyprpm update || {
    echo "Failed to update Hyprland plugin headers; run: hyprpm update"
    return
  }

  if hyprpm list 2>/dev/null | grep -Fq "${plugin_name}"; then
    needs_add=0
  fi

  if [[ "${needs_add}" -eq 1 ]]; then
    hyprpm add "${plugin_repo}" || {
      echo "Failed to add ${plugin_name}; run: hyprpm add ${plugin_repo}"
      return
    }
  fi

  hyprpm enable "${plugin_name}" || {
    echo "Failed to enable ${plugin_name}; run: hyprpm enable ${plugin_name}"
    return
  }

  hyprpm update || {
    echo "Failed to update Hyprland plugins; run: hyprpm update"
    return
  }

  hyprpm reload || {
    echo "Failed to reload Hyprland plugins; restart Hyprland or run: hyprpm reload"
  }
}

prepare_stow_package() {
  local package="$1"
  local package_dir="${REPO_DIR}/${package}"
  local rel src target src_real target_real

  while IFS= read -r -d '' src; do
    rel="${src#${package_dir}/}"
    target="${TARGET_HOME}/${rel}"

    if [[ -L "${target}" ]]; then
      src_real="$(readlink -f "${src}")"
      target_real="$(readlink -f "${target}")"
      if [[ "${target_real}" == "${src_real}" ]]; then
        backup_target "${target}"
      fi
    elif target_exists "${target}" && [[ ! -d "${target}" ]]; then
      backup_target "${target}"
    fi
  done < <(find "${package_dir}" -mindepth 1 -type d -print0)

  while IFS= read -r -d '' src; do
    rel="${src#${package_dir}/}"
    target="${TARGET_HOME}/${rel}"

    if target_exists "${target}"; then
      src_real="$(readlink -f "${src}")"
      target_real="$(readlink -f "${target}")"
      if [[ "${target_real}" != "${src_real}" ]]; then
        backup_target "${target}"
      fi
    fi
  done < <(find "${package_dir}" \( -type f -o -type l \) -print0)
}

PACKAGES=(
  base-devel
  git
  stow
  hyprland
  hyprpm
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
  sddm
  qt6-5compat
)

STOW_PACKAGES=(
  desktop
  hypr
  kitty
  rofi
  waybar
  zsh
)

echo "[1/6] Installing packages"
if [[ "$INSTALL_PACKAGES" -eq 1 ]]; then
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed "${PACKAGES[@]}"
  else
    echo "pacman not found; skipping package installation"
  fi
else
  echo "Skipping package installation (--no-packages)"
fi

echo "[2/6] Stowing dotfiles into ${TARGET_HOME}"
if ! command -v stow >/dev/null 2>&1; then
  echo "GNU stow is required. Install it first."
  exit 1
fi
if ! stow -n -d "${REPO_DIR}" -t "${TARGET_HOME}" "${STOW_PACKAGES[@]}" >/dev/null 2>&1; then
  echo "Existing files conflict with stow targets; backing them up first"
  for package in "${STOW_PACKAGES[@]}"; do
    prepare_stow_package "${package}"
  done
fi
stow -d "${REPO_DIR}" -t "${TARGET_HOME}" "${STOW_PACKAGES[@]}"
if [[ "${BACKUP_CREATED}" -eq 1 ]]; then
  echo "Existing files were backed up under ${BACKUP_ROOT}"
fi

echo "[3/6] Deploying SDDM theme (requires sudo)"
if [[ "${DEPLOY_SDDM}" -eq 1 && -f "${REPO_DIR}/sddm/install.sh" ]]; then
  sudo "${REPO_DIR}/sddm/install.sh"
elif [[ "${DEPLOY_SDDM}" -eq 0 ]]; then
  echo "Skipping SDDM deploy (--no-sddm)"
fi

echo "[4/6] Ensuring Hyprland host override file exists"
HOST_TEMPLATE="${REPO_DIR}/hypr/.config/hypr/host.lua.example"
HOST_LOCAL="${TARGET_HOME}/.config/hypr/host.lua"
if [[ ! -f "${HOST_LOCAL}" ]]; then
  install -Dm644 "${HOST_TEMPLATE}" "${HOST_LOCAL}"
  {
    echo
    echo "-- Hostname: $(hostname -s)"
  } >> "${HOST_LOCAL}"
  echo "Created ${HOST_LOCAL}"
fi

echo "[5/6] Installing Hyprland plugins"
if [[ "${INSTALL_HYPR_PLUGINS}" -eq 1 ]]; then
  install_hypr_edgehover
else
  echo "Skipping Hyprland plugins (--no-hypr-plugins)"
fi

echo "[6/6] Enabling services"
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
