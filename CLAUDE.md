# CLAUDE.md

## What this is

Personal dotfiles for an Arch Linux desktop running Hyprland + Waybar + SDDM, with Kitty/Zsh and macOS extras. Managed with GNU Stow.

## Repo structure

Each top-level directory is a stow package mirroring `$HOME`:

- `hypr/` - Hyprland, hyprpaper, hyprlock, hypridle, mako, xdg-portal configs + scripts
- `waybar/` - Waybar config (jsonc), CSS, helper scripts
- `kitty/` - Kitty terminal (loads per-OS overrides via `kitty.${KITTY_OS}.conf`)
- `zsh/` - `.zshrc` + Powerlevel10k config
- `desktop/` - XDG mimeapps, KDE globals, Dolphin
- `macos/` - macOS-only LaunchAgent + clipboard feedback
- `starship/`, `nvim/`, `yazi/` - present but not yet wired into bootstrap

Non-stow directories:

- `sddm/` - SDDM theme deployed via symlink (`sudo bash sddm/install.sh`), not stow

## Key files

- `bootstrap.sh` - Full setup: packages (pacman), stow, SDDM deploy, host overrides, services
- `sddm/install.sh` - Symlinks theme to `/usr/share/sddm/themes/`, installs fonts, writes config drop-in to `/etc/sddm.conf.d/zz-hypr-dark.conf`
- `hypr/.config/hypr/host.local.conf.example` - Template for machine-specific overrides (monitors, input devices)
- `pkglist.txt` - Package snapshot reference

## Conventions

- **Stow layout**: files go under `<package>/.config/<app>/` (or `<package>/.<file>` for home-level dotfiles like `.zshrc`)
- **Scripts**: shell scripts live alongside their parent config (e.g. `waybar/.config/waybar/scripts/`, `hypr/.config/hypr/scripts/`). Mark executable.
- **SDDM is special**: it targets system paths (`/usr/share/sddm/themes/`, `/etc/sddm.conf.d/`), so it uses a dedicated install script with `sudo`, not stow
- **Host overrides**: machine-specific Hyprland config goes in `~/.config/hypr/host.local.conf` (not tracked in git)
- **Commit style**: imperative, descriptive summaries (e.g. "Refine Waybar telemetry and clipboard UX across platforms")
- **Target OS**: Arch Linux (pacman). macOS support is limited to Kitty clipboard extras.
