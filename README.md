# dotfiles

Personal dotfiles for Arch Linux with Hyprland, Waybar, SDDM, Kitty, and Zsh.

## Layout

- `desktop/` -> desktop defaults (`mimeapps`, KDE globals, Dolphin)
- `hypr/` -> Hyprland, hyprpaper, hyprlock, hypridle, mako, portal config
- `waybar/` -> Waybar config, style, helper scripts
- `kitty/` -> Kitty terminal config
- `sddm/` -> Custom SDDM login theme (hypr-dark) + install script
- `zsh/` -> Zsh and Powerlevel10k config
- `pkglist.txt` -> package snapshot reference

## Quick Start (Arch)

```bash
git clone https://github.com/Farteta/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs packages, backs up existing files that conflict with stow targets, stows configs, deploys the SDDM theme, creates a host override file for Hyprland, and enables key services.

Existing conflicting files are moved under `~/.local/state/dotfiles-backups/bootstrap-*` before stow runs. Use `--no-packages`, `--no-services`, or `--no-sddm` to skip those bootstrap phases.

## Manual Stow

```bash
cd ~/dotfiles
stow -t ~ desktop hypr kitty waybar zsh
```

### Kitty Linux overrides

`kitty.conf` includes Linux-specific overrides from `~/.config/kitty/kitty.linux.conf`.

macOS dotfiles live in the separate `mac-dotfiles` repo.

### SDDM theme (hypr-dark)

The `sddm/` directory contains a custom SDDM theme that matches the hyprlock aesthetic. It is installed with a dedicated root-owned script instead of stow because it writes into system paths.

Manual deploy:

```bash
sudo ./sddm/install.sh
```

What `sddm/install.sh` does:

- copies `sddm/themes/hypr-dark` to `/usr/share/sddm/themes/hypr-dark`
- installs JetBrainsMono Nerd Font into `/usr/local/share/fonts/JetBrainsMonoNerdFont` when it is available in the calling user's local font directory, so the `sddm` user can render the theme correctly
- writes `/etc/sddm.conf.d/zz-hypr-dark.conf` to make `hypr-dark` the active theme and set the cursor/font defaults

Edit `sddm/themes/hypr-dark/theme.conf` to change the wallpaper path or accent colour.

## Host Overrides (Hyprland)

Main config sources:

- `~/.config/hypr/host.local.conf`

Use this file for machine-specific overrides like monitor layout/scale, device-specific input settings, etc.

Template location in repo:

- `hypr/.config/hypr/host.local.conf.example`

## Update Flow

```bash
cd ~/dotfiles
git pull --rebase
./bootstrap.sh
```
